#!/bin/bash
# post-tool-trace.sh records the tool name from tool_name, legacy tool, or "unknown".
# Usage: bash tests/hooks/test-post-tool-trace.sh [path/to/post-tool-trace.sh]. Exit 0 = pass.

ROOT=$(cd "$(dirname "$0")/../.." && pwd)
HANDLER="${1:-$ROOT/hooks/handlers/post-tool-trace.sh}"
HANDLER=$(cd "$(dirname "$HANDLER")" && pwd)/$(basename "$HANDLER")
[ -f "$HANDLER" ] || { echo "FAIL: handler not found: $HANDLER"; exit 1; }
command -v python3 >/dev/null 2>&1 && command -v jq >/dev/null 2>&1 \
  || { echo "FAIL: python3 and jq are required"; exit 1; }

fail=0
check() {  # $1 case name, $2 payload, $3 expected tool
  local dir sid line
  dir=$(mktemp -d "${TMPDIR:-/tmp}/post-tool-trace-XXXXXX")
  sid="test-$1"
  mkdir -p "$dir/.prd/logs"
  printf '%s' "$sid" > "$dir/.prd/logs/.current_session_id"
  ( cd "$dir" && printf '%s' "$2" | env -u CKS_HQ -u CKS_ACTIVE_USER bash "$HANDLER" ) \
    || { echo "FAIL $1: handler exited non-zero"; fail=1; return; }
  line=$(tail -n 1 "$dir/.prd/logs/sessions/$sid.jsonl" 2>/dev/null)
  if printf '%s' "$line" | grep -q "\"tool\":\"$3\""; then
    echo "PASS $1: \"tool\":\"$3\""
  else
    echo "FAIL $1: expected \"tool\":\"$3\", got: ${line:-<no line>}"; fail=1
  fi
}

check tool_name '{"tool_name":"Bash","tool_input":{"command":"echo hi"},"tool_response":{"stdout":"hi"}}' Bash
check legacy-tool '{"tool":"Read","tool_input":{"file_path":"x"},"tool_response":{}}' Read
check no-key '{"tool_input":{},"tool_response":{}}' unknown

# tool_use_id: carried through so an Agent|Task call's tool-trace line joins to the
# same dispatch's Jev routing line and SubagentStop line on this id.
dir=$(mktemp -d "${TMPDIR:-/tmp}/post-tool-trace-XXXXXX")
sid="test-tool-use-id"
mkdir -p "$dir/.prd/logs"
printf '%s' "$sid" > "$dir/.prd/logs/.current_session_id"
( cd "$dir" && printf '%s' '{"tool_name":"Agent","tool_use_id":"toolu_x","tool_input":{},"tool_response":{}}' | env -u CKS_HQ -u CKS_ACTIVE_USER bash "$HANDLER" ) \
  || { echo "FAIL tool-use-id: handler exited non-zero"; fail=1; }
line=$(tail -n 1 "$dir/.prd/logs/sessions/$sid.jsonl" 2>/dev/null)
if printf '%s' "$line" | grep -q '"tool_use_id":"toolu_x"'; then
  echo "PASS tool-use-id: \"tool_use_id\":\"toolu_x\""
else
  echo "FAIL tool-use-id: expected tool_use_id toolu_x, got: ${line:-<no line>}"; fail=1
fi

exit "$fail"
