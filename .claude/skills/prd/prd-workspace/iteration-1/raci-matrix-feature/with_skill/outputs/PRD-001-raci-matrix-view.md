# PRD-001: RACI Matrix View

**Status:** Draft
**Author:** User (via PRD skill)
**Created:** 2026-03-23
**Last Updated:** 2026-03-23
**Priority:** P1-High

## Problem Statement

ProcessFlow currently only renders business processes as swimlane flow diagrams. Process owners, department managers, and compliance officers need to quickly determine who is Responsible, Accountable, Consulted, and Informed for each step in a process. Today, this information is either implicit in the swimlane lane assignments or maintained in separate spreadsheets outside the system, leading to stale data and duplication of effort.

## Motivation

- The `ProcessType` enum in `src/types.ts` already includes `'RACI'` but it has no implementation — this was planned but never built.
- Swimlane processes already contain lane/role data (`node.data.lane`), meaning RACI-R (Responsible) can be derived automatically for existing processes.
- Compliance audits and process governance reviews frequently require RACI matrices. Embedding them in ProcessFlow eliminates a manual artifact.
- This is a high-value, moderate-effort feature because half the data (role assignments) already exists in the node model.

## Personas

| Persona | Role | Goal | Context |
|---------|------|------|---------|
| Process Owner | Editor/Admin | Assign RACI designations to each process step | Creates and maintains process documentation |
| Department Manager | Viewer/Editor | Review RACI to ensure accountability is clear | Oversees team responsibilities |
| Compliance Officer | Viewer | Verify that every step has a clear accountable party | Audits processes for governance |
| General Viewer | Viewer | Understand who does what in a process at a glance | Onboarding, reference |

## Solution Overview

Add a RACI matrix view as an alternative rendering mode within `ProcessFlow.tsx`. The matrix is a table where:
- **Rows** = process steps (derived from task/event nodes)
- **Columns** = roles/participants (derived from swimlane lane names)
- **Cells** = RACI designation (R, A, C, I, or empty)

The RACI data will be stored in the `ProcessNode.data` object as a `raci` map (`Record<string, 'R' | 'A' | 'C' | 'I'>`), keyed by role/lane name. For existing swimlane processes, the lane assignment auto-populates as "R" (Responsible).

A toggle button in the ProcessFlow toolbar switches between "Flow View" and "RACI View."

### Architecture Sketch

```
ProcessFlow.tsx
  ├── Flow View (existing ReactFlow rendering)
  └── RACI View (new)
       └── RaciMatrix.tsx (new component)
            ├── Reads nodes[] and extracts steps + lanes
            ├── Renders HTML table with RACI cells
            └── (Phase 2) Inline cell editing → updates node.data.raci
```

## Detailed Requirements

### Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-1 | Toggle between Flow View and RACI View in ProcessFlow toolbar | Must |
| FR-2 | RACI matrix renders as a table: rows = process steps (ordered by flow sequence), columns = roles | Must |
| FR-3 | Each cell displays one of: R, A, C, I, or empty | Must |
| FR-4 | For swimlane processes, auto-derive "R" from the node's lane assignment when no explicit RACI data exists | Must |
| FR-5 | RACI data persisted in `ProcessNode.data.raci` as `Record<string, 'R' | 'A' | 'C' | 'I'>` | Must |
| FR-6 | Processes with type `'RACI'` default to RACI View on load | Should |
| FR-7 | Color-code RACI cells (e.g., R=blue, A=red, C=yellow, I=gray) for quick scanning | Should |
| FR-8 | RACI matrix is exportable as CSV or markdown table | Could |
| FR-9 | Inline editing of RACI cells (click cell to cycle through R/A/C/I/empty) | Must (Phase 2) |
| FR-10 | Validation: each step should have exactly one "A" (Accountable) — show warning if missing | Should (Phase 2) |

### Non-Functional Requirements

