---
type: learning
name: phase-04-ponytail-enhance-ladder
description: Phase 04 retrospective — 7-rung write-time minimalism ladder added to engineering-discipline + synced across 4 drift points
---

# Phase 04 Learnings — Ponytail Enhance Ladder

**Shipped:** 2026-07-05 as v5.1.196 (branch `ponytail-enhance-ladder`, commit cb1a999)
**Status:** Review complete — 9/9 ACs delivered, RELEASE recommended (pending user confirm + PR)

## What Was Built

A 7-rung write-time minimalism ladder (YAGNI → reuse → stdlib → native → dependency →
one line → minimum) plus a guards-first paragraph and 4 rationalization rows, added to
`.claude/rules/engineering-discipline.md` and synced byte-identically into 4 locations:
the live rule, the bootstrap catalog template, the embedded v5.0.0→v5.0.14 migration copy,
and a new idempotent v5.1.195→v5.1.196 migration note in `version-changes.md`.

Net-zero surface area (Enhance decision — no new rule/command/agent/skill). CLAUDE.md untouched.

## Key Decisions

- **Enhance, not Add-alongside** — the ladder extended an existing rule rather than creating
  `.claude/rules/ponytail-ladder.md`. Kept surface area flat and the "Three rules" framing
  intact by adding the ladder as an unnumbered operational section.
- **Rule prose + rationalizations, no hook** — the ladder is judgment guidance (non-deterministic
  Layer 6 per `setup-philosophy.md`), so it is enforced via rule + rationalizations table, not a
  script. The rationalization rows (Block B) are the only guard against agents reasoning it away.
- **Author once, paste into 4 sync points** — a single canonical block was written in PLAN.md and
  pasted verbatim into all four locations. This mitigated the PM-1 sync-drift risk; the IT-01
  parity `diff` came back empty, proving it worked.
- **Guards-first ordering** — the guards paragraph sits BEFORE the numbered rungs so an agent
  encounters the never-eliminate clause before applying rung 1 (satisfies AC-06).

## Gotchas

- **Same-branch worktree collision** — the isolated-worktree executor could not commit on
  `ponytail-enhance-ladder` because git forbids the same branch checked out in two worktrees at
  once. It committed on a temp branch; the orchestrator had to fast-forward local `main` to
  `origin/main` and cherry-pick the sprint commit onto the correct branch. Verify the version
  chain has no skip after any such cherry-pick.
- **Executor cannot write SUMMARY.md from inside the worktree** (harness restriction) — the
  orchestrator wrote it afterward under `dispatch-first.md`'s read-only `.prd/` carve-out. This is
  structural, not a one-off: it recurs on every isolated-worktree sprint. Tracked as tech-debt.
- **Soft 80-line budget overrun** — the rule grew to 81 lines vs the guardrails ~80-line guideline.
  Non-blocking (CONTEXT.md §213 flagged this budget as soft for always-on rules), but shows the
  ladder is near the ceiling; future additions to this rule should compress, not append.

## Structural Analog Reinforced

This feature is a clean case of the `setup-philosophy.md` bucket test in practice: a "be simple"
value was operationalized as a *procedure* (the ladder) guarded by a *rationalizations table*
(anti-drift) — the correct treatment for a non-deterministic judgment rule, without reaching for a
deterministic hook. Reusable template for turning any aspirational rule into a walkable checklist.

## Backlog

- prd-executor worktree branch-collision + SUMMARY-write handling → GitHub tech-debt issue (see 04-REVIEW.md)
- Optional: trim rule file back under 80 lines (cosmetic)
