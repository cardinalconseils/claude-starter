#!/usr/bin/env python3
"""scripts/jev-route.py — PreToolUse hook body for the Agent/Task tool.

Asks TypeSafe Jev which Claude model tier a subagent dispatch needs and whether it is
high-stakes, then rewrites tool_input.model when it is safe to lower it. Role defaults
come from agents/<role>.md frontmatter `model:` and are the ceiling unless
CKS_JEV_ALLOW_UPGRADE is set. A project's .prd/prd-config.json override never reaches
this hook as a separate signal — it resolves to an explicit tool_input.model before
dispatch, and an explicit model always wins over Jev, so this hook leaves it alone.
Never raises past main(); always exits 0.

Usage:
  Hook mode (default): reads a PreToolUse hook payload on stdin, writes a hook JSON
    reply (or nothing) on stdout.
  Report mode: `python3 jev-route.py --report [--days N]` reads the decision log and
    prints a savings table. Stdlib only — no third-party imports.

Config precedence per key (first hit wins): env var -> <repo-root>/.cks/jev-routing.json
-> ~/.cks/jev-routing.json -> built-in default. See DEFAULTS/ENV_MAP below and
skills/jev-routing/SKILL.md for the schema. TYPESAFE_API_KEY is read from the environment
only — never from a config file, never logged, never echoed.
"""

import datetime
import json
import os
import re
import socket
import subprocess
import sys
import time
import urllib.error
import urllib.request

RANK = {"haiku": 0, "sonnet": 1, "opus": 2, "fable": 3}

DEFAULTS = {
    "enabled": False,
    "min_confidence": 0.6,
    "high_stakes_threshold": 0.5,
    "allow_upgrade": False,
    "exempt_roles": ["cks:chief-of-staff"],
    "timeout_s": 4,
    "model": "jev-latest",
    "base_url": "https://api.typesafe.ai",
    "log_path": "~/.cks/logs/jev-routing.jsonl",
}

# Keys with no env var (high_stakes_threshold, exempt_roles) fall straight through to
# the config-file / default layers.
ENV_MAP = {
    "enabled": "CKS_JEV_ROUTING",
    "min_confidence": "CKS_JEV_MIN_CONFIDENCE",
    "allow_upgrade": "CKS_JEV_ALLOW_UPGRADE",
    "timeout_s": "CKS_JEV_TIMEOUT",
    "model": "CKS_JEV_MODEL",
    "base_url": "CKS_JEV_BASE_URL",
    "log_path": "CKS_JEV_LOG",
}

TIER_CRITERIA = {
    "haiku": (
        "Mechanical or bulk work with a clear recipe: formatting, renaming, moving or "
        "copying files, summarising or extracting from text already provided, writing "
        "docs from existing code, simple lookups, running a fixed list of commands and "
        "reporting output, persisting given content to files."
    ),
    "sonnet": (
        "Standard execution against a defined spec: implementing a planned change, "
        "writing or running tests, fixing a bug whose cause is known, bounded research, "
        "drafting copy from a brief, filing issues, routine git and CI work."
    ),
    "opus": (
        "Open-ended judgment: architecture or schema design, root-causing an unknown "
        "failure across files, security, legal or compliance review, strategy or "
        "prioritisation, ambiguous requirements, or work where a subtle mistake is "
        "expensive."
    ),
}

TIER_INSTRUCTIONS = (
    "Which Claude model tier is sufficient to do this task well on the first attempt? "
    "Pick the cheapest tier that will not degrade the result."
)

HIGH_STAKES_INSTRUCTIONS = (
    "This task can cause costly or irreversible harm if done carelessly."
)
HIGH_STAKES_CRITERIA = {
    "true": (
        "It touches production systems, money or billing, credentials or security "
        "controls, deletes or migrates data, sends external communication, or commits "
        "to an architectural decision."
    ),
    "false": "Mistakes would be cheap to notice and reverse.",
}


# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------

def load_json_file(path):
    try:
        with open(path, "r", encoding="utf-8") as f:
            return json.load(f)
    except Exception:
        return {}


def to_bool(v):
    if isinstance(v, bool):
        return v
    if v is None:
        return False
    return str(v).strip().lower() in ("on", "1", "true", "yes")


def repo_root_from_cwd(cwd):
    try:
        out = subprocess.run(
            ["git", "rev-parse", "--show-toplevel"],
            cwd=cwd, capture_output=True, text=True, timeout=3,
        )
        if out.returncode == 0:
            p = out.stdout.strip()
            if p:
                return p
    except Exception:
        pass
    p = os.environ.get("CLAUDE_PROJECT_DIR")
    if p:
        return p
    return cwd


