# Verification — Phase 06: Dependency-Aware Issue Schema

**Run ID:** 9450dac5
**Maturity:** Pilot
**Date:** 2026-05-20
**Method:** Static artifact verification (markdown templates + agent instructions; no executable test suite applies to these file types). Algorithm logic reviewed for correctness against the PLAN worked example.

## DoD verdict: MET (with one deferred manual gate — see Functional E2E track)

## CONTEXT.md Acceptance Criteria

| # | Criterion | Result | Evidence |
|---|-----------|--------|----------|
| AC1 | investigate/uat/test write `## Dependencies` in every issue body | PASS | `## Dependencies` block present in skills/github-issues/SKILL.md (canonical, covers prd-verifier + test) and agents/investigator.md (covers investigate + uat-via-investigator) |
| AC2 | Instructions guide AI to fill depends-on by scanning open issues first | PASS | "scan open issues" rule in SKILL.md; "reuse the open-issue list...do NOT make a second list_issues call" in investigator.md |
| AC3 | debug --all reads `## Dependencies`, builds graph, sorts into waves | PASS | Step 1.5 parses section, builds adjacency list, topological sort (mode-multi-issue.md) |
| AC4 | cks:wave-N labels applied before dispatch | PASS | `gh issue edit {n} --add-label "cks:wave-{N}"` in Step 1.5 step 6, before per-wave Steps 2-4 |
| AC5 | Wave N parallel; wave N+1 waits for wave N | PASS | Wave gate after Step 4: "Do not start the next wave until every worker...has merged" |
| AC6 | No-dependency issues land in wave 1 | PASS | Step 1.5 step 4: "Issues with no in-run dependencies land in wave 1"; graceful fallback also -> wave 1 |
| AC7 | symptom-of issues excluded from dispatch when root-cause in same run | PASS | Step 1.5 step 2 "Deduplicate symptoms": drop symptom-of #N when #N in run set |

## Technical Criteria

| Criterion | Result | Evidence |
|-----------|--------|----------|
| depends-on always present, empty when none, never omitted | PASS | "never omit the field" in both SKILL.md and investigator.md |
| Dependency cycle reported and halts (no auto-resolve) | PASS | Step 1.5 step 5 cycle guard: "report the cycle explicitly and STOP" |
| Graceful fallback when `## Dependencies` section missing | PASS | Step 1.5 step 1: missing section -> depends-on empty -> wave 1, do NOT crash |
| commands/debug.md stays a thin dispatcher (no inline algorithm) | PASS | 58 lines; grep for topological/adjacency in command = 0 |
| prd-verifier.md and uat-runner.md NOT modified | PASS | git diff --name-only vs main: neither file present |

## Algorithm Logic Review

The non-trivial piece (topo-sort + wave batching) was reviewed:
- Dedup of symptom issues happens BEFORE adjacency-list construction, so dropped issues never receive a wave assignment.
- Edges restricted to in-run issues, preventing dangling references to out-of-run issue numbers.
- Wave = max(dep waves) + 1 is the standard longest-path layering; no-dep issues correctly anchor at wave 1.
- Matches the PLAN.md worked example: #A (root, no deps) -> wave 1; #B (depends-on #A) -> wave 2; #C (symptom-of #A) -> skipped.

## Functional E2E track

DEFERRED (documented, not silently skipped). Group C requires opening 3 real GitHub issues with a depends-on chain and running `/cks:debug --issues A,B,C` to observe live wave ordering. This needs interactive GitHub MCP issue creation and a real debug run, which is out of band for this autonomous static-verification pass. Recommended as the Pilot manual gate before production promotion. All static and logic criteria pass; the runtime gate is the only outstanding item.
