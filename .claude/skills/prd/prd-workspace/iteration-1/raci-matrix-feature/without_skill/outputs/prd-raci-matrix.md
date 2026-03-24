# PRD: RACI Matrix View for ProcessFlow

**Author:** Claude Code
**Date:** 2026-03-23
**Status:** Draft
**Version:** 1.0

---

## 1. Problem Statement

ProcessFlow currently supports a `RACI` value in the `ProcessType` enum (`src/types.ts:17`), and the Edit Process modal already allows users to select "RACI" as a process type (`src/components/EditProcessModal.tsx:50`). However, there is no dedicated rendering for RACI processes. When a user selects a RACI-typed process, it falls through to the default swimlane/ReactFlow diagram renderer in `ProcessFlow.tsx`, which is not appropriate for a RACI matrix.

A RACI matrix is a tabular responsibility-assignment tool where:

- **Rows** represent process steps or activities
- **Columns** represent roles or stakeholders
- **Cells** contain one of: R (Responsible), A (Accountable), C (Consulted), I (Informed)

Users need a purpose-built matrix view that makes role assignments clear at a glance, rather than trying to infer responsibility from swimlane placement.

## 2. Goals

1. Provide a dedicated RACI matrix view when `process.type === 'RACI'`.
2. Allow inline editing of RACI assignments (admin/editor roles).
3. Store RACI data in the existing `process.content` JSON field for consistency.
4. Maintain feature parity with the swimlane view for metadata display (sidebar info, KPIs, tech stack, notes, AI actions).
5. Support export of the RACI matrix (CSV/PDF).

## 3. Non-Goals

- Converting existing swimlane processes to RACI automatically.
- Multi-level RACI (e.g., RASCI with "Supportive" added). This can be a follow-up.
- Real-time collaborative editing (existing Firestore listeners handle sync, but no conflict resolution is in scope).

## 4. User Stories

| ID | Role | Story | Acceptance Criteria |
|----|------|-------|---------------------|
| US-1 | Editor | I want to create a new process with type "RACI" and see a matrix instead of a swimlane diagram | When process type is RACI, a table view renders with roles as columns and steps as rows |
| US-2 | Editor | I want to add/remove roles (columns) to the RACI matrix | A button allows adding a new role column; columns can be removed |
| US-3 | Editor | I want to add/remove process steps (rows) to the RACI matrix | A button allows adding a new step row; rows can be removed and reordered |
| US-4 | Editor | I want to assign R, A, C, or I to each cell by clicking | Clicking a cell cycles through blank -> R -> A -> C -> I -> blank, or opens a dropdown |
| US-5 | Viewer | I want to see the RACI matrix in a clean, color-coded table | Each assignment type has a distinct color: R=blue, A=red/orange, C=yellow, I=green |
| US-6 | Admin | I want to generate an AI SOP that includes RACI assignments | The existing AI SOP prompt is enhanced to include RACI data when available |
| US-7 | Editor | I want to export the RACI matrix as CSV | An export button downloads the matrix as a CSV file |

## 5. Data Model

### 5.1 RACI Content Schema

The `process.content` field (JSON string) will store RACI data in this shape when `process.type === 'RACI'`:

```typescript
interface RACIContent {
  roles: string[];           // Column headers, e.g. ["Project Manager", "Developer", "QA Lead"]
  steps: RACIStep[];         // Row data
}

interface RACIStep {
  id: string;                // Unique ID for the step
  name: string;              // Step/activity name
  description?: string;      // Optional step description
  assignments: Record<string, RACIValue>;  // role name -> assignment
}

type RACIValue = 'R' | 'A' | 'C' | 'I' | '';
```

Example content JSON:

```json
{
  "roles": ["Project Manager", "Developer", "QA Lead", "Stakeholder"],
  "steps": [
    {
      "id": "step-1",
      "name": "Define Requirements",
      "assignments": {
        "Project Manager": "A",
        "Developer": "C",
        "QA Lead": "C",
        "Stakeholder": "R"
      }
    },
    {
      "id": "step-2",
      "name": "Design Solution",
      "assignments": {
        "Project Manager": "I",
        "Developer": "R",
        "QA Lead": "C",
        "Stakeholder": "A"
      }
    }
  ]
}
```

### 5.2 Backward Compatibility

- Existing swimlane processes (nodes/edges JSON) are unaffected.
- The `ProcessFlow` component will branch on `processData.type` to decide which renderer to use.
- If a RACI process has invalid content, it falls back to an empty matrix with a prompt to start adding steps and roles.

## 6. UI/UX Design

### 6.1 Matrix Table Layout

```
+---------------------+----------+-----------+----------+-------------+
|   Process Step      |  PM      | Developer | QA Lead  | Stakeholder |
+---------------------+----------+-----------+----------+-------------+
| Define Requirements |  A       |  C        |  C       |  R          |
| Design Solution     |  I       |  R        |  C       |  A          |
| Implement           |  I       |  R        |  I       |  -          |
| Test                |  I       |  C        |  R       |  I          |
| Deploy              |  A       |  R        |  C       |  I          |
+---------------------+----------+-----------+----------+-------------+
```

