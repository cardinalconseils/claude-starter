---
description: Write PRD and execution plan for a phase
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

# /cks:plan — Write PRD + Update Roadmap

Load the workflow instructions from `${CLAUDE_PLUGIN_ROOT}/skills/prd/workflows/plan-phase.md` and follow them exactly.

## Quick Reference

Launches the **prd-planner** agent to:
1. Read the CONTEXT.md from discovery
2. Write a PRD document in `docs/prds/`
3. Create an execution plan (PLAN.md) in the phase directory
4. Update ROADMAP.md with phases and success criteria

## Argument Handling

- No args: Plan the current phase from STATE.md
- Phase number: Plan that specific phase
