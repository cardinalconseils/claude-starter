---
type: learning
name: phase-08-arch-pattern-auto-invocation
description: Phase 08 retrospective — deterministic arch-pattern detection wired into 3 lifecycle gates
---

# Phase 08 Learnings — Architecture Pattern Auto-Invocation

**Shipped:** 2026-06-07 as v5.1.125
**Status:** Complete — 9/9 ACs delivered

## What Was Built

Deterministic distributed-pattern detection wired into 3 lifecycle gates:
- **Planning [3a]** — scans CONTEXT.md, mandatory dispatch to `architecture-generator` before PLAN.md
- **Sprint [3c]** — non-blocking catch after SUMMARY.md
- **Review [4a]** — diff scan, DECISION REQUIRED block (fix now / defer ADR / dismiss)

New files: `.claude/rules/arch-patterns.md`, `skills/architecture/references/distributed-patterns.md`
Modified: `agents/prd-planner.md` (Step 1d), `agents/prd-verifier.md`, `agents/architecture-generator.md` (Mode 3), `skills/architecture/SKILL.md`

## Key Decisions

- **Keyword regex over LLM classifier** — deterministic, auditable, zero token cost. v2 LLM hybrid deferred.
- **Mode 3 on architecture-generator** — reused existing agent rather than creating a new one. Correct call.
- **Sprint gate [3b] → [3c]** — CONTEXT.md said [3b] but build used [3c] (correct post-build gate per lifecycle spec). No functional impact.

## Gotchas

- **Sprint ran before formal design** — DESIGN.md was written retroactively as validation. PRD-STATE.md got left at "designed" even though the sprint had completed. Always update PRD-STATE.md immediately after sprint completion.
- **Mode 3 scope creep** — adding a new mode to `architecture-generator` wasn't in CONTEXT.md. It was the right call (reuse > new agent) but undocumented. When adding modes to shared agents mid-sprint, note it in SUMMARY.md explicitly.
- **PRD-STATE.md staleness** — two sessions updated the file concurrently; state became inconsistent. One session closing a phase must update PRD-STATE.md atomically before other sessions resume.

## Structural Analogs Established

`arch-patterns.md` follows the same pattern as `scheduling.md` and `evals.md`:
> keyword match → mandatory agent dispatch → user-surface block

This triad is now a proven CKS pattern. Future rule files should follow this structure.

## Backlog

- Issue #326: [linked from review]
- Issue #327: [linked from review]
- v2: LLM-based pattern classifier (hybrid with keyword regex)
- Phase 09 could extend the catalog beyond 12 patterns as usage data accumulates
