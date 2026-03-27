# Step 4b: Secrets Identification

<context>
Phase: Discover (Phase 1)
Requires: {NN}-CONTEXT.md exists (at least partially)
Produces: {NN}-SECRETS.md
</context>

## Instructions

Read and execute the secrets discovery hook:

```
Read ${SKILL_ROOT}/workflows/secrets/hook-discover.md
Execute its instructions.
```

This hook parses the CONTEXT.md for technology mentions, cross-references with known secrets, and asks the user to confirm which secrets are needed.

## Success Condition

- `{NN}-SECRETS.md` exists in the phase directory

## On Failure

- If hook-discover.md cannot be read: create minimal SECRETS.md with empty table
