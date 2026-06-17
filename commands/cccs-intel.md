---
description: "CCCS threat intelligence monitor — setup, run, status, and stop the scheduled CCCS alert feed to Telegram"
allowed-tools:
  - Agent
  - AskUserQuestion
  - Read
---

# /cks:cccs-intel

CCCS threat intel monitor. Fetches alerts + advisories from the Canadian Centre for Cyber Security. Sends new threats to Telegram daily.

## Quick Reference

```
/cks:cccs-intel            → first-time setup wizard
/cks:cccs-intel --run      → trigger a manual run now
/cks:cccs-intel --status   → show state, last run, seen threat count
/cks:cccs-intel --stop     → pause the monitor (keeps state)
```

## Usage

Parse `$ARGUMENTS` and forward to agent:

```
Agent(
  subagent_type="cks:cccs-intel-monitor",
  prompt="$ARGUMENTS"
)
```

If no arguments: default to `--setup` mode. Check `.agents/cccs-intel-monitor/state.json` — if it exists and `active: true`, default to `--status` instead of re-running setup.

## What It Does

- **Setup**: wizard collects Telegram bot token env var + chat ID, confirms connection, sets cadence, registers CronCreate schedule, seeds seen threat list
- **Run**: fetches CCCS threat list, diffs against seen, sends new threats to Telegram, writes dated run report
- **Status**: shows active state, last run date, total threats seen, cadence
- **Stop**: pauses the monitor — cron keeps running but exits cleanly until re-activated

## Integration

`/cks:ciso` automatically includes a CCCS threat intel section (Step 8) using the same CLI. This command manages the _ongoing monitoring_ layer — ciso audits are one-shot, this monitor is continuous.

## Prerequisites

- CCCS CLI at `/Users/pmc/printing-press/library/cccs/build/cccs`
- `TELEGRAM_BOT_TOKEN` env var set (never stored in state files)
- Telegram chat ID (stored in `.agents/cccs-intel-monitor/state.json`)
