# Workflow: Review Phase (Phase 4) — Orchestrator

<purpose>
Orchestrates sprint review, retrospective, backlog refinement, and the critical
iteration decision that routes back to the correct phase or forward to release.
Each sub-step is a separate file — Read it, then execute its instructions.
</purpose>

## Pre-Conditions
- Phase has completed Sprint (phase_status = "sprinted")
- PR exists from Sprint [3g]

## Invocation

### Load shared context
Read `${SKILL_ROOT}/workflows/review-phase/_shared.md` — banner templates and variables.
Read `.prd/PRD-STATE.md` — extract `{NN}`, `{name}`, `{iteration_count}`.

### Step 0: Initialize Review
Read `${SKILL_ROOT}/workflows/review-phase/step-0-init.md`
Execute its instructions (phase mode, progress banner).

### Step 1: Determine Target Phase
Read `${SKILL_ROOT}/workflows/review-phase/step-1-target.md`
Execute its instructions.

---

### Sub-step [4a]: Sprint Review
Read `${SKILL_ROOT}/workflows/review-phase/step-4a-sprint-review.md`
Execute its instructions.

### Sub-step [4b]: Retrospective
Read `${SKILL_ROOT}/workflows/review-phase/step-4b-retrospective.md`
Execute its instructions.

### Sub-step [4c]: Backlog Refinement
Read `${SKILL_ROOT}/workflows/review-phase/step-4c-backlog.md`
Execute its instructions.

### Sub-step [4d]: Iteration Decision
Read `${SKILL_ROOT}/workflows/review-phase/step-4d-iteration.md`
Execute its instructions.

---

### Step 5: Completion Banner & Context Reset
Read `${SKILL_ROOT}/workflows/review-phase/step-5-complete.md`
Execute its instructions.

**Do NOT chain to the next workflow via Skill().** Stop here.

## Post-Conditions
- `.prd/phases/{NN}-{name}/{NN}-REVIEW.md` exists (feedback + retro)
- `.prd/phases/{NN}-{name}/{NN}-BACKLOG.md` exists (if items identified)
- PRD-STATE.md updated with iteration decision
- PRD-ROADMAP.md updated
- `.learnings/` updated (if retro skill available)
