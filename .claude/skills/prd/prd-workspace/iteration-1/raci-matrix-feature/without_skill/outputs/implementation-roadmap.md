# Implementation Roadmap: RACI Matrix View

**Date:** 2026-03-23
**Estimated Total Effort:** 3-4 days

---

## Phase 1: Foundation (Day 1)

### Task 1.1: Add RACI Type Definitions
- **File:** `src/types.ts`
- **Work:** Add `RACIContent`, `RACIStep`, and `RACIValue` type definitions.
- **Effort:** 15 min
- **Dependencies:** None

### Task 1.2: Create RACICell Component
- **File:** `src/components/RACICell.tsx` (new)
- **Work:**
  - Render a single cell with color coding based on value (R/A/C/I/empty).
  - In edit mode, handle click to cycle through values.
  - Apply Tailwind classes matching the project's existing style (zinc palette, small text).
- **Effort:** 1 hour
- **Dependencies:** Task 1.1

### Task 1.3: Create RACIMatrix Component (Read-Only)
- **File:** `src/components/RACIMatrix.tsx` (new)
- **Work:**
  - Accept `RACIContent` data and render as an HTML table.
  - Include a color-coded legend bar above the table.
  - Responsive: horizontal scroll on small screens.
  - Sticky first column (step names) for wide matrices.
  - Use `Card` component wrapper for consistency.
- **Effort:** 2 hours
- **Dependencies:** Task 1.1, Task 1.2

### Task 1.4: Wire RACI View into ProcessFlow
- **File:** `src/components/ProcessFlow.tsx`
- **Work:**
  - Import `RACIMatrix`.
  - In the center column (currently `lg:col-span-3`), check `processData.type`.
  - If `'RACI'`, parse content as `RACIContent` and render `<RACIMatrix>`.
  - Otherwise, render existing `<ReactFlow>` diagram.
  - Handle fallback: if RACI content is malformed, show empty matrix with helper text.
- **Effort:** 1 hour
- **Dependencies:** Task 1.3

**Phase 1 Deliverable:** A RACI process can be viewed as a read-only, color-coded matrix table within the existing ProcessFlow page layout.

---

## Phase 2: Editing (Day 2)

### Task 2.1: Cell Editing
- **File:** `src/components/RACICell.tsx` (modify)
- **Work:**
  - Accept `editable` prop.
  - On click, cycle value: '' -> 'R' -> 'A' -> 'C' -> 'I' -> ''.
  - Emit `onChange(stepId, role, newValue)` callback.
- **Effort:** 30 min
- **Dependencies:** Phase 1

### Task 2.2: Add/Remove Roles (Columns)
- **File:** `src/components/RACIMatrix.tsx` (modify)
- **Work:**
  - "Add Role" button opens inline input at end of header row.
  - Validate: non-empty, no duplicates.
  - Delete button (X icon) on each column header (with confirmation).
  - Removing a role removes all its assignments from every step.
- **Effort:** 1 hour
- **Dependencies:** Phase 1

### Task 2.3: Add/Remove/Reorder Steps (Rows)
- **File:** `src/components/RACIMatrix.tsx` (modify)
- **Work:**
  - "Add Step" button at table bottom adds a row with empty assignments.
  - Inline editing of step name (click to edit).
  - Delete button on each row (with confirmation).
  - Drag-to-reorder using a simple drag handle (or up/down arrows for simplicity).
- **Effort:** 1.5 hours
- **Dependencies:** Phase 1

### Task 2.4: Save RACI Data to Firestore
- **File:** `src/components/ProcessFlow.tsx` (modify), `src/components/RACIMatrix.tsx` (modify)
- **Work:**
  - RACIMatrix emits `onContentChange(raciContent)` on every edit.
  - ProcessFlow serializes to JSON and uses existing `saveProcess` pattern.
  - "Save Process" button triggers Firestore update with version increment.
  - Match existing UX: alert on success, error handling via `handleFirestoreError`.
- **Effort:** 1 hour
- **Dependencies:** Tasks 2.1-2.3

**Phase 2 Deliverable:** Editors and admins can fully create and modify RACI matrices and persist them to Firestore.

---

## Phase 3: Validation and AI (Day 3)

