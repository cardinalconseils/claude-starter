# Step 1: Determine Target Phase

<context>
Phase: Design (Phase 2)
Requires: PRD-STATE.md
Produces: Phase identification
</context>

## Instructions

Read `.prd/PRD-STATE.md` to find the active phase, or use the phase number argument.

Verify that {NN}-CONTEXT.md exists:
```
Read .prd/phases/{NN}-{name}/{NN}-CONTEXT.md
```

If no {NN}-CONTEXT.md → tell the user: "No discovery found. Run `/cks:discover {NN}` first."

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "phase.design.started" "{NN}-{name}" "Design phase started"`
