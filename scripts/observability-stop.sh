#!/bin/bash
# Finalize session observability record and update running totals.
# Called from stop.sh. Always exits 0.

CP_CONFIG=".cks/control-plane/config.yaml"
[ -f "$CP_CONFIG" ] || exit 0

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
OBS_DIR=".cks/control-plane/observability"
SESSIONS_DIR="${OBS_DIR}/sessions"

SESSION_ID=$(cat "${OBS_DIR}/.current-session-id" 2>/dev/null | xargs)
[ -z "$SESSION_ID" ] && SESSION_ID="$(date +%Y-%m-%d-%H%M)"
SESSION_FILE="${SESSIONS_DIR}/${SESSION_ID}.json"
TOTALS_FILE="${OBS_DIR}/totals.json"
COUNTER_FILE="${OBS_DIR}/.tool-count"

END_TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
TOOL_COUNT=$(cat "$COUNTER_FILE" 2>/dev/null | tr -d '[:space:]' || echo "0")
[ -z "$TOOL_COUNT" ] && TOOL_COUNT=0

if [ -f "$SESSION_FILE" ] && command -v jq >/dev/null 2>&1; then
  START_TS=$(jq -r '.start_ts // empty' "$SESSION_FILE" 2>/dev/null)
  if [ -n "$START_TS" ]; then
    START_EPOCH=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$START_TS" +%s 2>/dev/null || \
                  date -d "$START_TS" +%s 2>/dev/null || echo 0)
    END_EPOCH=$(date +%s)
    DURATION=$(( END_EPOCH - START_EPOCH ))
  else
    DURATION=0
  fi

  BRANCH=$(jq -r '.branch // "unknown"' "$SESSION_FILE" 2>/dev/null)
  jq -cn \
    --arg sid "$SESSION_ID" \
    --arg sts "$(jq -r '.start_ts // ""' "$SESSION_FILE" 2>/dev/null)" \
    --arg ets "$END_TS" \
    --arg br "$BRANCH" \
    --argjson tc "$TOOL_COUNT" \
    --argjson dur "$DURATION" \
    '{session_id:$sid,start_ts:$sts,end_ts:$ets,branch:$br,tool_calls:$tc,cks_commands:0,duration_seconds:$dur}' \
    > "${SESSION_FILE}.tmp" 2>/dev/null && mv "${SESSION_FILE}.tmp" "$SESSION_FILE" 2>/dev/null

  if [ -f "$TOTALS_FILE" ]; then
    PREV_SESSIONS=$(jq -r '.total_sessions // 0' "$TOTALS_FILE" 2>/dev/null || echo 0)
    PREV_DURATION=$(jq -r '.total_duration_seconds // 0' "$TOTALS_FILE" 2>/dev/null || echo 0)
    PREV_TOOLS=$(jq -r '.total_tool_calls // 0' "$TOTALS_FILE" 2>/dev/null || echo 0)
    PREV_WEEK=$(jq -r '.week_duration_seconds // 0' "$TOTALS_FILE" 2>/dev/null || echo 0)
    PREV_WEEK_SESS=$(jq -r '.week_sessions // 0' "$TOTALS_FILE" 2>/dev/null || echo 0)
    PREV_WEEK_DATE=$(jq -r '.week_start // ""' "$TOTALS_FILE" 2>/dev/null)
  else
    PREV_SESSIONS=0; PREV_DURATION=0; PREV_TOOLS=0
    PREV_WEEK=0; PREV_WEEK_SESS=0; PREV_WEEK_DATE=""
  fi

  WEEK_START=$(date -v-7d +%Y-%m-%d 2>/dev/null || date -d '7 days ago' +%Y-%m-%d 2>/dev/null || echo "")
  if [ -z "$PREV_WEEK_DATE" ] || [ -n "$WEEK_START" -a "$PREV_WEEK_DATE" \< "$WEEK_START" ]; then
    PREV_WEEK=0; PREV_WEEK_SESS=0
    PREV_WEEK_DATE="$(date +%Y-%m-%d)"
  fi

  NEW_SESSIONS=$(( PREV_SESSIONS + 1 ))
  NEW_DURATION=$(( PREV_DURATION + DURATION ))
  NEW_TOOLS=$(( PREV_TOOLS + TOOL_COUNT ))
  NEW_WEEK=$(( PREV_WEEK + DURATION ))
  NEW_WEEK_SESS=$(( PREV_WEEK_SESS + 1 ))

  jq -cn \
    --argjson ts "$NEW_SESSIONS" \
    --argjson td "$NEW_DURATION" \
    --argjson tt "$NEW_TOOLS" \
    --argjson ws "$NEW_WEEK" \
    --argjson wss "$NEW_WEEK_SESS" \
    --arg wd "$PREV_WEEK_DATE" \
    --arg updated "$END_TS" \
    '{total_sessions:$ts,total_duration_seconds:$td,total_tool_calls:$tt,week_duration_seconds:$ws,week_sessions:$wss,week_start:$wd,last_updated:$updated}' \
    > "${TOTALS_FILE}.tmp" 2>/dev/null && mv "${TOTALS_FILE}.tmp" "$TOTALS_FILE" 2>/dev/null
fi

SYNC_SCRIPT="$PLUGIN_ROOT/scripts/observability-sync.sh"
[ -x "$SYNC_SCRIPT" ] && "$SYNC_SCRIPT" 2>/dev/null || true

exit 0
