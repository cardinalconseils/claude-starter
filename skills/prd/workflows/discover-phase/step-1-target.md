# Step 1: Determine Target Phase

<context>
Phase: Discover (Phase 1)
Requires: .prd/PRD-STATE.md and .prd/PRD-ROADMAP.md exist
Produces: {NN} and {name} variables set for downstream steps
</context>

## Inputs

- Read: `.prd/PRD-STATE.md`
- Read: `.prd/PRD-ROADMAP.md`
- Parse: `$ARGUMENTS` for phase number

## Instructions

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.1.started" "{NN}-{name}" "Step 1: Determine target phase"`

**If phase number provided as argument:**
- Use that phase (e.g., argument `1` → `.prd/phases/01-*/`)
- If phase directory doesn't exist, create it with `mkdir -p`

**If no argument:**
- Check PRD-STATE.md for active phase
- If no active phase, check PRD-ROADMAP.md for next phase needing discovery
- If no phases exist, ask the user what they want to build via AskUserQuestion

Set variables: `{NN}`, `{name}`, `{phase_dir}` for all downstream steps.

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.1.completed" "{NN}-{name}" "Step 1: Target phase determined"`

## Success Condition

- `{NN}` and `{name}` are determined
- Phase directory `.prd/phases/{NN}-{name}/` exists

## On Failure

- If no phase found and no argument: redirect to `/cks:new`
