# Sprint: phase-06--dependency-aware-iss — 2026-05-20

**Run ID:** 9450dac5
**Result:** SUCCESS
**Gates:** Plan ✓  Implement ✓  Verify ✓
**PR:** https://github.com/cardinalconseils/claude-starter/pull/270 (merged, commit aadb434)
**Version:** 5.1.87

## What Was Built

Dependency-aware issue schema (Phase 06). Every CKS-opened GitHub issue now carries a structured ## Dependencies section (depends-on, file-scope, root-cause, symptom-of). cks:debug --all parses it, topologically sorts issues into dependency waves, applies cks:wave-N labels, and dispatches parallel workers wave-by-wave (sequential waves, parallel within each wave). Symptom dedup + cycle guard + graceful fallback for legacy issues included.

4 files changed (file-disjoint Wave 1 groups):
- skills/github-issues/SKILL.md
- agents/investigator.md
- skills/debug/workflows/mode-multi-issue.md
- commands/debug.md

## Decisions Made

- Moved the cks:wave-N label-taxonomy edit from Group B into Group A's SKILL.md commit, keeping the two parallel groups fully file-disjoint (zero merge-conflict risk).
- Did NOT edit prd-verifier.md or uat-runner.md — covered transitively (prd-verifier uses the github-issues skill template; uat-runner files via the investigator). Avoided scope creep.
- Symptom dedup runs BEFORE topo-sort so dropped issues never receive a wave assignment.

## Retro Notes

- GOTCHA: Agent() dispatch tool was unavailable in this execution context. The pipeline's Box-node dispatch model could not run as designed; fell back to direct Edit/Write in the worktree (isolation preserved, logged in checkpoint). The dispatch-first rule assumes Agent dispatch exists — when it doesn't, the orchestrator must do the work directly to complete the lifecycle.
- GOTCHA: list_peers MCP tool also unavailable — peers check skipped (non-blocking).
- GOTCHA: pre-commit hook auto-bumps version on EVERY commit, so a 4-commit sprint bumped 5.1.83 -> 5.1.87. The hook also auto-syncs the CHANGELOG header. Plan for header drift if writing CHANGELOG manually mid-sprint.
- DEFERRED: Live 3-issue chained --issues run (Group C) is the Pilot manual gate — static + algorithm-logic verification passed all 7 ACs, but real-issue runtime confirmation remains.
- Maturity: Pilot. No executable test suite applies to markdown agent/skill templates — verification was static-artifact + algorithm-logic review.
