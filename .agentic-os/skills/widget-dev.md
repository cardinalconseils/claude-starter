---
name: widget-dev
domain: Widget Dev
description: "Widget Dev skill for CKS — Claude Code Starter Kit — defines how Claude executes recurring dashboard widget tasks"
---

# Widget Dev — Skill

## Purpose

Covers all work to build and maintain dashboard widgets: creating new widgets, updating layout, wiring data sources, debugging rendering, and documenting the widget API.

## Recurring Tasks

### Task: Create new dashboard widget

**When**: A new metric, status, or data view needs a widget in the dashboard.

**Output**: Widget component file with data binding, layout slot, and a entry in `dashboard/index.html`.

**Instructions**:
1. Read `dashboard/index.html` to understand the existing card/grid pattern
2. Define the widget's data contract (props in, display out)
3. Scaffold the widget using the existing `.card` pattern — keep markup minimal
4. Wire a static placeholder first; confirm render before adding live data
5. Add the widget to the grid with a consistent label and section header

**Quality bar**: Widget renders without JS errors; follows existing card CSS pattern; no inline styles that duplicate existing classes.

---

### Task: Update widget layout

**When**: A widget needs to be resized, repositioned, or reordered in the dashboard grid.

**Output**: Updated `dashboard/index.html` with revised grid placement.

**Instructions**:
1. Read the current grid definition in `dashboard/index.html`
2. Identify the target widget by its section comment or `h3` label
3. Adjust `grid-template-columns`, `grid-column`, or card order as needed
4. Verify no other widgets are displaced — check all breakpoints mentally
5. Keep changes surgical — do not reformat unrelated cards

**Quality bar**: Layout change is isolated to the target widget; no unrelated HTML touched.

---

### Task: Add data source to widget

**When**: A widget needs to pull from a new API, DB query, or computed feed.

**Output**: Updated widget with data fetch logic and error/loading state.

**Instructions**:
1. Identify the data source type (REST API, localStorage, computed from DOM, etc.)
2. Add fetch logic scoped to the widget — do not pollute global scope
3. Handle loading state (show placeholder) and error state (show fallback text)
4. Store retrieved data in localStorage if it should persist across page loads
5. Document the data contract in a comment above the fetch block

**Quality bar**: Widget handles fetch failure gracefully; no unhandled promise rejections; data contract documented.

---

### Task: Debug widget rendering

**When**: A widget shows blank, stale, incorrect, or broken output.

**Output**: Root-cause fix with a one-line comment explaining why if non-obvious.

**Instructions**:
1. Open browser devtools console and read all errors before touching code
2. Trace the render path: data fetch → transform → DOM update
3. Add a `console.log` at each step to locate where data goes wrong — remove before committing
4. Fix the root cause — never add a `.catch(() => {})` to silence an error
5. Verify the fix by reloading the page and confirming the widget displays correctly

**Quality bar**: Root cause fixed (not silenced); no debug `console.log` left in committed code; widget renders correctly on reload.

---

### Task: Document widget API

**When**: A widget has props, data contracts, or configuration options that other developers need to understand.

**Output**: Inline JSDoc comment block above the widget + entry in `docs/widgets.md` (create if absent).

**Instructions**:
1. Identify all inputs (data props, config options, localStorage keys) the widget consumes
2. Write a JSDoc block above the widget definition: `@param`, `@returns`, `@example`
3. Add or update `docs/widgets.md` with a table row: widget name, inputs, outputs, data source
4. Keep docs co-located with the widget where possible — the JSDoc is the primary reference

**Quality bar**: All public inputs documented; `docs/widgets.md` entry present; no placeholder text left.

---

## Context Sources

- `dashboard/index.html` — existing widget patterns and grid layout
- `memory/wiki/` — architecture decisions about data sources and widget contracts
- `memory/raw/` — design notes, mockups, data feed specs

## Output Destinations

- Finished widgets → `dashboard/index.html`, committed to branch, PR opened
- Widget API docs → `docs/widgets.md`
- Architecture decisions → `memory/wiki/`
