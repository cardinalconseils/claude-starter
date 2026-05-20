#!/bin/bash
# Write session start record for observability tracking.
# Creates .cks/control-plane/observability/sessions/YYYY-MM-DD-HHMM.json
# Always exits 0. Silent on failure.

CP_CONFIG=".cks/control-plane/config.yaml"
[ -f "$CP_CONFIG" ] || exit 0

OBS_DIR=".cks/control-plane/observability"
SESSIONS_DIR="${OBS_DIR}/sessions"
mkdir -p "$SESSIONS_DIR" 2>/dev/null

SESSION_ID="$(date +%Y-%m-%d-%H%M)"
SESSION_FILE="${SESSIONS_DIR}/${SESSION_ID}.json"
COUNTER_FILE="${OBS_DIR}/.tool-count"

echo "0" > "$COUNTER_FILE" 2>/dev/null

if [ ! -f "$SESSION_FILE" ]; then
  START_TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  BRANCH="$(git branch --show-current 2>/dev/null || echo "unknown")"
  printf '{"session_id":"%s","start_ts":"%s","branch":"%s","tool_calls":0,"cks_commands":0,"duration_seconds":null,"end_ts":null}\n' \
    "$SESSION_ID" "$START_TS" "$BRANCH" > "$SESSION_FILE" 2>/dev/null
fi

echo "$SESSION_ID" > "${OBS_DIR}/.current-session-id" 2>/dev/null

exit 0
