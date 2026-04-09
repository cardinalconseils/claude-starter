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

## Dispatch

```
Agent(subagent_type="cks:tdd-runner", prompt="Run the project test suite. Detect the test runner from package.json/Makefile/pyproject.toml, execute tests, and report results with pass/fail summary. Args: $ARGUMENTS")
```

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
