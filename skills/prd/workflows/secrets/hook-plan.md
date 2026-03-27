# Secrets Hook: Planning

<context>
Phase: Sprint (Phase 3), sub-step [3a] Sprint Planning
Runs after: planner agent produces PLAN.md
Runs before: user approves sprint scope
Requires: {NN}-SECRETS.md exists, {NN}-PLAN.md exists
Produces: Updated {NN}-PLAN.md with secrets pre-conditions
</context>

## Inputs

- Read: `.prd/phases/{NN}-{name}/{NN}-SECRETS.md`
- Read: `.prd/phases/{NN}-{name}/{NN}-PLAN.md`

## Instructions

### 1. Read secrets manifest

Read `{NN}-SECRETS.md`. Filter to secrets with `status == "pending"`.

If no `{NN}-SECRETS.md` exists: skip silently (feature may not need secrets).
If all secrets are resolved: add a note to PLAN.md header and exit.

### 2. Map secrets to blocking tasks

For each pending secret, identify which PLAN.md tasks depend on it by matching the Environment Mapping "Used In" files against task file scopes.

If mapping fails (no clear file match): list the secret as blocking "implementation tasks" (conservative).

### 3. Inject pre-conditions into PLAN.md

Prepend a section after the PLAN.md header:

```markdown
## Pre-Conditions: Unresolved Secrets

The following secrets must be resolved before dependent tasks can execute.
Sprint will create blocking retrieval tasks for each.

| Secret | Provider | How to Get | Blocks |
|--------|----------|-----------|--------|
| SEC-{NN}-01: {NAME} | {Provider} | {Dashboard path} | {task IDs or "implementation"} |
```

### 4. Report

```
Secrets pre-conditions injected into PLAN.md:
  {N} pending secrets → {M} tasks blocked
  Sprint will prompt for retrieval before implementation.
```

## Success Condition

- PLAN.md contains "Pre-Conditions: Unresolved Secrets" section (or "All secrets resolved" note)
- Each pending secret is listed with its blocking scope

## On Failure

- If SECRETS.md does not exist: skip silently
- If PLAN.md does not exist: skip (planner hasn't run yet)
