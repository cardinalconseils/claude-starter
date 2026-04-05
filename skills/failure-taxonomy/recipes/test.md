# Recipe: test

## Detection Confirmation

Before applying this recipe, verify:
- Test command ran (not a build failure that prevented tests from running)
- At least some tests executed (check for "X tests ran" or similar)
- Failures are assertion-level, not infrastructure-level

## Auto-Recovery Steps

### Step 1: Categorize test failures

| Category | Signal | Approach |
|----------|--------|----------|
| Assertion mismatch | `expected X, got Y` | Read test + source — is the test wrong or the code? |
| Snapshot outdated | `snapshot mismatch`, `obsolete snapshot` | Update snapshots if code change is intentional |
| Missing fixture | `ENOENT`, `file not found` in test | Check if test data moved or was deleted |
| Timeout | `exceeded timeout`, `async callback` | Check for missing awaits or slow operations |
| Import error in test | `Cannot find module` in test file | This is actually a `compile` failure — reclassify |

### Step 2: Determine if auto-fixable

**Auto-fixable:**
- Snapshot updates when the code change was intentional
- Missing await in async test
- Test references old function name that was renamed

**NOT auto-fixable (escalate immediately):**
- Logic assertion failures where the code behavior changed unexpectedly
- Tests that fail because a feature is genuinely broken
- Flaky tests that pass/fail non-deterministically

### Step 3: Apply fix (if auto-fixable)
- For snapshots: run `npm test -- -u` or equivalent
- For renamed references: update the test to match current code
- For missing awaits: add the await

### Step 4: Verify
- Re-run ONLY the failing tests (not full suite) to save time
- If passing → emit `recovery.succeeded`
- If still failing → emit `recovery.escalated`

## Escalation

Report to user:
```
Failure: test ({N} failing)
Tests: {list of failing test names}
Category: {assertion mismatch / timeout / etc.}
Attempted: {what was tried, or "not auto-fixable"}
Action needed: Review test logic vs implementation
```
