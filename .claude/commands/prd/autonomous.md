---
name: prd:autonomous
description: Run all remaining phases autonomously — discuss → plan → execute → verify → ship. No interruption.
argument-hint: "[--from N] [--skip-verify]"
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

# /prd:autonomous — Full Autonomous Cycle

<objective>
Execute all remaining phases autonomously. For each incomplete phase: discuss → plan → execute → verify → commit. After all phases: ship (push → PR → review → deploy → update roadmap). Pauses only for true blockers.
</objective>

<execution_context>
@.claude/skills/prd/workflows/autonomous.md
@.claude/skills/prd/workflows/ship.md
</execution_context>

<process>
Execute the autonomous workflow from `.claude/skills/prd/workflows/autonomous.md` end-to-end.

Includes the ship workflow at the end — commit → push → PR → review → deploy → update roadmap.

Preserve all workflow gates (phase discovery, per-phase execution, verification routing, progress display, shipping).
</process>

## Argument Handling

- No args: Run all remaining phases with verification + ship
- `--from N`: Start from phase N (skip earlier phases)
- `--skip-verify`: Skip verification step (faster, less safe)
