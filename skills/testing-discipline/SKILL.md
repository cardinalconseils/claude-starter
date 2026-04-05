---
name: testing-discipline
description: "Test-driven development discipline and testing strategy for production applications. Use when: writing tests, fixing bugs, implementing features, running test suites, choosing what to test, or when the agent skips testing. Enforces RED-GREEN-REFACTOR cycle and the Prove-It Pattern for bug fixes."
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# Testing Discipline

## Overview

Domain expertise for test-driven development, test strategy, and the discipline of proving code works through automated tests. Covers the TDD cycle, the Prove-It Pattern for bug fixes, test pyramid, what to test, framework patterns, and mocking discipline.

## When to Use

- Implementing any new feature (write the test first)
- Fixing any bug (reproduce with a failing test first)
- Deciding what tests to write for existing code
- Choosing between unit, integration, and E2E tests
- An agent skipped testing or claims "it works" without proof
- Running or configuring test suites

## When NOT to Use

- Performance/load testing (different discipline)
- Manual QA checklists or UAT scripts
- Static analysis or linting (complementary but separate)

## Process

### TDD Cycle: RED-GREEN-REFACTOR

1. **RED**: Write a test that describes the desired behavior. Run it. It MUST fail. If it passes, your test is wrong or the feature already exists.
2. **GREEN**: Write the minimum code to make the test pass. No more. Resist the urge to build ahead.
3. **REFACTOR**: Clean up the code (and tests) while keeping all tests green. Extract, rename, simplify.

The cycle repeats for each behavior. Small cycles (5-15 minutes) keep you focused.

### The Prove-It Pattern (Bug Fixes)

1. Bug reported or observed
2. Write a test that **reproduces the bug** -- this test MUST FAIL
3. The failing test is proof the bug exists
4. Fix the bug -- the test now PASSES
5. The passing test is proof the fix works
6. The test stays in the suite **forever** -- it prevents regression

Never fix a bug without a test. "I fixed it" without a test means "I think I fixed it."

### Test Pyramid

| Level | Quantity | Speed | Scope | Examples |
|-------|----------|-------|-------|----------|
| Unit | Many (70%) | Fast (ms) | Single function/class | Pure logic, transformations, validators |
| Integration | Some (20%) | Medium (s) | Multiple components | API routes + DB, service + external API |
| E2E | Few (10%) | Slow (s-min) | Full user flow | Login -> create -> verify in UI |

Invest most effort in unit tests. They run fast, catch most bugs, and pinpoint failures.

### What to Test

- Business logic and domain rules
- Edge cases: null, undefined, empty string, empty array, boundary values
- Error paths: invalid input, network failures, permission denied
- Security boundaries: auth checks, input validation, access control
- State transitions: status changes, workflow progressions

### What NOT to Test

- Framework internals (React rendering, Express routing)
- Third-party library behavior (trust their tests)
- Trivial code with no logic (getters, simple pass-through)
- Static content (HTML structure, CSS classes)
- Private implementation details (test behavior, not internals)

### Framework Patterns

| Layer | Recommended Tools |
|-------|------------------|
| Unit tests | Jest, Vitest, pytest, Go testing |
| Component tests | Testing Library (React/Vue/Svelte) |
| API integration | Supertest, httpx, requests |
| E2E tests | Playwright, Cypress |
| Mocking | jest.mock, vi.mock, unittest.mock |

### Test Naming

```
describe("UserService", () => {
  describe("createUser", () => {
    it("creates a user with valid email and password", ...)
    it("throws ValidationError when email is empty", ...)
    it("throws ConflictError when email already exists", ...)
  })
})
```

Pattern: `it("[expected behavior] when [condition]")`

### Mocking Discipline

- Mock at **boundaries**: external APIs, databases, file system, time
- Do NOT mock internal functions -- that tests implementation, not behavior
- Use dependency injection to make mocking easy
- Reset mocks between tests (`beforeEach` / `afterEach`)
- If you need more than 3 mocks in a unit test, the unit is too coupled

## Common Rationalizations

| Rationalization | Reality |
|----------------|---------|
| "This is too simple to test" | Simple code with tests stays simple. Simple code without tests becomes complex. |
| "I'll add tests later" | Later means never. The test is the proof. Write it now. |
| "Tests slow me down" | Debugging without tests is what slows you down. Tests are the fast path. |
| "The manual test worked" | Manual tests don't prevent regressions. Automated tests do. |
| "100% coverage is the goal" | Coverage measures lines executed, not correctness. Test behavior, not coverage numbers. |

## Red Flags

- Feature shipped with zero tests
- Bug "fixed" with no regression test
- Tests that pass when the feature is broken (testing implementation, not behavior)
- Test suite takes >5 minutes for unit tests (likely testing too broadly)
- Mocks on internal functions instead of boundaries
- Tests with no assertions (they always pass)
- Skipped tests (`it.skip`, `@pytest.mark.skip`) left in the suite

## Verification

- [ ] Every new feature has tests written BEFORE implementation (RED first)
- [ ] Every bug fix has a regression test that fails without the fix
- [ ] Test suite passes with zero skipped tests
- [ ] Unit tests run in under 30 seconds
- [ ] No mocks on internal functions -- only at boundaries
- [ ] Edge cases covered: null, empty, boundary values, error paths
- [ ] Test names describe behavior, not implementation
- [ ] CI runs full test suite on every PR
- [ ] No tests with zero assertions
