---
description: "Phase 5: Release Management — environment promotion (Dev → Staging → RC → Production)"
argument-hint: "[phase number or 'all']"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:release — Phase 5: Release Management

Dispatch the **deployer** agent (which has `skills: prd, cicd-starter` loaded at startup).

```
Agent(subagent_type="deployer", prompt="Run Phase 5: Release for the current feature. Read .prd/PRD-STATE.md to identify the active phase. Read workflows/release-phase.md for step-by-step process. Arguments: $ARGUMENTS")
```

## Pre-Release Steps

Before dispatching the deployer, the release command runs:

1. **Version bump + Changelog** — run `scripts/bump-version.sh` to finalize the version, generate a grouped changelog from all commits since the last tag, and stage the updated files
2. **Commit release artifacts** — if version/changelog files were updated, commit them as `chore: release v{version}`

These steps ensure CHANGELOG.md and version stamps are current before any deployment begins.

## Quick Reference

Environment promotion with quality gates at each stage:

```
[5a] Dev Deploy + Internal Validation
[5b] Staging Deploy + Feedback
[5c] RC Deploy + E2E Regression Suite
[5d] Production Deploy + Smoke Test + E2E Validation
[5e] Post-Deploy Monitoring + CLAUDE.md Update
```

## Argument Handling

- No args: Release the most recently reviewed phase
- Phase number: Release that specific phase
- `all`: Release all reviewed phases together
