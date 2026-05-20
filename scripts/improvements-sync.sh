#!/bin/bash
# Syncs .cks/control-plane/improvements/ proposals to Supabase improvements table.
# Called by stop.sh at session end. Silent on failure. Always exits 0.

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

IMP_BASE=".cks/control-plane/improvements"

_upsert_proposal() {
  local status_dir="$1" status_val="$2"
  for f in "${IMP_BASE}/${status_dir}/"*.md; do
    [ -f "$f" ] || continue
    PROP_ID=$(basename "$f" .md)
    PROP_TYPE=$(grep "^type:" "$f" 2>/dev/null | sed 's/type: *//' | xargs)
    PROP_CONF=$(grep "^confidence:" "$f" 2>/dev/null | sed 's/confidence: *//' | xargs)
    PROP_IMPACT=$(grep "^impact:" "$f" 2>/dev/null | sed 's/impact: *//' | xargs)
    [ -z "$PROP_CONF" ] && PROP_CONF=0
    if command -v jq >/dev/null 2>&1; then
      payload=$(jq -cn \
        --arg oid "$ORG_ID" --arg pid "$PROJECT_ID" \
        --arg propid "$PROP_ID" --arg st "$status_val" \
        --arg pt "$PROP_TYPE" --argjson conf "$PROP_CONF" \
        --arg imp "$PROP_IMPACT" \
        --arg content "$(cat "$f")" \
        '{org_id:$oid,project_id:$pid,proposal_id:$propid,status:$st,type:$pt,confidence:$conf,impact:$imp,content:$content,updated_at:"now()"}')
    else
      continue
    fi
    [ -z "$payload" ] && continue
    curl -s -o /dev/null -X POST "${SUPABASE_URL}/rest/v1/improvements" \
      -H "apikey: ${SERVICE_KEY}" \
      -H "Authorization: Bearer ${SERVICE_KEY}" \
      -H "Content-Type: application/json" \
      -H "Prefer: resolution=merge-duplicates" \
      -d "$payload" 2>/dev/null || true
  done
}

_upsert_proposal "pending" "pending"
_upsert_proposal "accepted" "accepted"
_upsert_proposal "rejected" "rejected"

exit 0