def resolve_config(repo_cfg, global_cfg):
    def pick(key):
        env_name = ENV_MAP.get(key)
        if env_name and os.environ.get(env_name, "") != "":
            return os.environ[env_name]
        if key in repo_cfg:
            return repo_cfg[key]
        if key in global_cfg:
            return global_cfg[key]
        return DEFAULTS[key]

    return {
        "enabled": to_bool(pick("enabled")),
        "min_confidence": float(pick("min_confidence")),
        "high_stakes_threshold": float(
            repo_cfg.get("high_stakes_threshold", global_cfg.get(
                "high_stakes_threshold", DEFAULTS["high_stakes_threshold"]))
        ),
        "allow_upgrade": to_bool(pick("allow_upgrade")),
        "exempt_roles": repo_cfg.get("exempt_roles", global_cfg.get(
            "exempt_roles", DEFAULTS["exempt_roles"])),
        "timeout_s": float(pick("timeout_s")),
        "model": str(pick("model")),
        "base_url": str(pick("base_url")).rstrip("/"),
        "log_path": os.path.expanduser(str(pick("log_path"))),
    }


# ---------------------------------------------------------------------------
# Role resolution
# ---------------------------------------------------------------------------

def resolve_role(plugin_root, subagent_type):
    """Returns (role_default_model_or_None, role_summary). Only cks:<role> dispatches
    have a known default — every other subagent_type (general-purpose, Explore, Plan,
    other plugins) has no known default; the caller treats opus as its ceiling."""
    if not subagent_type.startswith("cks:"):
        return None, ""
    role = subagent_type[len("cks:"):]
    path = os.path.join(plugin_root, "agents", f"{role}.md")
    try:
        with open(path, "r", encoding="utf-8") as f:
            text = f.read()
    except Exception:
        return None, ""
    parts = text.split("---", 2)
    front = parts[1] if len(parts) >= 3 else text
    model_m = re.search(r"^model:\s*(\S+)", front, re.M)
    desc_m = re.search(r"^description:\s*(.*)$", front, re.M)
    model = model_m.group(1).strip() if model_m else None
    if model not in RANK:
        model = None
    summary = desc_m.group(1).strip()[:300] if desc_m else ""
    return model, summary


# ---------------------------------------------------------------------------
# Jev call
# ---------------------------------------------------------------------------

def cap_brief(text, limit=12000, head=8000, tail=4000):
    text = text or ""
    if len(text) <= limit:
        return text
    omitted = len(text) - head - tail
    return f"{text[:head]}\n[… {omitted} chars omitted …]\n{text[-tail:]}"


def call_jev(base_url, api_key, model, state, timeout_s):
    body = {
        "model": model,
        "state": state,
        "questions": {
            "tier": {
                "type": "choice",
                "instructions": TIER_INSTRUCTIONS,
                "criteria": TIER_CRITERIA,
            },
            "high_stakes": {
                "type": "noul",
                "instructions": HIGH_STAKES_INSTRUCTIONS,
                "criteria": HIGH_STAKES_CRITERIA,
            },
        },
    }
    data = json.dumps(body).encode("utf-8")
    req = urllib.request.Request(
        base_url + "/v1/systemone",
        data=data,
        method="POST",
        headers={
            "authorization": f"Bearer {api_key}",
            "content-type": "application/json",
        },
    )
    with urllib.request.urlopen(req, timeout=timeout_s) as resp:
        raw = resp.read()
    return json.loads(raw.decode("utf-8"))


def extract_answer(resp):
    answers = resp["answers"]
    tier = answers["tier"]
    choice = tier["choice"]
    if choice not in RANK:
        raise ValueError(f"unknown tier choice {choice!r}")
    confidence = float(tier["confidence"])
    probabilities = tier.get("probabilities", {}) or {}
    high_stakes = float(answers["high_stakes"]["noul"])
    usage = resp.get("usage", {}) or {}
    return choice, confidence, probabilities, high_stakes, usage


def classify_error(e):
    if isinstance(e, urllib.error.HTTPError):
        return f"http_{e.code}"
    if isinstance(e, socket.timeout):
        return "timeout"
    if isinstance(e, urllib.error.URLError):
        reason = str(e.reason)
        return "timeout" if "timed out" in reason.lower() else "url_error"
    if isinstance(e, (ValueError, KeyError, TypeError)):
        return "malformed"
    return type(e).__name__.lower()


# ---------------------------------------------------------------------------
# Policy
# ---------------------------------------------------------------------------

