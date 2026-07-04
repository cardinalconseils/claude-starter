#!/bin/bash
# Write minimal session metadata stub to control-plane memory.
# Called from pre-compact.sh and stop.sh — shell layer only, no model dispatch.
# The stub gives the next session a baseline even if /cks:save-context was never run.

SESSION_DIR=".cks/control-plane/memory/sessions"
[ -d ".cks/control-plane" ] || exit 0

mkdir -p "$SESSION_DIR"

DATE=$(date +%Y-%m-%d)
TIME=$(date +%H:%M)
BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
PHASE=$(grep "Active Phase:" .prd/PRD-STATE.md 2>/dev/null | sed 's/.*: *//' | xargs 2>/dev/null)
NEXT=$(grep "Next Action:" .prd/PRD-STATE.md 2>/dev/null | sed 's/.*: *//' | xargs 2>/dev/null)
UNCOMMITTED=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
COMMITS=$(git log --oneline -3 2>/dev/null)

SESSION_FILE="$SESSION_DIR/$DATE.md"

{
  printf "\n## Session %s %s [auto-stub]\n" "$DATE" "$TIME"
  printf "Branch: %s | Phase: %s | Uncommitted: %s\n" "$BRANCH" "${PHASE:-—}" "$UNCOMMITTED"
  printf "Next: %s\n" "${NEXT:-—}"
  if [ -n "$COMMITS" ]; then
    printf "Commits:\n"
    printf "%s\n" "$COMMITS" | sed 's/^/  /'
  fi
} >> "$SESSION_FILE"
