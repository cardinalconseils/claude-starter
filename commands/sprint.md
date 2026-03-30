---
description: "Phase 3: Sprint Execution — plan, build, review, QA, UAT, merge"
argument-hint: "[phase number]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:sprint — Phase 3: Sprint Execution

Dispatch the **prd-planner** agent for sprint planning, then the **prd-executor** agent for implementation. The sprint workflow orchestrates multiple sub-agents internally.

```
Agent(subagent_type="prd-planner", prompt="Run Phase 3: Sprint for the current feature. Read .prd/PRD-STATE.md to identify the active phase. Read the CONTEXT.md and DESIGN.md from previous phases. Read workflows/sprint-phase.md for step-by-step process. Arguments: $ARGUMENTS")
```

## Quick Reference

Orchestrates the full sprint cycle from planning through merge:

```
[3a]  Sprint Planning        — backlog, estimates, sprint goal
[3a+] Secrets Pre-Conditions — inject unresolved secrets into plan
[3b]  Design & Architecture  — TDD (technical design document)
[3b+] Secrets Gate           — verify secrets before implementation
[3c]  Implementation         — code it (prd-executor agent)
[3c+] De-Sloppify            — remove debug artifacts, dead code
[3d]  Code Review             — guardrails check + peer review
[3e]  QA Validation           — unit + integration + E2E + Newman API contract tests
[3f]  UAT                     — stakeholder validation
[3g]  Merge to Main           — commit + PR
[3h]  Documentation Check     — auto-detect and update API docs
```

## Argument Handling

- No args: Sprint the current phase from STATE.md
- Phase number: Sprint that specific phase
