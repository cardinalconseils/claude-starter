#!/bin/bash
# PreToolUse (Agent|Task) — pause dispatches when API spend reaches the BUDGET.md ceiling.
# The ceiling is the founder's number; a dispatch past it is a gated action, not a default.
# Block mechanism mirrors destructive-op-guard.sh: reason on stderr + exit 2. All the
# arithmetic lives in scripts/budget-check.sh; this file only routes the event.

INPUT=$(cat 2>/dev/null)
TOOL_NAME=$(printf '%s' "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_name',''))" 2>/dev/null)
case "$TOOL_NAME" in ""|Agent|Task) ;; *) exit 0 ;; esac

PLUGIN_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
bash "$PLUGIN_ROOT/scripts/budget-check.sh"
exit $?
