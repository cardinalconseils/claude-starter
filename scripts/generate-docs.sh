#!/bin/bash
# scripts/generate-docs.sh — regenerate the role catalogue, help block and counts from source.
#
# Sources: agents/*.md frontmatter, scripts/agent-graph.sh --edges, scripts/agent-map.tsv,
#          docs/v6-workforce.md roster order, counts of commands/*.md, skills/*/, legacy/agents/*.md.
# Targets (only the text between <!-- generated:<name> start/end --> markers is rewritten;
#          two files have no markers because a comment would be printed or cost a line):
#   docs/wiki/agents.md                        generated:roles
#   commands/help.md                           generated:agents  (anchor: the "ROLES (N — agents/*.md" line
#                                              up to the next blank line — the block is printed verbatim)
#   commands/README.md                         generated:count
#   README.md                                  generated:structure-counts
#   docs/ARCHITECTURE.md                       generated:layer-counts
#   CLAUDE.md                                  agents/ commands/ skills/ lines by pattern (150-line cap)
#   skills/chief-of-staff/references/roster.md generated:roster, generated:lookup
#
# Usage: bash scripts/generate-docs.sh [--check]
#   --check   regenerate into a temp copy; exit 1 with a unified diff if any target differs
# Exit: 0 = written / current, 1 = drift (--check), 2 = a source or anchor is missing

set -uo pipefail
PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CHECK=0
for arg in "$@"; do
  [ "$arg" = "--check" ] && CHECK=1
done

TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT

# The graph script exits 1 on a dirty graph but still prints every edge; a dirty graph is
# test-integrity's finding, not ours, so only the edge list is consumed here.
bash "$PLUGIN_ROOT/scripts/agent-graph.sh" --edges --quiet > "$TMP/edges" 2>/dev/null
if [ ! -s "$TMP/edges" ]; then
  echo "generate-docs: scripts/agent-graph.sh --edges produced no edges" >&2
  exit 2
fi

OUT_ROOT="$PLUGIN_ROOT"
[ "$CHECK" = "1" ] && OUT_ROOT="$TMP/out"

python3 - "$PLUGIN_ROOT" "$OUT_ROOT" "$TMP/edges" <<'PY'
import os, re, sys, textwrap

ROOT, OUT, EDGES = sys.argv[1], sys.argv[2], sys.argv[3]
CORE = ["Read", "Grep", "Glob", "Bash"]
SERVER_NAMES = {
    "plugin_github_github": "GitHub", "plugin_sentry_sentry": "Sentry",
    "claude-in-chrome": "Claude in Chrome", "cloudflare": "Cloudflare",
    "Apollo_io": "Apollo.io", "aHref": "Ahrefs",
}
WRAP = 100


def die(msg):
    sys.stderr.write("generate-docs: " + msg + "\n")
    sys.exit(2)


def read(rel):
    with open(os.path.join(ROOT, rel), encoding="utf-8") as f:
        return f.read()


def frontmatter(text):
    lines = text.split("\n")
    if not lines or lines[0].strip() != "---":
        return {}
    fm, key = {}, None
    for line in lines[1:]:
        if line.strip() == "---":
            break
        m = re.match(r"^([A-Za-z_][\w-]*):\s*(.*)$", line)
        if m:
            key, val = m.group(1), m.group(2).strip()
            fm[key] = [] if val == "" else val.strip('"')
            continue
        m = re.match(r"^\s+-\s+(.*)$", line)
        if m and key is not None and isinstance(fm[key], list):
            fm[key].append(m.group(1).strip().strip('"'))
    return fm


# ── sources ──────────────────────────────────────────────────────────────────
agents = {}
for fn in sorted(os.listdir(os.path.join(ROOT, "agents"))):
    if not fn.endswith(".md") or fn == "README.md":
        continue
    fm = frontmatter(read("agents/" + fn))
    for req in ("name", "subagent_type", "description", "model", "tools", "skills"):
        if req not in fm:
            die("agents/%s has no %s in its frontmatter" % (fn, req))
    agents[fn[:-3]] = fm

