#!/bin/bash
# Checks control plane component health.
# Writes .cks/control-plane/health/latest.json
# Prints warnings to stdout only when degraded (silent when healthy).
# Always exits 0 — never blocks sessions.

CP_DIR=".cks/control-plane"
HEALTH_DIR="${CP_DIR}/health"
CP_CONFIG="${CP_DIR}/config.yaml"
QUEUE_DIR="${CP_DIR}/sync-queue"

mkdir -p "$HEALTH_DIR" 2>/dev/null

TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
WARNINGS=""
COMPONENTS=""

_check() {
  local name="$1" status="$2" detail="$3"
  COMPONENTS="${COMPONENTS:+${COMPONENTS},}{\"component\":\"${name}\",\"status\":\"${status}\",\"detail\":\"${detail}\"}"
  [ "$status" = "warn" ] || [ "$status" = "error" ] && \
    WARNINGS="${WARNINGS:+${WARNINGS}|}${name}: ${detail}"
}

if [ -f "$CP_CONFIG" ]; then
  _check "config" "ok" "config.yaml present"
else
  _check "config" "error" "config.yaml missing — run /cks:control-plane init"
fi

for d in "memory/project" "memory/sessions" "memory/agents"; do
  if [ ! -d "${CP_DIR}/${d}" ]; then
    mkdir -p "${CP_DIR}/${d}" 2>/dev/null
    _check "memory:${d}" "warn" "directory was missing — auto-recreated"
  else
    _check "memory:${d}" "ok" "present"
  fi
done

if [ -d "${CP_DIR}/heartbeat/state" ]; then
  HB_COUNT=$(ls "${CP_DIR}/heartbeat/state/"*.json 2>/dev/null | wc -l | tr -d ' ')
  _check "heartbeat" "ok" "${HB_COUNT} agent(s) registered"
else
  _check "heartbeat" "warn" "heartbeat/state dir missing"
fi

SUPABASE_URL=$(grep "supabase_url:" "$CP_CONFIG" 2>/dev/null | sed 's/.*supabase_url: *//' | xargs)
if [ -n "$SUPABASE_URL" ]; then
  if command -v curl >/dev/null 2>&1; then
    HTTP=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 "${SUPABASE_URL}/rest/v1/" 2>/dev/null)
    if [ "$HTTP" = "200" ] || [ "$HTTP" = "401" ]; then
      _check "supabase" "ok" "reachable (${HTTP})"
    else
      _check "supabase" "warn" "unreachable (HTTP ${HTTP:-timeout}) — sync will queue"
    fi
  else
    _check "supabase" "warn" "curl not found — cannot check reachability"
  fi
else
  _check "supabase" "ok" "not configured (dev mode)"
fi

QUEUE_DEPTH=$(ls "${QUEUE_DIR}/"*.json 2>/dev/null | wc -l | tr -d ' ')
if [ "$QUEUE_DEPTH" -gt 0 ]; then
  _check "sync-queue" "warn" "${QUEUE_DEPTH} item(s) queued — run /cks:control-plane --drain"
else
  _check "sync-queue" "ok" "empty"
fi

STALE_LOCKS=$(find "${CP_DIR}" -name "*.lock" -mmin +5 2>/dev/null | wc -l | tr -d ' ')
if [ "$STALE_LOCKS" -gt 0 ]; then
  _check "locks" "warn" "${STALE_LOCKS} stale lock(s) found"
else
  _check "locks" "ok" "no stale locks"
fi

OVERALL="ok"
[ -n "$WARNINGS" ] && OVERALL="degraded"
echo "{\"timestamp\":\"${TS}\",\"overall\":\"${OVERALL}\",\"components\":[${COMPONENTS}]}" \
  > "${HEALTH_DIR}/latest.json" 2>/dev/null

if [ -n "$WARNINGS" ]; then
  echo "   ⚠ Control plane warnings:"
  echo "$WARNINGS" | tr '|' '\n' | sed 's/^/     /'
fi

exit 0
