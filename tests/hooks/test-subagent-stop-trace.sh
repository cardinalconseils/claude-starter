#!/bin/bash
# subagent-stop-trace.sh writes one line per real dispatch to .prd/logs/agents/<role>.jsonl
# and writes nothing for a role-less payload with no transcript usage (phantom SubagentStop).
# Usage: bash tests/hooks/test-subagent-stop-trace.sh [path/to/subagent-stop-trace.sh]. Exit 0 = pass.

ROOT=$(cd "$(dirname "$0")/../.." && pwd)
HANDLER="${1:-$ROOT/hooks/handlers/subagent-stop-trace.sh}"
HANDLER=$(cd "$(dirname "$HANDLER")" && pwd)/$(basename "$HANDLER")
[ -f "$HANDLER" ] || { echo "FAIL: handler not found: $HANDLER"; exit 1; }
command -v python3 >/dev/null 2>&1 || { echo "FAIL: python3 is required"; exit 1; }

fail=0

# (a) no role, no transcript — writes nothing
dir=$(mktemp -d "${TMPDIR:-/tmp}/subagent-stop-trace-XXXXXX")
mkdir -p "$dir/.prd/logs"
printf 'test-a' > "$dir/.prd/logs/.current_session_id"
( cd "$dir" && printf '{"session_id":"test-a"}' | bash "$HANDLER" ) \
  || { echo "FAIL a-no-role: handler exited non-zero"; fail=1; }
if [ -d "$dir/.prd/logs/agents" ] && [ -n "$(ls -A "$dir/.prd/logs/agents" 2>/dev/null)" ]; then
  echo "FAIL a-no-role: expected no line written, found $(ls "$dir/.prd/logs/agents")"; fail=1
else
  echo "PASS a-no-role: nothing written"
fi
rm -rf "$dir"

# (b) normal payload with agent_type — writes one line
dir=$(mktemp -d "${TMPDIR:-/tmp}/subagent-stop-trace-XXXXXX")
mkdir -p "$dir/.prd/logs"
printf 'test-b' > "$dir/.prd/logs/.current_session_id"
( cd "$dir" && printf '{"session_id":"test-b","agent_type":"cks:builder","agent_id":"a1"}' | bash "$HANDLER" ) \
  || { echo "FAIL b-normal: handler exited non-zero"; fail=1; }
LINE=$(tail -n 1 "$dir/.prd/logs/agents/cks:builder.jsonl" 2>/dev/null)
if printf '%s' "$LINE" | grep -q '"role": "cks:builder"'; then
  echo "PASS b-normal: role=cks:builder line written"
else
  echo "FAIL b-normal: expected role cks:builder, got: ${LINE:-<no line>}"; fail=1
fi
rm -rf "$dir"

exit "$fail"
