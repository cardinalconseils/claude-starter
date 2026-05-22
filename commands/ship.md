---
description: "Ship the plugin — clean project docs, bump version, commit, push, open PR."
argument-hint: "[--dry-run]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:ship — Plugin Release

Cleans project-generated documents from the working tree, bumps the plugin version,
and opens a PR — all in one flow.

## What It Does

1. **Clean** — dry-run shows what git clean will remove; confirm before wiping
2. **Bump** — runs `scripts/bump-version.sh` to increment version + generate changelog entry
3. **Commit** — stages bumped files and commits as `chore: release vX.Y.Z`
4. **PR** — pushes branch and opens a GitHub PR

`--dry-run` stops after the clean preview, no changes made.

## Dispatch

```
Agent(subagent_type="cks:ship-runner", prompt="
  args: {arguments passed to /cks:ship}
  project_root: {current directory}
  Run the full ship flow: clean project docs → bump version → commit → PR.
")
```

## Quick Reference

```
/cks:ship            → clean → bump → commit → PR
/cks:ship --dry-run  → preview only, no changes
```
