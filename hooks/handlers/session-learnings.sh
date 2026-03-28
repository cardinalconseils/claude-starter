#!/bin/bash
# CKS Session Learnings — captures patterns and context at session end
# Runs as a Stop hook to persist working knowledge across sessions
# This data is re-injected by /cks:sprint-start and the SessionStart hook

PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")
LEARNINGS_DIR="${PROJECT_ROOT}/.learnings"

# Only run if we're in a project with .prd/
if [ ! -d "${PROJECT_ROOT}/.prd" ]; then
  exit 0
fi

# Create learnings directory if needed
mkdir -p "$LEARNINGS_DIR"

DATE=$(date +%Y-%m-%d)
SESSION_FILE="${LEARNINGS_DIR}/session-${DATE}.md"

# Capture session context
BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
CHANGED_FILES=$(git diff --name-only 2>/dev/null | head -20)
STAGED_FILES=$(git diff --cached --name-only 2>/dev/null | head -20)
RECENT_COMMITS=$(git log --since=midnight --oneline 2>/dev/null | head -10)
TODOS=$(grep -rn "TODO\|FIXME\|HACK" ${PROJECT_ROOT}/src ${PROJECT_ROOT}/app ${PROJECT_ROOT}/lib 2>/dev/null | head -10)

# Capture PRD phase for context
PHASE=""
PHASE_NAME=""
if [ -f "${PROJECT_ROOT}/.prd/PRD-STATE.md" ]; then
  PHASE=$(grep "Active Phase:" "${PROJECT_ROOT}/.prd/PRD-STATE.md" 2>/dev/null | sed 's/.*: *//;s/\*//g' | xargs)
  PHASE_NAME=$(grep "Phase Name:" "${PROJECT_ROOT}/.prd/PRD-STATE.md" 2>/dev/null | sed 's/.*: *//;s/\*//g' | xargs)
fi

# Count today's commits
COMMIT_COUNT=$(git log --since=midnight --oneline 2>/dev/null | wc -l | tr -d ' ')
CHANGED_COUNT=$(echo "$CHANGED_FILES" | grep -c . 2>/dev/null || echo 0)
[ -z "$CHANGED_FILES" ] && CHANGED_COUNT=0

# Only write if there's something to capture
if [ "$COMMIT_COUNT" -eq 0 ] && [ "$CHANGED_COUNT" -eq 0 ] && [ -z "$STAGED_FILES" ]; then
  exit 0
fi

# Build a concise one-line summary for quick re-injection
SUMMARY="Branch: ${BRANCH}"
[ -n "$PHASE" ] && SUMMARY="${SUMMARY} | Phase: ${PHASE} ${PHASE_NAME}"
SUMMARY="${SUMMARY} | Commits: ${COMMIT_COUNT} | Uncommitted: ${CHANGED_COUNT} files"

# Append to today's session file
cat >> "$SESSION_FILE" <<EOF

---

## Session $(date +%H:%M) — ${SUMMARY}

**Branch:** ${BRANCH}
**Phase:** ${PHASE:-—} ${PHASE_NAME}

### Commits Today
\`\`\`
${RECENT_COMMITS:-none}
\`\`\`

### Files Changed (unstaged)
\`\`\`
${CHANGED_FILES:-none}
\`\`\`

### Files Staged
\`\`\`
${STAGED_FILES:-none}
\`\`\`

### Open Markers
\`\`\`
${TODOS:-none}
\`\`\`

EOF

# Update .prd/PRD-STATE.md working notes if it exists
if [ -f "${PROJECT_ROOT}/.prd/PRD-STATE.md" ]; then
  # Check if Working Notes section exists
  if ! grep -q "## Working Notes" "${PROJECT_ROOT}/.prd/PRD-STATE.md"; then
    cat >> "${PROJECT_ROOT}/.prd/PRD-STATE.md" <<EOF

## Working Notes

_Auto-captured by CKS session hooks. Persists context across sessions._

| Date | Branch | Files Changed | Key Activity |
|------|--------|---------------|-------------|
EOF
  fi

  # Append today's note
  FILE_COUNT=$(echo "$CHANGED_FILES" | grep -c . 2>/dev/null || echo 0)
  LAST_COMMIT=$(echo "$RECENT_COMMITS" | head -1)
  echo "| ${DATE} | ${BRANCH} | ${FILE_COUNT} files | ${LAST_COMMIT:-no commits} |" >> "${PROJECT_ROOT}/.prd/PRD-STATE.md"
fi

# Maintain .gitignore for learnings
if [ -f "${PROJECT_ROOT}/.gitignore" ]; then
  if ! grep -q ".learnings" "${PROJECT_ROOT}/.gitignore"; then
    echo ".learnings/" >> "${PROJECT_ROOT}/.gitignore"
  fi
fi

exit 0
