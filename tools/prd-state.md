# PRD State — Read/Write Protocol

## File Location

`.prd/PRD-STATE.md` — single source of truth for lifecycle position.

## Fields

| Field | Valid Values | Example |
|-------|-------------|---------|
| Active Phase | `1`, `2`, `3`, `4`, `5`, `idle` | `3` |
| Phase Name | `Discover`, `Design`, `Sprint`, `Review`, `Release`, `Idle` | `Sprint` |
| Phase Status | `IN_PROGRESS`, `COMPLETED`, `BLOCKED` | `IN_PROGRESS` |
| Last Action | Free text describing what happened | `Sprint planning complete` |
| Last Action Date | `YYYY-MM-DD` | `2026-04-02` |
| Next Action | Free text describing what to do next | `Implement task 1 of 4` |
| Suggested Command | `/cks:{command}` | `/cks:sprint` |
| Iteration Count | Integer `0`+ | `1` |
| Iteration Reason | Free text or `—` | `Bugs found in review` |
| Secrets Tracking | `clean`, `not scanned`, or description | `clean` |
| Active PRD | Path to active feature dir or `—` | `.prd/phases/03-backend-api/` |

## Attractor State Table

The `## Attractor State` section in `.prd/PRD-STATE.md` is owned by `cks:attractor-runner`
and persists pipeline position across sessions. The runner's `readState` / `writeState` /
`enterNode` helpers read and write this table; if the section is absent, every helper
falls back to all-null defaults and the Kanban sync silently no-ops.

The initial scaffold (created by `/cks:new`, `/cks:bootstrap`, `/cks:adopt`) must include:

```markdown
## Attractor State

_Read/written by `cks:attractor-runner` during pipeline execution. Do not edit by hand._

| Field | Value |
|-------|-------|
| attractor_mode | false |
| current_node | — |
| node_history | — |
| github_phase_item_id | — |
| run_id | — |
| last_sync | — |
```

Field meanings:

| Field | Valid Values | Notes |
|-------|-------------|-------|
| attractor_mode | `true`, `false` | Mirrors `.claude-plugin/plugin.json:attractor_mode`. When false, all GitHub sync is no-op. |
| current_node | DOT node ID or `—` | Set by `runner.enterNode(nodeName)` at the start of every node. |
| node_history | Comma-separated node IDs or `—` | Append-only history of nodes the run has entered. |
| github_phase_item_id | GitHub issue number, GraphQL node ID, or `—` | Written by `/cks:new` Step 3b when attractor-mode is on. When `—` or null, all sync calls no-op. |
| run_id | UUID or `—` | Matches the directory under `.attractor/runs/<run_id>/`. |
| last_sync | ISO-8601 timestamp or `—` | Updated whenever a successful `moveCard` / `setCustomField` round-trip completes. |

## Reading State

Use `grep` + `sed` to extract fields (same pattern as session-start.sh):

```bash
PHASE=$(grep "Active Phase:" .prd/PRD-STATE.md | sed 's/.*: *//;s/\*//g' | xargs)
```

In an agent context, read the whole file and parse the fields from markdown.

## Updating State

**Always update these fields together after any phase action:**
1. `Phase Status` — new status
2. `Last Action` — what just happened
3. `Last Action Date` — today's date
4. `Next Action` — what should happen next
5. `Suggested Command` — the command to run next

**Update these only on phase transitions:**
- `Active Phase` + `Phase Name` — when moving to a new phase
- `Active PRD` — when the feature directory changes
- `Iteration Count` + `Iteration Reason` — when looping back to a previous phase

## Constraints

- Never delete fields — only update values
- Never rename fields — other hooks and agents parse by field name
- Always include the trailing space after the colon: `Field: value` not `Field:value`
- Markdown bold markers (`*`) around values are optional but must be handled by readers
