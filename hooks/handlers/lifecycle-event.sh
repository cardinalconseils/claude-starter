#!/bin/bash
# Reusable lifecycle event emitter — replaces scattered jq commands in hooks.
# Source this file, then call emit_event.
#
# Usage:
#   source "$(dirname "$0")/lifecycle-event.sh"
#   emit_event "INFO" "phase.sprint.started" "03-backend-api" '{"tasks":4}' "Sprint started"
#
# Args:
#   $1 — severity: INFO, WARN, ERROR
#   $2 — event type: dotted string (e.g., lane.started, failure.classified)
#   $3 — feature_id: feature directory name or "system"
#   $4 — metadata: JSON object string (use '{}' for empty)
#   $5 — message: human-readable description

emit_event() {
  local severity="${1:-INFO}"
  local event="$2"
  local feature_id="${3:-system}"
  local metadata="${4:-{}}"
  local message="${5:-}"

  if [ -z "$event" ]; then
    return 0
  fi

  mkdir -p .prd/logs

  local ts
  ts="$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")"

  local sid
  sid="$(cat .prd/logs/.current_session_id 2>/dev/null || date -u +"%Y-%m-%dT%H:%M")"

  # Use jq if available, fall back to printf
  if command -v jq >/dev/null 2>&1; then
    jq -cn \
      --arg ts "$ts" \
      --arg sev "$severity" \
      --arg evt "$event" \
      --arg fid "$feature_id" \
      --arg sid "$sid" \
      --argjson meta "$metadata" \
      --arg msg "$message" \
      '{timestamp:$ts,severity:$sev,event:$evt,feature_id:$fid,session_id:$sid,metadata:$meta,message:$msg}' \
      >> .prd/logs/lifecycle.jsonl
  else
    printf '{"timestamp":"%s","severity":"%s","event":"%s","feature_id":"%s","session_id":"%s","metadata":%s,"message":"%s"}\n' \
      "$ts" "$severity" "$event" "$feature_id" "$sid" "$metadata" "$message" \
      >> .prd/logs/lifecycle.jsonl
  fi
}