| ID | Requirement | Target |
|----|-------------|--------|
| NFR-1 | RACI view render time | < 200ms for processes with up to 50 steps |
| NFR-2 | Mobile responsiveness | Horizontal scroll on small screens, sticky first column |
| NFR-3 | Accessibility | Table uses proper `<th>` headers, ARIA roles, keyboard navigable |

## User Stories

1. As a **department manager**, I want to toggle to a RACI view of any swimlane process so that I can quickly see accountability assignments without interpreting a flow diagram.
2. As a **process owner**, I want to assign RACI designations to each step so that roles beyond "Responsible" (Accountable, Consulted, Informed) are documented.
3. As a **compliance officer**, I want to see a warning when a process step lacks an Accountable party so that governance gaps are flagged automatically.
4. As a **viewer**, I want to see a color-coded RACI matrix so that I can scan responsibilities at a glance.

## Acceptance Criteria

- [ ] A "RACI View" / "Flow View" toggle button appears in ProcessFlow toolbar when viewing a process
- [ ] Clicking the toggle switches between the ReactFlow diagram and the RACI matrix table
- [ ] The RACI matrix rows correspond to process step nodes (task, gateway, event), ordered by flow sequence
- [ ] The RACI matrix columns correspond to unique roles/lanes extracted from node data
- [ ] For swimlane processes without explicit RACI data, the lane assignment appears as "R" in the correct cell
- [ ] RACI cells are color-coded by designation type
- [ ] Processes with `type === 'RACI'` open in RACI View by default
- [ ] The RACI matrix is read-only in Phase 1; no edits can be made to cells
- [ ] The view works correctly for processes with 1-50 steps and 1-10 roles
- [ ] The table is horizontally scrollable on mobile with a sticky step-name column

## Out of Scope

- **RACI editing UI** — Deferred to Phase 2. Phase 1 is read-only.
- **RACI for non-swimlane process types** — Only swimlane and RACI process types are supported initially. Customer Journey, Top-to-Bottom, and ERD types are excluded.
- **RACI-VS or RACI-VR variants** — Only the standard four designations (R, A, C, I) are supported.
- **RACI-based process creation wizard** — Users cannot create a new process starting from a RACI matrix. They must create a swimlane process first.
- **PDF export of RACI matrix** — CSV/markdown export may be added, but PDF rendering is out of scope.

## Technical Design

### Architecture Impact

**Files to modify:**
- `src/components/ProcessFlow.tsx` — Add view toggle state, conditionally render RaciMatrix or ReactFlow, extract step ordering logic
- `src/types.ts` — Add `RaciDesignation` type and extend `ProcessNode.data` type hint (the `[key: string]: any` already allows `raci`, but explicit typing improves DX)

**New files:**
- `src/components/RaciMatrix.tsx` — New component: accepts `nodes[]`, `edges[]`, renders the RACI table
- `src/components/RaciCell.tsx` — Small presentational component for a single RACI cell with color coding (reusable for Phase 2 editing)

### Data Model Changes

No Firestore schema changes required. RACI data is stored within the existing `ProcessNode.data` object (which uses `[key: string]: any`). The `content` JSON string in the `Process` document already serializes all node data, so RACI assignments persist automatically.

New shape within `ProcessNode.data`:
```typescript
{
  label: string;
  lane?: string;
  raci?: Record<string, 'R' | 'A' | 'C' | 'I'>; // key = role/lane name
}
```

### API Changes

None. All data flows through existing Firestore document reads/writes.

### Dependencies

No new external libraries required. The RACI matrix is a plain HTML table styled with Tailwind CSS.

## Implementation Phases

### Phase 1: Read-Only RACI Matrix View
**Goal:** Users can toggle to a RACI matrix table for any swimlane process, with auto-derived Responsible assignments.
**Estimated Scope:** Medium

