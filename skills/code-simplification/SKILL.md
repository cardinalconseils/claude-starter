---
name: code-simplification
description: >
  Simplifies code for clarity and maintainability while preserving exact behavior.
  Use when: refactoring for readability, reviewing complex code, after a feature
  works but feels heavy, during code review when complexity is flagged, or when
  consolidating scattered logic.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# Code Simplification

## Overview

Simplification makes code easier to read, maintain, and extend without changing what it does. Every simplification must preserve all inputs, outputs, side effects, and error behavior exactly. The goal is not fewer lines — it is less cognitive load per line.

## When to Use

- Refactoring for readability after a feature is complete
- Reviewing complex code during code review
- After a feature works but feels heavy or tangled
- When complexity is flagged by a reviewer or linter
- Consolidating scattered logic into cohesive units

## When NOT to Use

- During active feature development (finish first, simplify second)
- When you do not have tests covering the code (add tests first)
- To "improve" code that is already clear and idiomatic
- As a vehicle for sneaking in behavior changes

## Process

### 1. Read Before Touching

Read CLAUDE.md, neighboring files, and project conventions. Simplification means making code more consistent with the codebase, not imposing external preferences.

### 2. Verify Test Coverage

Before any change, confirm tests exist for the code you will simplify. If coverage is missing, add tests first — simplification without tests is gambling.

### 3. Apply One Principle at a Time

**Preserve Behavior Exactly** — All inputs, outputs, side effects, and error behavior must be identical before and after. If you are not sure, do not change it.

**Follow Project Conventions** — Match the style of the surrounding codebase. Do not introduce patterns the project does not use.

**Prefer Clarity Over Cleverness** — Explicit is better than compact when compact requires mental parsing. A readable if/return beats a dense ternary chain.

**Small, Verifiable Changes** — One simplification at a time. Run tests after each. Never batch multiple simplifications into one change.

**Scope Discipline** — Only simplify what you are asked to simplify. Do not "clean up" adjacent code, rename unrelated variables, or reorganize imports.

### 4. Verify After Each Change

Run the test suite after every individual simplification. If a test fails, revert immediately — do not debug forward.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "This refactor will only take a minute" | Unscoped refactors are the #1 source of regressions. Define scope before starting. |
| "Fewer lines is always better" | Fewer lines that require more mental effort to parse is worse, not better. |
| "Let me also fix this while I'm here" | Scope creep in simplification defeats the purpose. One thing at a time. |
| "This pattern is outdated, let me modernize it" | Consistency with the codebase beats consistency with the latest trends. |
| "Nobody will understand this later" | If it has tests and follows project conventions, it is understandable. |

## Red Flags

- Simplifying code that has no test coverage
- Changing behavior "slightly" as part of a simplification
- Touching files beyond the agreed scope
- Batching multiple simplifications into one commit
- Introducing patterns not used elsewhere in the project
- Simplifying working code because of personal style preference

## Verification

- [ ] Behavior is identical before and after (all tests pass)
- [ ] Only the agreed scope was modified
- [ ] Changes follow existing project conventions
- [ ] Each simplification was committed separately
- [ ] No adjacent "cleanup" was smuggled in
- [ ] Code is genuinely easier to read, not just shorter
