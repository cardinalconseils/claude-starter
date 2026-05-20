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
CP_CONFIG=".cks/control-plane/config.yaml"
# Phase 3: Release registry + sync session end
if [ -f "$CP_CONFIG" ]; then
  REGISTRY_SCRIPT="$PLUGIN_ROOT/scripts/agent-registry.sh"
  if [ -n "${CKS_SESSION_ID:-}" ] && [ -x "$REGISTRY_SCRIPT" ]; then
    "$REGISTRY_SCRIPT" release "$CKS_SESSION_ID" 2>/dev/null || true
    SYNC_SCRIPT="$PLUGIN_ROOT/scripts/sync-agent-sessions.sh"
    [ -x "$SYNC_SCRIPT" ] && "$SYNC_SCRIPT" end "$CKS_SESSION_ID" 2>/dev/null || true
  fi
fi
# Phase 4: Observability stop
OBS_STOP="$PLUGIN_ROOT/scripts/observability-stop.sh"
[ -x "$OBS_STOP" ] && "$OBS_STOP" 2>/dev/null || true
# Phase 5: Improvements sync
SYNC_IMP="$PLUGIN_ROOT/scripts/improvements-sync.sh"
[ -x "$SYNC_IMP" ] && "$SYNC_IMP" 2>/dev/null || true
# Phase 6: Drain queue if non-empty
DRAIN="$PLUGIN_ROOT/scripts/control-plane-drain.sh"
QUEUE_DEPTH=$(ls ".cks/control-plane/sync-queue/"*.json 2>/dev/null | wc -l | tr -d ' ')
[ "${QUEUE_DEPTH:-0}" -gt 0 ] && [ -x "$DRAIN" ] && "$DRAIN" 2>/dev/null || true
STOP_MEM="$PLUGIN_ROOT/scripts/stop-memory.sh"
[ -x "$STOP_MEM" ] && "$STOP_MEM" 2>/dev/null || true

exit 0
