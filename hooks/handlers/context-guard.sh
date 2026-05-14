#!/bin/bash
# Context window safeguard — warns when approaching 55% auto-compact threshold
# Fires on UserPromptSubmit; injects systemMessage if near limit
# Must exit 0 — non-zero would block the user's message

INPUT=$(cat 2>/dev/null)

# Extract ratio using jq if available, else python3, else skip silently
RATIO="0"
if command -v jq >/dev/null 2>&1; then
  RATIO=$(echo "$INPUT" | jq -r '.context_window_usage_ratio // 0' 2>/dev/null || echo "0")
elif command -v python3 >/dev/null 2>&1; then
  RATIO=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('context_window_usage_ratio', 0))" 2>/dev/null || echo "0")
fi

# Convert to integer percentage
PCT=$(printf "%.0f" "$(echo "$RATIO * 100" | bc -l 2>/dev/null || echo "0")" 2>/dev/null || echo "0")
PCT=${PCT:-0}

if [ "$PCT" -ge 55 ]; then
  # Auto-write shell fallback so HANDOFF.md always exists before the agent runs
  PLUGIN_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
  bash "${PLUGIN_ROOT}/scripts/write-handoff-fallback.sh" >/dev/null 2>&1
  MSG="🛑 CONTEXT AT ${PCT}% — shell handoff auto-written to .prd/HANDOFF.md. STOP current work. Run /cks:handoff for full agent handoff, then tell the user to type /clear to start a fresh session. The new session will auto-load the ⚡ Next Step."
  echo "{\"systemMessage\": \"${MSG}\"}"
elif [ "$PCT" -ge 48 ]; then
  MSG="💡 Context at ${PCT}%. Run /cks:handoff soon — handoff must be written before 55%."
  echo "{\"systemMessage\": \"${MSG}\"}"
fi

exit 0
