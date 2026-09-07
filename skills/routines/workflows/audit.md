# Audit — drift between `.routines/` and the triggers that exist

Run on `/cks:routine audit`, and weekly as part of the watchdog's hunt. The chief of staff
reads the trigger list (read-only, not gated) and hands both sides to the watchdog; the
watchdog compares and reports, writes nothing.

## 1. Collect (chief of staff)

- `list_triggers(include_completed: false, limit: 100)` — page with `cursor` until exhausted.
  Keep per trigger: `id`, `name`, `cron_expression`, `enabled`, `ended_reason`,
  `suspension_reason`, `next_run_at`, `last_run.{status, fired_at}`.
- `.routines/*/ROUTINE.md` frontmatter (`slug`, `cadence`, `trigger_id`, `created`),
  `.routines/*/STATE.md` (`last_run`, `runs_total`, `paused`), `ls .routines/*/runs/`.
- Also list `.agents/*/state.json` and any `proactive.json` under `users/*/` — legacy
  `CronCreate` schedules that should have become profiles.

If `list_triggers` is unavailable, the audit degrades to profile-only checks (rows 4–6
below) and says so under `NOT READ`.

## 2. Compare (dispatch `cks:watchdog`, Level 1, both lists pasted in)

| # | Drift | Severity | Finding text |
|---|---|---|---|
| 1 | Profile has a `trigger_id` that `list_triggers` does not return | high | routine exists on paper only — re-register or archive |
| 2 | Trigger named `cks routine — <slug>` with no `.routines/<slug>/` | high | orphan trigger — profile lost or never committed; pause it |
| 3 | `cadence` ≠ `cron_expression` | medium | one side was edited without the other — profile is the contract |
| 4 | `enabled: false` (or `ended_reason` / `suspension_reason` set) while `STATE.md` has no `paused:` line — or the reverse | medium | paused state not recorded / trigger silently disabled |
| 5 | `STATE.md.last_run` older than two cadences while the trigger is enabled | medium | runs are firing without persisting, or not firing — check `last_run.status` |
| 6 | Trigger `last_run.fired_at` has no matching `runs/<date>.md` | medium | the run did not reach step 5 of `routine-run.md` — read that session |
| 7 | `last_run.status` FAILED, or two consecutive non-SUCCEEDED | high | routine is not doing its job |
| 8 | `runs_total` ≥ the stop condition's backstop and trigger still enabled | medium | stop condition never enforced |
| 9 | `.agents/<name>/state.json` schedule with no profile | low | legacy `CronCreate` job — migrate per `skills/scheduled-agents/SKILL.md` |
| 10 | Trigger prompt does not contain `--routine` and `routine-run.md` | low | registered outside `register.md` — prompt drift |

## 3. Report

The watchdog returns the table with only the rows that fired, each with the slug, trigger
id and the evidence field it compared. The chief of staff:

- puts each high finding under `NEEDS YOU` with the recommended fix (`GATED:` when it is a
  pause, a re-register, or a delete — every trigger change stays gated, even in an audit);
- has `cks:project-manager` open or update one issue per medium/high finding, labelled
  `cks:routine:<slug>` + `severity:<level>` (or `cks:routine:audit` for orphan triggers);
- reports "no drift" in one line when nothing fired — a clean audit is still reported.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "It's an audit, I can just re-enable the trigger" | Trigger changes are gated even here. Report, recommend, route `GATED:`. |
| "No Remote MCP, skip the audit" | Profile-only checks still run. Say what was not compared. |
| "The cadence differs by a minute, not worth a finding" | The profile is the contract. A minute of drift is a sign the trigger was edited by hand. |
| "Low findings are noise" | Legacy crons and prompt drift are how routines silently fork. Report them once; the issue dedups. |

## Verification

- [ ] `list_triggers` paged to exhaustion, or `NOT READ` says the audit was profile-only
- [ ] Every `.routines/*/` and every `cks routine — *` trigger appears on exactly one side of the comparison or matches
- [ ] Findings carry slug, trigger id and the compared evidence; severities per the table
- [ ] No trigger changed during the audit; fixes routed `GATED:` or filed as issues
- [ ] Clean audit reported explicitly
