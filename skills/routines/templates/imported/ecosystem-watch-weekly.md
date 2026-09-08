---
slug: ecosystem-watch-weekly
goal: "Every Monday the ecosystem sources in .agents/ecosystem-watch/state.json are read, each new item is classified into a bulletin (priority, type, affects, required pattern), and every HIGH bulletin is in front of a human before any agent applies it."
north_star_goal: "<slot: the NORTH-STAR.md goal about building on current platform patterns — fill at import>"
owner_role: researcher
sources:
  - "cardinalconseils/claude-starter: .agents/ecosystem-watch/state.json — the source list (Anthropic news, Supabase blog, Vercel changelog, n8n release notes) and seen_titles"
  - "cardinalconseils/claude-starter: skills/ecosystem-watch/SKILL.md (priority rubric, types), skills/ecosystem-watch/index.md, skills/ecosystem-watch/bulletins/"
  - "The four source URLs listed in state.json, fetched live"
connectors: [github]
cadence: "0 13 * * 1"
environment: inherit
repo: cardinalconseils/claude-starter
autonomy_level: 2
stop_condition: "All sources return NOT READ (egress blocked) for 4 consecutive runs — recommend changing environment; or 104 runs since created, whichever first."
report_to: [push, issue]
budget_per_run: 4.00
quiet_hours: none
created: "<slot: date the existing trigger was created — read from list_triggers created_at>"
trigger_id: "<existing — fill from list_triggers>"
---

# ecosystem-watch-weekly (imported)

Already runs as a Claude Code Remote trigger (its commits read `chore: ecosystem-watch run
<date> — N new bulletins, M pending review`). Imported so the audit can match it and so
`.agents/ecosystem-watch/state.json` is known to be routine state, not a stray `CronCreate`
file.

## Import steps

1. `list_triggers` → the weekly ecosystem-watch trigger; copy `id` → `trigger_id`,
   `created_at` → `created`. Confirm `0 13 * * 1`; the trigger is the truth if it differs.
2. The existing trigger commits bulletins directly to `main`. Under this profile the level
   is 2 — bulletins arrive as a PR. Re-registering is the moment that changes; until then the
   run log notes "legacy direct-commit trigger" under `NOT READ` so the audit does not flag
   the missing PR as a failure.
3. `state.json` stays where it is (the researcher reads and rewrites `seen_titles` there —
   its write scope covers `.research/`, so the rewrite is done by the operator dispatch that
   commits the run, from the researcher's returned list). `STATE.md` on HQ carries only the
   routine counters and the HIGH-pending list.

## What one run does

Researcher fetches each source, diffs titles against `seen_titles`, classifies every new
item with the `ecosystem-watch` rubric (HIGH / MEDIUM / LOW; BREAKING_CHANGE / OPPORTUNITY /
DEPRECATION / ENHANCEMENT / SECURITY), and drafts one bulletin per HIGH or MEDIUM item in
the skill's bulletin format. Builder writes the bulletins and the `index.md` rows on a
branch; shipper opens the PR. Every HIGH bulletin gets an issue with `needs-you` — human
review precedes any agent changing its pattern. A source that returns `EGRESS_BLOCKED` is
`NOT READ`, counted toward the stop condition, never marked seen.

## What noise is

Version-bump titles with no changelog body (`v0.111.0` alone); posts already in
`seen_titles`; LOW items — logged in the run, no bulletin, no issue.