roster_order = []
in_table = False
for line in read("docs/v6-workforce.md").split("\n"):
    if line.startswith("## Roster"):
        in_table = True
        continue
    if in_table and line.startswith("## "):
        break
    if in_table and line.startswith("| ") and not line.startswith("| Role") and not line.startswith("|---"):
        role = line.split("|")[1].strip().strip("`")
        if role in agents and role not in roster_order:
            roster_order.append(role)
roles = roster_order + sorted(r for r in agents if r not in roster_order)

dispatch = {r: {} for r in roles}
for line in open(EDGES, encoding="utf-8"):
    line = line.strip()
    if " -> " not in line:
        continue
    src, target = line.rsplit(" -> ", 1)
    role = target[len("cks:"):] if target.startswith("cks:") else target
    if role not in dispatch:
        continue
    if src.startswith("commands/"):
        bucket, item = "commands", "/cks:" + src[len("commands/"):-3]
    elif src.startswith("skills/"):
        bucket, item = "skills", src.split("/")[1]
    elif src.startswith("pipelines/"):
        bucket, item = "pipelines", src[len("pipelines/"):].replace(".dot", "")
    elif src.startswith(".claude/rules/"):
        bucket, item = "rules", src[len(".claude/rules/"):-3]
    elif src.startswith("agents/"):
        bucket, item = "agents", src[len("agents/"):-3]
    else:
        bucket, item = "other", src
    dispatch[role].setdefault(bucket, set()).add(item)

allowlisted = set()
allow_path = os.path.join(ROOT, "scripts/agent-graph.allowlist")
if os.path.exists(allow_path):
    for line in open(allow_path, encoding="utf-8"):
        line = line.split("#")[0].strip()
        if line:
            allowlisted.add(line[len("cks:"):] if line.startswith("cks:") else line)

agent_map = []
for line in read("scripts/agent-map.tsv").split("\n"):
    if not line.strip() or line.startswith("#"):
        continue
    cols = line.split("\t")
    if len(cols) < 2:
        die("scripts/agent-map.tsv row has fewer than 2 columns: " + line)
    old, new = cols[0].strip(), cols[1].strip()
    hint = cols[2].strip() if len(cols) > 2 else ""
    agent_map.append((old, new, hint))
absorbed = {r: [] for r in roles}
for old, new, _ in agent_map:
    role = new[len("cks:"):] if new.startswith("cks:") else None
    if role in absorbed and old != new:
        absorbed[role].append(old[len("cks:"):] if old.startswith("cks:") else old)

n_agents = len(agents)
n_commands = len([f for f in os.listdir(os.path.join(ROOT, "commands"))
                  if f.endswith(".md") and f != "README.md"])
n_skills = len([d for d in os.listdir(os.path.join(ROOT, "skills"))
                if os.path.isdir(os.path.join(ROOT, "skills", d))])
legacy_dir = os.path.join(ROOT, "legacy", "agents")
n_legacy = len([f for f in os.listdir(legacy_dir) if f.endswith(".md")]) if os.path.isdir(legacy_dir) else 0


# ── derived views ────────────────────────────────────────────────────────────
def writes(tools):
    w, e = "Write" in tools, "Edit" in tools
    if w and e:
        return "Write + Edit"
    if w:
        return "Write"
    if e:
        return "Edit (no Write)"
    return "read-only (no Write/Edit)"


def mcp_summary(tools):
    servers = {}
    for t in tools:
        if not t.startswith("mcp__"):
            continue
        rest = t[len("mcp__"):]
        if rest.startswith("claude_ai_"):
            server, _, tool = rest[len("claude_ai_"):].partition("__")
        else:
            server, _, tool = rest.partition("__")
        name = SERVER_NAMES.get(server, server.replace("_", " "))
        servers.setdefault(name, []).append(tool or "*")
    parts = []
    for name, tl in servers.items():
        parts.append(name + " (all tools)" if "*" in tl else name + ": " + ", ".join(tl))
    return parts


def grant_summary(tools, with_core=False):
    other = [t for t in tools if t not in CORE and t not in ("Write", "Edit") and not t.startswith("mcp__")]
    parts = []
    if with_core:
        parts.append(", ".join(t for t in CORE if t in tools))
    parts.append(writes(tools))
    if other:
        parts.append(", ".join(other))
    parts.extend(mcp_summary(tools))
    return "; ".join(parts)


