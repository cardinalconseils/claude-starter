#!/bin/bash
# scripts/role-eval-check.sh — score one role-eval case deterministically.
# Reads <case>/expected.md (three sections of "- verb: args" bullets), the scratch
# worktree the role wrote into, the role's returned text, and its transcript, and
# prints PASS/FAIL per bullet plus one JSON summary line. Never edits anything.
# Usage:
#   bash scripts/role-eval-check.sh --case <dir> --scratch <dir> --return <file> \
#        [--transcript <jsonl>] [--tools <file>] [--trace <jsonl>]
#   bash scripts/role-eval-check.sh --lint <case dir or roles root>
# Exit: 0 = case passed (or lint clean), 1 = a check failed, 2 = usage error.
command -v python3 >/dev/null 2>&1 || { echo "python3 required" >&2; exit 2; }

python3 - "$@" <<'PY'
import sys, os, re, json, glob, fnmatch, subprocess

args = sys.argv[1:]
opt = {}
i = 0
while i < len(args):
    a = args[i]
    if a.startswith("--") and i + 1 < len(args):
        opt[a[2:]] = args[i + 1]; i += 2
    else:
        print(f"usage error near {a!r}", file=sys.stderr); sys.exit(2)

SECTIONS = {"artifact shape": "artifact_ok", "must not": "must_not_ok", "return shape": "return_ok"}

def parse(path):
    checks, section = [], None
    for raw in open(path, encoding="utf-8"):
        line = raw.rstrip("\n")
        if line.startswith("## "):
            section = SECTIONS.get(line[3:].strip().lower())
            continue
        m = re.match(r"^\s*-\s+([a-z-]+)(?::\s*(.*))?$", line)
        if m and section:
            checks.append((section, m.group(1), (m.group(2) or "").strip()))
    return checks

VERBS = {"exists", "absent", "heading", "contains", "not-contains", "frontmatter", "unchanged",
         "writes-only-under", "no-writes", "no-new-files", "no-written-file-matches",
         "commit-count", "tool-not-called", "tool-called", "return-matches",
         "return-not-matches", "return-section", "trace-outcome"}

if "lint" in opt:
    root = opt["lint"]
    files = [os.path.join(root, "expected.md")] if os.path.isfile(os.path.join(root, "expected.md")) \
        else sorted(glob.glob(os.path.join(root, "**", "expected.md"), recursive=True))
    bad = 0
    for f in files:
        checks = parse(f)
        seen = {s for s, _, _ in checks}
        for want in SECTIONS.values():
            if want not in seen:
                print(f"LINT {f}: section for {want} has no checks"); bad += 1
        for s, verb, arg in checks:
            if verb not in VERBS:
                print(f"LINT {f}: unknown check '{verb}: {arg}'"); bad += 1
            if verb in {"heading", "contains", "not-contains", "frontmatter", "commit-count"} and " :: " not in arg:
                print(f"LINT {f}: '{verb}' needs 'path :: value'"); bad += 1
    print(f"lint: {len(files)} expected.md files, {bad} problems")
    sys.exit(1 if bad else 0)

for req in ("case", "scratch", "return"):
    if req not in opt:
        print(f"--{req} is required", file=sys.stderr); sys.exit(2)

case, scratch = opt["case"], opt["scratch"]
ret = open(opt["return"], encoding="utf-8", errors="replace").read()

# Diff of the scratch worktree: added vs modified, ignoring the trace log the hook writes.
def diff():
    try:
        out = subprocess.run(["git", "-C", scratch, "status", "--porcelain", "--untracked-files=all"],
                             capture_output=True, text=True, check=True).stdout
    except Exception:
        return None
    added, modified = [], []
    for line in out.splitlines():
        code, path = line[:2], line[3:].strip()
        if path.startswith(".prd/logs/"):
            continue
        (added if "?" in code or "A" in code else modified).append(path)
    return added, modified

D = diff()

# Tool calls: every tool_use block name in the transcript, or a plain list from --tools.
tools = None
if "tools" in opt and os.path.isfile(opt["tools"]):
    tools = [l.strip() for l in open(opt["tools"]) if l.strip()]
elif "transcript" in opt and os.path.isfile(opt["transcript"]):
    tools = []
    for line in open(opt["transcript"], encoding="utf-8", errors="replace"):
        try:
            d = json.loads(line)
        except Exception:
            continue
        msg = d.get("message") if isinstance(d, dict) else None
        content = msg.get("content") if isinstance(msg, dict) else None
        if isinstance(content, list):
            for b in content:
                if isinstance(b, dict) and b.get("type") == "tool_use":
                    tools.append(str(b.get("name")))

