# Secrets Hook: Sprint

<context>
Phase: Sprint (Phase 3), sub-step [3c] Implementation
Runs before: executor agent is dispatched
Requires: {NN}-SECRETS.md exists with pending secrets
Produces: User prompted to resolve secrets; SECRETS.md updated
</context>

## Inputs

- Read: `.prd/phases/{NN}-{name}/{NN}-SECRETS.md`
- Read: `.env.local` or `.env` (if exists)

## Instructions

### 1. Read secrets manifest

Read `{NN}-SECRETS.md`. Filter to `status == "pending"`.

If no `{NN}-SECRETS.md` exists: skip (proceed to implementation).
If no pending secrets: skip (proceed to implementation).

### 2. Re-check environment files

The user may have added secrets since discovery. For each pending secret:
- Check if the `.env` key now has a value in `.env.local`
- If found: update `{NN}-SECRETS.md` status to `resolved`, set date

### 3. Present blocking retrieval tasks

For remaining pending secrets, present a BLOCKING prompt:

```
AskUserQuestion({
  questions: [{
    question: "These secrets must be retrieved before implementation can proceed. Go fetch each one, then confirm:",
    header: "Retrieve Secrets",
    multiSelect: false,
    options: [
      { label: "SEC-{NN}-01: {SECRET_NAME}",
        description: "Go to: {Provider Dashboard Path}. Get: {what to look for}. Scope: {access level}" },
      // Repeat for each pending secret — one option per secret to focus attention
      { label: "I've added them to .env.local",
        description: "Re-check .env.local for all pending secrets" },
      { label: "Skip — use mock values for now",
        description: "Proceed with placeholders. Secrets must be resolved before release." }
    ]
  }]
})
```

### 4. Handle responses

- **"I've added them"**: Re-read `.env.local`, update SECRETS.md for any found
- **"Skip — use mock values"**: Mark remaining as `deferred` in SECRETS.md. Add TODO comment to PLAN.md: `<!-- DEFERRED SECRETS: resolve before release -->`
- **Specific secret selected**: User is confirming they've retrieved it. Mark as `resolved` in SECRETS.md. If more pending secrets remain, loop back to step 3.

### 5. Update manifest

Write updated statuses to `{NN}-SECRETS.md`.

### 6. Report

```
Secrets status:
  {R} resolved | {D} deferred | {P} still pending
  {status message}
```

## Success Condition

- All secrets either `resolved` or `deferred`
- SECRETS.md reflects current state
- Implementation can proceed

## On Failure

- Never block indefinitely — "Skip — use mock values" is always an escape hatch
- Deferred secrets create a blocking check in the release phase preflight
