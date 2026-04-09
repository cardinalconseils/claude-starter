---
description: "Token optimization — configure cost-saving defaults and audit context usage"
argument-hint: "[--audit | --apply | --status]"
allowed-tools:
  - Read
  - Agent
---

# /cks:optimize — Token & Cost Optimization

Parse the mode argument and dispatch the token-optimizer agent.

## Routing

| Invocation | Mode |
|------------|------|
| `/cks:optimize` | Audit — analyze and recommend |
| `/cks:optimize --audit` | Audit — analyze and recommend |
| `/cks:optimize --apply` | Apply recommended settings |
| `/cks:optimize --status` | Show current settings |

## Dispatch

```
Agent(subagent_type="cks:token-optimizer", prompt="
  mode: {audit | apply | status}
  project_root: {current directory}
")
```

## Quick Reference

```
/cks:optimize              → Audit context budget + recommend savings
/cks:optimize --apply      → Apply recommended settings
/cks:optimize --status     → Show current token/cost settings
```
