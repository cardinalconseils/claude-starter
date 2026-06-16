---
type: log
name: memory-log
description: Chronological history of significant knowledge events in this project
---

# Memory Log

Append-only. One entry per significant knowledge event — decision made, gotcha discovered, learning captured, format change.
Format: `## [YYYY-MM-DD] Title`

---

## [2026-06-07] Phase 08 arch-pattern auto-invocation shipped

Deterministic distributed-pattern detection wired into 3 lifecycle gates (planning, sprint, review).
See: `memory/wiki/learnings/phase-08-arch-pattern-auto-invocation.md`

## [2026-06-15] OKF memory format adopted

CKS memory bundles aligned to OKF v0.1 spec. Type taxonomy established (`learning`, `decision`, `article`, `fact`, `index`, `log`). Wiki agent updated to inject frontmatter. Session-loader now surfaces recent `type:learning` entries before sprint — closing the self-improvement feedback loop.
See: `.claude/rules/memory-format.md`

## [2026-06-15] Weekly self-improvement loop wired into session-loader

`/cks:improve` fires automatically every Sunday — triggered by session-loader Step 6 (date check, no cron expiry). Reads `memory/wiki/learnings/`, proposes `.claude/rules/` + skills updates. Human approval required before any file changes. State: `.agents/cks-improve/state.json`.
