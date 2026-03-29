# Step 1: Determine Target Phase

<context>
Phase: Sprint (Phase 3)
Requires: PRD-STATE.md
Produces: Phase identification + prerequisite check
</context>

## Instructions

Read `.prd/PRD-STATE.md` to find the active phase, or use the phase number argument.

Verify that DESIGN.md exists:
```
Read .prd/phases/{NN}-{name}/{NN}-DESIGN.md
```

If no DESIGN.md → tell the user: "No design found. Run `/cks:design {NN}` first."

If DESIGN.md exists but no CONTEXT.md → error: "No discovery found. Run `/cks:discover {NN}` first."
