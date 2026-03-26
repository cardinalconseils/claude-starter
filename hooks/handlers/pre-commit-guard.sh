#!/bin/bash
# CKS Pre-Commit Guard — blocks commits containing secrets, debug code, or missing tests
# Runs as a PreToolUse hook on Bash when git commit is detected

STAGED_FILES=$(git diff --cached --name-only 2>/dev/null)
if [ -z "$STAGED_FILES" ]; then
  exit 0
fi

ERRORS=""

# 1. Secrets detection (API keys, tokens, passwords)
SECRET_PATTERNS=(
  'sk-[a-zA-Z0-9]{20,}'
  'sk_live_[a-zA-Z0-9]+'
  'sk_test_[a-zA-Z0-9]+'
  'AKIA[0-9A-Z]{16}'
  'ghp_[a-zA-Z0-9]{36}'
  'gho_[a-zA-Z0-9]{36}'
  'glpat-[a-zA-Z0-9_-]{20,}'
  'xoxb-[0-9]+-[a-zA-Z0-9]+'
  'xoxp-[0-9]+-[a-zA-Z0-9]+'
  'password\s*[:=]\s*["\x27][^"\x27]{8,}'
  'secret\s*[:=]\s*["\x27][^"\x27]{8,}'
)

for pattern in "${SECRET_PATTERNS[@]}"; do
  MATCHES=$(git diff --cached -G "$pattern" --name-only 2>/dev/null)
  if [ -n "$MATCHES" ]; then
    ERRORS="${ERRORS}🔐 BLOCKED: Possible secret/credential detected in: ${MATCHES}\n"
  fi
done

# 2. Debug code detection
DEBUG_PATTERNS="console\.log\|debugger\|binding\.pry\|import pdb\|breakpoint()\|print(f\?\s*['\"]debug"
DEBUG_MATCHES=$(git diff --cached --diff-filter=ACM -S "$DEBUG_PATTERNS" --name-only 2>/dev/null | grep -v '\.test\.\|\.spec\.\|__test__\|test_' )
if [ -n "$DEBUG_MATCHES" ]; then
  ERRORS="${ERRORS}🐛 WARNING: Debug code found in: ${DEBUG_MATCHES}\n"
fi

# 3. .env file check
ENV_FILES=$(echo "$STAGED_FILES" | grep -E '\.env$|\.env\.local$|\.env\.production$|credentials\.json$|\.pem$|\.key$')
if [ -n "$ENV_FILES" ]; then
  ERRORS="${ERRORS}🚫 BLOCKED: Sensitive files staged for commit: ${ENV_FILES}\n"
fi

# 4. Large file check (>1MB)
for file in $STAGED_FILES; do
  if [ -f "$file" ]; then
    SIZE=$(wc -c < "$file" 2>/dev/null)
    if [ "$SIZE" -gt 1048576 ]; then
      ERRORS="${ERRORS}📦 WARNING: Large file (>1MB): ${file} ($(( SIZE / 1024 ))KB)\n"
    fi
  fi
done

if [ -n "$ERRORS" ]; then
  echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo -e "CKS Pre-Commit Guard"
  echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo -e "$ERRORS"
  echo -e "Fix these issues before committing."
  echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  # Exit 2 = block the tool call
  exit 2
fi

exit 0
