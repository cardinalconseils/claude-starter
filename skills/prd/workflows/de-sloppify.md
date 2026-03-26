# Workflow: De-Sloppify Pass

## Purpose

A cleanup pass that runs after sprint implementation [3c] and before code review [3d]. Instead of constraining Claude during generation (which degrades output quality), let it be thorough, then clean up in a focused pass.

## When to Run

- **Automatically:** Between sprint sub-steps [3c] (Implementation) and [3d] (Code Review)
- **Manually:** `/cks:refactor --clean` anytime

## What It Removes

### 1. Test Cleanup
- Tests that verify language/framework behavior (not your code)
- Tests that test mock implementations instead of real behavior
- Redundant test cases that cover the same branch
- Tests with no assertions

### 2. Over-Defensive Code
- Null checks where the type system guarantees non-null
- Try/catch blocks around code that can't throw
- Validation of internal function arguments (trust internal code)
- Redundant type assertions / type guards

### 3. Debug Artifacts
- `console.log` / `print()` / `fmt.Println` debug statements
- Commented-out code blocks
- `// TODO: remove this` markers
- Debug-only imports

### 4. Unnecessary Abstractions
- Wrapper functions that add no logic
- Interfaces with only one implementation (unless at a package boundary)
- Utility functions used exactly once
- Configuration for things that will never change

### 5. Cosmetic Issues
- Inconsistent naming (camelCase vs snake_case mixing)
- Unused imports
- Unused variables
- Empty catch blocks

## What It KEEPS

- All business logic
- All tests that verify YOUR code's behavior
- Error handling at system boundaries (user input, external APIs, DB)
- Comments that explain WHY (not WHAT)
- Type annotations on public APIs

## Implementation

Run as a focused agent pass in a fresh context:

```
Agent prompt:
You are a code cleanup specialist. Review the files modified during this sprint
and remove ONLY:
  1. Debug artifacts (console.log, commented code, debug imports)
  2. Tests that test the framework, not the app
  3. Over-defensive code (null checks the type system handles)
  4. Wrapper functions used once that add no logic
  5. Unused imports and variables

Do NOT:
  - Refactor working code
  - Change public APIs
  - Remove error handling at system boundaries
  - Remove comments that explain WHY
  - Add new code or features

Files to review: {list of files from NN-SUMMARY.md}
```

## Output

```
De-Sloppify Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Removed:
  - {n} debug statements
  - {n} unused imports
  - {n} over-defensive checks
  - {n} dead code blocks
  - {n} redundant tests

Files cleaned: {list}
Lines removed: {count}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Integration with Sprint Phase

In `sprint-phase.md`, between [3c] and [3d]:

```
[3c] Implementation     ✅ done
[3c+] De-Sloppify       ▶ current    ← NEW
[3d] Code Review         ○ pending
```

The de-sloppify pass MUST complete before code review begins. This ensures the reviewer sees clean code, not implementation artifacts.
