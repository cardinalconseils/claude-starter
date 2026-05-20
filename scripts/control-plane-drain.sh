#!/bin/bash
# Drain the sync queue — retry failed Supabase syncs from previous sessions.
# Exits 0 always. Prints drain results to stdout.

CP_CONFIG=".cks/control-plane/config.yaml"
[ -f "$CP_CONFIG" ] || exit 0

SUPABASE_URL=$(grep "supabase_url:" "$CP_CONFIG" 2>/dev/null | sed 's/.*supabase_url: *//' | xargs)
SERVICE_KEY=$(grep "supabase_service_key:" "$CP_CONFIG" 2>/dev/null | sed 's/.*supabase_service_key: *//' | xargs)
QUEUE_DIR=".cks/control-plane/sync-queue"

[ -z "$SUPABASE_URL" ] && exit 0
command -v curl >/dev/null 2>&1 || exit 0

ITEMS=$(ls "${QUEUE_DIR}/"*.json 2>/dev/null)
[ -z "$ITEMS" ] && echo "sync-queue: empty — nothing to drain" && exit 0

SUCCESS=0; FAIL=0
for f in $ITEMS; do
  [ -f "$f" ] || continue
  payload=$(cat "$f" 2>/dev/null)
  [ -z "$payload" ] && rm -f "$f" && continue
  HTTP=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 \
    -X POST "${SUPABASE_URL}/rest/v1/memory" \
    -H "apikey: ${SERVICE_KEY}" \
    -H "Authorization: Bearer ${SERVICE_KEY}" \
    -H "Content-Type: application/json" \
    -H "Prefer: resolution=merge-duplicates" \
    -d "$payload" 2>/dev/null)
  if [ "$HTTP" = "200" ] || [ "$HTTP" = "201" ]; then
    rm -f "$f"
    SUCCESS=$((SUCCESS + 1))
  else
    FAIL=$((FAIL + 1))
  fi
done

echo "sync-queue drain: ${SUCCESS} synced, ${FAIL} failed"
exit 0
