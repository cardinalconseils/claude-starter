#!/bin/bash
# CKS SessionStart hook — show kickstart OR PRD status

# Priority 1: Check for kickstart in progress
if [ -f ".kickstart/state.md" ]; then
  KICKSTART_LAST=$(grep "last_phase:" .kickstart/state.md 2>/dev/null | sed 's/.*: *//' | xargs)
  if [ "$KICKSTART_LAST" != "complete" ] && [ -n "$KICKSTART_LAST" ]; then
    KICKSTART_NAME=$(grep "last_phase_name:" .kickstart/state.md | sed 's/.*: *//' | xargs)
    KICKSTART_STATUS=$(grep "last_phase_status:" .kickstart/state.md | sed 's/.*: *//' | xargs)

    # Count completed phases from progress table
    DONE_COUNT=$(grep -c "| done |" .kickstart/state.md 2>/dev/null || echo 0)
    SKIPPED_COUNT=$(grep -c "| skipped |" .kickstart/state.md 2>/dev/null || echo 0)
    TOTAL=$((DONE_COUNT + SKIPPED_COUNT))

    cat <<EOF
📍 CKS Session Resume — KICKSTART IN PROGRESS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Phase:   ${KICKSTART_LAST} — ${KICKSTART_NAME}
Status:  ${KICKSTART_STATUS}
Done:    ${TOTAL}/8 phases
Run:     /cks:kickstart (will resume from Phase ${KICKSTART_LAST})
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
    exit 0
  fi
fi

# Priority 2: Show PRD phase status
if [ -f ".prd/PRD-STATE.md" ]; then
  # Extract key fields, strip markdown bold markers
  PHASE=$(grep "Active Phase:" .prd/PRD-STATE.md | sed 's/.*: *//;s/\*//g' | xargs)
  PHASE_NAME=$(grep "Phase Name:" .prd/PRD-STATE.md | sed 's/.*: *//;s/\*//g' | xargs)
  STATUS=$(grep "Phase Status:" .prd/PRD-STATE.md | sed 's/.*: *//;s/\*//g' | xargs)
  LAST=$(grep "Last Action:" .prd/PRD-STATE.md | head -1 | sed 's/.*: *//;s/\*//g' | xargs)
  LAST_DATE=$(grep "Last Action Date:" .prd/PRD-STATE.md | sed 's/.*: *//;s/\*//g' | xargs)
  NEXT=$(grep "Next Action:" .prd/PRD-STATE.md | sed 's/.*: *//;s/\*//g' | xargs)
  CMD=$(grep "Suggested Command:" .prd/PRD-STATE.md | sed 's/.*: *//;s/\*//g' | xargs)

  cat <<EOF
📍 CKS Session Resume
━━━━━━━━━━━━━━━━━━━━
Phase:   ${PHASE} — ${PHASE_NAME}
Status:  ${STATUS}
Last:    ${LAST} (${LAST_DATE})
Next:    ${NEXT}
Run:     ${CMD}
━━━━━━━━━━━━━━━━━━━━
EOF
fi
