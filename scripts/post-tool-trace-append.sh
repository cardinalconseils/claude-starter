#!/bin/bash
# Appends a parsed PostToolUse trace line to the session JSONL, then ships it to the
# Supabase events sink in the background (opt-in via CKS_TELEMETRY_SINK=supabase).
# Split out of post-tool-trace.sh to keep that hook under the 30-line hook budget.
# Exit 0 always.

PARSED="$1"
[ -z "$PARSED" ] && exit 0
command -v jq >/dev/null 2>&1 || exit 0

mkdir -p .prd/logs/sessions
SID=$(cat .prd/logs/.current_session_id 2>/dev/null || date -u +"%Y-%m-%dT%H:%M")
TS=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")

LINE=$(printf '%s' "$PARSED" | jq -c --arg ts "$TS" --arg sid "$SID" '. + {timestamp: $ts, session_id: $sid}')
printf '%s\n' "$LINE" >> ".prd/logs/sessions/${SID}.jsonl" 2>/dev/null || true

if [ "$CKS_TELEMETRY_SINK" = "supabase" ]; then
  bash "$(dirname "$0")/telemetry-ship.sh" tool "$LINE" >/dev/null 2>&1 &
fi

exit 0
