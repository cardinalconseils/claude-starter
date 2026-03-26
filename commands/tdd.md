---
description: "Standalone TDD workflow — RED/GREEN/REFACTOR cycle, usable anytime (not phase-locked)"
argument-hint: "<feature or file to test>"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - Agent
  - AskUserQuestion
  - TodoWrite
---

# /cks:tdd — Test-Driven Development

Standalone TDD workflow that works **anytime** — during a sprint, before a sprint, or independently. Not phase-locked.

## Usage

```
/cks:tdd "user authentication"     → TDD a new feature
/cks:tdd src/lib/billing.ts        → TDD around an existing file
/cks:tdd --fix                     → Write tests for existing untested code
```

## The Cycle

```
┌─────────────────────────────────────────┐
│          RED → GREEN → REFACTOR         │
│                                         │
│  1. Define   — What should this do?     │
│  2. Write    — Failing test first       │
│  3. Run      — Confirm it fails (RED)   │
│  4. Implement — Minimal code to pass    │
│  5. Run      — Confirm it passes (GREEN)│
│  6. Refactor — Clean without breaking   │
│  7. Run      — Still green              │
│  8. Repeat   — Next behavior            │
└─────────────────────────────────────────┘
```

## Steps Claude Executes

### 1. Detect Test Runner

Scan project for test configuration:
- `package.json` → Jest, Vitest, Mocha, Playwright
- `pyproject.toml` / `pytest.ini` → pytest
- `go.mod` → `go test`
- `Cargo.toml` → `cargo test`
- `mix.exs` → ExUnit

If no test runner found, ask user which to set up.

### 2. Understand the Target

- If given a feature description: identify files that will need to be created/modified
- If given a file path: read the file, understand its public API
- If `--fix`: find files with no corresponding test files

### 3. Write Failing Tests (RED)

Write test file(s) following project conventions:
- Colocate tests: `Component.test.tsx` next to `Component.tsx`
- Or in `__tests__/` or `tests/` directory (match existing pattern)
- Cover: happy path, edge cases, error cases
- Use descriptive test names: `should reject expired tokens`

```
Test structure:
  describe("{module/feature}")
    it("should {expected behavior}")     ← happy path
    it("should reject {invalid input}")  ← edge case
    it("should throw when {error case}") ← error handling
```

### 4. Run Tests — Confirm RED

Run the test suite. Every new test MUST fail. If a test passes immediately, it's not testing new behavior — rewrite it.

### 5. Implement Minimal Code (GREEN)

Write the **minimum** code to make tests pass:
- No extra features beyond what tests require
- No premature optimization
- No speculative abstractions

### 6. Run Tests — Confirm GREEN

All tests must pass. If any fail, fix the implementation (not the test, unless the test has a bug).

### 7. Refactor (IMPROVE)

With green tests as safety net:
- Extract duplicated logic
- Improve naming
- Simplify conditionals
- Remove dead code

### 8. Run Tests — Still GREEN

Confirm refactoring didn't break anything.

### 9. Coverage Check

Run coverage if available:
- Target: 80%+ branch coverage on new code
- Report uncovered lines
- Don't chase 100% — focus on behavior coverage

### 10. Report

```
TDD Summary: {feature}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Tests written:  {count}
Tests passing:  {count} ✅
Coverage:       {percent}%
Files created:  {list}
Files modified: {list}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## PRD Integration (Optional)

If `.prd/PRD-STATE.md` exists and phase is "sprinting":
- Read acceptance criteria from `{NN}-CONTEXT.md`
- Map each acceptance criterion to at least one test
- Report which criteria are covered vs uncovered

## Constraints

- NEVER write implementation before the test
- NEVER skip the RED step — if a test passes immediately, it's a bad test
- NEVER test implementation details (private methods, internal state)
- Test behavior: inputs → outputs, side effects, error conditions
- Keep tests fast: mock external services, use in-memory DBs for unit tests
- One logical assertion per test (multiple `expect` calls for one behavior is fine)
