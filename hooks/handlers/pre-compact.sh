#!/bin/bash
# PreCompact hook — injects session state into compaction summary
# Output here becomes part of what Claude sees after compaction resumes

BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
CHANGED=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')

PHASE=""
NEXT=""
if [ -f ".prd/PRD-STATE.md" ]; then
  PHASE=$(grep "Active Phase:" .prd/PRD-STATE.md | sed 's/.*: *//;s/\*//g' | xargs 2>/dev/null)
  NEXT=$(grep "Next Action:" .prd/PRD-STATE.md | sed 's/.*: *//;s/\*//g' | xargs 2>/dev/null)
fi

echo "=== CKS Session State (pre-compact) ==="
echo "Branch:  ${BRANCH}"
echo "Changes: ${CHANGED} uncommitted file(s)"
[ -n "$PHASE" ] && echo "Phase:   ${PHASE}"
[ -n "$NEXT" ]  && echo "Next:    ${NEXT}"
echo "Resume:  /cks:sprint-start to reload full context"
echo "======================================="

exit 0
