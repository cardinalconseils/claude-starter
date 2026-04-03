---
description: "Run full test suite with pass/fail summary and optional coverage"
allowed-tools:
  - Agent
---

# /test

## What It Does
Runs the full test suite for [PROJECT_NAME] and reports results with a
pass/fail summary, failure details, and coverage if available.

## Usage
```
/test [--unit] [--integration] [--coverage]
```

## Arguments
| Argument | Required | Description |
|----------|----------|-------------|
| `--unit` | No | Run unit tests only |
| `--integration` | No | Run integration tests only |
| `--coverage` | No | Include coverage report |

## Steps Claude Executes

1. Run the appropriate test command for [STACK_TOOL]
2. Capture output — pass count, fail count, error details
3. If `--coverage` flagged, include coverage percentage per module
4. Report: summary first, then failures with file/line references

## Output
```
Tests: 42 passed, 0 failed
Coverage: 87%  (if --coverage)

[If failures:]
FAILED: [test name] — [file:line]
  Expected: [x]
  Received: [y]
```

## Example
```
/test --coverage
```
Runs full suite with coverage report.

## Constraints
- Never report "passing" if any test fails
- Always show the full error for each failure, not just the count
- If test runner is not configured, report the setup steps needed