Tasks:
- [ ] Create `RaciMatrix.tsx` component that accepts nodes and edges
- [ ] Implement step ordering: topological sort of nodes using edges to determine flow sequence
- [ ] Extract unique roles from `node.data.lane` across all nodes
- [ ] Build table rendering: rows = ordered steps, columns = roles, cells = RACI designation
- [ ] Auto-derive "R" from lane assignment when `node.data.raci` is absent
- [ ] Create `RaciCell.tsx` with color-coded display (R=blue, A=red, C=yellow, I=gray)
- [ ] Add view toggle button to ProcessFlow toolbar (between info card and AI actions)
- [ ] Default to RACI View when `process.type === 'RACI'`
- [ ] Add horizontal scroll wrapper with sticky first column for mobile
- [ ] Ensure proper table semantics and accessibility attributes

Acceptance Criteria:
- [ ] Toggle button appears and switches views without page reload
- [ ] RACI table renders correctly for a swimlane process with 3+ lanes and 5+ steps
- [ ] Lane assignments appear as "R" in the correct role column
- [ ] Color coding visually distinguishes R, A, C, I designations
- [ ] Table is usable on mobile (horizontal scroll, sticky step column)

### Phase 2: RACI Inline Editing
**Goal:** Editors and admins can assign and modify RACI designations directly in the matrix view.
**Estimated Scope:** Medium

Tasks:
- [ ] Make `RaciCell.tsx` interactive: click cycles through R → A → C → I → empty
- [ ] Gate editing behind role check (admin/editor only; viewer sees read-only)
- [ ] On cell change, update `node.data.raci` in local state
- [ ] Save changes to Firestore via existing `saveProcess` pattern in ProcessFlow
- [ ] Add validation warning banner: "Step X has no Accountable party"
- [ ] Add "Add Role" column action to include roles not in swimlane lanes
- [ ] Add undo support (revert last cell change)

Acceptance Criteria:
- [ ] Clicking a RACI cell as an editor cycles through designations
- [ ] Viewers cannot modify cells (click does nothing or shows tooltip)
- [ ] Changes persist to Firestore after save
- [ ] Warning appears when any step lacks an "A" designation
- [ ] A new role column can be added that doesn't correspond to an existing lane

### Phase 3: RACI Export and Polish
**Goal:** Users can export the RACI matrix and benefit from UX refinements.
**Estimated Scope:** Small

Tasks:
- [ ] Add "Export as CSV" button to RACI view toolbar
- [ ] Add "Copy as Markdown" button to RACI view toolbar
- [ ] Add RACI legend/key to the view
- [ ] Add summary row showing count of R/A/C/I per role
- [ ] Add summary column showing count of R/A/C/I per step

Acceptance Criteria:
- [ ] CSV download contains correct RACI data with headers
- [ ] Markdown copy produces a valid markdown table in clipboard
- [ ] Legend clearly explains color coding
- [ ] Summary counts are accurate

## Success Metrics

| Metric | Current | Target | How to Measure |
|--------|---------|--------|----------------|
| RACI view adoption | 0% (doesn't exist) | 30% of process views include RACI toggle | Analytics event on toggle click |
| External RACI spreadsheets | Unknown (assumed common) | Reduce by 50% | User survey post-launch |
| Time to answer "who is accountable for step X?" | Minutes (read diagram + infer) | Seconds (scan RACI table) | User testing |

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Existing processes have no explicit RACI data | High | Low | Auto-derive "R" from lane assignments; RACI view works immediately without migration |
| Step ordering may be ambiguous for processes with parallel branches | Medium | Medium | Use topological sort; parallel steps appear in group with a note |
| Users confuse "lane assignment" with "full RACI" | Medium | Low | Show a notice in Phase 1: "Showing auto-derived Responsible assignments. Edit RACI in Phase 2." |
| Large processes (50+ steps) make the table unwieldy | Low | Medium | Add column/row freezing; consider pagination or collapsible sections in Phase 3 |

## Open Questions

- [ ] Should gateway nodes (decision points) appear as rows in the RACI matrix, or only task/event nodes? — Leaning toward including them since decisions have accountability too.
- [ ] Should the RACI view be available when creating a new process (empty state), or only for existing processes? — Start with existing processes only.

## Implementation Notes

*To be added during execution.*

---
*PRD created: 2026-03-23*
