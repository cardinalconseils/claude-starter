---
slug: cccs-threat-daily
goal: "Every day, each new Canadian Centre for Cyber Security alert or advisory that touches the stack the ventures run on is a GitHub issue labelled cccs-threat with its severity and the affected component — and nothing already seen is re-filed."
north_star_goal: "<slot: the NORTH-STAR.md goal about client security posture or the CISO offer — fill at import>"
owner_role: researcher
sources:
  - "https://www.cyber.gc.ca/en/alerts-advisories — alerts and advisories feed (the cccs CLI from printing-press wraps it when installed: `cccs list-threats`)"
  - "Stack inventory: each active venture's CLAUDE.md Stack section and package manifests — what 'touches the stack' means"
  - "GitHub: open issues labelled cccs-threat — dedup by advisory id"
connectors: [github]
cadence: "0 12 * * *"
environment: inherit
repo: "<slot: owner/repo where cccs-threat issues are filed — read from the existing trigger's prompt>"
autonomy_level: 1
stop_condition: "The advisories feed returns NOT READ for 5 consecutive runs (feed moved or blocked — re-interview sources); or 365 runs since created, whichever first."
report_to: [push, issue]
budget_per_run: 1.50
quiet_hours: none
created: "<slot: date the existing trigger was created — read from list_triggers created_at>"
trigger_id: "<existing — fill from list_triggers>"
---

# cccs-threat-daily (imported)

Already runs as a Claude Code Remote trigger. Imported so the audit can match it; the live
trigger is untouched until the chief of staff re-registers it under this profile.

## Import steps

1. `list_triggers` → the daily CCCS trigger; copy `id` → `trigger_id`, `created_at` →
   `created`; read its prompt for the repo issues go to and fill `repo`.
2. Confirm `cron_expression` is `0 12 * * *`; the trigger is the truth if it differs.
3. If `.agents/cccs-intel-monitor/state.json` exists (the pre-routine `CronCreate` state),
   copy its seen-advisory ids into `STATE.md seen:` (cap 30, newest) so the first routine run
   does not re-file old advisories, then leave the JSON in place for the legacy command.

## What one run does

The researcher fetches the feed (CLI when present, web otherwise), diffs advisory ids against
`seen:` and the open `cccs-threat` issues, keeps only advisories naming a product, library,
or cloud service in the stack inventory, and returns: id | title | CCCS severity | affected
component | link. Project manager files issues labelled `cccs-threat`, `cks:routine:cccs-threat-daily`,
`severity:<critical→high, high→high, medium→medium, low→low>`. Level 1: no fixes, no
notifications beyond the push and the issue; a `critical` advisory on a production
component adds `needs-you`.

## What noise is

Advisories for products absent from every stack inventory; advisories older than 30 days on
a first run; duplicate ids across the alert and advisory lists. Telegram delivery, which the
legacy agent did itself, is now `report_to` — never a direct send from the researcher.
