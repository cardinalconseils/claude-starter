# Recipe: test

## Trigger
Test suite failure, assertion error, 0 passing, N failed.

## Severity
`blocking` — Auto-recoverable: Partial

## Steps

1. Run the failing test in isolation: `npx jest {test-file} --no-coverage` or equivalent.
2. Read the assertion output — what was expected vs. what was received?
3. Check if the failure is in the test itself (bad fixture, wrong expectation) or in the production code.
4. If production code bug: trace to origin (where bad data was introduced, not where it was detected).
5. If test fixture stale: update the fixture to match current behavior only if the behavior is intentionally correct.
6. Apply fix via `cks:debugger-worker`; re-run the isolated test to verify.

## Auto-Fix: Partial
Fixture staleness is auto-fixable. Production code bugs require diagnosis first.

## Escalation Message
> Test still failing after fix attempt. Provide the full assertion diff and the file:line of the production code that produces the wrong value.
