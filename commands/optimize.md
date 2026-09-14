---
description: "Token optimization — configure cost-saving defaults and audit context usage"
argument-hint: "[--audit | --status]"
allowed-tools:
  - Read
  - Agent
---

# /cks:optimize — Token & Cost Optimization

Parse the argument and dispatch `cks:finops` in `Mode: audit` with an optimization focus.
Finops reports and recommends; it has no `Edit` — settings changes come back as
recommendations for the operator to apply after the owner agrees.

## Routing

| Invocation | Focus |
|------------|-------|
| `/cks:optimize` or `--audit` | Context-budget audit + ranked savings (cost-audit §4 and §6) |
| `/cks:optimize --status` | Current settings and burn only — the Context Budget block plus `scripts/cost-report.sh`, no recommendations |

## Dispatch

```
Agent(subagent_type="cks:finops", prompt="
  Mode: audit
  Focus: token optimization — {full audit | status only}
  Run bash scripts/cost-report.sh --json (current period) and --by model for measured spend;
  then the context-budget audit (skills/finops/workflows/cost-audit.md §4). Return the Context
  Budget block, the cost report table, and — for the full audit — recommendations ranked by
  saving with an owner role for each. Do not change settings.
  project_root: {current directory}
")
```

## Quick Reference

```
/cks:optimize              → audit context budget + measured spend, recommend savings
/cks:optimize --status     → show current token/cost settings and burn, no recommendations
```
