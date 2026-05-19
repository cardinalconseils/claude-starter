---
description: "Triage open PRs, stale branches, and GitHub issues — surfaces each item with an ACTION REQUIRED decision block"
argument-hint: "[--prs] [--branches] [--issues] — default: all three"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:triage — PR, Branch & Issue Triage

Surface every open PR, stale branch, and GitHub issue. For each item, present an ACTION REQUIRED decision block and execute the chosen action.

## Scope Detection

Parse `$ARGUMENTS` for scope flags:

| Flag | Scope |
|------|-------|
| `--prs` | PRs only |
| `--branches` | Branches only |
| `--issues` | Issues only |
| (none) | All three |

## Dispatch

```
Agent(subagent_type="cks:triage-runner", prompt="
  scope: {prs|branches|issues|all — parsed from $ARGUMENTS}
  project_root: {current working directory}
  Fetch, classify, and triage each item. Present ACTION REQUIRED blocks with AskUserQuestion for each decision. Execute approved actions. Print a TRIAGE COMPLETE summary at the end.
")
```

## Quick Reference

```
/cks:triage              → Triage PRs + branches + issues
/cks:triage --prs        → PRs only
/cks:triage --branches   → Branches only
/cks:triage --issues     → Issues only
```