def apply_policy(default_model, ceiling, choice, confidence, high_stakes, cfg):
    """Returns (final_model_or_None, reason, emit_bool)."""
    if high_stakes >= cfg["high_stakes_threshold"]:
        return default_model, "high_stakes", False
    if confidence < cfg["min_confidence"]:
        return default_model, "low_confidence", False

    target = choice
    if RANK[target] > RANK[ceiling] and not cfg["allow_upgrade"]:
        return default_model, "upgrade_blocked", False

    baseline = default_model if default_model is not None else ceiling
    if RANK[target] < RANK[baseline]:
        reason = "downgraded"
    elif RANK[target] > RANK[baseline]:
        reason = "upgraded"
    else:
        reason = "same"

    # Known CKS roles: only emit when the target actually differs from the role
    # default (the subagent gets that default automatically otherwise). Unknown
    # roles have no provable default — leaving model unset means "whatever the
    # parent session is running", which target may or may not match — so always emit.
    emit = (target != default_model) if default_model is not None else True
    return target, reason, emit


# ---------------------------------------------------------------------------
# Logging
# ---------------------------------------------------------------------------

def iso_now():
    return datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%S.%f")[:-3] + "Z"


def append_log(log_path, record):
    try:
        d = os.path.dirname(log_path)
        if d:
            os.makedirs(d, exist_ok=True)
        with open(log_path, "a", encoding="utf-8") as f:
            f.write(json.dumps(record, sort_keys=True) + "\n")
    except Exception:
        pass


def ship_event(record):
    """Fire-and-forget mirror of a routing decision to the Supabase events sink.
    Never raises and never blocks the hook on the child process."""
    if os.environ.get("CKS_TELEMETRY_SINK") != "supabase":
        return
    try:
        script = os.path.join(os.path.dirname(os.path.abspath(__file__)), "telemetry-ship.sh")
        subprocess.Popen(
            ["bash", script, "jev", json.dumps(record)],
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
        )
    except Exception:
        pass


# ---------------------------------------------------------------------------
# Hook entry point
# ---------------------------------------------------------------------------

def process(payload):
    tool_name = payload.get("tool_name") or payload.get("tool") or ""
    if tool_name not in ("Agent", "Task"):
        return

    session_id = str(payload.get("session_id") or "")
    tool_use_id = str(payload.get("tool_use_id") or "")

    tool_input = payload.get("tool_input")
    if not isinstance(tool_input, dict):
        return
    if tool_input.get("model"):
        return  # an explicit caller choice always wins

    cwd = payload.get("cwd") or os.getcwd()
    repo_root = repo_root_from_cwd(cwd)
    repo_cfg = load_json_file(os.path.join(repo_root, ".cks", "jev-routing.json"))
    global_cfg = load_json_file(os.path.expanduser("~/.cks/jev-routing.json"))
    cfg = resolve_config(repo_cfg, global_cfg)

    if not cfg["enabled"]:
        return
    api_key = os.environ.get("TYPESAFE_API_KEY", "").strip()
    if not api_key:
        return

    subagent_type = str(tool_input.get("subagent_type") or "").strip()
    if subagent_type in (cfg["exempt_roles"] or []):
        return

    plugin_root = os.environ.get("CLAUDE_PLUGIN_ROOT") or os.path.dirname(
        os.path.dirname(os.path.abspath(__file__)))
    default_model, role_summary = resolve_role(plugin_root, subagent_type)
    ceiling = default_model or "opus"

    description = str(tool_input.get("description") or "")
    prompt = str(tool_input.get("prompt") or "")
    state = {
        "agent_role": subagent_type,
        "role_default_model": default_model or "unknown",
        "role_summary": role_summary,
        "task_title": description,
        "brief": cap_brief(prompt),
    }

    repo_label = os.path.basename(repo_root.rstrip("/")) or repo_root
    t0 = time.time()
    try:
        resp = call_jev(cfg["base_url"], api_key, cfg["model"], state, cfg["timeout_s"])
        choice, confidence, probabilities, high_stakes, usage = extract_answer(resp)
    except Exception as e:
        latency_ms = int((time.time() - t0) * 1000)
        record = {
            "ts": iso_now(), "repo": repo_label, "role": subagent_type,
            "default": default_model, "choice": None, "confidence": None,
            "probabilities": None, "high_stakes": None, "final": None,
            "reason": f"fail_open:{classify_error(e)}",
            "latency_ms": latency_ms, "jev_usage": None,
            "session_id": session_id, "tool_use_id": tool_use_id,
        }
        append_log(cfg["log_path"], record)
        ship_event(record)
        return
    latency_ms = int((time.time() - t0) * 1000)

    final, reason, emit = apply_policy(
        default_model, ceiling, choice, confidence, high_stakes, cfg)

    record = {
        "ts": iso_now(), "repo": repo_label, "role": subagent_type,
        "default": default_model, "choice": choice, "confidence": confidence,
        "probabilities": probabilities, "high_stakes": high_stakes, "final": final,
        "reason": reason, "latency_ms": latency_ms, "jev_usage": usage,
        "session_id": session_id, "tool_use_id": tool_use_id,
    }
    append_log(cfg["log_path"], record)
    ship_event(record)

    if emit and final:
        updated_input = dict(tool_input)
        updated_input["model"] = final
        label = default_model or "parent"
        out = {
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "updatedInput": updated_input,
            },
            "systemMessage": (
                f"Jev routed {subagent_type} {label}→{final} "
                f"(conf {confidence:.2f})"
            ),
        }
        print(json.dumps(out))


