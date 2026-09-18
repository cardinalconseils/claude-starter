---
description: "Enter the Attractor sprint pipeline — Preflight → Discover → Plan → Implement → Verify → Sprint Review → Release → Learnings"
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

Loads the attractor orchestrator (Orchestrator Exception, `.claude/rules/commands.md`) which runs
`pipelines/sprint.dot`: Preflight → Discover → Plan → ReviewPlan → Implement → Verify → SprintReview →
Release → CreatePR → ReviewAndTest → BrowserUAT → AutoMerge → Learnings → End (goal gates on Plan,
Implement, Verify). `--role=<role>` (default `coder`) is passed through to the runner.

## Pre-sprint phase gates (mandatory — `.claude/rules/phase-gates.md`, `.claude/rules/preflight.md`)

Read `active_phase` from `.prd/PRD-STATE.md`; glob `.preflight/{NN}-*/PREFLIGHT.md` (+ its verdict),
`.prd/phases/{NN}-*/CONTEXT.md`, `.prd/phases/{NN}-*/DESIGN.md`. Print the phase status banner from
`phase-gates.md` (rows 1–3: path, ✅/⚠️, recommend; row 4 Sprint → runs now), then gate each phase in
sequence with `AskUserQuestion`. Never skip a gate. Never decide autonomously.

**Gate 1 — Pre-Flight** (`header: "Phase 1 Gate"`). Missing or verdict `NO` → options
`Run pre-flight (Recommended)` / `Stop — I'll come back`. Found with verdict `YES` →
`Skip — already done (Recommended)` / `Re-run pre-flight`. There is no "sprint without pre-flight".
On Run / Re-run, dispatch inline and continue:
`Agent(subagent_type="cks:architect", prompt="Mode: preflight — feature {slug}, phase {NN}. Read skills/agile-eagle/workflows/preflight.md; write .preflight/{NN}-{slug}/PREFLIGHT.md; return the Cleared for takeoff verdict.")`
Re-read the verdict from disk: `NO` → `▶ ACTION REQUIRED` naming each BLOCK gotcha, `Then: re-run /cks:preflight {NN}`; stop. Stop → end here.

**Gate 2 — Discover** (`header: "Phase 2 Gate"`). Missing → `Run /cks:discover first (Recommended)`
(stop; user re-runs `/cks:sprint`) / `Sprint without discovery`. Found → `Skip — already done (Recommended)`.

**Gate 3 — Design** (`header: "Phase 3 Gate"`). Same shape with `/cks:design` and DESIGN.md.

After the gates: `Skill(skill="cks:attractor")` with `Role hint: {role}`, `Args: $ARGUMENTS`, and `PREFLIGHT gate: passed at {path}
— the architect (plan mode) must read it before writing PLAN.md` so the pipeline's `Preflight` node does not ask again.

## Role Mapping
- `coder` (default): prd, incremental-implementation, testing-discipline, debug, code-simplification
- `marketer`: ai-marketing, brand-marketing, online-marketing, product-marketing
- `analyst`: repo-exploration, deep-research, observability, monitoring
- `devops`: cicd-starter, shipping-checklist, environment-management, security-hardening, ciso

## After Pipeline Completes
Read `.prd/PRD-STATE.md`, print `✅ Sprint complete for Phase {NN}. Next → /cks:review {NN}` (suggest `/compact` first if long).

## Quick Reference
- `/cks:sprint` — sprint the current phase from PRD-STATE.md · `/cks:sprint 03` — that phase
- `/cks:sprint --resume | --start-at <node> | --dry-run | --auto | --role=devops`
