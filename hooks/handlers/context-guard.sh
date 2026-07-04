#!/bin/bash
# Blocks user message at 75% context window — instructs user to run /fork
# Fires on UserPromptSubmit; exits 1 at threshold to hard-block the message.
# No noise below 75% — single clean threshold, no graduated warnings.

INPUT=$(cat 2>/dev/null)

RATIO="0"
if command -v jq >/dev/null 2>&1; then
  RATIO=$(echo "$INPUT" | jq -r '.context_window_usage_ratio // 0' 2>/dev/null || echo "0")
elif command -v python3 >/dev/null 2>&1; then
  RATIO=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('context_window_usage_ratio',0))" 2>/dev/null || echo "0")
fi

PCT=$(awk "BEGIN{printf \"%d\", ${RATIO} * 100}" 2>/dev/null || echo "0")
PCT=${PCT:-0}

if [ "$PCT" -ge 75 ]; then
  echo "{\"decision\": \"block\", \"reason\": \"Context at ${PCT}% — run /fork now to branch the session before continuing. After forking, the new branch has a fresh context budget and full history. If /fork is unavailable, run /compact then /clear and resume with /cks:sprint-start.\"}"
  exit 1
fi

exit 0
