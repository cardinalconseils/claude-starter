#!/bin/bash
# Log kickstart phase completion via SubagentStop event
# Detection: if .kickstart/state.md was modified in the last 30 seconds, a phase just completed
PLUGIN_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
STATE_FILE=".kickstart/state.md"
if [ -f "$STATE_FILE" ]; then
  # Check if state.md was recently modified (within last 30 seconds)
  if [ "$(find "$STATE_FILE" -mmin -0.5 2>/dev/null)" ]; then
    LAST_PHASE=$(grep "last_phase_name:" "$STATE_FILE" 2>/dev/null | sed 's/.*: *//')
    LAST_STATUS=$(grep "last_phase_status:" "$STATE_FILE" 2>/dev/null | sed 's/.*: *//')
    if [ -n "$LAST_PHASE" ] && [ "$LAST_STATUS" = "done" ]; then
      bash "${PLUGIN_ROOT}/scripts/cks-log.sh" INFO \
        "kickstart.phase.completed" "_project" \
        "Kickstart phase complete: $LAST_PHASE" \
        "{\"phase\":\"$LAST_PHASE\"}"
    fi
  fi
fi
exit 0
