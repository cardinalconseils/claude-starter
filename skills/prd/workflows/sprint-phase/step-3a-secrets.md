# Sub-step [3a+]: Secrets Pre-Conditions

<context>
Phase: Sprint (Phase 3)
Requires: PLAN.md created ([3a])
Produces: Updated PLAN.md with secrets pre-conditions
</context>

## Instructions

After planning completes, check for unresolved secrets and inject pre-conditions into PLAN.md:

```
Read ${SKILL_ROOT}/workflows/secrets/hook-plan.md
Execute its instructions.
```

This reads `{NN}-SECRETS.md`, identifies pending secrets, and prepends a "Pre-Conditions: Unresolved Secrets" section to PLAN.md mapping each secret to the tasks it blocks.
