# Step 4b: Secrets Identification

<context>
Phase: Discover (Phase 1)
Requires: {NN}-CONTEXT.md exists (at least partially)
Produces: {NN}-SECRETS.md
</context>

## Instructions

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.4b.started" "{NN}-{name}" "Step 4b: Secrets identification"`

Read and execute the secrets discovery hook:

```
Read ${SKILL_ROOT}/workflows/secrets/hook-discover.md
Execute its instructions.
```

This hook parses the CONTEXT.md for technology mentions, cross-references with known secrets, and asks the user to confirm which secrets are needed.

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.4b.completed" "{NN}-{name}" "Step 4b: Secrets identification complete"`

## Success Condition

- `{NN}-SECRETS.md` exists in the phase directory

## On Failure

- If hook-discover.md cannot be read: create minimal SECRETS.md with empty table
