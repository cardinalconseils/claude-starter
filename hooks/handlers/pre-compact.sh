#!/bin/bash
# PreCompact hook — writes HANDOFF.md fallback + auto-stubs session memory + injects save instruction
# Output here becomes part of what Claude sees before compaction runs

PLUGIN_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
HANDOFF_FILE=$(bash "${PLUGIN_ROOT}/scripts/write-handoff-fallback.sh" 2>/dev/null || echo ".prd/HANDOFF.md")

# Write minimal session metadata stub deterministically (no model required)
SAVE_STUB="$PLUGIN_ROOT/scripts/session-memory-save.sh"
[ -x "$SAVE_STUB" ] && "$SAVE_STUB" 2>/dev/null || true

BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
CHANGED=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
PHASE=$(grep "Active Phase:" .prd/PRD-STATE.md 2>/dev/null | sed 's/.*: *//;s/\*//g' | xargs 2>/dev/null)
NEXT=$(grep "Next Action:" .prd/PRD-STATE.md 2>/dev/null | sed 's/.*: *//;s/\*//g' | xargs 2>/dev/null)
SESSION_DATE=$(date +%Y-%m-%d)

echo "=== CKS Session State (pre-compact) ==="
echo "Branch:  ${BRANCH}"
echo "Changes: ${CHANGED} uncommitted file(s)"
[ -n "$PHASE" ] && echo "Phase:   ${PHASE}"
[ -n "$NEXT" ]  && echo "Next:    ${NEXT}"
echo "Handoff: ${HANDOFF_FILE}"
echo "Resume:  /cks:sprint-start to reload full context"
echo "======================================="
echo ""
echo "MEMORY SAVE REQUIRED: A metadata stub was auto-written to .cks/control-plane/memory/sessions/${SESSION_DATE}.md."
echo "Before compacting, review this session and append any decisions, dead ends, or next steps to that file."
echo "Format: ## [HH:MM] {topic} with Decision: / Why: / Next: fields. Skip chatter."

exit 0