# ---------------------------------------------------------------------------
# --report mode
# ---------------------------------------------------------------------------

def default_log_path():
    cwd = os.getcwd()
    repo_root = repo_root_from_cwd(cwd)
    repo_cfg = load_json_file(os.path.join(repo_root, ".cks", "jev-routing.json"))
    global_cfg = load_json_file(os.path.expanduser("~/.cks/jev-routing.json"))
    return resolve_config(repo_cfg, global_cfg)["log_path"]


def cmd_report(argv):
    days = None
    if "--days" in argv:
        i = argv.index("--days")
        try:
            days = int(argv[i + 1])
        except Exception:
            days = None
    log_path = default_log_path()
    try:
        lines = open(log_path, "r", encoding="utf-8").read().splitlines()
    except Exception:
        print(f"No log at {log_path}")
        return 0

    cutoff = None
    if days is not None:
        cutoff = datetime.datetime.now(datetime.timezone.utc) - datetime.timedelta(days=days)

    records = []
    for line in lines:
        line = line.strip()
        if not line:
            continue
        try:
            r = json.loads(line)
        except Exception:
            continue
        if cutoff is not None:
            try:
                ts = datetime.datetime.strptime(r.get("ts", ""), "%Y-%m-%dT%H:%M:%S.%fZ")
                ts = ts.replace(tzinfo=datetime.timezone.utc)
                if ts < cutoff:
                    continue
            except Exception:
                pass
        records.append(r)

    if not records:
        print(f"No dispatches logged in {log_path}" + (f" (last {days}d)" if days else ""))
        return 0

    by_role = {}
    total_tokens = 0
    for r in records:
        role = r.get("role") or "unknown"
        b = by_role.setdefault(role, {
            "dispatches": 0, "downgraded": 0, "upgraded": 0,
            "kept": {"high_stakes": 0, "low_confidence": 0, "upgrade_blocked": 0, "same": 0},
            "fail_open": 0, "latency_sum": 0, "latency_n": 0,
        })
        b["dispatches"] += 1
        reason = r.get("reason") or ""
        if reason.startswith("fail_open"):
            b["fail_open"] += 1
        elif reason == "downgraded":
            b["downgraded"] += 1
        elif reason == "upgraded":
            b["upgraded"] += 1
        elif reason in b["kept"]:
            b["kept"][reason] += 1
        lat = r.get("latency_ms")
        if isinstance(lat, (int, float)):
            b["latency_sum"] += lat
            b["latency_n"] += 1
        usage = r.get("jev_usage") or {}
        if isinstance(usage, dict):
            total_tokens += int(usage.get("input_tokens") or 0) + int(usage.get("output_tokens") or 0)

    header = f"{'Role':<20} {'Dispatches':>10} {'Downgraded':>10} {'Upgraded':>9} {'Kept(hs/lc/ub/same)':>20} {'FailOpen':>9} {'AvgLatMs':>9}"
    print(header)
    print("-" * len(header))
    for role in sorted(by_role):
        b = by_role[role]
        kept = b["kept"]
        kept_str = f"{kept['high_stakes']}/{kept['low_confidence']}/{kept['upgrade_blocked']}/{kept['same']}"
        avg_lat = int(b["latency_sum"] / b["latency_n"]) if b["latency_n"] else 0
        print(f"{role:<20} {b['dispatches']:>10} {b['downgraded']:>10} {b['upgraded']:>9} {kept_str:>20} {b['fail_open']:>9} {avg_lat:>9}")
    print("-" * len(header))
    print(f"Total Jev tokens: {total_tokens}")
    return 0


# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------

def main(argv):
    if len(argv) > 1 and argv[1] == "--report":
        try:
            return cmd_report(argv[1:]) or 0
        except Exception:
            return 0

    try:
        raw = sys.stdin.read()
    except Exception:
        return 0
    if not raw or not raw.strip():
        return 0
    try:
        payload = json.loads(raw)
    except Exception:
        return 0
    try:
        process(payload)
    except Exception:
        pass
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv) or 0)
