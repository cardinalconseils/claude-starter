#!/bin/bash
# CKS Stop hook — remind about uncommitted changes and session close
# Must output valid JSON or nothing (Claude Code Stop hook requirement)

MESSAGES=""

# Check for missing "Next Action" breadcrumb in PRD-STATE — the most common cause of lost context
if [ -f ".prd/PRD-STATE.md" ]; then
  NEXT=$(grep "Next Action:" .prd/PRD-STATE.md | sed 's/.*: *//;s/\*//g' | xargs 2>/dev/null)
  CMD=$(grep "Suggested Command:" .prd/PRD-STATE.md | sed 's/.*: *//;s/\*//g' | xargs 2>/dev/null)
  if [ -z "$NEXT" ] || [ "$NEXT" = "—" ]; then
    CRUMB="⚠ No Next Action set in PRD-STATE.md — next session will have no context. Update it before stopping."
    MESSAGES="${MESSAGES:+${MESSAGES} | }${CRUMB}"
  fi
fi

# Nudge sprint-close if guardrails exist but no session learnings captured today
if [ -d ".claude/rules" ]; then
  RULES_COUNT=$(ls .claude/rules/*.md 2>/dev/null | wc -l | tr -d ' ')
  TODAY=$(date +%Y-%m-%d)
  if [ "$RULES_COUNT" -gt 0 ] && [ ! -f ".learnings/session-${TODAY}.md" ]; then
    MESSAGES="${MESSAGES:+${MESSAGES} | }No session close today. /cks:sprint-close to audit rules + capture learnings."
  fi
fi

if [ -n "$MESSAGES" ]; then
  echo "{\"systemMessage\": \"${MESSAGES}\"}"
fi

# Memory: write session snapshot + sync to DB if control plane active
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
STOP_MEM="$PLUGIN_ROOT/scripts/stop-memory.sh"
[ -x "$STOP_MEM" ] && "$STOP_MEM" 2>/dev/null || true

exit 0
