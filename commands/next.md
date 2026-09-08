---
description: "Auto-advance to the next logical step in the workflow"
allowed-tools:
  - Read
  - Agent
  - Skill
  - AskUserQuestion
  - Bash
---

# /cks:next — Auto-Advance to Next Step

Read `.prd/PRD-STATE.md` to determine current state, then dispatch the appropriate role.

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

Before routing, if state is "No active phase" or "All phases complete": run these checks in parallel:
```bash
gh issue list --label "cks:factory" --state open --json number,title 2>/dev/null
gh issue list --label "cks:backlog" --state open --json number,title 2>/dev/null
```
If either returns issues → load the factory (see table below).
If `gh` is unavailable or returns empty → fall through to normal routing.

| Current State | Action |
|---|---|
| No `.prd/` | Tell user to run `/cks:bootstrap` or `/cks:kickstart` first |
| No active phase, factory queue not empty | `Skill(skill="cks:github-issues")` — Arguments: `--auto` (Orchestrator Exception: the factory runs the pipeline top-level) |
| No active phase | Tell user to run `/cks:new` to create a feature |
| Status: `discovering` | Dispatch `Agent(subagent_type="cks:strategist", prompt="Mode: discover. Continue Phase 1: Discovery for the active phase. Read .prd/PRD-STATE.md. You MUST use AskUserQuestion interactively — do NOT run in autonomous mode.")` |
| Status: `discovered` | Dispatch `Agent(subagent_type="cks:architect", prompt="Mode: design. Run Phase 2: Design for the active phase. Read .prd/PRD-STATE.md. Read the CONTEXT.md from Phase 1. Read workflows/design-phase.md for step-by-step process. MANDATORY: You MUST use AskUserQuestion at every interactive checkpoint — [2a] UX flow review, [2b] API contract approval, [2d] screen review, [2f] design sign-off. Do NOT skip any checkpoint.")` |
| Status: `designing` | Dispatch `Agent(subagent_type="cks:architect", prompt="Mode: design. Continue Phase 2: Design for the active phase. Read .prd/PRD-STATE.md. MANDATORY: You MUST use AskUserQuestion at every interactive checkpoint — [2a] UX flow review, [2b] API contract approval, [2d] screen review, [2f] design sign-off. Do NOT skip any checkpoint.")` |
| Status: `designed` | Dispatch `Agent(subagent_type="cks:architect", prompt="Mode: plan. Run Phase 3: Sprint planning for the active phase. Read .prd/PRD-STATE.md. Write PLAN.md, then return — implementation is a cks:builder dispatch.")` |
| Status: `sprinting` | Dispatch `Agent(subagent_type="cks:builder", prompt="Mode: implement. Continue Phase 3: Sprint for the active phase. Read .prd/PRD-STATE.md and the phase PLAN.md. Write SUMMARY.md before returning.")` |
| Status: `reviewing` | Dispatch `Agent(subagent_type="cks:tester", prompt="Mode: verify. Continue Phase 4: Review for the active phase. Read .prd/PRD-STATE.md. Write VERIFICATION.md + CONFIDENCE.md before returning.")` |
| Status: `releasing` | Dispatch `Agent(subagent_type="cks:shipper", prompt="Mode: release. Continue Phase 5: Release for the active phase. Read .prd/PRD-STATE.md. Production deploy is gated — confirm before promoting.")` |
| Phase complete, more phases remain | Advance to next phase's discovery |
| All phases complete, factory queue not empty | `Skill(skill="cks:github-issues")` — Arguments: `--auto` |
| All phases complete | Report completion |

This is the "just keep going" command.

## Quick Reference

```
/cks:next     → read PRD-STATE.md, dispatch the role for the current status
```
