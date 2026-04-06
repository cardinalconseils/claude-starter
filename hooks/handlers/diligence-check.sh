#!/bin/bash
# CKS Diligence Check — after sprint agent completes, flag if diligence review needed
# SubagentStop hook — advisory only (exit 0 always)

# Only relevant if .prd/ exists
if [ ! -d ".prd" ] 2>/dev/null; then
  exit 0
fi

STATE_FILE=".prd/PRD-STATE.md"
if [ ! -f "$STATE_FILE" ] 2>/dev/null; then
  exit 0
fi

# Check if we just finished a sprint phase
PHASE_STATUS=$(grep "^Phase Status:" "$STATE_FILE" 2>/dev/null | sed 's/Phase Status: *//')
PHASE_NAME=$(grep "^Phase Name:" "$STATE_FILE" 2>/dev/null | sed 's/Phase Name: *//')

if echo "$PHASE_NAME" | grep -qi "sprint" 2>/dev/null; then
  if echo "$PHASE_STATUS" | grep -qi "sprinted\|completed" 2>/dev/null; then
    echo "💡 Sprint complete — run /cks:audit --diligence for quality review"
  fi
fi

exit 0
