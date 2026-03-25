---
description: Show project progress and route to the next action
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - Agent
  - WebSearch
  - WebFetch
  - Skill
  - AskUserQuestion
  - TodoRead
  - TodoWrite
  - "mcp__*"
---

# /cks:progress — Show Status + Route to Next Action

Load the workflow instructions from `${CLAUDE_PLUGIN_ROOT}/skills/prd/workflows/progress.md` and follow them exactly.

## Quick Reference

Reads project state and displays:
1. Overall project progress (phases complete / total)
2. Current phase status and what's been done
3. What the next logical action is
4. Suggested command to run next

This is the "where am I?" command — it never modifies state, only reads and reports.
