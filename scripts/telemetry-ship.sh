#!/bin/bash
# Ships one telemetry line (tool/dispatch/jev trace) to the Supabase `events` table so
# cloud and local sessions land in one place. Opt-in via CKS_TELEMETRY_SINK=supabase.
# Silent, best-effort, always exits 0. Usage: telemetry-ship.sh <kind> <jsonl-line>

[ "$CKS_TELEMETRY_SINK" = "supabase" ] || exit 0
[ $# -ge 2 ] || exit 0
KIND="$1"
LINE="$2"

CP_CONFIG=".cks/control-plane/config.yaml"
[ -f "$CP_CONFIG" ] || exit 0

QUEUE_DIR=".cks/control-plane/sync-queue"
mkdir -p "$QUEUE_DIR" 2>/dev/null

SUPABASE_URL=$(grep "supabase_url:" "$CP_CONFIG" 2>/dev/null | sed 's/.*supabase_url: *//' | xargs)
SERVICE_KEY=$(grep "supabase_service_key:" "$CP_CONFIG" 2>/dev/null | sed 's/.*supabase_service_key: *//' | xargs)

[ -z "$SUPABASE_URL" ] && exit 0
[ -z "$SERVICE_KEY" ] && exit 0
command -v curl >/dev/null 2>&1 || exit 0
command -v python3 >/dev/null 2>&1 || exit 0

REPO=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null)
[ -z "$REPO" ] && REPO=$(basename "$(pwd)")

# dedupe_key is sha256 of the raw line so a replayed queue file (or a retried POST)
# collides with the row already written instead of duplicating it.
PAYLOAD=$(python3 -c "
import sys, json, hashlib
kind, line, repo = sys.argv[1], sys.argv[2], sys.argv[3]
try:
    d = json.loads(line)
    if not isinstance(d, dict):
        d = {}
except Exception:
    d = {}
row = {
    'kind': kind,
    'repo': repo,
    'session_id': str(d.get('session_id') or '') or None,
    'tool_use_id': str(d.get('tool_use_id') or '') or None,
    'role': str(d.get('role') or '') or None,
    'model': str(d.get('model') or '') or None,
    'cost_usd': d.get('cost_usd'),
    'payload': d,
    'dedupe_key': hashlib.sha256(line.encode('utf-8')).hexdigest(),
}
ts = d.get('ts') or d.get('timestamp')
if ts:
    row['ts'] = ts
print(json.dumps(row))
" "$KIND" "$LINE" "$REPO" 2>/dev/null)

[ -z "$PAYLOAD" ] && exit 0

HTTP=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 \
  -X POST "${SUPABASE_URL}/rest/v1/events?on_conflict=dedupe_key" \
  -H "apikey: ${SERVICE_KEY}" \
  -H "Authorization: Bearer ${SERVICE_KEY}" \
  -H "Content-Type: application/json" \
  -H "Prefer: resolution=ignore-duplicates" \
  -d "$PAYLOAD" 2>/dev/null)

if [ "$HTTP" != "200" ] && [ "$HTTP" != "201" ] && [ "$HTTP" != "204" ]; then
  QUEUE_FILE="${QUEUE_DIR}/events-$(date +%s%3N)-${RANDOM}.json"
  printf '%s' "$PAYLOAD" > "$QUEUE_FILE" 2>/dev/null
fi

exit 0
