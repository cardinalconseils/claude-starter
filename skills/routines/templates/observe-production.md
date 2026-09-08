---
slug: observe-production
goal: "Every new production error, failed deploy, or degraded LLM trace on the project has a labelled GitHub issue with a severity, and every fix-worthy one has a verified PR open, within one cadence of appearing."
north_star_goal: "<slot: the NORTH-STAR.md goal that keeps this product live for paying users — e.g. G1 'zero silent outages'>"
owner_role: observer
sources:
  - "Sentry project: <slot: org/project as shown in the Sentry MCP — issues, new since last run>"
  - "LangSmith project: <slot: project name — runs with error or latency above the p95 the profile body names>"
  - "Vercel: runtime logs and the last deployment's build logs for <slot: project name>"
  - "GitHub: open issues labelled cks:routine:observe-production in <slot: owner/repo>"
connectors: [Sentry, github, Vercel]
cadence: "0 */6 * * *"
environment: inherit
repo: "<slot: owner/repo of the project being observed — the debugger opens PRs here>"
autonomy_level: 2
stop_condition: "5 consecutive runs with zero new findings (STATE.md consecutive_empty_runs) — recommend moving cadence to daily; or 360 runs since created, whichever first."
report_to: [push, issue]
budget_per_run: 5.00
quiet_hours: "23:00-07:00 America/Toronto"
created: "<slot: ISO date the founder accepted this profile>"
trigger_id: ""
---

# observe-production

The owner's reference routine: observe → issue → fix → verify → report, unattended.

## What one run looks for

- Sentry: issues first seen since `STATE.md.last_run`, and any issue whose event count grew
  by more than 3× — carry the Sentry issue id as the dedup key in `seen:`.
- LangSmith: runs in error, and runs slower than `<slot: p95 latency in ms the founder
  considers degraded>` — key is the trace id.
- Vercel: a failed or cancelled deployment, or runtime log lines at `error` since the last
  run — key is the deployment id or the log line hash.
- Correlate: a Sentry spike that starts at a deployment timestamp is one finding, not two.

## What a finding is

A new key, or a known key with a material change (count ×3, status regressed, first
occurrence in production after being staging-only). Severity: `high` = users blocked or
data at risk; `medium` = degraded but working; `low` = noise-adjacent but real.

## What noise is

Sentry issues already `resolved` or `ignored`; LangSmith runs tagged `eval` or `test`;
Vercel preview deployments; anything whose key is in `seen:`. Sources the observer cannot
reach go to `NOT READ` — never guessed.

## Fix chain (Level 2)

For each `high` or `medium` finding whose proposed action is a code change, `routine-run.md`
step 3 dispatches `cks:debugger` on `repo` (remote session — the project is not HQ) and
`cks:tester` against the issue. The PR is opened, never merged. `low` findings get an issue
only. A finding whose action is "roll back the deploy" is a `GATED:` line — production
deploys are gated regardless of level.

## Report

Push text: the `NEEDS YOU` lines (gated rollbacks, escalations) and the `DISPATCHED` lines
(issue → PR → tester verdict). A run with no findings pushes nothing and files nothing; the
run log still records the sources read and their counts.