### 6.2 Color Coding

| Value | Color | Tailwind Class | Meaning |
|-------|-------|----------------|---------|
| R | Blue | `bg-blue-100 text-blue-700` | Responsible - does the work |
| A | Orange | `bg-orange-100 text-orange-700` | Accountable - owns the outcome |
| C | Yellow | `bg-yellow-100 text-yellow-700` | Consulted - provides input |
| I | Green | `bg-green-100 text-green-700` | Informed - kept in the loop |
| (empty) | Gray | `bg-zinc-50 text-zinc-300` | No assignment |

### 6.3 Interaction Model

- **View mode (viewer role):** Read-only table with color-coded cells.
- **Edit mode (editor/admin on Draft status):**
  - Click cell to cycle through R -> A -> C -> I -> blank.
  - "Add Role" button at top-right of table adds a new column.
  - "Add Step" button at bottom of table adds a new row.
  - Inline editing of step names and role names.
  - Drag handle on rows to reorder steps.
  - Delete icon on rows/columns to remove them (with confirmation).

### 6.4 Page Layout

The RACI view reuses the same overall `ProcessFlow` page layout:
- Left sidebar: Executive Summary, KPIs, Tech Stack (unchanged).
- Center: RACI matrix table replaces the ReactFlow diagram.
- Right sidebar: Notes (unchanged).
- Below center: AI Actions card (unchanged, prompt enhanced for RACI context).

### 6.5 Legend

A small legend bar appears above the matrix table showing the four RACI values with their colors.

## 7. Technical Design

### 7.1 New Files

| File | Purpose |
|------|---------|
| `src/components/RACIMatrix.tsx` | Main RACI matrix table component with view/edit modes |
| `src/components/RACICell.tsx` | Individual cell component handling click-to-cycle and color coding |
| `src/types.ts` (modified) | Add `RACIContent`, `RACIStep`, `RACIValue` interfaces |

### 7.2 Modified Files

| File | Change |
|------|--------|
| `src/components/ProcessFlow.tsx` | Branch rendering: if `processData.type === 'RACI'`, render `<RACIMatrix>` instead of `<ReactFlow>`. Pass same props (process, user, save handler). |
| `src/components/EditProcessModal.tsx` | When type is RACI, optionally show a "seed roles" field or note that roles are managed in the matrix view. |

### 7.3 Component Hierarchy

```
ProcessFlow
  |-- (if type === 'RACI')
  |     |-- RACIMatrix
  |     |     |-- RACICell (per cell)
  |     |     |-- Add Role button
  |     |     |-- Add Step button
  |-- (else)
  |     |-- ReactFlow (existing swimlane view)
  |-- Sidebar (KPIs, Tech Stack, etc.) -- shared
  |-- AI Actions Card -- shared
  |-- Notes Sidebar -- shared
```

### 7.4 State Management

The `RACIMatrix` component will:
1. Parse `processData.content` into `RACIContent` on mount.
2. Maintain local state for roles and steps using `useState`.
3. Call the existing `saveProcess` pattern (update Firestore doc) on explicit save.
4. No new external state management needed.

### 7.5 Validation Rules

- Each step should have at most one "A" (Accountable) across all roles (warn, not block).
- Each step should have at least one "R" (Responsible) (warn, not block).
- Role names and step names must be non-empty.
- Duplicate role names are not allowed.

## 8. AI Integration

When generating SOP or Benchmarking content for a RACI process, the prompt in `generateAIContent` should be enhanced:

- Include the RACI matrix data in a human-readable format in the prompt.
- Ask the AI to reference specific role assignments in the SOP.
- For benchmarking, ask the AI to evaluate whether RACI assignments follow best practices (e.g., single accountable per step).

## 9. Export

### 9.1 CSV Export

Format:
```
Step,Project Manager,Developer,QA Lead,Stakeholder
Define Requirements,A,C,C,R
Design Solution,I,R,C,A
```

### 9.2 Future: PDF Export

Not in initial scope but the table structure makes PDF generation straightforward with a library like `jspdf` or server-side rendering.

## 10. Success Metrics

- Users can create, view, and edit RACI matrices without leaving ProcessFlow.
- RACI processes persist and reload correctly from Firestore.
- AI-generated SOPs for RACI processes reference role assignments.
- No regressions in existing swimlane rendering.

## 11. Open Questions

1. Should we support importing RACI data from CSV? (Suggested: Phase 2)
2. Should RACI roles link to the `UserProfile` or `Department` entities? (Suggested: No, keep as free-text strings initially)
3. Should the matrix support filtering/sorting by role or assignment type? (Suggested: Phase 2)
