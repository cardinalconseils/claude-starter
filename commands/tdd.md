---
description: "Standalone TDD workflow — RED/GREEN/REFACTOR cycle, usable anytime (not phase-locked)"
argument-hint: "<feature or file to test>"
allowed-tools:
  - Read
  - Agent
---

# /cks:tdd — Test-Driven Development

Dispatch the **tdd-runner** agent (which has `skills: prd` loaded at startup).

## Dispatch

```
Agent(subagent_type="tdd-runner", prompt="Run TDD cycles for: $ARGUMENTS. Detect the test runner, write failing tests first (RED), implement minimal code (GREEN), then refactor. Repeat for each behavior. If --fix flag present, write tests for existing untested code. Arguments: $ARGUMENTS")
```

## Quick Reference

```
/cks:tdd "user authentication"     → TDD a new feature
/cks:tdd src/lib/billing.ts        → TDD around an existing file
/cks:tdd --fix                     → Write tests for existing untested code
```

The tdd-runner agent handles: test runner detection, failing test writing, minimal implementation, refactoring, coverage checks, and PRD criteria mapping.
