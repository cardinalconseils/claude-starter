#!/bin/bash
# Log design system generation via SubagentStop event
# Detection: if DESIGN.md was modified in the last 30 seconds
PLUGIN_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
DESIGN_FILE="DESIGN.md"

if [ -f "$DESIGN_FILE" ]; then
  if [ "$(find "$DESIGN_FILE" -mmin -0.5 2>/dev/null)" ]; then
    source "$(dirname "$0")/lifecycle-event.sh"
    emit_event "INFO" "design.system.generated" "_project" \
      '{}' "DESIGN.md generated or updated"
  fi
fi

exit 0
