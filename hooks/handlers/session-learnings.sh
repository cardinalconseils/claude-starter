#!/bin/bash
# CKS Session Learnings — captures patterns and context at session end
# Runs as a Stop hook to persist working knowledge across sessions

PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")
LEARNINGS_DIR="${PROJECT_ROOT}/.cks-learnings"

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
RECENT_COMMITS=$(git log --oneline -5 2>/dev/null)
TODOS=$(grep -rn "TODO\|FIXME\|HACK" ${PROJECT_ROOT}/src ${PROJECT_ROOT}/app ${PROJECT_ROOT}/lib 2>/dev/null | head -10)

# Only write if there's something to capture
if [ -z "$CHANGED_FILES" ] && [ -z "$STAGED_FILES" ]; then
  exit 0
fi

# Append to today's session file
cat >> "$SESSION_FILE" <<EOF

---

## Session $(date +%H:%M)

**Branch:** ${BRANCH}

### Files Changed (unstaged)
\`\`\`
${CHANGED_FILES:-none}
\`\`\`

### Files Staged
\`\`\`
${STAGED_FILES:-none}
\`\`\`

### Recent Commits
\`\`\`
${RECENT_COMMITS:-none}
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
  if ! grep -q ".cks-learnings" "${PROJECT_ROOT}/.gitignore"; then
    echo ".cks-learnings/" >> "${PROJECT_ROOT}/.gitignore"
  fi
fi

exit 0
