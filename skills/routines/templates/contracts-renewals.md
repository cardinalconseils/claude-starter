---
slug: contracts-renewals
goal: "No contract, subscription, or notice window in .contracts/ passes its renewal, expiry, or notice date unnoticed: each one is on the board with its lead-time bucket and a drafted renewal or termination note at least one bucket before it is due."
north_star_goal: "<slot: the NORTH-STAR.md goal about client retention or cost control — e.g. G2 'renew every retainer 30 days before term'>"
owner_role: writer
sources:
  - "HQ: .contracts/**/*.md — every MSA, SOW, NDA, subscription, lease; dates in frontmatter (term_end, notice_days, auto_renew) or in the body"
  - "HQ: users/<founder slug>/reminders.md — renewals already acknowledged"
  - "GitHub: open issues labelled cks:routine:contracts-renewals on HQ"
connectors: [github]
cadence: "0 13 * * 1"
environment: inherit
repo: HQ
autonomy_level: 2
stop_condition: ".contracts/ holds no file with a future date (nothing to watch); or 104 runs since created, whichever first — then re-interview."
report_to: [push, issue]
budget_per_run: 1.50
quiet_hours: "22:00-08:00 America/Toronto"
created: "<slot: ISO date the founder accepted this profile>"
trigger_id: ""
---

# contracts-renewals

A scan for dates, then a draft. The writer role scans (cheap, mechanical); a clause that
needs judgment goes to the reviewer through the chief of staff, never decided by the writer.

## What one run looks for

For every file under `.contracts/`: `term_end`, `notice_days`, `auto_renew`, `renewal_date`
in frontmatter, or the first dated "term", "renew", "expire", "notice" sentence in the body.
Compute the **action date** = the earlier of `term_end − notice_days` and `renewal_date`.
Key for `seen:` is `<file path>:<action date>`.

## Lead-time buckets

| Bucket | Action date is | Severity |
|---|---|---|
| overdue | in the past | high |
| this week | ≤ 7 days | high |
| 2–4 weeks | 8–28 days | medium |
| 1–3 months | 29–90 days | low |
| later | > 90 days | none — listed in the log only |

## Draft (Level 2)

For every `high` and `medium` row without an acknowledged reminder, the writer drafts the
renewal or termination note from `skills/contracts/templates/` into
`.contracts/<name>/drafts/<date>-<renew|terminate>.md` (its write scope) and the project
manager links it from the issue. The draft is never sent — sending external mail is gated;
the brief carries `GATED: send renewal note for <name> — affects <counterparty> — reversible: no`.

A contract whose clause the writer cannot classify (ambiguous notice, penalty on
termination) is a `medium` finding tagged `needs review`; the chief of staff dispatches the
reviewer with the file path.

## What noise is

Files under `.contracts/_archived/`; dates already in `reminders.md` as acknowledged; a key
in `seen:` whose bucket has not changed since the last run.
