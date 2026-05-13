#!/bin/bash
# PreCompact hook — writes HANDOFF.md fallback + injects state into compaction summary
# Output here becomes part of what Claude sees after compaction resumes

PLUGIN_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
HANDOFF_FILE=$(bash "${PLUGIN_ROOT}/scripts/write-handoff-fallback.sh" 2>/dev/null || echo ".prd/HANDOFF.md")

BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
CHANGED=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
PHASE=$(grep "Active Phase:" .prd/PRD-STATE.md 2>/dev/null | sed 's/.*: *//;s/\*//g' | xargs 2>/dev/null)
NEXT=$(grep "Next Action:" .prd/PRD-STATE.md 2>/dev/null | sed 's/.*: *//;s/\*//g' | xargs 2>/dev/null)

echo "=== CKS Session State (pre-compact) ==="
echo "Branch:  ${BRANCH}"
echo "Changes: ${CHANGED} uncommitted file(s)"
[ -n "$PHASE" ] && echo "Phase:   ${PHASE}"
[ -n "$NEXT" ]  && echo "Next:    ${NEXT}"
echo "Handoff: ${HANDOFF_FILE}"
echo "Resume:  /cks:sprint-start to reload full context"
echo "======================================="

exit 0
