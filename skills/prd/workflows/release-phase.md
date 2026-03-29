# Workflow: Release Phase (Phase 5) — Orchestrator

<purpose>
Orchestrates environment promotion from Development through Production with
quality gates at each stage. Each sub-step is a separate file — Read it,
then execute its instructions.
Pipeline: preflight → Dev → Staging → RC → Production → post-deploy.
</purpose>

## Pre-Conditions
- Phase has been reviewed (phase_status = "reviewed")
- PR exists from Sprint [3g]
- Git has a remote configured

## Invocation

### Load shared context
Read `${SKILL_ROOT}/workflows/release-phase/_shared.md` — banner templates and variables.
Read `.prd/PRD-STATE.md` — extract `{NN}`, `{name}`.

### Step 0: Initialize Release + Preflight
Read `${SKILL_ROOT}/workflows/release-phase/step-0-init.md`
Execute its instructions (phase mode, progress banner, preflight checks).

---

### Sub-step [5a]: Dev Deploy + Internal Validation
Read `${SKILL_ROOT}/workflows/release-phase/step-5a-dev-deploy.md`
Execute its instructions.

### Sub-step [5b]: Staging Deploy + Feedback
Read `${SKILL_ROOT}/workflows/release-phase/step-5b-staging-deploy.md`
Execute its instructions.

### Sub-step [5c]: RC Deploy + E2E Regression Suite
Read `${SKILL_ROOT}/workflows/release-phase/step-5c-rc-deploy.md`
Execute its instructions.

### Sub-step [5d]: Production Deploy + Smoke Test
Read `${SKILL_ROOT}/workflows/release-phase/step-5d-prod-deploy.md`
Execute its instructions.

### Sub-step [5e]: Post-Deploy
Read `${SKILL_ROOT}/workflows/release-phase/step-5e-post-deploy.md`
Execute its instructions.

---

### Step 6: Update State
Read `${SKILL_ROOT}/workflows/release-phase/step-6-state.md`
Execute its instructions.

### Step 7: Completion Report & Context Reset
Read `${SKILL_ROOT}/workflows/release-phase/step-7-complete.md`
Execute its instructions.

## Post-Conditions
- Feature deployed to production
- CHANGELOG.md updated
- Documentation refreshed (API, architecture, components, onboarding) — stale docs flagged
- CLAUDE.md updated
- PRD-STATE.md, PRD-ROADMAP.md, PRD document updated
- `.learnings/` updated (auto-retro)
- Monitoring confirmed active
