---
slug: workforce-review
goal: "Every Monday there is one PR on cardinalconseils/claude-starter (or a brief saying none was warranted) that improves the roles or skills whose dispatches failed most last week, with a pre/post role-eval delta table proving the change is non-negative."
north_star_goal: "<slot: the NORTH-STAR.md goal about the workforce's reliability — e.g. G4 'agents finish what they are dispatched for'>"
owner_role: historian
sources:
  - "Project repos: .prd/logs/agents/*.jsonl — one line per dispatch (role, outcome, session_id); the week's window"
  - "HQ: .routines/*/STATE.md and runs/ — routine outcomes, NOT READ lines, escalations"
  - "Project repos: .learnings/**/*.md and memory/wiki/learnings/*.md — captured learnings not yet reflected in a role or skill"
  - "cardinalconseils/claude-starter: agents/*.md, skills/*/SKILL.md, .evals/golden/roles/<role>/ — what the roles currently say and what they are measured against"
connectors: [github]
cadence: "0 14 * * 1"
environment: inherit
repo: cardinalconseils/claude-starter
autonomy_level: 2
stop_condition: "No agents/*.jsonl line in the window (nothing dispatched — nothing to learn from); or 3 consecutive weeks with a delta table of all zeros; or 52 runs since created, whichever first."
report_to: [push, issue]
budget_per_run: 8.00
quiet_hours: none
created: "<slot: ISO date the founder accepted this profile>"
trigger_id: ""
---

# workforce-review

The self-improvement loop from `docs/v6-workforce.md` and `.claude/rules/telemetry.md`
(Layer 2): record → measure → improve, each step gated. **Level 2 permanently** — the
plugin is changed only by a human merge; this profile never records an upgrade.

## The chain, one run

1. **Historian observes.** Reads the week's `agents/*.jsonl` per repo it can reach, joins
   with routine `STATE.md`/`runs/` and unabsorbed learnings, clusters failures by role
   (`outcome: error`, repeated `NOT READ`, escalations that named a role). Returns a table:
   role | failures / dispatches | the recurring cause | the file it lives in (`agents/<role>.md`
   or `skills/<name>/SKILL.md`) | the proposed edit in one sentence. Key for `seen:` is
   `<role>:<cause hash>`.
2. **Project manager files** one issue per proposed edit on `claude-starter`, labelled
   `cks:routine:workforce-review`, `severity:<by failure rate>`, body = the evidence lines.
3. **Builder applies** each accepted edit on a branch `<issue>-workforce-review-<role>`
   (worktree isolation, on the plugin repo through a remote session). Role bodies stay
   under ~200 lines; procedures move to workflows, never deleted.
4. **Tester measures** with `skills/evals/workflows/role-eval.md`: the role's three golden
   briefs before and after the edit, `pre_score` / `post_score` / `delta`, written to
   `.evals/results/roles/<role>.json` (the `.sleep/applied/*.json` delta contract).
5. **Shipper opens the PR** with the delta table in the body. `delta < 0` for any role
   blocks the PR — the branch is left, the issue gets the table, and the brief escalates.
   `delta ≥ 0` → PR open, `needs-you` label, human merge.

Three dispatches at most in flight; the historian's table is cut to the top three roles by
failure rate — the rest wait for next week and stay in `STATE.md.next_run_should`.

## What noise is

A single failed dispatch with no repeat; failures whose cause is a missing connector or a
`NOT READ` on the environment (those are operator findings, filed once and not re-proposed);
roles with fewer than three dispatches in the window.

## Report

Push: the `DISPATCHED` lines (issue → PR → delta) and any `NEEDS YOU`. The run log keeps
the full failure table so the next historian run can see what was already proposed.
