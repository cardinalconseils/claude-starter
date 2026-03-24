---
name: monetize
description: "Run full monetization evaluation: discover -> research -> evaluate -> report -> roadmap"
argument-hint: "[path | \"description\"] (optional)"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - Agent
  - Skill
  - AskUserQuestion
  - TodoRead
  - TodoWrite
  - WebSearch
  - WebFetch
  - "mcp__*"
---

# /monetize — Full Monetization Evaluation

<objective>
Run the complete monetization evaluation flow. Detect input mode, gather context,
research market, score models, generate business case, update roadmap, and hand off to PRD.
</objective>

<execution_context>
@.claude/skills/monetize/SKILL.md
</execution_context>

<process>
Read the SKILL.md and execute the full flow as described.
Use `$ARGUMENTS` to determine input mode.
</process>
