# Step 0: Progress Banner

<context>
Phase: Discover (Phase 1)
Requires: .prd/PRD-STATE.md exists
Produces: Visual progress banner displayed to user
</context>

## Inputs

- Read: `.prd/PRD-STATE.md` — extract {NN}, {name}, {phase_status}
- Scan: `.prd/phases/{NN}-{name}/` — check for existing artifacts

## Instructions

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.0.started" "{NN}-{name}" "Step 0: Progress banner"`

Read PRD-STATE.md and scan the phase directory for existing artifacts. Display the lifecycle progress banner using the template from `_shared.md`.

For each discovery sub-element [1a] through [1j], determine status:
- If `{NN}-CONTEXT.md` exists, check which sections are populated → mark those `✅ done`
- If `{NN}-CONTEXT.md` doesn't exist → all elements `○ pending`

Display the banner with accurate status markers.

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.0.completed" "{NN}-{name}" "Step 0: Progress banner displayed"`

## Success Condition

- Banner displayed with correct status for all elements
- User can see where discovery stands

## On Failure

- If STATE.md is missing: display banner with all elements as `○ pending`
