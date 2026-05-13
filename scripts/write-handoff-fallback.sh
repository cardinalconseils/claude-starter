#!/bin/bash
# Write a minimal shell-based HANDOFF.md before compaction.
# Only writes if no agent-written handoff exists from the last 10 minutes.

BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
CHANGED=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
LAST_COMMIT=$(git log --oneline -1 2>/dev/null || echo "no commits")
RECENT=$(git log --oneline -5 2>/dev/null || echo "")

PHASE=""
NEXT=""
if [ -f ".prd/PRD-STATE.md" ]; then
  PHASE=$(grep "Active Phase:" .prd/PRD-STATE.md | sed 's/.*: *//;s/\*//g' | xargs 2>/dev/null)
  NEXT=$(grep "Next Action:" .prd/PRD-STATE.md | sed 's/.*: *//;s/\*//g' | xargs 2>/dev/null)
fi

HANDOFF_DIR=".prd"
[ -d "$HANDOFF_DIR" ] || HANDOFF_DIR="."
HANDOFF_FILE="$HANDOFF_DIR/HANDOFF.md"

# Skip if a fresh handoff already exists (< 10 min old)
if [ -f "$HANDOFF_FILE" ]; then
  AGE=$(( $(date +%s) - $(date -r "$HANDOFF_FILE" +%s 2>/dev/null || echo 0) ))
  [ "$AGE" -lt 600 ] && echo "$HANDOFF_FILE" && exit 0
fi

cat > "$HANDOFF_FILE" <<EOF
# Handoff — $(date '+%Y-%m-%d %H:%M') (auto — pre-compact fallback)

**Branch:** ${BRANCH}  **Phase:** ${PHASE:-unknown}  **Commit:** ${LAST_COMMIT}

## State at Compact
- Uncommitted files: ${CHANGED}
- Next action: ${NEXT:-see .prd/PRD-STATE.md}

## Recent Commits
${RECENT}

## Resume Steps
1. Run: \`/cks:sprint-start\` to reload full context
2. Check \`.prd/PRD-STATE.md\` for active phase

_Shell fallback — run /cks:handoff for a full agent-written handoff._
EOF

echo "$HANDOFF_FILE"
