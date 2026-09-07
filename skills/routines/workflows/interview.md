# Interview — from an idea to a registrable `ROUTINE.md`

Run by `cks:strategist` when the chief of staff dispatches it for
`/cks:routine new "<idea>"`. The output is a **draft**: the strategist proposes, the chief
of staff registers (`register.md`). You never create a trigger.

In CLI every question below is an `AskUserQuestion` call — one question per call, 2–4
options plus the built-in "Other", the recommended option first and labelled
`(Recommended)`. In channel mode (`skills/chief-of-staff/workflows/channel-mode.md`) the
same questions go out through the channel `reply` tool as a pending clarification, one at
a time; never `AskUserQuestion` there.

Before asking anything, read: `NORTH-STAR.md` (lookup order in
`skills/chief-of-staff/SKILL.md`), the existing `.routines/*/ROUTINE.md` (an overlapping
routine is a reason to extend, not to add), and the seed templates in
`skills/routines/templates/` — if one matches the idea, start from it and ask only the
questions its `<slot:` fields need.

## Questions, in order

| # | Ask | Fills | Notes |
|---|---|---|---|
| 1 | What outcome do you want from one run? | `goal` | Push back on activities ("scan Sentry") until it is an outcome ("every new production error has an issue with a severity by 08:00"). |
| 2 | Which North Star goal does this serve? | `north_star_goal` | Offer the goals read from `NORTH-STAR.md`. "None" is an answer — record it and recommend DROP in the decision block. |
| 3 | Regions, domains, sources — where does the run look? | `sources`, `connectors` | Concrete: URLs, repos, file paths, MCP servers. Map each source to the connector the fired session needs (Sentry, github, Gmail, Stripe…). |
| 4 | How much lead time do findings need? | body (lead-time buckets) | For events, renewals, deadlines: the buckets the digest sorts into (this week / 2–4 weeks / 1–3 months). |
| 5 | How often, and at what local time? | `cadence` | Convert to UTC before writing the cron; confirm the converted time back. Hourly or every-N-hours uses minute 0. |
| 6 | Where does the brief go, in what shape? | `report_to`, body (format) | `push` (short lines), `email` (digest), `channel:<name>`, `issue`. Push text is the brief's ACTIVE / DISPATCHED / NEEDS YOU lines only. |
| 7 | What may one run cost? | `budget_per_run` | USD. Offer 0.50 / 2 / 5 with what each buys (reads only / reads + one fixer / full chain). |
| 8 | What counts as noise? | body (noise rules), `STATE.md` seed | Names, sources, severities to ignore; dedup keys the owner role should carry in `seen:`. |
| 9 | How much may it do on its own? | `autonomy_level` | Offer 1 (suggest) and 2 (draft PRs, never merge) only. Level 3+ is not an interview option — say why (`.claude/rules/loops.md`). |
| 10 | When does it stop? | `stop_condition` | Must be checkable from GitHub, `STATE.md`, a date or a ledger — plus an iteration backstop. Reject "when it's done". |
| 11 | Which role owns the run? | `owner_role` | Recommend from the sources: observability → observer; web/news → researcher; money → finops; contracts → writer or reviewer; repo health → watchdog. Never chief-of-staff. |
| 12 | Environment, repo, quiet hours | `environment`, `repo`, `quiet_hours` | Default `inherit`, `HQ`, the profile's quiet window (`users/<slug>/profile.md`) or `none`. |

Skip a question whose answer is already fixed by the template or the idea text, but say
which field you filled from where. Never invent a source, a connector name, or a goal id.

## Output — two files, returned as text

You do not write into `.routines/` unless that scope was granted to you in this dispatch;
return both files verbatim in your result and the chief of staff has `cks:operator` write
them at Level 1.

1. `.routines/<slug>/ROUTINE.md` — every schema field present (`SKILL.md`), `created` =
   today, `trigger_id` empty, body with: what one run looks for, what a finding is, what
   noise is, the report format, and the lead-time buckets when relevant. Leave a
   `<slot: …>` only where the founder deferred an answer.
2. `.routines/<slug>/references/<slug>-sources.md` — the list the owner role reads first
   every run: one line per source (what it is, how to read it, which connector, what a hit
   looks like, what to ignore). This file is the routine's "where to look", so the profile
   body stays about "what matters".

Close with the decision block the chief of staff will forward:

```
─────────────────────────────────────────────────
❓ DECISION REQUIRED
─────────────────────────────────────────────────
Register routine <slug>? Goal: {goal}. Serves {north_star_goal}. Fires {cadence, local
and UTC}. Level {1|2}. Budget ${n}/run. Owner: {owner_role}. Stops when {stop_condition}.

  1. Register as drafted — chief of staff creates the trigger now
  2. Register paused — profile committed, trigger created disabled, first fire by run-now
  3. Do not register — keep the draft in .routines/<slug>/ for later

Recommended: {n} — {one sentence grounded in the North Star answer and the budget}
─────────────────────────────────────────────────
```

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The idea is clear, I'll skip the questions" | Twelve questions, each one call. Skip only what the template or idea fixes, and say so. |
| "Level 3 is what he asked for" | Not an interview option. Record the wish in the body; the founder upgrades after one reviewed cycle. |
| "I'll create the trigger while I'm here" | You propose. The chief of staff registers. The MCP is not yours to call. |
| "A goal id is a formality" | It is what DROP cites in every run. No goal → recommend option 3. |
| "Plain-text questions are faster in CLI" | `AskUserQuestion`, one per call (`.claude/rules/ask-user-question.md`). Channel mode is the only exception. |

## Verification

- [ ] Every question asked via `AskUserQuestion` (CLI) or the channel `reply` tool (channel mode), one per call
- [ ] `north_star_goal` is a goal that exists in `NORTH-STAR.md`, or "none" with DROP recommended
- [ ] `cadence` written in UTC and confirmed back in local time
- [ ] `autonomy_level` is 1 or 2; `stop_condition` externally checkable with a backstop
- [ ] Both files returned verbatim; `<slot:` only where the founder deferred
- [ ] `❓ DECISION REQUIRED` block present with a grounded recommendation; no trigger created
