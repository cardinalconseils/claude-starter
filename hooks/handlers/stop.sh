#!/bin/bash
# CKS Stop hook — remind about uncommitted changes and session close
# Must output valid JSON or nothing (Claude Code Stop hook requirement)

MESSAGES=""

if git rev-parse --git-dir > /dev/null 2>&1; then
  CHANGES=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  if [ "$CHANGES" -gt 0 ]; then
    MESSAGES="Uncommitted changes: ${CHANGES} file(s). /cks:go commit"
  fi
fi

# Nudge sprint-close if guardrails exist but no session learnings captured today
if [ -d ".claude/rules" ]; then
  RULES_COUNT=$(ls .claude/rules/*.md 2>/dev/null | wc -l | tr -d ' ')
  TODAY=$(date +%Y-%m-%d)
  if [ "$RULES_COUNT" -gt 0 ] && [ ! -f ".learnings/session-${TODAY}.md" ]; then
    if [ -n "$MESSAGES" ]; then
      MESSAGES="${MESSAGES} | No session close today. /cks:sprint-close"
    else
      MESSAGES="No session close today. /cks:sprint-close to audit rules + capture learnings."
    fi
  fi
fi

if [ -n "$MESSAGES" ]; then
  echo "{\"systemMessage\": \"${MESSAGES}\"}"
fi
