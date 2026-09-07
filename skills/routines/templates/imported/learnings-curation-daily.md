---
slug: learnings-curation-daily
goal: "Every day, material added to cardinalconseils/cardinal-guides since the last run is turned into validated learnings attributed to the agents they should change, delivered as one PR on cardinalconseils/claude-starter — or a report saying nothing qualified."
north_star_goal: "<slot: the NORTH-STAR.md goal about the workforce learning from the guides — fill at import; the existing trigger predates the North Star>"
owner_role: historian
sources:
  - "cardinalconseils/cardinal-guides: guides/**/*.md added or changed since STATE.md.last_run"
  - "cardinalconseils/claude-starter: .learnings/knowledge/ (existing entries and .curator-state.json), skills/learnings/SKILL.md (entry format, confidence rules, attribution)"
connectors: [github]
cadence: "0 11 * * *"
environment: inherit
repo: cardinalconseils/claude-starter
autonomy_level: 2
stop_condition: "7 consecutive runs with no new source material (cardinal-guides idle — recommend weekly cadence); or 365 runs since created, whichever first."
report_to: [push]
budget_per_run: 3.00
quiet_hours: none
created: "<slot: date the existing trigger was created — read from list_triggers created_at>"
trigger_id: "<existing — fill from list_triggers>"
---

# learnings-curation-daily (imported)

This routine already runs as a Claude Code Remote trigger created before `skills/routines/`
existed. The profile is imported so the workforce knows it exists and the audit can match
it; nothing about the live trigger changes until the chief of staff re-registers it.

## Import steps

1. `list_triggers` → find the daily learnings-curation trigger; copy its `id` into
   `trigger_id` and its `created_at` into `created`.
2. Confirm `cron_expression` is `0 11 * * *`; if it differs, the trigger is the truth for
   the imported profile — update `cadence` here and note it in the run log.
3. Commit `.routines/learnings-curation-daily/` to HQ with an empty `STATE.md` seed; the
   existing `.learnings/knowledge/.curator-state.json` on the plugin repo stays the
   historian's own memory — `STATE.md` carries only the routine-level counters.

## What one run does

The `learnings` skill is the contract (entry format, confidence, validation, attribution);
`agents/learnings-curator.md` was the run procedure and folds into the historian role. First
run with no state processes only the last 7 days of guides and says so — never a backfill.
Output is a branch and PR on `claude-starter` under `.learnings/knowledge/`, one PR per run,
human merge (Level 2). The push carries the counts: written, refused, attributed-to.

## What noise is

A guide with no durable claim (recorded in `skipped` with the reason, never re-read);
material already attributed; anything whose confidence rule fails validation.
