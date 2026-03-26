---
description: "Phase 3: Sprint Execution — plan, build, review, QA, UAT, merge"
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

# /cks:sprint — Phase 3: Sprint Execution

Load the workflow instructions from `${CLAUDE_PLUGIN_ROOT}/skills/prd/workflows/sprint-phase.md` and follow them exactly.

## Quick Reference

Orchestrates the full sprint cycle from planning through merge:

```
[3a] Sprint Planning        — backlog, estimates, sprint goal
[3b] Design & Architecture  — TDD (technical design document)
[3c] Implementation         — code it (prd-executor agent)
[3d] Code Review            — peer review
[3e] QA Validation          — unit + integration + E2E tests
[3f] UAT                    — stakeholder validation
[3g] Merge to Main          — PR + merge
```

## Argument Handling

- No args: Sprint the current phase from STATE.md
- Phase number: Sprint that specific phase
