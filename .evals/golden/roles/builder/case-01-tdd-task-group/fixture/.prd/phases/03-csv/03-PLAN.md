# Execution Plan: Phase 03 — CSV serializer
**PRD:** PRD-003  **Created:** 2026-09-06

## Goal
A correct RFC 4180 serializer for applicant rows.

## Tasks
### Task 1: toCsv(rows)
**Files:** `src/csv.js`, `test/csv.test.js`  **Description:** `toCsv(rows)` takes an array of objects with keys `name,email,phone,job,applied_at` and returns a string: header line then one line per row, `\r\n` line endings.  **Acceptance:** AC-1, AC-2

## Acceptance Criteria
- [ ] AC-1: header is `name,email,phone,job,applied_at`; empty input returns the header only.
- [ ] AC-2: a value containing a comma, a double quote or a newline is wrapped in double quotes and inner quotes are doubled.

## Dependencies
None.
## Risk Notes
Excel FR: out of scope for this task.
## Estimated Scope
Small — one pure function.
