#!/bin/bash
# Pre-commit integrity check — runs fast validation on plugin cross-references
# Blocks commit if any hard failures found (broken agent refs, missing skills, etc.)

INPUT=$(cat 2>/dev/null)
TOOL_NAME=$(printf '%s' "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_name',''))" 2>/dev/null)
case "$TOOL_NAME" in ""|Bash) ;; *) exit 0 ;; esac
COMMAND=$(printf '%s' "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('command',''))" 2>/dev/null)
case "$COMMAND" in *"git commit"*) ;; *) exit 0 ;; esac

PLUGIN_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SCRIPT="$PLUGIN_ROOT/scripts/test-integrity.sh"

# Only run if staged files include plugin structure files
STAGED=$(git diff --cached --name-only 2>/dev/null)
if ! echo "$STAGED" | grep -qE '^(commands|agents|skills|hooks)/'; then
  exit 0
fi

if [ ! -f "$SCRIPT" ]; then
  exit 0
fi

OUTPUT=$(bash "$SCRIPT" --quick 2>&1)
EXIT_CODE=$?

if [ "$EXIT_CODE" -ne 0 ]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "CKS Integrity Check — FAILED"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "$OUTPUT" | grep '❌'
  echo ""
  echo "Run: bash scripts/test-integrity.sh --verbose"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  exit 2
fi

exit 0
