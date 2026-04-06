#!/bin/bash
# CKS Complexity Gate — warns before oversized sprints
# PreToolUse hook on Agent dispatch when sprint-related
# Non-blocking warning (exit 0 always)

# Only run if .prd/ exists
if [ ! -d ".prd" ] 2>/dev/null; then
  exit 0
fi

# Find active feature CONTEXT.md
STATE_FILE=".prd/PRD-STATE.md"
if [ ! -f "$STATE_FILE" ] 2>/dev/null; then
  exit 0
fi

ACTIVE_PRD=$(grep "^Active PRD:" "$STATE_FILE" 2>/dev/null | sed 's/Active PRD: *//')
if [ -z "$ACTIVE_PRD" ]; then
  exit 0
fi

CONTEXT=$(find "$ACTIVE_PRD" -name "*-CONTEXT.md" 2>/dev/null | head -1)
if [ -z "$CONTEXT" ] || [ ! -f "$CONTEXT" ]; then
  exit 0
fi

# Count complexity signals
STORIES=$(grep -c "^### US-" "$CONTEXT" 2>/dev/null || echo 0)
CRITERIA=$(grep -c "^\- \[" "$CONTEXT" 2>/dev/null || echo 0)
ENDPOINTS=$(grep -ci "endpoint\|api route\|POST\|GET\|PUT\|DELETE" "$CONTEXT" 2>/dev/null || echo 0)

if [ "$STORIES" -gt 7 ] || [ "$CRITERIA" -gt 20 ] || [ "$ENDPOINTS" -gt 8 ]; then
  echo "⚠ COMPLEXITY: ${STORIES} stories, ${CRITERIA} criteria, ${ENDPOINTS} endpoints — consider splitting"
fi

exit 0
