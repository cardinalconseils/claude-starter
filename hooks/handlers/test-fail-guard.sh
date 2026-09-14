#!/bin/bash
# PreToolUse + PostToolUse (Bash) — stop the retry loop after two consecutive failing test
# runs. Post payloads record the outcome, Pre payloads block the third attempt until the
# streak file is removed. Block mechanism mirrors destructive-op-guard.sh (stderr, exit 2).
# Detection and the streak file live in scripts/test-fail-streak.sh.

INPUT=$(cat 2>/dev/null)
TOOL_NAME=$(printf '%s' "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_name',''))" 2>/dev/null)
case "$TOOL_NAME" in ""|Bash) ;; *) exit 0 ;; esac

PLUGIN_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
printf '%s' "$INPUT" | bash "$PLUGIN_ROOT/scripts/test-fail-streak.sh"
exit $?
