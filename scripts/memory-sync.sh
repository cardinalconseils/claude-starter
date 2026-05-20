#!/bin/bash
# Syncs .cks/control-plane/memory/ files to Supabase memory table.
# Called by stop-memory.sh at session end. Silent on failure. Always exits 0.

CP_CONFIG=".cks/control-plane/config.yaml"
[ -f "$CP_CONFIG" ] || exit 0

SUPABASE_URL=$(grep "supabase_url:" "$CP_CONFIG" 2>/dev/null | sed 's/.*supabase_url: *//' | xargs)
SERVICE_KEY=$(grep "supabase_service_key:" "$CP_CONFIG" 2>/dev/null | sed 's/.*supabase_service_key: *//' | xargs)
ORG_ID=$(grep "org_id:" "$CP_CONFIG" 2>/dev/null | sed 's/.*org_id: *//' | xargs)
PROJECT_ID=$(grep "project_id:" "$CP_CONFIG" 2>/dev/null | sed 's/.*project_id: *//' | xargs)

[ -z "$SUPABASE_URL" ] && exit 0
[ -z "$SERVICE_KEY" ] || [ -z "$ORG_ID" ] || [ -z "$PROJECT_ID" ] && exit 0
command -v curl >/dev/null 2>&1 || exit 0

MEMORY_DIR=".cks/control-plane/memory"

_upsert() {
  local mtype="$1" agent_id="$2" key="$3" content_file="$4"
  [ -f "$content_file" ] || return
  local payload
  if command -v jq >/dev/null 2>&1; then
    payload=$(jq -cn \
      --arg oid "$ORG_ID" --arg pid "$PROJECT_ID" \
      --arg mt "$mtype" --arg aid "$agent_id" \
      --arg k "$key" --arg c "$(cat "$content_file")" \
      '{org_id:$oid,project_id:$pid,memory_type:$mt,agent_id:($aid|if .=="" then null else . end),key:$k,content:$c,updated_at:"now()"}')
  else
    payload=$(python3 -c "
import json, sys
d = {'org_id':'$ORG_ID','project_id':'$PROJECT_ID','memory_type':'$mtype',
     'agent_id': None if '$agent_id'=='' else '$agent_id',
     'key':'$key','content':open(sys.argv[1]).read(),'updated_at':'now()'}
print(json.dumps(d))" "$content_file" 2>/dev/null)
  fi
  [ -z "$payload" ] && return
  curl -s -o /dev/null -X POST "${SUPABASE_URL}/rest/v1/memory" \
    -H "apikey: ${SERVICE_KEY}" \
    -H "Authorization: Bearer ${SERVICE_KEY}" \
    -H "Content-Type: application/json" \
    -H "Prefer: resolution=merge-duplicates" \
    -d "$payload" 2>/dev/null || true
}

for f in facts decisions gotchas; do
  _upsert "project" "" "$f" "${MEMORY_DIR}/project/${f}.md"
done

LATEST_SESSION=$(ls -t "${MEMORY_DIR}/sessions/"*.md 2>/dev/null | head -1)
if [ -n "$LATEST_SESSION" ]; then
  SESSION_KEY=$(basename "$LATEST_SESSION" .md)
  _upsert "session" "" "$SESSION_KEY" "$LATEST_SESSION"
fi

for f in "${MEMORY_DIR}/agents/"*.md; do
  [ -f "$f" ] || continue
  AGENT_KEY=$(basename "$f" .md)
  _upsert "agent" "$AGENT_KEY" "memory" "$f"
done

exit 0
