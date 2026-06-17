---
type: article
name: cccs-intel-monitor
description: CCCS threat intelligence monitor — daily fetch of CCCS alerts/advisories with Telegram delivery
---

# CCCS Intel Monitor

Scheduled agent that monitors the Canadian Centre for Cyber Security (cyber.gc.ca) for new cyber threats and delivers alerts to Telegram.

## What It Does

- Fetches all published alerts, advisories, and bulletins from CCCS daily
- Diffs against previously seen threats — no duplicate notifications
- Sends new threats to Telegram, classified by severity (CRITICAL/HIGH/MEDIUM)
- Integrates with `/cks:ciso` which runs a one-shot threat check in every audit

## Setup

```
/cks:cccs-intel
```

The wizard will collect your Telegram bot token env var name and chat ID, test the connection, and register the cron schedule.

## Commands

```
/cks:cccs-intel            → setup wizard (or status if already active)
/cks:cccs-intel --run      → manual run now
/cks:cccs-intel --status   → show state and last run
/cks:cccs-intel --stop     → pause monitor
```

## File Layout

```
.agents/cccs-intel-monitor/
  state.json          — config, seen threat IDs, last run date
  README.md           — this file
  runs/               — dated run reports
    YYYY-MM-DD.md
```

## Telegram Message Format

```
🚨 CCCS CRITICAL (Alert)
*Title of the security alert*
📅 2026-06-17
Brief summary of the threat (up to 200 chars)
🔗 https://cyber.gc.ca/en/...
```

Severity mapping: `alert` → 🚨 CRITICAL, `advisory` → ⚠️ HIGH, `bulletin` → 📋 MEDIUM

## Env Vars Required

| Variable | Description |
|---|---|
| `TELEGRAM_BOT_TOKEN` | Bot token from @BotFather (never stored in state.json) |

`telegram_chat_id` is stored in `state.json` — it's not a secret.

## Stopping the Monitor

```
/cks:cccs-intel --stop
```

Sets `active: false` in state.json. The cron keeps its schedule but the agent exits cleanly without fetching or sending. Resume by running `/cks:cccs-intel --setup` again.
