#!/bin/bash
# scripts/agent-trace.sh — turn one SubagentStop payload (stdin) into a line in
# .prd/logs/agents/<role>.jsonl. SubagentStop field names differ across Claude Code
# versions, so every lookup is optional with an explicit default. Exit 0 always.
command -v python3 >/dev/null 2>&1 || exit 0
[ -d ".prd/logs" ] || exit 0
SID=$(cat .prd/logs/.current_session_id 2>/dev/null)

python3 -c "
import sys, json, os, datetime
try:
    d = json.load(sys.stdin)
except Exception:
    d = {}
if not isinstance(d, dict):
    d = {}
role = str(d.get('agent_type') or d.get('subagent_type') or 'unknown')
sid = sys.argv[1] or str(d.get('session_id') or '')
transcript = str(d.get('agent_transcript_path') or d.get('transcript_path') or '')
last = ''
try:
    with open(transcript, 'rb') as f:
        for raw in f:
            line = raw.decode('utf-8', 'replace')
            if '\"assistant\"' in line:
                last = line
except Exception:
    pass
low = last.lower()
failed = 'outcome=fail' in low or 'outcome=error' in low or '\"is_error\": true' in low or '\"is_error\":true' in low
rec = {
    'ts': datetime.datetime.now(datetime.timezone.utc).strftime('%Y-%m-%dT%H:%M:%S.000Z'),
    'role': role,
    'agent_id': str(d.get('agent_id') or ''),
    'outcome': 'error' if failed else 'completed',
    'session_id': sid,
    'transcript': os.path.basename(transcript) if transcript else '',
}
os.makedirs('.prd/logs/agents', exist_ok=True)
with open(os.path.join('.prd/logs/agents', role.replace('/', '_') + '.jsonl'), 'a') as f:
    f.write(json.dumps(rec) + '\n')
" "$SID" 2>/dev/null
exit 0