def purpose(role, desc):
    label = role.replace("-", " ")
    m = re.match(r"^" + re.escape(label) + r"\s+—\s+", desc, re.IGNORECASE)
    if m:
        desc = desc[m.end():]
    first = re.split(r"(?<=[.!?])\s+(?=[A-Z])", desc, 1)[0]
    return first[:1].upper() + first[1:]


def blurb(role, desc, width):
    text = purpose(role, desc).rstrip(".")
    if len(text) <= width:
        return text
    cut = text[: width - 1]
    if " " in cut:
        cut = cut[: cut.rfind(" ")]
    return cut.rstrip(" ,;:—-") + "…"


def dispatched_by(role):
    d = dispatch[role]
    if not d:
        if role in allowlisted:
            return "none — loaded top-level via `Skill(skill=\"cks:%s\")`" % role
        return "none"
    parts = []
    for bucket, label in (("commands", None), ("skills", "skills"), ("pipelines", "pipelines"),
                          ("rules", "rules"), ("agents", "agents"), ("other", "other")):
        if bucket in d:
            items = ", ".join(sorted(d[bucket]))
            parts.append(items if label is None else label + ": " + items)
    return "; ".join(parts)


def runs_as(role):
    return "top-level skill" if role in allowlisted else "sub-agent"


def wrap(text):
    return "\n".join(textwrap.wrap(text, WRAP, break_long_words=False, break_on_hyphens=False))


# ── generated bodies ─────────────────────────────────────────────────────────
def roles_body():
    out = []
    for r in roles:
        fm = agents[r]
        runs = ("top-level skill (`Skill(skill=\"cks:%s\")`); the agent file exists only for `claude --agent`" % r
                if r in allowlisted else "sub-agent")
        out.append("## %s\n" % r)
        out.append(wrap("**Purpose:** " + fm["description"]))
        out.append(wrap("**Model:** %s. **Writes:** %s. **Runs as:** %s." % (fm["model"], writes(fm["tools"]), runs)))
        out.append(wrap("**Grants:** " + grant_summary(fm["tools"], with_core=True) + "."))
        out.append(wrap("**Skills:** " + ", ".join(fm["skills"]) + "."))
        out.append(wrap("**Dispatched by:** " + dispatched_by(r) + "."))
        out.append(wrap("**Absorbed (v5):** " + (", ".join(absorbed[r]) if absorbed[r] else "none") + "."))
        out.append("")
    return "\n".join(out).rstrip("\n") + "\n"


def help_lines():
    lines = []
    for r in roles:
        prefix = "  %-18s" % r
        lines.append(prefix + blurb(r, agents[r]["description"], 80 - len(prefix)))
    return lines


def roster_body():
    out = ["| Role | Purpose | Grant | Model | Dispatched by | Runs |", "|---|---|---|---|---|---|"]
    for r in roles:
        fm = agents[r]
        out.append("| `cks:%s` | %s | %s | %s | %s | %s |" % (
            r, purpose(r, fm["description"]).rstrip("."), grant_summary(fm["tools"]),
            fm["model"], dispatched_by(r), runs_as(r)))
    return "\n".join(out) + "\n"


def lookup_body():
    out = ["| v5 `subagent_type` | v6 target | Brief hint |", "|---|---|---|"]
    for old, new, hint in sorted(agent_map):
        target = "`Skill(skill=\"cks:%s\")`" % new[len("skill:"):] if new.startswith("skill:") else "`%s`" % new
        out.append("| `%s` | %s | %s |" % (old, target, hint))
    return "\n".join(out) + "\n"


# ── splicing ─────────────────────────────────────────────────────────────────
def between(text, name, body, rel):
    start, end = "<!-- generated:%s start -->" % name, "<!-- generated:%s end -->" % name
    if start not in text or end not in text:
        die("%s has no %s / %s markers" % (rel, start, end))
    head, _, rest = text.partition(start)
    inner, _, tail = rest.partition(end)
    return head + start + "\n" + body + end + tail


def sub_between(text, name, patterns, rel):
    start, end = "<!-- generated:%s start -->" % name, "<!-- generated:%s end -->" % name
    if start not in text or end not in text:
        die("%s has no %s / %s markers" % (rel, start, end))
    head, _, rest = text.partition(start)
    inner, _, tail = rest.partition(end)
    return head + start + sub_patterns(inner, patterns, rel) + end + tail


