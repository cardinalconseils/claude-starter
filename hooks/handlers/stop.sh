#!/bin/bash
# CKS Stop hook — remind about uncommitted changes
# Must output valid JSON or nothing (Claude Code Stop hook requirement)

if git rev-parse --git-dir > /dev/null 2>&1; then
  CHANGES=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  if [ "$CHANGES" -gt 0 ]; then
    # Output JSON with systemMessage for display
    echo "{\"systemMessage\": \"⚠ Uncommitted changes: ${CHANGES} file(s) modified. Consider running /cks:go commit before closing.\"}"
  fi
fi
