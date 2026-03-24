#!/bin/bash
# CKS Stop hook — remind about uncommitted changes

if git rev-parse --git-dir > /dev/null 2>&1; then
  CHANGES=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  if [ "$CHANGES" -gt 0 ]; then
    echo "⚠ Uncommitted changes: ${CHANGES} file(s) modified. Consider running /cks:go commit or /cks:ship before closing."
  fi
fi
