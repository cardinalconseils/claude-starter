# Secrets Manifest Format

Reference schema for `{NN}-SECRETS.md` files in `.prd/phases/{NN}-{name}/`.

## Template

```markdown
# Secrets Manifest: {Feature Name}

**Phase:** {NN}
**Date:** {YYYY-MM-DD}
**Status:** {N}/{M} resolved

## Secrets

| ID | Name | Provider | How to Get | Scope | Status | Resolved Date |
|----|------|----------|-----------|-------|--------|---------------|
| SEC-{NN}-01 | {ENV_VAR_NAME} | {Provider} | {Dashboard path or URL} | {Access level} | pending | — |

## Environment Mapping

| Secret | .env Key | Used In | Required For |
|--------|----------|---------|-------------|
| SEC-{NN}-01 | {ENV_VAR_NAME} | {source file path} | {what it enables} |

## Pre-Sprint Checklist

- [ ] SEC-{NN}-01: {ENV_VAR_NAME} — retrieve from {provider dashboard path}

## Notes

{Provider-specific instructions, rotation policies, scope justifications}
```

## Field Definitions

- **ID**: `SEC-{NN}-{seq}` — parallels `US-{NN}-{seq}` (user stories)
- **Status**: `pending` | `resolved` | `deferred`
  - `pending` — not yet retrieved, blocks sprint tasks
  - `resolved` — retrieved and in .env.local
  - `deferred` — skipped with mock values, blocks release
- **Scope**: the minimum access level needed (e.g., "read-only", "test mode", "full access")
