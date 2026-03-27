# Workflow: Discover Phase (Phase 1) — Orchestrator

<purpose>
Orchestrates the 10 Elements of Discovery via chunked sub-steps.
Each sub-step is a separate file — Read it, then execute its instructions.
Produces a {NN}-CONTEXT.md and {NN}-SECRETS.md in the phase directory.
</purpose>

## Pre-Conditions
- `.prd/` directory exists (if not, redirect to `/cks:new`)
- Phase directory may or may not exist yet

## Invocation

### Load shared context
Read `${SKILL_ROOT}/workflows/discover-phase/_shared.md` — banner template and variables.
Read `.prd/PRD-STATE.md` — extract `{NN}`, `{name}`, `{phase_status}`.

### Step 0: Progress Banner
Read `${SKILL_ROOT}/workflows/discover-phase/step-0-progress.md`
Execute its instructions.

### Step 1: Determine Target Phase
Read `${SKILL_ROOT}/workflows/discover-phase/step-1-target.md`
Execute its instructions.

### Step 2: Auto-Research Technologies
Read `${SKILL_ROOT}/workflows/discover-phase/step-2-research.md`
Execute its instructions.

### Step 3: Check for Existing Discovery
Read `${SKILL_ROOT}/workflows/discover-phase/step-3-resume.md`
Execute its instructions.

### Step 4: Dispatch Discoverer Agent (10 Elements)
Read `${SKILL_ROOT}/workflows/discover-phase/step-4-elements.md`
Execute its instructions.

### Step 4b: Secrets Identification
Read `${SKILL_ROOT}/workflows/discover-phase/step-4b-secrets.md`
Execute its instructions.

### Step 5: Validate Output
Read `${SKILL_ROOT}/workflows/discover-phase/step-5-validate.md`
Execute its instructions.

### Step 6: Update State
Read `${SKILL_ROOT}/workflows/discover-phase/step-6-state.md`
Execute its instructions.

### Step 7: Completion Banner & Context Reset
Read `${SKILL_ROOT}/workflows/discover-phase/step-7-complete.md`
Execute its instructions.

**Do NOT chain to the next workflow via Skill().** Stop here.

## Post-Conditions
- `.prd/phases/{NN}-{name}/{NN}-CONTEXT.md` exists with all 10 discovery elements
- `.prd/phases/{NN}-{name}/{NN}-SECRETS.md` exists (secrets manifest)
- PRD-STATE.md updated to `discovered`
- PRD-ROADMAP.md updated