trace = None
if "trace" in opt and os.path.isfile(opt["trace"]):
    lines = [l for l in open(opt["trace"], encoding="utf-8", errors="replace") if l.strip()]
    if lines:
        try:
            trace = json.loads(lines[-1])
        except Exception:
            trace = None

def sp(p): return os.path.join(scratch, p)
def files(pattern):
    return [f for f in glob.glob(sp(pattern), recursive=True) if os.path.isfile(f)]
def read(p):
    return open(p, encoding="utf-8", errors="replace").read()
def split2(arg):
    a, _, b = arg.partition(" :: ")
    return a.strip(), b.strip()
def fixture_of(p): return os.path.join(case, "fixture", p)

def run(verb, arg):
    if verb == "exists":
        fs = files(arg)
        return (any(os.path.getsize(f) > 0 for f in fs), "" if fs else "no file")
    if verb == "absent":
        return (not files(arg), "")
    if verb in ("heading", "contains", "not-contains", "frontmatter"):
        p, v = split2(arg)
        fs = files(p)
        if not fs:
            return (verb == "not-contains", "no file")
        text = "\n".join(read(f) for f in fs)
        if verb == "heading":
            ok = any(l.lstrip().startswith("#") and v in l for l in text.splitlines())
        elif verb == "contains":
            ok = re.search(v, text, re.M) is not None
        elif verb == "not-contains":
            ok = re.search(v, text, re.M) is None
        else:
            fm = re.match(r"^---\n(.*?)\n---", text, re.S)
            ok = bool(fm) and re.search(rf"^{re.escape(v)}:", fm.group(1), re.M) is not None
        return (ok, "")
    if verb == "unchanged":
        fs = files(arg)
        if not fs or not os.path.isfile(fixture_of(arg)):
            return (False, "file or fixture missing")
        return (read(fs[0]) == read(fixture_of(arg)), "")
    if verb == "return-matches":
        return (re.search(arg, ret, re.M) is not None, "")
    if verb == "return-not-matches":
        return (re.search(arg, ret, re.M) is None, "")
    if verb == "return-section":
        return (any(l.strip().startswith(arg) for l in ret.splitlines()), "")
    if verb == "trace-outcome":
        if trace is None:
            return (False, "trace NOT READ — no .prd/logs/agents line for this dispatch")
        return (trace.get("outcome") == arg, f"outcome={trace.get('outcome')}")
    if verb in ("tool-not-called", "tool-called"):
        if tools is None:
            return (False, "transcript not found — pass --transcript or --tools")
        names = [x.strip() for x in arg.split(",") if x.strip()]
        hit = {n for n in names if any(fnmatch.fnmatch(t, n) for t in tools)}
        if verb == "tool-not-called":
            return (not hit, f"called: {sorted(hit)}" if hit else "")
        return (hit == set(names), f"missing: {sorted(set(names) - hit)}" if hit != set(names) else "")
    if D is None:
        return (False, "scratch is not a git repo — commit the fixture before dispatch")
    added, modified = D
    if verb == "no-writes":
        return (not added and not modified, f"wrote: {added + modified}" if added or modified else "")
    if verb == "no-new-files":
        return (not added, f"created: {added}" if added else "")
    if verb == "writes-only-under":
        scopes = [x.strip().rstrip("/") for x in arg.split(",") if x.strip()]
        stray = [p for p in added + modified if not any(p == x or p.startswith(x + "/") for x in scopes)]
        return (not stray, f"outside scope: {stray}" if stray else "")
    if verb == "commit-count":
        ref, n = split2(arg)
        try:
            out = subprocess.run(["git", "-C", scratch, "rev-list", "--count", ref],
                                 capture_output=True, text=True, check=True).stdout.strip()
        except Exception:
            return (False, f"cannot count commits on {ref}")
        return (out == n, f"{ref} has {out} commits")
    if verb == "no-written-file-matches":
        hits = [p for p in added + modified if os.path.isfile(sp(p)) and re.search(arg, read(sp(p)), re.M)]
        return (not hits, f"matched in: {hits}" if hits else "")
    return (False, "unknown check")

result = {"artifact_ok": True, "must_not_ok": True, "return_ok": True}
notes = []
for section, verb, arg in parse(os.path.join(case, "expected.md")):
    ok, note = run(verb, arg) if verb in VERBS else (False, "unknown check")
    print(f"{'PASS' if ok else 'FAIL'} [{section}] {verb}: {arg}" + (f"  — {note}" if note else ""))
    if not ok:
        result[section] = False
        notes.append(f"{verb}: {arg}" + (f" ({note})" if note else ""))
result["pass"] = all(result[k] for k in ("artifact_ok", "must_not_ok", "return_ok"))
result["notes"] = "; ".join(notes)
print(json.dumps(result))
sys.exit(0 if result["pass"] else 1)
PY
