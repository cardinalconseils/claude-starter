# Sprint Summary — Phase 06: Dependency-Aware Issue Schema

**Run ID:** 9450dac5
**Branch:** feat/phase-06--dependency-aware-iss-20260520-2130
**Maturity:** Pilot
**Date:** 2026-05-20

## Goal

Every CKS-opened GitHub issue carries a structured `## Dependencies` section, and `cks:debug --all` (multi-issue mode) parses those deps, topologically sorts issues into waves, and dispatches parallel workers wave-by-wave (sequential waves, parallel within each wave).

## What Was Built

### Group A — Issue Schema

**Task A1 — skills/github-issues/SKILL.md**
- Appended a `## Dependencies` block (4 fields: depends-on, file-scope, root-cause, symptom-of) to the canonical Issue Body Template, after `## Evidence`.
- Added a "Dependencies Authoring Rules" block: depends-on never omitted (empty string when none); scan open issues via list_issues(... labels="cks:auto-filed") before filling depends-on; file-scope derived from the Evidence block; root-cause/symptom-of are AI-filled.
- Added the `cks:wave-{N}` label family to the Label Taxonomy table, documenting that these labels are created on demand inside the debug multi-issue workflow (not pre-seeded — wave count is dynamic). This taxonomy edit was moved from B2 into Group A to keep the two parallel groups file-disjoint.

**Task A2 — agents/investigator.md**
- Appended the same `## Dependencies` block (identical 4-field format) to the inline [INV] issue body template, after `## Suggested Fix`.
- Added a "Filling the Dependencies section" guidance block right after the dedup check: reuse the existing dedup list_issues result to populate depends-on (no second API call), derive file-scope from the file:line evidence the investigator already cites, and AI-fill root-cause/symptom-of.

Per plan, agents/prd-verifier.md and agents/uat-runner.md were intentionally NOT modified — prd-verifier uses the github-issues skill template (covered by A1) and uat-runner files via the investigator (covered by A2). Editing them would be scope creep.

### Group B — Debug Wave Algorithm

**Task B1 — skills/debug/workflows/mode-multi-issue.md**
- Extended Step 1 extraction to capture the `## Dependencies` section.
- Inserted Step 1.5: Build Dependency Waves: parse deps (graceful fallback to wave 1 when the section is missing) -> dedup symptoms (drop symptom-of: #N issues when #N is in the run) -> build adjacency list -> topological sort into waves (no-dep issues = wave 1) -> cycle guard (report + STOP, no auto-resolve) -> apply cks:wave-{N} labels via gh issue edit.
- Reworked Steps 2-4 to run per wave, in wave order, with an explicit wave gate: the next wave does not start until all workers in the current wave complete and merge.
- Updated the Step 5 report to show wave assignments and skipped symptom issues.

**Task B2 — commands/debug.md**
- Threaded the wave instruction into the multi-issue dispatch prompt (sort into dependency waves, apply cks:wave-N labels, execute waves sequentially with parallel workers per wave). The command remains a thin dispatcher — no algorithm logic inline (58 lines).

## Files Changed

- skills/github-issues/SKILL.md (+16)
- agents/investigator.md (+12)
- skills/debug/workflows/mode-multi-issue.md (+39 / -9)
- commands/debug.md (1 line)

Total: 4 files, +60 / -9. prd-verifier.md and uat-runner.md untouched (verified).

## Skipped / Deferred

- Static-analysis dependency inference (CONTEXT.md section 8 — out of scope).
- Cross-session symptom-of detection (only within a single --all run).
- Live 3-issue runtime verification (Group C) — requires opening real GitHub issues; documented as the Pilot manual-gate follow-up.
