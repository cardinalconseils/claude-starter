# Confidence Ledger: Phase {NN} — {Name}

**Created:** {date}
**Feature:** {feature_name}
**Target:** All applicable gates green

## Gate Results

| # | Gate | Applies | Status | Evidence | Timestamp |
|---|------|---------|--------|----------|-----------|
| 1 | Build compiles | YES | - | - | - |
| 2 | Lint passes | {auto} | - | - | - |
| 3 | Type check passes | {auto} | - | - | - |
| 4 | De-sloppify complete | YES | - | - | - |
| 5 | Code review: no blockers | YES | - | - | - |
| 6 | Security scan: no criticals | YES | - | - | - |
| 7 | Unit tests pass | {auto} | - | - | - |
| 8 | Integration tests pass | {auto} | - | - | - |
| 9 | Acceptance criteria met | YES | - | - | - |
| 10 | UAT: user approved | YES | - | - | - |

## Gate Detection

<!-- Auto-populated by gate scanner at sprint start -->
<!-- Format: "Gate: YES (reason)" or "Gate: N/A (reason)" -->

| Gate | Detected | Reason |
|------|----------|--------|

## Confidence Score

0/{applicable} gates passed = 0%

## Failure Log

<!-- Tracks consecutive failures per gate for anti-loop breaker -->
<!-- After 2 consecutive failures on the same gate, escalate to user -->

| Gate | Attempt | Result | Action Taken |
|------|---------|--------|-------------|

## Manual Verification Items

<!-- Items that require human inspection (visual, UX, etc.) -->

| Item | Status | Verified By |
|------|--------|-------------|

---

## Gate Scanner Reference

**Always YES:** Build, De-sloppify, Code review, Security scan, Acceptance criteria, UAT

**Auto-detected:**
- **Lint:** Check for `.eslintrc*`, `biome.json`, or `lint` script in `package.json`
- **Type check:** Check for `tsconfig.json`
- **Unit tests:** Check for files matching `*.test.*` or `*.spec.*`
- **Integration tests:** Check for `*.integration.*` or `test/integration/` directory

**Valid Status Values:**
- `-` — Not yet run
- `PASS` — Gate passed with evidence
- `FAIL` — Gate failed (see Failure Log)
- `N/A` — Gate does not apply (auto-detected)
- `SKIP:user-approved` — User chose to skip with justification (counts as resolved)

**Anti-Loop Rule:** If a gate reaches 2 consecutive FAIL entries in the Failure Log, STOP retrying and escalate to the user via AskUserQuestion with options:
1. "Fix manually" — user will fix and re-run
2. "Mark as known issue" — gate stays FAIL but is documented
3. "Skip this gate" — gate marked SKIP:user-approved with justification
