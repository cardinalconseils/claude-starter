#!/bin/bash
# Sync latest observability session to Supabase observability_sessions table.
# Called by observability-stop.sh. Silent on failure. Always exits 0.

CP_CONFIG=".cks/control-plane/config.yaml"
[ -f "$CP_CONFIG" ] || exit 0

SUPABASE_URL=$(grep "supabase_url:" "$CP_CONFIG" 2>/dev/null | sed 's/.*supabase_url: *//' | xargs)
SERVICE_KEY=$(grep "supabase_service_key:" "$CP_CONFIG" 2>/dev/null | sed 's/.*supabase_service_key: *//' | xargs)
ORG_ID=$(grep "org_id:" "$CP_CONFIG" 2>/dev/null | sed 's/.*org_id: *//' | xargs)
PROJECT_ID=$(grep "project_id:" "$CP_CONFIG" 2>/dev/null | sed 's/.*project_id: *//' | xargs)

[ -z "$SUPABASE_URL" ] && exit 0
[ -z "$SERVICE_KEY" ] && exit 0
[ -z "$ORG_ID" ] && exit 0
[ -z "$PROJECT_ID" ] && exit 0
command -v curl >/dev/null 2>&1 || exit 0
command -v jq >/dev/null 2>&1 || exit 0

OBS_DIR=".cks/control-plane/observability"
SESSION_ID=$(cat "${OBS_DIR}/.current-session-id" 2>/dev/null | xargs)
[ -z "$SESSION_ID" ] && exit 0
SESSION_FILE="${OBS_DIR}/sessions/${SESSION_ID}.json"
[ -f "$SESSION_FILE" ] || exit 0

payload=$(jq -c \
  --arg oid "$ORG_ID" --arg pid "$PROJECT_ID" \
  '. + {org_id:$oid, project_id:$pid}' "$SESSION_FILE" 2>/dev/null)
[ -z "$payload" ] && exit 0

curl -s -o /dev/null -X POST "${SUPABASE_URL}/rest/v1/observability_sessions" \
  -H "apikey: ${SERVICE_KEY}" \
  -H "Authorization: Bearer ${SERVICE_KEY}" \
  -H "Content-Type: application/json" \
  -H "Prefer: resolution=merge-duplicates" \
  -d "$payload" 2>/dev/null || true

exit 0
