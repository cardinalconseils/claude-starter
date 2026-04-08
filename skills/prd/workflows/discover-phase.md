# Workflow: Discover Phase (Phase 1) — Orchestrator

<purpose>
Orchestrates the 11 Elements of Discovery via chunked sub-steps.
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

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "phase.discover.started" "{NN}-{name}" "Discovery phase started"`

### Load phase mode
Read `.prd/prd-config.json` — extract `phases.discover.mode`.
If not set or file missing, default to `interactive`.
Set PHASE_MODE = the extracted value.

**Mode behavior for this phase:**
- `interactive` → Execute all steps below as written (current behavior). Use AskUserQuestion for all decisions.
- `auto` → Execute all steps without pausing. For AskUserQuestion calls, select the first (recommended) option automatically. Exception: Step 4 (11 Elements discovery) ALWAYS asks the user regardless of mode — per project convention.
- `gated` → Execute steps like auto, but after Step 7 (Completion), pause and ask: "Discovery complete. Review {NN}-CONTEXT.md and proceed? (Yes / Re-run discovery)"

### Load model strategy
Read `.prd/prd-config.json` — extract `models` section.
Read `${SKILL_ROOT}/references/model-strategy.md` — get tier map and defaults.
For each `Agent()` dispatch in this phase:
1. Look up the agent name in `models.overrides` — if found, use that model
2. Otherwise look up the agent's tier in the reference, use `models.default[tier]`
3. If no `models` section exists, fall back to agent frontmatter `model:`
Pass `model="{resolved}"` to every `Agent()` call.

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

> **Expertise:** Read the `product-maturity` skill — ask the user which maturity stage they're targeting (Prototype, Pilot, Candidate, or Production) to calibrate quality expectations.

### Step 4: Dispatch Discoverer Agent (11 Elements)
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

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "phase.discover.completed" "{NN}-{name}" "Discovery phase completed"`

**Do NOT chain to the next workflow via Skill().** Stop here.

## Post-Conditions
- `.prd/phases/{NN}-{name}/{NN}-CONTEXT.md` exists with all 11 discovery elements
- `.prd/phases/{NN}-{name}/{NN}-SECRETS.md` exists (secrets manifest)
- PRD-STATE.md updated to `discovered`
- PRD-ROADMAP.md updated
