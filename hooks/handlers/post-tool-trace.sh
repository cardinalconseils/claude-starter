#!/bin/bash
# PostToolUse — emit per-tool-call trace to per-session JSONL. Exit 0 always.

INPUT=$(cat 2>/dev/null)
[ -z "$INPUT" ] && exit 0
command -v python3 >/dev/null 2>&1 || exit 0
command -v jq >/dev/null 2>&1 || exit 0

PARSED=$(printf '%s' "$INPUT" | python3 -c "
import sys, json, hashlib
d = json.load(sys.stdin)
tool = d.get('tool', 'unknown')
args = json.dumps(d.get('tool_input', {}), sort_keys=True)
digest = hashlib.sha256(args.encode()).hexdigest()[:8]
r = d.get('tool_response', {})
outcome = 'error' if isinstance(r, dict) and r.get('error') else 'success'
print(json.dumps({'tool': tool, 'args_digest': digest, 'outcome': outcome}))
" 2>/dev/null)
[ -z "$PARSED" ] && exit 0

mkdir -p .prd/logs/sessions
SID=$(cat .prd/logs/.current_session_id 2>/dev/null || date -u +"%Y-%m-%dT%H:%M")
TS=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")

printf '%s\n' "$(printf '%s' "$PARSED" | jq -c \
  --arg ts "$TS" --arg sid "$SID" '. + {timestamp: $ts, session_id: $sid}')" \
  >> ".prd/logs/sessions/${SID}.jsonl" 2>/dev/null || true

exit 0
