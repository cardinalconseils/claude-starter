# Testing Guardrail Catalog

## Trigger

Generated when bootstrap detects `has_tests: true` (test framework found in scan).

## Template

Write the following to `.claude/rules/testing.md`, replacing placeholders with detected values.

```markdown
---
globs:
  - "**/*.test.*"
  - "**/*.spec.*"
  - "**/tests/**"
  - "**/__tests__/**"
  - "**/test/**"
  - "**/cypress/**"
  - "**/e2e/**"
  - "**/playwright/**"
---

# Testing Rules

## Test Structure

- One test file per module — colocate tests next to the source file or mirror the source tree in a tests/ directory
- Use descriptive test names that state the expected behavior: "returns 404 when user not found", not "test user"
- Group related tests with describe/context blocks by feature or method
- Each test must be independent — no shared mutable state between tests, no order dependency

## What to Test

- Test behavior, not implementation — assert on outputs and side effects, not internal method calls
- Cover the happy path first, then edge cases, then error paths
- Every API endpoint must have at least: one success case, one auth failure case, one validation failure case
- Every utility/helper function must have tests for boundary values and null/undefined inputs

## What Not to Do

- Never mock what you do not own — wrap third-party APIs in an adapter and mock the adapter
- Never write tests that pass when the feature is broken (tautological tests)
- Never use `test.skip` or `xit` without a linked issue or TODO explaining why
- Never test private internals — if you need to test it, it should be exported or extracted

## Test Data

- Use factories or fixtures for test data — never hardcode raw objects in every test
- Never use production data or real credentials in tests
- Use deterministic data — avoid random values that make failures non-reproducible
- Clean up test data after each run — tests must be re-runnable

## Running Tests

- Run `{TEST_COMMAND}` (default: `npm test`) before every commit
- A failing test blocks the commit — never skip tests to land code faster
- New features require tests in the same PR — no "add tests later" PRs

## Coverage

- Do not chase 100% coverage — focus on critical paths and business logic
- Untested code in critical paths (auth, payments, data mutations) is a bug
- Integration tests for API routes are more valuable than unit tests for React components
```

## Customization Notes

- If `test_framework` is "vitest": adjust the "Running Tests" command to `npx vitest` or detected script
- If `test_framework` is "jest": adjust to `npx jest` or detected script
- If `test_framework` is "pytest": change globs to include `"**/test_*.py"`, `"**/*_test.py"`, `"**/conftest.py"` and adjust commands to `pytest`
- If `test_framework` is "go-test": change globs to `"**/*_test.go"` and commands to `go test ./...`
- If `test_framework` is "cargo-test": change globs to `"**/tests/**"`, `"**/*.rs"` (test modules inline) and commands to `cargo test`
- If Cypress or Playwright detected: add a section "## E2E Tests" with: "E2E tests run against a local dev server — never against staging or production" and "Keep E2E tests focused on user journeys, not unit-level assertions"
