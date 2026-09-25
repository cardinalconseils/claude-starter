#!/bin/bash
# PostToolUse — emit per-tool-call trace to per-session JSONL. Exit 0 always.

INPUT=$(cat 2>/dev/null)
[ -z "$INPUT" ] && exit 0
command -v python3 >/dev/null 2>&1 || exit 0
command -v jq >/dev/null 2>&1 || exit 0

PARSED=$(printf '%s' "$INPUT" | python3 -c "
import sys, json, hashlib
d = json.load(sys.stdin)
tool = d.get('tool_name') or d.get('tool') or 'unknown'
args = json.dumps(d.get('tool_input', {}), sort_keys=True)
digest = hashlib.sha256(args.encode()).hexdigest()[:8]
r = d.get('tool_response', {})
outcome = 'error' if isinstance(r, dict) and r.get('error') else 'success'
tool_use_id = str(d.get('tool_use_id') or '')
print(json.dumps({'tool': tool, 'args_digest': digest, 'outcome': outcome, 'tool_use_id': tool_use_id}))
" 2>/dev/null)
[ -z "$PARSED" ] && exit 0

PLUGIN_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
bash "$PLUGIN_ROOT/scripts/post-tool-trace-append.sh" "$PARSED" 2>/dev/null

exit 0
