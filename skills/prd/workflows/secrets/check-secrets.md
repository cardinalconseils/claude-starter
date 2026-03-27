# Secrets Check: Status Report

<context>
Phase: Any (utility)
Requires: {NN}-SECRETS.md may or may not exist
Produces: Status report (no file changes)
</context>

## Inputs

- Read: `.prd/phases/{NN}-{name}/{NN}-SECRETS.md`

## Instructions

### 1. Read manifest

If `{NN}-SECRETS.md` does not exist: report "No secrets manifest found" and exit.

### 2. Count statuses

Parse the Secrets table. Count:
- `resolved` — secrets retrieved and available
- `pending` — secrets not yet retrieved
- `deferred` — skipped with mock values

### 3. Report

```
Secrets: {total} total | {resolved} resolved | {pending} pending | {deferred} deferred

{If pending > 0:}
  ⚠ Pending secrets block implementation:
    - SEC-{NN}-XX: {NAME} — {Provider}

{If deferred > 0:}
  ⚠ Deferred secrets block release:
    - SEC-{NN}-XX: {NAME} — {Provider}

{If all resolved:}
  ✅ All secrets resolved
```

## Success Condition

- Status report displayed accurately

## On Failure

- If SECRETS.md is malformed: report "Secrets manifest exists but could not be parsed"
