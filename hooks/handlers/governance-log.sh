#!/bin/bash
# PostToolUse (Bash) — log risky command outcomes to .cks/governance.json. Exit 0 always.

INPUT=$(cat 2>/dev/null)
[ -z "$INPUT" ] && exit 0
command -v python3 >/dev/null 2>&1 || exit 0
command -v jq >/dev/null 2>&1 || exit 0

PARSED=$(printf '%s' "$INPUT" | python3 -c "
import sys, json, hashlib, re
d = json.load(sys.stdin)
cmd = d.get('tool_input', {}).get('command', '')
if not cmd:
    sys.exit(0)
args = json.dumps(d.get('tool_input', {}), sort_keys=True)
digest = hashlib.sha256(args.encode()).hexdigest()[:8]
r = d.get('tool_response', {})
outcome = 'error' if isinstance(r, dict) and r.get('error') else 'success'
patterns = [
    (r'rm\s+-f\b', 'Forced file deletion'),
    (r'git\s+branch\s+-D', 'Force-delete branch'),
    (r'git\s+(checkout|restore)\s+\.', 'Discard working tree'),
    (r'kubectl\s+delete', 'Cloud resource delete'),
    (r'aws\s+.*delete', 'Cloud resource delete'),
    (r'gcloud\s+.+\s+delete\b', 'Cloud resource delete'),
    (r'ALTER\s+TABLE\b.*DROP\s+COLUMN', 'Schema column drop'),
]
risk_reason = next((rr for p, rr in patterns if re.search(p, cmd, re.I)), None)
if not risk_reason:
    sys.exit(0)
decision = 'approved' if outcome == 'success' else 'ran-with-error'
print(json.dumps({'tool': 'Bash', 'args_digest': digest, 'risk_level': 'HIGH', 'risk_reason': risk_reason, 'decision': decision}))
" 2>/dev/null)
[ -z "$PARSED" ] && exit 0

mkdir -p .cks
SID=$(cat .prd/logs/.current_session_id 2>/dev/null || date -u +"%Y-%m-%dT%H:%M")
TS=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")
printf '%s\n' "$(printf '%s' "$PARSED" | jq -c --arg ts "$TS" --arg sid "$SID" '. + {ts: $ts, session_id: $sid}')" \
  >> ".cks/governance.json" 2>/dev/null || true
exit 0
