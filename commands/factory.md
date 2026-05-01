---
description: "AFK software factory — pull labeled GitHub Issues and run the full lifecycle pipeline for each one autonomously"
argument-hint: "[--label cks:factory] [--dry-run] [--limit N]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:factory — AFK Software Factory

Pull labeled GitHub Issues from the backlog and run the full CKS lifecycle pipeline for each one autonomously.

```
Agent(subagent_type="cks:factory-runner", prompt="Run the AFK factory pipeline. Arguments: $ARGUMENTS")
```

## Quick Reference

Default label filter: `cks:factory` (opt-in) and `cks:backlog` (punted scope)

```
/cks:factory                   Pick up all cks:factory + cks:backlog issues
/cks:factory --label cks:factory  Only pick up cks:factory issues
/cks:factory --dry-run         List matching issues, don't implement
/cks:factory --limit 3         Process at most 3 issues (oldest first)
```

## What It Does

1. Reads open GitHub Issues labeled `cks:factory` or `cks:backlog`
2. Shows the queue and asks for confirmation (unless `--auto`)
3. For each issue: creates a `.prd/` feature, runs the full autonomous pipeline
4. Opens a PR per issue, removes the label, comments with the PR link
5. Moves on to the next issue

## When to Use

- You have a backlog of known issues or enhancements from previous sprints
- You want Claude to drain the queue while you're AFK
- After a sprint-close, to implement the `cks:backlog` punts from that session
