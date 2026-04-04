# Secrets Gate: Pre-Release Validation

<context>
Phase: Release (Phase 5) — Preflight
Requires: {NN}-SECRETS.md may or may not exist
Produces: PASS/FAIL gate result
</context>

## Inputs

- Read: `.prd/phases/{NN}-{name}/{NN}-SECRETS.md`

## Instructions

### 1. Read manifest

If `{NN}-SECRETS.md` does not exist: PASS (no secrets needed).

### 2. Check for blocking statuses

Parse the Secrets table. Check for:
- `pending` — secrets never retrieved → **FAIL**
- `deferred` — mocked during sprint → **FAIL** (cannot ship mocks to production)

### 3. Gate result

**If all secrets are `resolved`:**
```
✅ Secrets gate: PASS — all {N} secrets resolved
```

**If any are `pending` or `deferred`:**
```
❌ Secrets gate: FAIL — {N} unresolved secrets block release

Pending (never retrieved):
  - SEC-{NN}-XX: {NAME} — {Provider} — How to get: {instructions}

Deferred (mocked during sprint):
  - SEC-{NN}-XX: {NAME} — {Provider} — How to get: {instructions}

These must be resolved before release. Add them to .env.local and update
{NN}-SECRETS.md status to "resolved".
```

Use AskUserQuestion:
```
question: "{N} secrets are unresolved. Release cannot proceed with mock values in production."
options:
  - "I've added them — re-check" → re-read SECRETS.md, re-run gate
  - "Resolve now" → list each secret with instructions, wait for user
  - "Cancel release" → exit release phase
```

## Success Condition

- All secrets in `resolved` status, OR no secrets manifest exists
