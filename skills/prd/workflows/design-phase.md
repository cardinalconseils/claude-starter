# Workflow: Design Phase (Phase 2) — Orchestrator

<purpose>
Orchestrates UX/UI design via chunked sub-steps.
Each sub-step is a separate file — Read it, then execute its instructions.
Produces mockups, flowcharts, diagrams, component specs, and a consolidated {NN}-DESIGN.md.
Uses Stitch MCP for screen generation and diagrams, Chrome DevTools MCP for browser review.
</purpose>

## Pre-Conditions
- `.prd/phases/{NN}-{name}/{NN}-CONTEXT.md` exists (if not, redirect to `/cks:discover`)
- `.prd/` state files exist

## Invocation

### Load shared context
Read `${SKILL_ROOT}/workflows/design-phase/_shared.md` — banner template and variables.
Read `.prd/PRD-STATE.md` — extract `{NN}`, `{name}`, `{phase_status}`.

### Load phase mode
Read `.prd/prd-config.json` — extract `phases.design.mode`.
If not set, file missing, or value is empty → PHASE_MODE = `interactive`.
**IMPORTANT:** `interactive` is the ONLY safe default for design. Never assume `auto`.

Set PHASE_MODE = the extracted value.

**Mode behavior for this phase:**
- `interactive` → Execute all steps as written. Use AskUserQuestion for ALL decisions. **This is the default.**
- `auto` → Execute all steps without pausing. Select recommended options automatically. **Only used when explicitly set in prd-config.json or invoked via `/cks:autonomous`.**
- `gated` → Execute steps like auto, but after the final step, pause and ask: "Design complete. Review {NN}-DESIGN.md and proceed? (Yes / Revise design)"

**Guard:** If PHASE_MODE is `interactive`, you MUST call AskUserQuestion at minimum 3 times during this phase:
1. [2a] UX flow review
2. [2d] Screen review (per screen)
3. [2f] Design sign-off
If you reach Step 7 without having asked the user at least 3 questions, STOP — you skipped interactive checkpoints.

### Load Stitch MCP reference
Read `${SKILL_ROOT}/workflows/design-phase/stitch-mcp.md` — prompt patterns for screens, diagrams, and MCP fallbacks.

### Step 0: Progress Banner
Read `${SKILL_ROOT}/workflows/design-phase/step-0-progress.md`
Execute its instructions.

### Step 1: Determine Target Phase
Read `${SKILL_ROOT}/workflows/design-phase/step-1-target.md`
Execute its instructions.

### Step 2: Load Design Context
Read `${SKILL_ROOT}/workflows/design-phase/step-2-context.md`
Execute its instructions.

### Step 3: Dispatch Designer Agent (or Agent Team)
Read `${SKILL_ROOT}/workflows/design-phase/step-3-dispatch.md`
Execute its instructions.

### Step 4: Validate Output
Read `${SKILL_ROOT}/workflows/design-phase/step-4-validate.md`
Execute its instructions.

### Step 5: Create Design Summary
Read `${SKILL_ROOT}/workflows/design-phase/step-5-summary.md`
Execute its instructions.

### Step 6: Update State
Read `${SKILL_ROOT}/workflows/design-phase/step-6-state.md`
Execute its instructions.

### Step 7: Completion Banner & Context Reset
Read `${SKILL_ROOT}/workflows/design-phase/step-7-complete.md`
Execute its instructions.

**Do NOT chain to the next workflow via Skill().** Stop here.

## Post-Conditions
- `.prd/phases/{NN}-{name}/design/` directory with UX flows, diagrams, screens, component specs
- `.prd/phases/{NN}-{name}/design/diagrams/` with `.mmd` source + `.svg` rendered files (user flows, flowcharts, state/sequence diagrams, ERDs)
- `.prd/phases/{NN}-{name}/{NN}-DESIGN.md` summary exists
- PRD-STATE.md updated
- PRD-ROADMAP.md updated
