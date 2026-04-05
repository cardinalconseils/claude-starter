---
name: incremental-implementation
description: >
  Drives incremental development through thin vertical slices. Use when:
  implementing features, building new functionality, executing sprint tasks,
  or when the agent tries to build everything at once. Enforces
  one-feature-at-a-time discipline with test-verify-commit cycles.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# Incremental Implementation

## Overview

Build in thin vertical slices — one feature end-to-end before starting the next. Each slice is independently testable, verifiable, and committable. This prevents the "build everything then debug everything" anti-pattern that wastes hours on cascading failures.

## When to Use

- Implementing any feature from a plan or spec
- Building new functionality with multiple parts
- Executing sprint tasks
- Agent is attempting to build multiple features simultaneously
- Large implementation that tempts a "do it all at once" approach

## When NOT to Use

- Single-file config changes or one-line fixes
- Pure refactors with no behavioral change (use dedicated refactor workflow)

## Process

### 1. Pick ONE Task

Select a single task from the plan. If no plan exists, stop and create one first.

### 2. Read Acceptance Criteria

Know what "done" looks like before writing code. If criteria are vague, ask for clarification.

### 3. Load Relevant Context

Read existing code, patterns, types, and conventions. Match the codebase style — do not introduce new patterns without discussion.

### 4. Write a Failing Test

If a testing framework is present, write a test that captures the expected behavior. Watch it fail. This confirms the test is actually testing something.

### 5. Implement Minimum Code

Write the minimum code to make the test pass. No extras, no "while I'm here" additions, no premature abstractions.

### 6. Run Full Test Suite

Run all tests, not just the new one. Check for regressions. A feature that breaks existing features is not a feature.

### 7. Run Build

Verify the project compiles and builds cleanly. Type errors, lint errors, and build warnings are bugs.

### 8. Commit with Descriptive Message

One commit per working slice. The message describes what the slice adds, not how it was built.

### 9. Mark Complete, Move to Next

Update the plan, mark the task done, pick the next slice. Repeat from Step 1.

## Key Principles

**Vertical slices, not horizontal layers.** Build one feature end-to-end (UI + API + DB) rather than all features one layer at a time. A vertical slice is usable; a horizontal layer is not.

**Each slice must be independently testable.** If you cannot test it in isolation, the slice is too coupled. Break it smaller.

**Never leave the codebase broken between slices.** After every commit, the project must build, tests must pass, and existing features must work.

**Commit after each working slice.** Small commits are reviewable, revertable, and debuggable. Large commits are none of these.

**If a slice is too big, break it into sub-slices.** Signs a slice is too big: more than 5 files changed, more than 200 lines added, or estimated time exceeds 30 minutes.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "Let me build the whole backend first" | Untested code is unknown code. Build and verify slice by slice. |
| "I'll commit everything at the end" | Large commits are unreviewable and un-revertable. Commit per slice. |
| "This feature is too interconnected to slice" | Every feature can be sliced. Start with the simplest user story. |
| "Tests slow me down" | Tests slow you down now. No tests slow you down forever. |
| "I'll just scaffold everything then fill it in" | Scaffolds without tests rot. Build real slices, not empty shells. |
| "It's faster to do it all at once" | It feels faster. It is not. Debug time on monolithic changes dwarfs slice overhead. |

## Red Flags

- Agent modifying more than 5 files without a commit
- Agent building multiple features before testing any
- Agent skipping test runs between slices
- Agent writing "scaffold" code with TODO comments instead of real implementations
- Agent committing hundreds of lines in a single commit
- Agent building all API routes before any UI (horizontal, not vertical)
- Agent saying "I'll test it all at the end"

## Verification

- [ ] Each slice was implemented and committed independently
- [ ] Tests were run after each slice (no "test later" deferrals)
- [ ] Build passes after every commit
- [ ] No existing functionality was broken by new slices
- [ ] Commits are small, focused, and descriptively messaged
- [ ] No TODO/scaffold stubs left uncommitted
