---
description: "Phase 3: Sprint Execution — plan, build, review, QA, UAT, merge"
argument-hint: "[phase number] [--role=coder|marketer|analyst|devops]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:sprint — Phase 3: Sprint Execution

Dispatch the **prd-planner** agent for sprint planning, then the **prd-executor** agent for implementation. The sprint workflow orchestrates multiple sub-agents internally.

If `$ARGUMENTS` includes `--role=<role>`, parse it and instruct the dispatched agent to load only that role's skill set (see Role Mapping below). If no `--role` is passed, default to `coder`.

```
Agent(subagent_type="cks:prd-planner", prompt="Run Phase 3: Sprint for the current feature. Read .prd/PRD-STATE.md to identify the active phase. Read the CONTEXT.md and DESIGN.md from previous phases. Read workflows/sprint-phase.md for step-by-step process. Role: {parsed-role-or-coder}. Load only role-appropriate skills. Arguments: $ARGUMENTS")
```

## Role Mapping
- `coder` (default): prd, incremental-implementation, testing-discipline, debug, code-simplification
- `marketer`: ai-marketing, brand-marketing, online-marketing, product-marketing
- `analyst`: repo-exploration, deep-research, observability, monitoring
- `devops`: cicd-starter, shipping-checklist, environment-management, security-hardening, ciso

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

## After Agent Completes

When the sprint agent returns, **always suggest the next step**:

```
Read .prd/PRD-STATE.md to check the current status, then tell the user:

  ✅ Sprint complete for Phase {NN}.
  Next → /cks:review {NN}
  (Run /compact first if the conversation is long)
```

## Argument Handling

- No args: Sprint the current phase from STATE.md
- Phase number: Sprint that specific phase
