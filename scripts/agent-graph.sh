#!/bin/bash
# scripts/agent-graph.sh — dispatch-graph integrity for CKS agents.
#
# Declared:   every agents/*.md must declare subagent_type: cks:<basename>
# Referenced: every subagent_type="…" in commands/ agents/ skills/ hooks/ scripts/
#             CLAUDE.md .claude/rules/ plus cks_agent="…" in pipelines/*.dot
# Fails on:   dangling refs (referenced, not declared)
#             unreferenced agents (declared, never dispatched) unless allowlisted
#             namespace drift (declared type != cks:<basename>)
#
# Usage: bash scripts/agent-graph.sh [--edges] [--json] [--legacy] [--quiet]
#   --edges   print "source-file -> subagent_type" for every dispatch site
#   --json    machine-readable summary on stdout
#   --legacy  also scan legacy/agents/ and report old types still referenced
#   --quiet   only print failures
# Exit: 0 = clean, 1 = failures

set -uo pipefail
PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ALLOWLIST="$PLUGIN_ROOT/scripts/agent-graph.allowlist"
EDGES=0; JSON=0; LEGACY=0; QUIET=0
for arg in "$@"; do
  case "$arg" in
    --edges) EDGES=1 ;; --json) JSON=1 ;; --legacy) LEGACY=1 ;; --quiet) QUIET=1 ;;
  esac
done
say() { [ "$QUIET" = "1" ] || echo "$1"; }

TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT

# ── declared ──────────────────────────────────────────────
: > "$TMP/declared"; : > "$TMP/namespace_fail"
for f in "$PLUGIN_ROOT"/agents/*.md; do
  b=$(basename "$f" .md); [ "$b" = "README" ] && continue
  d=$(grep -m1 -E '^subagent_type:' "$f" | sed 's/subagent_type: *//' | tr -d '"' | xargs)
  echo "$d" >> "$TMP/declared"
  [ "$d" = "cks:$b" ] || echo "agents/$b.md declares '$d' (expected cks:$b)" >> "$TMP/namespace_fail"
done
sort -u "$TMP/declared" -o "$TMP/declared"

# ── referenced (with source file for --edges) ─────────────
scan_refs() {
  grep -rnoE 'subagent_type="[^"]+"' \
    "$PLUGIN_ROOT/commands" "$PLUGIN_ROOT/agents" "$PLUGIN_ROOT/skills" \
    "$PLUGIN_ROOT/hooks" "$PLUGIN_ROOT/scripts" "$PLUGIN_ROOT/CLAUDE.md" \
    "$PLUGIN_ROOT/.claude/rules" 2>/dev/null \
    | sed -E 's/^([^:]+):[0-9]+:subagent_type="([^"]+)"$/\1\t\2/'
  grep -rnoE 'cks_agent *= *"[^"]+"' "$PLUGIN_ROOT/pipelines" 2>/dev/null \
    | sed -E 's/^([^:]+):[0-9]+:cks_agent *= *"([^"]+)"$/\1\t\2/'
}
# Keep only well-formed types. Template slots ({type}, <cks_agent>) and regex
# fragments inside scripts are not dispatch sites; bare names are a namespace bug.
scan_refs \
  | grep -vE '(scripts/agent-graph\.sh|scripts/test-integrity\.sh)' \
  | sed "s|$PLUGIN_ROOT/||" > "$TMP/edges_raw"
awk -F'\t' '$2 ~ /^cks:[a-z0-9][a-z0-9-]*$/' "$TMP/edges_raw" > "$TMP/edges"
awk -F'\t' '$2 ~ /^[a-z][a-z0-9-]*$/ && $2 != "general-purpose" {print $1"\t"$2}' "$TMP/edges_raw" > "$TMP/bare"
cut -f2 "$TMP/edges" | sort -u > "$TMP/referenced"

# ── allowlist ─────────────────────────────────────────────
: > "$TMP/allow"
[ -f "$ALLOWLIST" ] && sed -E 's/#.*$//' "$ALLOWLIST" | awk 'NF{print $1}' | sort -u > "$TMP/allow"

