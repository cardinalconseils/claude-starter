---
description: "Enter the Attractor sprint pipeline — Discover → Plan → Implement → Verify → Sprint Review → Release → Learnings"
argument-hint: "[--resume] [--start-at <node>] [--dry-run] [--auto] [--role=coder|marketer|analyst|devops]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
  - EnterPlanMode
  - ExitPlanMode
  - EnterWorktree
  - ExitWorktree
  - TodoRead
  - TodoWrite
  - Bash
  - Write
  - Glob
  - Grep
---

# /cks:sprint — Attractor Sprint Pipeline

Enters the full CKS sprint lifecycle defined in `pipelines/sprint.dot`. Loads the
**attractor-orchestrator** skill into the top-level session, which drives the pipeline
through Discover → Plan → ReviewPlan → Implement → Verify → SprintReview → Release →
Learnings → End, enforcing goal gates on Plan, Implement, and Verify.

If `$ARGUMENTS` includes `--role=<role>`, the role hint is passed through to the runner
(see Role Mapping below). If no `--role` is passed, default to `coder`.

## Pre-Flight Check

Before dispatching the runner, check for a PREFLIGHT.md artifact:

```bash
# Read active phase from .prd/PRD-STATE.md
# Look for .preflight/{NN}-*/PREFLIGHT.md
```

- **Found** → pass path to runner: `PREFLIGHT.md found at {path} — prd-planner must read it before writing PLAN.md`
- **Not found** → show suggestion block:

```
· · · · · · · · · · · · · · · · · · · · · · · ·
💡 SUGGESTION
· · · · · · · · · · · · · · · · · · · · · · · ·
No PRE-FLIGHT map found for this feature.
Run /cks:preflight first to map dependencies, risks,
and phase order before the sprint begins.
Proceeding without it — but surprises are on you.
· · · · · · · · · · · · · · · · · · · · · · · ·
```

Then dispatch regardless — the suggestion is advisory, never a gate.

```
Skill(skill="cks:attractor-orchestrator")
```

Role hint: `{parsed-role-or-coder}` (if `--role` passed). PREFLIGHT context: `{path if found}`. Args: `$ARGUMENTS`.

## Role Mapping
- `coder` (default): prd, incremental-implementation, testing-discipline, debug, code-simplification
- `marketer`: ai-marketing, brand-marketing, online-marketing, product-marketing
- `analyst`: repo-exploration, deep-research, observability, monitoring
- `devops`: cicd-starter, shipping-checklist, environment-management, security-hardening, ciso

## Quick Reference

Orchestrates the full sprint cycle from planning through learnings via the Attractor pipeline:

```
Discover      — gather and clarify requirements (CONTEXT.md)
Plan          — produce PRD + PLAN.md [goal gate]
ReviewPlan    — human approval gate before implementation
Implement     — execute the plan (prd-executor) [goal gate]
Verify        — run tests + check acceptance criteria [goal gate]
SprintReview  — human checkpoint before release
Release       — version bump + CHANGELOG
CreatePR      — push branch + open GitHub PR
ReviewAndTest — code review + test run
BrowserUAT    — visual + UX testing in browser
AutoMerge     — merge PR + remove worktree
Learnings     — capture sprint outcome to wiki
```

## After Pipeline Completes

When the sprint pipeline finishes, **always suggest the next step**:

```
Read .prd/PRD-STATE.md to check the current status, then tell the user:

  ✅ Sprint complete for Phase {NN}.
  Next → /cks:review {NN}
  (Run /compact first if the conversation is long)
```

## Argument Handling

- No args: Sprint the current phase from STATE.md
- Phase number: Sprint that specific phase
