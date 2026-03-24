---
description: Verify acceptance criteria for a completed phase
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

# /cks:verify — Verify Phase Acceptance Criteria

Load the workflow instructions from `.claude/skills/prd/workflows/verify-phase.md` and follow them exactly.

## Quick Reference

Launches the **prd-verifier** agent to:
1. Read the phase PLAN.md for acceptance criteria
2. Run tests, check code, verify each criterion
3. Write VERIFICATION.md with pass/fail results
4. Update STATE.md and ROADMAP.md with verification status

## Argument Handling

- No args: Verify the most recently executed phase
- Phase number: Verify that specific phase
