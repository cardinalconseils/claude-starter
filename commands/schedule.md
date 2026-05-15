---
description: "Set up a recurring agent — analytics, sentiment monitoring, or asset generation. Runs on a schedule while you're away."
argument-hint: "[analytics|sentiment|assets|custom] [--cadence daily|weekly|monthly]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:schedule — Recurring Agent Setup

Dispatch the **scheduler** agent to interview you, build a recurring agent, and register it with `CronCreate`.

```
Agent(subagent_type="cks:scheduler", prompt="Set up a recurring agent. Arguments: $ARGUMENTS. Read .kickstart/context.md and CLAUDE.md for project context if available.")
```

## Quick Reference

```
/cks:schedule                      Pick an agent type interactively
/cks:schedule analytics            Pre-select analytics agent template
/cks:schedule sentiment            Pre-select sentiment monitoring template
/cks:schedule assets               Pre-select asset generation template
/cks:schedule custom               Describe your own recurring job
/cks:schedule --cadence weekly     Override default cadence
```

## What It Does

1. Asks what kind of recurring job you need (analytics, sentiment, assets, or custom)
2. Interviews you for sources, outputs, and cadence
3. Writes a state file the recurring agent reads each run (`.agents/{name}/state.json`)
4. Registers a cron schedule via `CronCreate`

## When to Use

- You want a weekly synthesis of product analytics
- You want daily sentiment monitoring from Reddit, G2, or Twitter
- You need a recurring asset (demo deck, report) generated from your repo
- Any job that has the same shape but runs repeatedly on a schedule