comm -13 "$TMP/declared" "$TMP/referenced" > "$TMP/dangling"
comm -23 "$TMP/declared" "$TMP/referenced" | comm -23 - "$TMP/allow" > "$TMP/unreferenced"
comm -12 "$TMP/allow" "$TMP/referenced" > "$TMP/stale_allow"

# ── legacy scan ───────────────────────────────────────────
: > "$TMP/legacy_hits"
if [ "$LEGACY" = "1" ] && [ -d "$PLUGIN_ROOT/legacy/agents" ]; then
  for f in "$PLUGIN_ROOT"/legacy/agents/*.md; do
    [ -f "$f" ] || continue
    t=$(grep -m1 -E '^subagent_type:' "$f" | sed 's/subagent_type: *//' | tr -d '"' | xargs)
    [ -z "$t" ] && continue
    grep -rlF "\"$t\"" "$PLUGIN_ROOT/commands" "$PLUGIN_ROOT/agents" "$PLUGIN_ROOT/skills" \
      "$PLUGIN_ROOT/pipelines" "$PLUGIN_ROOT/hooks" 2>/dev/null \
      | sed "s|$PLUGIN_ROOT/||;s|^|$t\t|" >> "$TMP/legacy_hits"
  done
fi

# ── output ────────────────────────────────────────────────
FAIL=0
if [ "$EDGES" = "1" ]; then
  sort -u "$TMP/edges" | awk -F'\t' '{print $1" -> "$2}'
fi
if [ "$JSON" = "1" ]; then
  python3 - "$TMP" <<'PY'
import json, sys, os
t = sys.argv[1]
rd = lambda n: [l.rstrip("\n") for l in open(os.path.join(t, n)) if l.strip()]
print(json.dumps({
  "declared": len(rd("declared")), "referenced": len(rd("referenced")),
  "dangling": rd("dangling"), "unreferenced": rd("unreferenced"),
  "namespace_fail": rd("namespace_fail"), "stale_allowlist": rd("stale_allow"),
  "legacy_hits": rd("legacy_hits"), "edges": len(rd("edges"))
}))
PY
fi

# In --json mode the human-readable lines go to stderr so stdout stays parseable.
[ "$JSON" = "1" ] && exec 3>&1 1>&2
if [ -s "$TMP/namespace_fail" ]; then FAIL=1; sed 's/^/  ❌ namespace: /' "$TMP/namespace_fail"; fi
if [ -s "$TMP/bare" ]; then FAIL=1; awk -F'\t' '{print "  ❌ unnamespaced dispatch: "$2"  in "$1}' "$TMP/bare"; fi
if [ -s "$TMP/dangling" ]; then
  FAIL=1
  while read -r t; do
    src=$(awk -F'\t' -v t="$t" '$2==t{print $1}' "$TMP/edges" | sort -u | head -3 | paste -sd, -)
    echo "  ❌ dangling: $t  (referenced by $src)"
  done < "$TMP/dangling"
fi
if [ -s "$TMP/unreferenced" ]; then FAIL=1; sed 's/^/  ❌ unreferenced (not allowlisted): /' "$TMP/unreferenced"; fi
if [ -s "$TMP/stale_allow" ]; then sed 's/^/  ⚠️  allowlisted but now referenced (remove from allowlist): /' "$TMP/stale_allow"; fi
if [ -s "$TMP/legacy_hits" ]; then FAIL=1; awk -F'\t' '{print "  ❌ legacy type still referenced: "$1"  in "$2}' "$TMP/legacy_hits"; fi

say "  declared=$(wc -l < "$TMP/declared" | xargs) referenced=$(wc -l < "$TMP/referenced" | xargs) edges=$(wc -l < "$TMP/edges" | xargs) allowlisted=$(wc -l < "$TMP/allow" | xargs) dangling=$(wc -l < "$TMP/dangling" | xargs) unreferenced=$(wc -l < "$TMP/unreferenced" | xargs)"
[ "$FAIL" = "0" ] && say "  ✅ agent graph clean"
exit "$FAIL"
