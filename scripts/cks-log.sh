#!/bin/bash
# scripts/cks-log.sh — Append a structured event to .prd/logs/lifecycle.jsonl
#
# Usage: bash scripts/cks-log.sh <severity> <event> <feature_id> <message> [metadata_json]
#
# Example:
#   bash scripts/cks-log.sh INFO "phase.discover.started" "01-backend-api" "Discovery started" '{"elements":0}'

set -euo pipefail

SEVERITY="${1:?Usage: cks-log.sh <severity> <event> <feature_id> <message> [metadata_json]}"
EVENT="${2:?Missing event}"
FEATURE_ID="${3:?Missing feature_id}"
MESSAGE="${4:?Missing message}"
METADATA="${5:-"{}"}"

# Validate severity
case "$SEVERITY" in
  INFO|WARN|ERROR) ;;
  *) echo "cks-log: invalid severity '$SEVERITY' (use INFO, WARN, ERROR)" >&2; exit 1 ;;
esac

# Validate jq is available
if ! command -v jq &>/dev/null; then
  echo "cks-log: jq is required but not installed. Install via: brew install jq" >&2
  exit 1
fi

mkdir -p .prd/logs

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")

# Session ID: read from file (written by session-start hook), fallback to timestamp
SESSION_ID_FILE=".prd/logs/.current_session_id"
if [ -f "$SESSION_ID_FILE" ]; then
  SESSION_ID=$(cat "$SESSION_ID_FILE")
else
  SESSION_ID=$(date -u +"%Y-%m-%dT%H:%M")
fi

# Build JSON event safely using jq
jq -cn \
  --arg ts "$TIMESTAMP" \
  --arg sev "$SEVERITY" \
  --arg evt "$EVENT" \
  --arg fid "$FEATURE_ID" \
  --arg sid "$SESSION_ID" \
  --argjson meta "$METADATA" \
  --arg msg "$MESSAGE" \
  '{timestamp:$ts, severity:$sev, event:$evt, feature_id:$fid, session_id:$sid, metadata:$meta, message:$msg}' \
  >> .prd/logs/lifecycle.jsonl
