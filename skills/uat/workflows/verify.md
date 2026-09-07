# Workflow: Verify

The acceptance-criteria verification loop that produces `VERIFICATION.md` and updates
`CONFIDENCE.md`. Ported from the `prd-verifier` agent; the parallel test workers it dispatched
are now sequential tracks run by the tester role itself.

## Step 1: Load criteria only

Read exactly: `.prd/phases/{NN}-{name}/{NN}-PLAN.md` (acceptance criteria),
`{NN}-SUMMARY.md` (what was implemented, files changed), and the PRD document the plan
references. Source files are read only when a criterion needs code inspection.

## Step 2: Choose tracks

| Track | Trigger |
|---|---|
| Unit tests | test files or a test command exist |
| Integration tests | integration test files or API tests exist |
| API contract | `testing/newman/api-contract.postman_collection.json` exists |
| E2E tests | E2E test files or browser tests exist |
| Code inspection | criteria no test covers |
| Build verification | always |
| Distributed pattern scan | always at [4a] |

Run every applicable track, one after another. Techniques per track:
`skills/prd/references/verification-patterns.md`.

## Step 3: Build check (always first)

```bash
npm run build 2>&1 || true
npx tsc --noEmit 2>&1 || true
npm run lint 2>&1 || true
```

(or the detected equivalents — `skills/shipping-checklist/workflows/go.md` Step 1).

## Step 4: Run the tracks

**Test tracks** — run the command, record PASS/FAIL per test, map results to criteria, note
tests that were expected but missing:

```
## {test_type} Test Results
- Command: {command}
- Result: {X}/{Y} passing
- Failures: {list}
- Criteria coverage:
  - [x] {criterion} — covered by {test name}
  - [ ] {criterion} — no test found
```

**Code inspection** — for each uncovered criterion read the relevant source, check the
behavior and its edge cases, report PASS/FAIL with `{file}:{line}` evidence.

**API contract** — `npx newman run {collection} --environment {env} --reporters cli,json
--reporter-json-export newman-results.json`; map each request to PASS/FAIL; flag wrong status
codes, missing fields, wrong types.

**Distributed pattern scan** — `git diff main...HEAD -- {files_changed}`; scan for new external
HTTP calls, queue/stream clients, DB write paths, third-party integrations, payment calls;
check whether the matching pattern from `.claude/rules/arch-patterns.md` (retry, idempotency
key, DLQ, circuit state) is handled; report the top 3 by severity (payment > data loss >
observability > reliability). Findings go under `## Distributed Pattern Check`; surface
`❓ DECISION REQUIRED` (add now / defer with ADR / dismiss with reason) and record dismissals
in `.prd/phases/{NN}/DISMISSED-PATTERNS.md`.

### 4b: Classify failures

Classify each failing track with `skills/failure-taxonomy` before consolidating. Run
`git log HEAD..origin/main --oneline` — commits there suggest `branch_divergence`, not a
regression. Include the classification so the fixer knows which recipe applies.

### 4c: Functional E2E

Answers "does the feature work end-to-end through the stack?" — not UAT, no human in the
loop. Detection order: `testing/e2e/` in the phase dir → run it; Newman collection → already
covered; else infer from the criteria — API feature → generate and run Newman smoke requests
per criterion; web feature → Playwright smoke tests (functional paths, no visual
assertions); CLI → invoke and assert stdout; library → integration test against the public
API; nothing detectable → "Functional E2E: not applicable". App not running → "Functional
E2E: app not running — skipped" and flag the gap for the release checklist. Failure blocks
auto-approval.

## Step 5: Consolidate

Map every acceptance criterion to at least one result; flag criteria with no coverage.

## Step 6a: Evidence Bundle front-matter (assemble before writing)

Per `.claude/rules/verification.md`:

```yaml
scope_changed:   # every file the sprint touched, from SUMMARY.md
uncovered:       # every AC skipped or not run, with a one-sentence reason; empty list = full coverage claimed
confidence:
  overall: 0.0   # set in Step 7 from the CONFIDENCE.md gate pass rate — computed, never estimated
  per_criterion: # one entry per AC in CONTEXT.md — none omitted
    - id: AC-1
      verdict: PASS | FAIL | SKIP     # no other values
      why: "root cause on FAIL, evidence on PASS, reason on SKIP"
```

## Step 6: Write VERIFICATION.md

`.prd/phases/{NN}-{name}/{NN}-VERIFICATION.md` — front-matter first, then:

```markdown
# Verification: Phase {NN} — {Name}
**Date:** {YYYY-MM-DD}   **Verdict:** {PASS | FAIL | PARTIAL}

## Acceptance Criteria Results
| # | Criterion | Result | Method | Evidence |

## Test Results
| Track | Pass | Fail | Skip | Command |

## Functional E2E
| Feature Type | Method | Result | Evidence |

## Distributed Pattern Check
{findings or "No distributed pattern signals in diff"}

## Definition of Done Checklist
| Item | Status |
| All acceptance criteria verified | ✓/✗ |
| Functional E2E ran or explicitly skipped with reason | ✓/✗ |
| SUMMARY.md describes actual work, not intended work | ✓/✗ |
| No "should work" / "looks good" in evidence | ✓/✗ |
**DoD verdict:** {MET / NOT MET}

## Code Quality
Lint / Build / Types: {PASS/FAIL — summary}

## Issues Found
### Blocking Issues
### Non-Blocking Issues

## Recommendation
{PASS | FAIL: {N} criteria not met | PARTIAL: core met, {N} need attention}
```

## Step 7: Verdict and CONFIDENCE.md

PASS = all criteria met; FAIL = one or more definitely not met; PARTIAL = core met, edge cases
or quality issues remain. Then update `CONFIDENCE.md` in the phase dir: Gate 7 (unit tests),
Gate 8 (integration tests), Gate 9 (acceptance criteria — PASS only on a PASS verdict); each
with evidence summary and ISO timestamp; FAIL gates appended to the Failure Log with the
attempt number. Anti-loop: a gate with 2 FAIL entries is not retried — escalate via
`AskUserQuestion` ("Fix manually" / "Mark as known issue" / "Skip this gate (with
justification)"). Recalculate `{passed}/{applicable} = {%}` and write the same value into the
VERIFICATION.md front-matter `confidence.overall`.

## Step 8: File issues

Verdict FAIL or PARTIAL → for each blocking issue, file per `skills/github-issues` (title
`[CKS] 🔴 {summary} ({phase-slug})`, label `cks:blocking`, dedup first), then report "Filed
{N} issue(s): #{n}". GitHub MCP unavailable → skip silently.

## Principles

1. Objective — check what the criteria say, not what they should say
2. Evidence on every pass/fail — file:line or test output
3. Never fix code — report for the builder or debugger
4. Check regressions — existing behavior still works
5. Flag uncertainty rather than guess
