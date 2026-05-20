#!/bin/bash
# CKS v6 Phase 3: Agent Registry — claim/release/list/clean
# Usage:
#   agent-registry.sh register  <session-id> <task-description>
#   agent-registry.sh claim     <session-id> <file-or-task-path>
#   agent-registry.sh release   <session-id> [file-or-task-path]
#   agent-registry.sh list
#   agent-registry.sh clean
# Always exits 0. Silent on failure.

REGISTRY_DIR=".cks/control-plane/agents/registry"
mkdir -p "$REGISTRY_DIR" 2>/dev/null

SUBCOMMAND="${1:-list}"
SESSION_ID="${2:-}"
RESOURCE="${3:-}"

_is_alive() {
  local pid="$1"
  [ -z "$pid" ] && return 1
  kill -0 "$pid" 2>/dev/null
}

_lock_file() {
  echo "${REGISTRY_DIR}/${1}.lock"
}

case "$SUBCOMMAND" in

  register)
    [ -z "$SESSION_ID" ] && exit 0
    LOCK_FILE=$(_lock_file "$SESSION_ID")
    NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    PID=$$
    [ -n "$CKS_SESSION_PID" ] && PID="$CKS_SESSION_PID"
    EXISTING_CLAIMS="[]"
    if [ -f "$LOCK_FILE" ] && command -v jq >/dev/null 2>&1; then
      EXISTING_CLAIMS=$(jq -r '.claimed_resources // []' "$LOCK_FILE" 2>/dev/null || echo "[]")
    fi
    TASK="${RESOURCE:-idle}"
    if command -v jq >/dev/null 2>&1; then
      jq -cn \
        --arg sid "$SESSION_ID" \
        --arg pid "$PID" \
        --arg task "$TASK" \
        --arg ts "$NOW" \
        --argjson claims "$EXISTING_CLAIMS" \
        '{session_id:$sid,pid:($pid|tonumber),task:$task,registered_at:$ts,updated_at:$ts,claimed_resources:$claims}' \
        > "$LOCK_FILE" 2>/dev/null
    else
      printf '{"session_id":"%s","pid":%s,"task":"%s","registered_at":"%s","updated_at":"%s","claimed_resources":[]}\n' \
        "$SESSION_ID" "$PID" "$TASK" "$NOW" "$NOW" > "$LOCK_FILE" 2>/dev/null
    fi
    ;;

  claim)
    [ -z "$SESSION_ID" ] || [ -z "$RESOURCE" ] && exit 0
    LOCK_FILE=$(_lock_file "$SESSION_ID")
    [ -f "$LOCK_FILE" ] || exit 0
    NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    if command -v jq >/dev/null 2>&1; then
      TMP=$(mktemp)
      jq --arg r "$RESOURCE" --arg ts "$NOW" \
        '.claimed_resources += [$r] | .claimed_resources |= unique | .updated_at = $ts' \
        "$LOCK_FILE" > "$TMP" 2>/dev/null && mv "$TMP" "$LOCK_FILE" || rm -f "$TMP"
    fi
    ;;

  release)
    [ -z "$SESSION_ID" ] && exit 0
    LOCK_FILE=$(_lock_file "$SESSION_ID")
    if [ -z "$RESOURCE" ]; then
      rm -f "$LOCK_FILE" 2>/dev/null
    else
      [ -f "$LOCK_FILE" ] || exit 0
      if command -v jq >/dev/null 2>&1; then
        NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
        TMP=$(mktemp)
        jq --arg r "$RESOURCE" --arg ts "$NOW" \
          '.claimed_resources -= [$r] | .updated_at = $ts' \
          "$LOCK_FILE" > "$TMP" 2>/dev/null && mv "$TMP" "$LOCK_FILE" || rm -f "$TMP"
      fi
    fi
    ;;

  list)
    [ -d "$REGISTRY_DIR" ] || exit 0
    for f in "$REGISTRY_DIR"/*.lock; do
      [ -f "$f" ] || continue
      if command -v jq >/dev/null 2>&1; then
        PID=$(jq -r '.pid // 0' "$f" 2>/dev/null)
        if _is_alive "$PID"; then
          cat "$f"
        else
          rm -f "$f" 2>/dev/null
        fi
      else
        cat "$f"
      fi
      echo ""
    done
    ;;

  clean)
    [ -d "$REGISTRY_DIR" ] || exit 0
    CLEANED=0
    for f in "$REGISTRY_DIR"/*.lock; do
      [ -f "$f" ] || continue
      PID=$(grep -o '"pid":[0-9]*' "$f" 2>/dev/null | grep -o '[0-9]*$')
      if ! _is_alive "$PID"; then
        rm -f "$f" 2>/dev/null
        CLEANED=$((CLEANED + 1))
      fi
    done
    echo "Cleaned ${CLEANED} stale lock(s)"
    ;;

esac

exit 0
