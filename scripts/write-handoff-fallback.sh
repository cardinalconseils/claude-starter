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
HANDOFF_LATEST="$HANDOFF_DIR/HANDOFF.md"

# Skip if a fresh handoff already exists (< 10 min old)
if [ -f "$HANDOFF_LATEST" ]; then
  AGE=$(( $(date +%s) - $(date -r "$HANDOFF_LATEST" +%s 2>/dev/null || echo 0) ))
  [ "$AGE" -lt 600 ] && echo "$HANDOFF_LATEST" && exit 0
fi

# Build unique filename: .prd/handoffs/HANDOFF-YYYY-MM-DD-HHMM-{branch-slug}.md
TIMESTAMP=$(TZ=America/New_York date '+%Y-%m-%d-%H%M' 2>/dev/null || date '+%Y-%m-%d-%H%M')
BRANCH_SLUG=$(echo "$BRANCH" | tr '/' '-' | tr '[:upper:]' '[:lower:]' | cut -c1-30)
mkdir -p "$HANDOFF_DIR/handoffs"
HANDOFF_UNIQUE="$HANDOFF_DIR/handoffs/HANDOFF-${TIMESTAMP}-${BRANCH_SLUG}.md"

CONTENT=$(cat <<EOF
# Handoff — $(TZ=America/New_York date '+%Y-%m-%d %H:%M EST' 2>/dev/null || date '+%Y-%m-%d %H:%M') (auto — pre-compact fallback)

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
)

echo "$CONTENT" > "$HANDOFF_UNIQUE"
echo "$CONTENT" > "$HANDOFF_LATEST"

echo "$HANDOFF_UNIQUE"
