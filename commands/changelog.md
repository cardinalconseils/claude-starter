---
description: "Auto-generate a CHANGELOG.md entry from git history"
argument-hint: "[--since <tag|commit|date>]"
allowed-tools:
  - Read
  - Agent
---

# /cks:changelog — Auto-Generate Changelog

Dispatch the changelog-generator agent to create a categorized changelog entry.

## Routing

| Invocation | Behavior |
|------------|----------|
| `/cks:changelog` | Generate from last tag (or last 50 commits) |
| `/cks:changelog --since v1.2.0` | Generate from specific tag |
| `/cks:changelog --since 2026-03-01` | Generate from date |

## Dispatch

```
Agent(subagent_type="cks:changelog-generator", prompt="
  since: {parsed --since value or 'auto'}
  project_root: {current directory}
")
```

## Quick Reference

```
/cks:changelog                   → From last tag
/cks:changelog --since v1.2.0    → From specific tag
/cks:changelog --since 2026-03-01 → From date
```