def sub_patterns(text, patterns, rel):
    for pat, repl in patterns:
        text, n = re.subn(pat, repl, text, count=1, flags=re.MULTILINE)
        if n == 0:
            die("%s: anchor not found: %s" % (rel, pat))
    return text


def write(rel, content):
    path = os.path.join(OUT, rel)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)


rel = "docs/wiki/agents.md"
write(rel, between(read(rel), "roles", roles_body(), rel))

rel = "commands/help.md"
lines = read(rel).split("\n")
idx = next((i for i, l in enumerate(lines) if re.match(r"^ROLES \(\d+ — agents/\*\.md", l)), None)
if idx is None:
    die(rel + ": anchor not found: ROLES (N — agents/*.md")
end = idx + 1
while end < len(lines) and lines[end].strip() != "":
    end += 1
lines[idx] = re.sub(r"^ROLES \(\d+", "ROLES (%d" % n_agents, lines[idx])
lines[idx + 1:end] = help_lines()
write(rel, "\n".join(lines))

rel = "commands/README.md"
write(rel, sub_between(read(rel), "count",
                       [(r"\*\*\d+ commands total\*\*", "**%d commands total**" % n_commands)], rel))

rel = "README.md"
write(rel, sub_between(read(rel), "structure-counts", [
    (r"^(├── commands/\s+← )\d+( slash commands)", r"\g<1>%d\g<2>" % n_commands),
    (r"^(├── agents/\s+← )\d+( roles)", r"\g<1>%d\g<2>" % n_agents),
    (r"^(│   └── legacy/agents/\s+← )\d+( v5 agents)", r"\g<1>%d\g<2>" % n_legacy),
    (r"^(├── skills/\s+← )\d+( skills)", r"\g<1>%d\g<2>" % n_skills),
], rel))

rel = "docs/ARCHITECTURE.md"
write(rel, sub_between(read(rel), "layer-counts", [
    (r"^(\| \*\*Skills\*\* \|[^|]*\| )\d+( skills \|)", r"\g<1>%d\g<2>" % n_skills),
    (r"^(\| \*\*Roles\*\* \|[^|]*\| )\d+( roles \(\+)\d+( legacy)", r"\g<1>%d\g<2>%d\g<3>" % (n_agents, n_legacy)),
    (r"^(\| \*\*Commands\*\* \|[^|]*\| )\d+( commands \|)", r"\g<1>%d\g<2>" % n_commands),
], rel))

rel = "CLAUDE.md"
write(rel, sub_patterns(read(rel), [
    (r"^(agents/\s+— )\d+( roles)", r"\g<1>%d\g<2>" % n_agents),
    (r"^(commands/\s+— )\d+( slash commands)", r"\g<1>%d\g<2>" % n_commands),
    (r"^(skills/\s+— )\d+( skills)", r"\g<1>%d\g<2>" % n_skills),
], rel))

rel = "skills/chief-of-staff/references/roster.md"
text = between(read(rel), "roster", roster_body(), rel)
write(rel, between(text, "lookup", lookup_body(), rel))

print("roles=%d commands=%d skills=%d legacy=%d" % (n_agents, n_commands, n_skills, n_legacy))
PY
STATUS=$?
[ "$STATUS" -ne 0 ] && exit "$STATUS"

TARGETS="docs/wiki/agents.md commands/help.md commands/README.md README.md docs/ARCHITECTURE.md CLAUDE.md skills/chief-of-staff/references/roster.md"
if [ "$CHECK" = "1" ]; then
  DRIFT=0
  for rel in $TARGETS; do
    if ! diff -u "$PLUGIN_ROOT/$rel" "$TMP/out/$rel" --label "a/$rel" --label "b/$rel"; then
      DRIFT=1
    fi
  done
  if [ "$DRIFT" = "1" ]; then
    echo "generate-docs: generated sections are stale — run: bash scripts/generate-docs.sh" >&2
    exit 1
  fi
  echo "  ✅ generated docs current"
else
  echo "  ✅ regenerated: $TARGETS"
fi
exit 0
