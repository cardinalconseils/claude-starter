#!/bin/bash
# PreToolUse hook — increment session tool-call counter.
# Must exit 0. Never blocks the tool call.

CP_CONFIG=".cks/control-plane/config.yaml"
[ -f "$CP_CONFIG" ] || exit 0

COUNTER_FILE=".cks/control-plane/observability/.tool-count"
[ -f "$COUNTER_FILE" ] || exit 0

COUNT=$(cat "$COUNTER_FILE" 2>/dev/null || echo "0")
echo $(( COUNT + 1 )) > "$COUNTER_FILE" 2>/dev/null || true

exit 0
