---
name: discuss
description: Interactive discovery session for a feature or phase
argument-hint: "[phase number or feature name]"
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

# /cks:discuss — Interactive Feature Discovery

Load the workflow instructions from `.claude/skills/prd/workflows/discuss-phase.md` and follow them exactly.

## Quick Reference

Launches the **prd-discoverer** agent for interactive requirements gathering. Produces a CONTEXT.md file in the phase directory.

## Argument Handling

- No args: Detect the current phase from STATE.md and discuss it
- Phase number (e.g., `1`, `01`): Discuss that specific phase
- Feature name: Start new feature discovery with that as the brief
