#!/bin/bash
# CKS Auto-Lint — runs linter after Edit/Write on source files
# PostToolUse hook — warns only, never blocks (exit 0 always)

FILE_PATH="${1:-}"
if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Only lint source files
case "$FILE_PATH" in
  *.ts|*.tsx|*.js|*.jsx) ;;
  *.py) ;;
  *.rs) ;;
  *.go) ;;
  *) exit 0 ;;
esac

# Skip test/config files
case "$FILE_PATH" in
  *.test.*|*.spec.*|*__test__*|*test_*) exit 0 ;;
  *.config.*|*.json|*.md) exit 0 ;;
esac

# Detect and run linter (quick, non-blocking)
if [ -f "package.json" ]; then
  LINT_CMD=$(node -e "try{console.log(JSON.parse(require('fs').readFileSync('package.json')).scripts.lint||'')}catch(e){}" 2>/dev/null)
  if [ -n "$LINT_CMD" ]; then
    npx --no-install eslint "$FILE_PATH" --max-warnings 0 2>/dev/null || echo "LINT: Issues in $FILE_PATH — run 'npm run lint' to see details"
  fi
elif [ -f "pyproject.toml" ] && command -v ruff >/dev/null 2>&1; then
  ruff check "$FILE_PATH" 2>/dev/null || echo "LINT: Issues in $FILE_PATH — run 'ruff check' to see details"
fi

exit 0
