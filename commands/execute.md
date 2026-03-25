---
description: Implement the next planned phase
argument-hint: "[phase number]"
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

# /cks:execute — Implement a Phase

Load the workflow instructions from `${CLAUDE_PLUGIN_ROOT}/skills/prd/workflows/execute-phase.md` and follow them exactly.

## Quick Reference

Launches the **prd-executor** agent to:
1. Read the PLAN.md for the target phase
2. Confirm scope with the user
3. Implement code changes
4. Write a SUMMARY.md with results
5. Update STATE.md and ROADMAP.md

## Argument Handling

- No args: Execute the next unfinished phase from STATE.md/ROADMAP.md
- Phase number: Execute that specific phase
