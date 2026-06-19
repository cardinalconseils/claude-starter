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
**attractor** skill into the top-level session, which drives the pipeline
through Discover → Plan → ReviewPlan → Implement → Verify → SprintReview → Release →
Learnings → End, enforcing goal gates on Plan, Implement, and Verify.

If `$ARGUMENTS` includes `--role=<role>`, the role hint is passed through to the runner
(see Role Mapping below). If no `--role` is passed, default to `coder`.

## Lifecycle Phase Gates (mandatory — see `.claude/rules/phase-gates.md`)

Before dispatching the attractor runner, check ALL pre-sprint phase artifacts in sequence
and gate each one with `AskUserQuestion`. Never skip a gate. Never decide autonomously.

Read active phase number from `.prd/PRD-STATE.md`, then check artifacts:

```
1. Pre-Flight → .preflight/{NN}-*/PREFLIGHT.md
2. Discover   → .prd/phases/{NN}-*/CONTEXT.md
3. Design     → .prd/phases/{NN}-*/DESIGN.md
4. Sprint     → always runs (it's what /cks:sprint does)
```

Display phase status banner first:
```
┌─── Pre-Sprint Phase Check ──────────────────────────────┐
│  Pre-Flight  {✅ found / ⚠️ missing}  → recommend: {Run/Skip}  │
│  Discover    {✅ found / ⚠️ missing}  → recommend: {Run/Skip}  │
│  Design      {✅ found / ⚠️ missing}  → recommend: {Run/Skip}  │
│  Sprint      → will run now                             │
└─────────────────────────────────────────────────────────┘
```

Then ask per gate in sequence:

**Gate 1 — Pre-Flight:**
```
question: "Pre-Flight: PREFLIGHT.md {✅ found / ⚠️ missing}. Run or skip?"
header: "Pre-Flight Gate"
options:
  - label: "Run /cks:preflight first (Recommended)"   ← when MISSING
    description: "Map dependencies and risks — takes ~5 min, saves hours"
  - label: "Skip — already done (Recommended)"         ← when FOUND
    description: "PREFLIGHT.md exists — pass it to the planner"
  - label: "Sprint without pre-flight"
    description: "Proceed now — accept that unknowns may surface mid-sprint"
```
If user selects "Run /cks:preflight first" → STOP. User must run `/cks:preflight` then re-run `/cks:sprint`.

**Gate 2 — Discover:**
```
question: "Discover: CONTEXT.md {✅ found / ⚠️ missing}. Run or skip?"
header: "Discover Gate"
options:
  - label: "Run /cks:discover first (Recommended)"   ← when MISSING
    description: "Gather requirements before planning — sprint without it is risky"
  - label: "Skip — already done (Recommended)"        ← when FOUND
    description: "CONTEXT.md exists — proceed to sprint"
  - label: "Sprint without discovery"
    description: "Proceed now — accept incomplete requirements"
```
If user selects "Run /cks:discover first" → STOP. User must run `/cks:discover` then re-run `/cks:sprint`.

**Gate 3 — Design:**
```
question: "Design: DESIGN.md {✅ found / ⚠️ missing}. Run or skip?"
header: "Design Gate"
options:
  - label: "Run /cks:design first (Recommended)"   ← when MISSING
    description: "Produce UX flows and component specs before implementation"
  - label: "Skip — already done (Recommended)"      ← when FOUND
    description: "DESIGN.md exists — proceed to sprint"
  - label: "Sprint without design"
    description: "Proceed now — implementation without UX specs"
```
If user selects "Run /cks:design first" → STOP. User must run `/cks:design` then re-run `/cks:sprint`.

After all gates pass (all skipped or stopped-and-rerun), dispatch the runner. Pass PREFLIGHT.md
path if found: `PREFLIGHT.md found at {path} — prd-planner must read it before writing PLAN.md`.

```
Skill(skill="cks:attractor")
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
