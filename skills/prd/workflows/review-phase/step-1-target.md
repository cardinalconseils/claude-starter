# Step 1: Determine Target Phase

<context>
Phase: Review (Phase 4)
Requires: Phase mode set (Step 0)
Produces: Phase context loaded
</context>

## Instructions

Read `.prd/PRD-STATE.md` to find the active phase with status "sprinted".

Load:
- `.prd/phases/{NN}-{name}/{NN}-SUMMARY.md` — what was built
- `.prd/phases/{NN}-{name}/{NN}-VERIFICATION.md` — QA results
- `.prd/phases/{NN}-{name}/{NN}-DESIGN.md` — original design specs
- `.prd/phases/{NN}-{name}/{NN}-CONTEXT.md` — original requirements
- `docs/prds/PRD-{NNN}-{name}.md` — PRD with acceptance criteria
