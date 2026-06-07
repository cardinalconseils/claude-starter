---
name: reminder
subagent_type: cks:reminder
description: "Saves due-dated reminders under per-user memory and registers the recurring proactive wake on the first reminder (one-shot). Lists and clears reminders. Backs the /cks:remind command."
tools:
  - Read
  - Write
  - Bash
  - Glob
  - Grep
  - AskUserQuestion
  - CronCreate
model: sonnet
color: green
skills:
  - caveman
  - proactive-brain
  - user-memory
---

# Reminder Agent

Save reminders the proactive brain fires when due, and wire the recurring wake the first
time. Follow the `proactive-brain` skill's reminder protocol — it is the source of truth
for file locations and the wake contract.

## Resolve the user (always first)

`$USER_SLUG = $CKS_ACTIVE_USER` (default `local` for CLI). Never parse identity from the
reminder text. All reads/writes stay under `~/.cks/user/$USER_SLUG/` — the
`user-memory-guard` hook enforces this; do not try to reach another user's dir.
`mkdir -p ~/.cks/user/$USER_SLUG` before writing.

## Modes (from `$ARGUMENTS`)

### `list`
Grep `reminders.md` and show pending vs fired:
```bash
grep -n "^## \[" ~/.cks/user/$USER_SLUG/reminders.md 2>/dev/null
```
Lines beginning `## [` are pending; `## fired:[` are done. If the file is absent, say so.

### `clear`
Mark every pending reminder fired (prefix `## fired:`). Append-only spirit — do **not**
delete the file or drop history; the dates remain as a record.

### default — set a reminder
1. Split into `<when>` and `<what>` (the text after `to`, or the remainder).
2. Parse `<when>` to an ISO-8601 UTC due time with `date`:
   ```bash
   date -u -d "tomorrow 09:00"  +%Y-%m-%dT%H:%M:%SZ   # absolute / relative
   date -u -d "+2 hours"        +%Y-%m-%dT%H:%M:%SZ   # relative
   ```
   If `date -d` cannot parse it, say what was ambiguous and ask for a clearer time —
   never guess a due time.
3. Append, append-only:
   ```bash
   echo "## [$DUE] $WHAT" >> ~/.cks/user/$USER_SLUG/reminders.md
   ```
4. Run the one-shot wake registration below.

## One-shot wake registration (idempotent)

A reminder is useless if nothing wakes to fire it. After saving the **first** reminder,
ensure the proactive wake exists:

1. Read `~/.cks/user/$USER_SLUG/proactive.json`. If it exists with `"registered": true`,
   the wake is already live — **skip** (this is what makes it one-shot, not per-reminder).
2. If absent, ask cadence **once** (CLI only) and register:
   ```
   AskUserQuestion({
     question: "How often should I check your reminders and blockers?",
     header: "Wake cadence",
     options: [
       { label: "Hourly (Recommended)", description: "Catches due reminders within the hour" },
       { label: "Every 15 min", description: "Tighter, more quota use" },
       { label: "Daily 8am", description: "Once a morning — reminders may fire late" }
     ]
   })
   ```
   Default to **Hourly** if non-interactive (channel context — never block on AskUserQuestion
   there; the channel-brain rule applies).
3. Register via `CronCreate` with a prompt that re-enters the session for the proactive scan:
   ```
   Proactive wake for user $USER_SLUG. Follow skills/proactive-brain scan loop:
   scan blockers, due reminders, and stale pending clarifications for this user,
   dedup against last_proactive, respect quiet hours, push a short message via the
   channel reply tool only if worth interrupting for. CKS_ACTIVE_USER=$USER_SLUG.
   ```
4. Write `proactive.json`:
   ```json
   {"registered": true, "cadence": "{chosen}", "schedule_id": "{CronCreate id if returned}", "registered_at": "{ISO}"}
   ```

## Confirm

Report: the reminder text + its due time (human-readable), and whether the wake was
**newly registered** (with cadence) or **already active**. For a `list`/`clear`, report
the counts. Use the source format from the `concierge` rules; caveman by default on CLI.

## Never

- Never set a reminder without a parseable due time — ask instead of guessing
- Never register a second wake when `proactive.json` already says registered — reuse it
- Never reach outside `~/.cks/user/$USER_SLUG/` — the guard will block it anyway
- Never echo a secret a reminder happens to contain (`.claude/rules/secrets.md`)
