#!/bin/bash
# CKS Post-Edit Guard — warns about issues after file edits
# Runs as a PostToolUse hook on Edit/Write

FILE_PATH="${1:-}"
if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

WARNINGS=""

# Check for console.log / debug statements in non-test files
if echo "$FILE_PATH" | grep -qE '\.(ts|tsx|js|jsx)$' && ! echo "$FILE_PATH" | grep -qE '\.test\.|\.spec\.|__test__'; then
  CONSOLE_COUNT=$(grep -c 'console\.log' "$FILE_PATH" 2>/dev/null || echo 0)
  if [ "$CONSOLE_COUNT" -gt 0 ]; then
    WARNINGS="${WARNINGS}⚠ ${CONSOLE_COUNT} console.log statement(s) in ${FILE_PATH}\n"
  fi
fi

# Check for TODO/FIXME/HACK markers
MARKER_COUNT=$(grep -cE 'TODO|FIXME|HACK|XXX' "$FILE_PATH" 2>/dev/null || echo 0)
if [ "$MARKER_COUNT" -gt 0 ]; then
  WARNINGS="${WARNINGS}📝 ${MARKER_COUNT} TODO/FIXME marker(s) in ${FILE_PATH}\n"
fi

if [ -n "$WARNINGS" ]; then
  echo -e "$WARNINGS"
fi

exit 0
