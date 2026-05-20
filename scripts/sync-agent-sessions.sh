#!/bin/bash
# CKS v6 Phase 3: Sync active agent sessions to Supabase agent_sessions table.
# Usage:
#   sync-agent-sessions.sh start <session-id> <task>
#   sync-agent-sessions.sh end   <session-id>
#   sync-agent-sessions.sh list
# Silent on failure. Always exits 0.

CP_CONFIG=".cks/control-plane/config.yaml"
[ -f "$CP_CONFIG" ] || exit 0

SUPABASE_URL=$(grep "supabase_url:" "$CP_CONFIG" 2>/dev/null | sed 's/.*supabase_url: *//' | xargs)
SERVICE_KEY=$(grep "supabase_service_key:" "$CP_CONFIG" 2>/dev/null | sed 's/.*supabase_service_key: *//' | xargs)
ORG_ID=$(grep "org_id:" "$CP_CONFIG" 2>/dev/null | sed 's/.*org_id: *//' | xargs)
[ -z "$ORG_ID" ] && ORG_ID=$(grep "^org:" "$CP_CONFIG" 2>/dev/null | sed 's/^org: *//' | xargs)
PROJECT_ID=$(grep "project_id:" "$CP_CONFIG" 2>/dev/null | sed 's/.*project_id: *//' | xargs)

[ -z "$SUPABASE_URL" ] && exit 0
[ -z "$SERVICE_KEY" ] && exit 0
[ -z "$ORG_ID" ] && exit 0
command -v curl >/dev/null 2>&1 || exit 0

SUBCOMMAND="${1:-list}"
SESSION_ID="${2:-}"
TASK="${3:-idle}"

_rest() {
  local method="$1" path="$2" data="$3"
  curl -s -o /dev/null -X "$method" "${SUPABASE_URL}/rest/v1/${path}" \
    -H "apikey: ${SERVICE_KEY}" \
    -H "Authorization: Bearer ${SERVICE_KEY}" \
    -H "Content-Type: application/json" \
    -H "Prefer: resolution=merge-duplicates" \
    ${data:+-d "$data"} 2>/dev/null || true
}

case "$SUBCOMMAND" in

  start)
    [ -z "$SESSION_ID" ] && exit 0
    NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    if command -v jq >/dev/null 2>&1; then
      PAYLOAD=$(jq -cn \
        --arg sid "$SESSION_ID" \
        --arg oid "$ORG_ID" \
        --arg pid "${PROJECT_ID:-}" \
        --arg task "$TASK" \
        --arg ts "$NOW" \
        '{session_id:$sid,org_id:$oid,project_id:($pid|if .=="" then null else . end),task:$task,status:"active",started_at:$ts,updated_at:$ts}')
    else
      PAYLOAD=$(printf '{"session_id":"%s","org_id":"%s","task":"%s","status":"active","started_at":"%s","updated_at":"%s"}' \
        "$SESSION_ID" "$ORG_ID" "$TASK" "$NOW" "$NOW")
    fi
    _rest POST "agent_sessions" "$PAYLOAD"
    ;;

  end)
    [ -z "$SESSION_ID" ] && exit 0
    NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    if command -v jq >/dev/null 2>&1; then
      PAYLOAD=$(jq -cn --arg ts "$NOW" '{status:"ended",ended_at:$ts,updated_at:$ts}')
    else
      PAYLOAD=$(printf '{"status":"ended","ended_at":"%s","updated_at":"%s"}' "$NOW" "$NOW")
    fi
    _rest PATCH "agent_sessions?session_id=eq.${SESSION_ID}&org_id=eq.${ORG_ID}" "$PAYLOAD"
    ;;

  list)
    curl -s -X GET \
      "${SUPABASE_URL}/rest/v1/agent_sessions?org_id=eq.${ORG_ID}&status=eq.active&order=started_at.desc" \
      -H "apikey: ${SERVICE_KEY}" \
      -H "Authorization: Bearer ${SERVICE_KEY}" \
      2>/dev/null || true
    ;;

esac

exit 0
