---
description: "Auto-advance to the next logical step in the workflow"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
  - Bash
---

# /cks:next — Auto-Advance to Next Step

Read `.prd/PRD-STATE.md` to determine current state, then dispatch the appropriate agent.

## Pre-flight: Commit Gate

Before advancing, run `git status` to check for uncommitted changes. If there are uncommitted files:
```
AskUserQuestion:
  question: "You have {N} uncommitted file(s). Commit before advancing?"
  options:
    - "Yes — commit first, then advance"
    - "No — advance without committing"
```
If the user chooses to commit, run `/cks:go commit` before proceeding.

## State Detection & Routing

| Current State | Action |
|---|---|
| No `.prd/` | Tell user to run `/cks:bootstrap` or `/cks:kickstart` first |
| No active phase | Tell user to run `/cks:new` to create a feature |
| Status: `discovering` | Dispatch `Agent(subagent_type="cks:prd-discoverer", prompt="Continue Phase 1: Discovery for the active phase. Read .prd/PRD-STATE.md. You MUST use AskUserQuestion interactively — do NOT run in autonomous mode.")` |
| Status: `discovered` | Dispatch `Agent(subagent_type="cks:prd-designer", prompt="Run Phase 2: Design for the active phase. Read .prd/PRD-STATE.md. Read the CONTEXT.md from Phase 1. Read workflows/design-phase.md for step-by-step process. MANDATORY: You MUST use AskUserQuestion at every interactive checkpoint — [2a] UX flow review, [2b] API contract approval, [2d] screen review, [2f] design sign-off. Do NOT skip any checkpoint.")` |
| Status: `designing` | Dispatch `Agent(subagent_type="cks:prd-designer", prompt="Continue Phase 2: Design for the active phase. Read .prd/PRD-STATE.md. MANDATORY: You MUST use AskUserQuestion at every interactive checkpoint — [2a] UX flow review, [2b] API contract approval, [2d] screen review, [2f] design sign-off. Do NOT skip any checkpoint.")` |
| Status: `designed` | Dispatch `Agent(subagent_type="cks:prd-planner", prompt="Run Phase 3: Sprint for the active phase. Read .prd/PRD-STATE.md.")` |
| Status: `sprinting` | Dispatch `Agent(subagent_type="cks:prd-planner", prompt="Continue Phase 3: Sprint for the active phase. Read .prd/PRD-STATE.md.")` |
| Status: `reviewing` | Dispatch `Agent(subagent_type="cks:prd-verifier", prompt="Continue Phase 4: Review for the active phase. Read .prd/PRD-STATE.md.")` |
| Status: `releasing` | Dispatch `Agent(subagent_type="cks:deployer", prompt="Continue Phase 5: Release for the active phase. Read .prd/PRD-STATE.md.")` |
| Phase complete, more phases remain | Advance to next phase's discovery |
| All phases complete | Report completion |

This is the "just keep going" command.
