---
description: "Set or list reminders — the proactive brain pushes them to you when due. First reminder auto-registers the recurring wake."
argument-hint: "<when> to <what>  |  list  |  clear"
allowed-tools:
  - Agent
---

# /cks:remind — Reminders for the Proactive Brain

Dispatch the **reminder** agent to save a due-dated reminder under your user memory and,
on your first reminder, register the recurring proactive wake in one step — so the agent
pushes the reminder to you (via channel, or surfaced on next session) when it comes due.

```
Agent(subagent_type="cks:reminder", prompt="Arguments: $ARGUMENTS. Follow the proactive-brain skill's reminder protocol: resolve the user, parse the due time, append to reminders.md, and ensure the proactive wake is registered (one-shot, idempotent).")
```

## Quick Reference

```
/cks:remind tomorrow 9am to deploy the bot   Set a reminder
/cks:remind in 2 hours to check CI           Relative time
/cks:remind friday to send the invoice       Day-of-week
/cks:remind list                             Show pending + fired reminders
/cks:remind clear                            Mark all pending reminders done
```

## What It Does

1. Parses `<when>` into an ISO due time (relative or absolute)
2. Appends `## [due] text` to `~/.cks/user/<slug>/reminders.md` (append-only)
3. **One-shot:** if no proactive wake is registered yet, asks cadence once and registers it
   via `CronCreate` — later reminders reuse the same wake
4. When due, the proactive brain pushes it out through the channel (or surfaces it on the
   next session for CLI)

## When to Use

- "Remind me to deploy after the review" — a task you don't want to drop
- Any time-bound nudge you want the agent to raise instead of you remembering it
