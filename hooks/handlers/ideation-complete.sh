#!/bin/bash
# Log standalone ideation completion via SubagentStop event
# Detection: if any file in .ideation/ was modified in the last 30 seconds
PLUGIN_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
IDEATION_DIR=".ideation"
if [ -d "$IDEATION_DIR" ]; then
  RECENT=$(find "$IDEATION_DIR" -name "*.md" -mmin -0.5 2>/dev/null | head -1)
  if [ -n "$RECENT" ]; then
    FILENAME=$(basename "$RECENT" .md)
    bash "${PLUGIN_ROOT}/scripts/cks-log.sh" INFO \
      "ideation.standalone.completed" "_project" \
      "Standalone ideation complete: $FILENAME" \
      "{\"file\":\"$RECENT\",\"mode\":\"standalone\"}"
  fi
fi
exit 0