### Task 3.1: RACI Validation Warnings
- **File:** `src/components/RACIMatrix.tsx` (modify)
- **Work:**
  - After each edit, run validation:
    - Warn if a step has no "R" assignment.
    - Warn if a step has multiple "A" assignments.
  - Display warnings as small banners below the table or as row-level indicators.
  - Warnings are advisory only (do not block save).
- **Effort:** 1 hour
- **Dependencies:** Phase 2

### Task 3.2: Enhanced AI Prompts for RACI
- **File:** `src/components/ProcessFlow.tsx` (modify)
- **Work:**
  - In `generateAIContent`, detect if process type is RACI.
  - Format RACI data as a readable table in the prompt.
  - SOP prompt: "Include role assignments from the RACI matrix in each step."
  - Benchmark prompt: "Evaluate whether RACI assignments follow best practices."
- **Effort:** 45 min
- **Dependencies:** Phase 1

### Task 3.3: CSV Export
- **File:** `src/components/RACIMatrix.tsx` (modify)
- **Work:**
  - "Export CSV" button in the matrix toolbar.
  - Generate CSV string from roles and steps data.
  - Trigger browser download (same pattern as existing `downloadMarkdown` in ProcessFlow).
- **Effort:** 45 min
- **Dependencies:** Phase 1

**Phase 3 Deliverable:** RACI matrices include validation feedback, AI-generated content references RACI assignments, and matrices can be exported as CSV.

---

## Phase 4: Polish and Testing (Day 4)

### Task 4.1: Empty State and Onboarding
- **File:** `src/components/RACIMatrix.tsx` (modify)
- **Work:**
  - When a new RACI process is created with no content, show a friendly empty state.
  - "Get started" prompt with buttons to add first role and first step.
  - Optional: pre-populate with common roles template (e.g., "Owner", "Executor", "Reviewer", "Stakeholder").
- **Effort:** 45 min

### Task 4.2: Responsive Design
- **File:** `src/components/RACIMatrix.tsx` (modify)
- **Work:**
  - Test and refine at mobile, tablet, and desktop breakpoints.
  - Ensure horizontal scroll works smoothly for wide matrices.
  - Sticky column and header behavior on scroll.
- **Effort:** 1 hour

### Task 4.3: Integration Testing
- **Work:**
  - Create a RACI process via the UI, add roles/steps, assign values, save.
  - Reload and verify data persists.
  - Test role-based access: viewer sees read-only, editor can edit on Draft.
  - Test status workflow: submit for approval, approve, verify read-only in Approved state.
  - Test AI SOP and Benchmark generation with RACI data.
  - Verify swimlane processes are completely unaffected.
- **Effort:** 1.5 hours

### Task 4.4: Edge Cases
- **Work:**
  - Process with 0 roles, 0 steps (empty state).
  - Process with 20+ roles (horizontal scroll).
  - Process with 50+ steps (vertical scroll, performance).
  - Switching process type from Swimlane to RACI (content format mismatch handling).
  - Malformed content JSON (graceful fallback).
- **Effort:** 1 hour

**Phase 4 Deliverable:** Production-ready RACI matrix feature with polished UX and verified correctness.

---

## File Change Summary

| File | Action | Phase |
|------|--------|-------|
| `src/types.ts` | Modify - add RACI types | 1 |
| `src/components/RACICell.tsx` | Create | 1-2 |
| `src/components/RACIMatrix.tsx` | Create | 1-4 |
| `src/components/ProcessFlow.tsx` | Modify - branch rendering by type | 1-3 |
| `src/components/EditProcessModal.tsx` | Minor modify - RACI-specific hints | 2 |

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Content format mismatch when switching process types | Medium | Medium | Add format detection in ProcessFlow; show warning if content does not match type |
| Performance with large matrices (50+ steps, 20+ roles) | Low | Low | HTML tables handle this well; add virtualization only if needed |
| RACI data loss on accidental type change | Medium | High | Confirm dialog when changing process type; warn about data format difference |
| Cell cycling UX confusion | Low | Low | Include tooltip on first interaction; legend always visible |

## Dependencies

- No new npm packages required for Phase 1-3.
- Optional: `@dnd-kit/core` for drag-to-reorder rows in Phase 2 (Task 2.3). Alternative: simple up/down arrow buttons requiring no new dependency.
- All existing project dependencies (React, Tailwind, Firestore, Lucide icons) are sufficient.
