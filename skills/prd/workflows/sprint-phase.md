# Workflow: Sprint Phase (Phase 3) — Orchestrator

<purpose>
Orchestrates full sprint execution via chunked sub-steps.
Each sub-step is a separate file — Read it, then execute its instructions.
Produces source code, tests, PRD document, and a merge-ready PR.
Pipeline: planning → architecture → implementation → review → QA → UAT → merge.
</purpose>

## Pre-Conditions
- `.prd/phases/{NN}-{name}/{NN}-DESIGN.md` exists (if not, redirect to `/cks:design`)
- `.prd/phases/{NN}-{name}/{NN}-CONTEXT.md` exists
- `.prd/` state files exist

## Invocation

### Load shared context
Read `${SKILL_ROOT}/workflows/sprint-phase/_shared.md` — banner templates and variables.
Read `.prd/PRD-STATE.md` — extract `{NN}`, `{name}`, `{phase_status}`, `{iteration_count}`.

### Step 0: Initialize Sprint
Read `${SKILL_ROOT}/workflows/sprint-phase/step-0-init.md`
Execute its instructions (auto mode tip, iteration detection, phase mode, progress banner).

### Step 1: Determine Target Phase
Read `${SKILL_ROOT}/workflows/sprint-phase/step-1-target.md`
Execute its instructions.

### Step 2: Check Sprint Resume
Read `${SKILL_ROOT}/workflows/sprint-phase/step-2-resume.md`
Execute its instructions.

---

### Sub-step [3a]: Sprint Planning
Read `${SKILL_ROOT}/workflows/sprint-phase/step-3a-planning.md`
Execute its instructions.

### Sub-step [3a+]: Secrets Pre-Conditions
Read `${SKILL_ROOT}/workflows/sprint-phase/step-3a-secrets.md`
Execute its instructions.

### Sub-step [3b]: Design & Architecture
Read `${SKILL_ROOT}/workflows/sprint-phase/step-3b-architecture.md`
Execute its instructions.

### Sub-step [3b+]: Secrets Gate
Read `${SKILL_ROOT}/workflows/sprint-phase/step-3b-secrets-gate.md`
Execute its instructions.

### Sub-step [3c]: Implementation
Read `${SKILL_ROOT}/workflows/sprint-phase/step-3c-implementation.md`
Execute its instructions.

### Sub-step [3c+]: De-Sloppify
Read `${SKILL_ROOT}/workflows/sprint-phase/step-3c-desloppify.md`
Execute its instructions.

### Sub-step [3d]: Code Review
Read `${SKILL_ROOT}/workflows/sprint-phase/step-3d-review.md`
Execute its instructions.

### Sub-step [3e]: QA Validation
Read `${SKILL_ROOT}/workflows/sprint-phase/step-3e-qa.md`
Execute its instructions.

### Sub-step [3f]: UAT
Read `${SKILL_ROOT}/workflows/sprint-phase/step-3f-uat.md`
Execute its instructions.

### Sub-step [3g]: Merge to Main
Read `${SKILL_ROOT}/workflows/sprint-phase/step-3g-merge.md`
Execute its instructions.

### Sub-step [3h]: Documentation Check
Read `${SKILL_ROOT}/workflows/sprint-phase/step-3h-docs.md`
Execute its instructions.

---

### Step 4: Update State
Read `${SKILL_ROOT}/workflows/sprint-phase/step-4-state.md`
Execute its instructions.

### Step 5: Sprint Review & Verdict
Read `${SKILL_ROOT}/workflows/sprint-phase/step-5-complete.md`
Execute its instructions. This collects the user's verdict: ship, iterate, or full review.

### Step 6: Ship (conditional — only if user chose "Ship it" in Step 5)
Read `${SKILL_ROOT}/workflows/sprint-phase/step-6-ship.md`
Execute its instructions. Merges PR, bumps version, tags, updates changelog and state.

**If user chose iterate or full review in Step 5, skip Step 6 and stop.**

## Post-Conditions

**Always (after Step 5):**
- `.prd/phases/{NN}-{name}/{NN}-REVIEW.md` exists (inline verdict)
- `docs/prds/PRD-{NNN}-{name}.md` exists
- `.prd/phases/{NN}-{name}/{NN}-PLAN.md` exists
- `.prd/phases/{NN}-{name}/{NN}-TDD.md` exists
- `.prd/phases/{NN}-{name}/{NN}-SUMMARY.md` exists
- `.prd/phases/{NN}-{name}/{NN}-VERIFICATION.md` exists
- Code committed and PR created
- PRD-STATE.md and PRD-ROADMAP.md updated
- API docs updated if endpoints changed (auto via [3h])

**If user chose "Ship it" (after Step 6):**
- PR merged to main
- Version bumped (if bump script exists)
- CHANGELOG.md updated
- Git tag created
- PRD-STATE.md phase_status = released
