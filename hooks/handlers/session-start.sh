#!/bin/bash
# CKS SessionStart hook — show PRD status if .prd/ exists

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
