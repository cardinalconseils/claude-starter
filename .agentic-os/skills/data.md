---
name: data
domain: Data
description: "Data skill for CKS — Claude Code Starter Kit — defines how Claude executes recurring data tasks: schemas, live sources, aggregations, memory layer, and exports"
---

# Data — Skill

## Purpose

Covers all data work: defining schemas, wiring live sources, building aggregations, feeding the memory layer with processed data, and exporting reports.

## Recurring Tasks

### Task: Define data schema

**When**: A new data entity, feed, or API response shape needs to be captured and agreed on before implementation.

**Output**: Schema definition file (JSON Schema, TypeScript type, or markdown spec) in `memory/wiki/schemas/`.

**Instructions**:
1. Identify the entity name, source, and consumers
2. List all fields: name, type, required/optional, example value
3. Write the schema in the project's preferred format (check existing files for convention)
4. Document constraints: max length, enum values, null semantics
5. Save to `memory/wiki/schemas/{entity}.md` and update `memory/index.md`

**Quality bar**: All fields documented with type + example; constraints explicit; schema saved to memory layer.

---

### Task: Wire live data source

**When**: A component or widget needs to consume a real API, database query, or computed feed.

**Output**: Data fetch or query implementation with error handling + loading state.

**Instructions**:
1. Confirm the data schema exists in `memory/wiki/schemas/` — create it first if not
2. Identify auth requirements (API key, OAuth, session token) — mask credentials, never hardcode
3. Implement the fetch/query with explicit error handling (not silent catch)
4. Add a loading/pending state visible to the consumer
5. Verify the live data matches the schema — log a warning if fields are missing or unexpected

**Quality bar**: No hardcoded credentials; error state visible to user; schema validation present.

---

### Task: Build aggregation query

**When**: Raw data needs to be summarized, grouped, counted, or transformed for display or reporting.

**Output**: Query or pipeline definition with sample output documented.

**Instructions**:
1. Read the source schema and identify the target shape (what does the consumer need?)
2. Write the query (SQL, JS reduce, pipeline step) as a named, reusable function
3. Add a comment stating WHAT the aggregation produces (not HOW it works)
4. Run against real or fixture data and document sample output in a comment
5. Save to the appropriate module; if reusable across domains, add to `memory/wiki/`

**Quality bar**: Aggregation is named and reusable; sample output documented; no magic numbers without explanation.

---

### Task: Add data to memory layer

**When**: Processed data, a report, or a reference dataset needs to be persisted in the memory layer for future Claude sessions.

**Output**: New file in `memory/wiki/` or `memory/output/` + updated `memory/index.md` entry.

**Instructions**:
1. Determine the correct folder: `wiki/` for reference/decisions, `output/` for deliverables
2. Name the file descriptively: `{date}-{topic}.md` or `{entity}-reference.md`
3. Write a one-line summary at the top of the file (Claude reads this to decide relevance)
4. Add an entry to `memory/index.md` under the Files section
5. Move any related `raw/` files to `wiki/` once they're codified — do not leave raw duplicates

**Quality bar**: `memory/index.md` updated; file has a one-line summary at top; no duplicate raw copies.

---

### Task: Export data report

**When**: A data summary or analysis needs to be packaged for sharing outside the project.

**Output**: Formatted report file in `memory/output/` (markdown, CSV, or JSON as appropriate).

**Instructions**:
1. Confirm the data source and aggregation are verified before exporting
2. Choose format based on consumer: markdown for humans, CSV/JSON for tools
3. Include a header with: report name, date, data source, and any caveats
4. Save to `memory/output/{date}-{report-name}.{ext}`
5. Add entry to `memory/index.md` and notify user of the file path

**Quality bar**: Report includes header with date + source; format matches consumer needs; `memory/index.md` updated.

---

## Context Sources

- `memory/wiki/schemas/` — data entity definitions
- `memory/raw/` — unprocessed data dumps, API response samples
- `memory/wiki/` — aggregation patterns, past query decisions

## Output Destinations

- Schemas → `memory/wiki/schemas/`
- Aggregation queries → source module or `memory/wiki/`
- Exported reports → `memory/output/`
- All new files → `memory/index.md` entry added
