# GitHub Projects v2 Integration — CKS v5

> How CKS integrates with GitHub Projects v2 to synchronize sprint workflow state and automate release tracking.

## Overview

CKS v5 introduces optional integration with **GitHub Projects v2**, enabling the Attractor pipeline to automatically sync sprint state to a Kanban board. This integration is:

- **Opt-in** — Enabled via configuration in `plugin.json`
- **Graceful** — Operates locally when GitHub is unreachable
- **Non-blocking** — Release workflow proceeds even if GitHub calls fail
- **Null-configured** — When not configured, all sync calls no-op silently

The integration is powered by the `attractor_mode` flag (defaults to `false` in v5) and controlled by the `github_project` config block.

## Architecture

The integration connects `plugin.json` config → `tools/github-project-sync.js` → `agents/attractor-runner.md` → GitHub Projects v2 Kanban board.

**Node → Column Mapping:**

| Node | Column | Maps to |
|------|--------|---------|
| Discover | Ready | Ready to plan |
| Plan | In Progress | Planning in progress |
| Implement | In Progress | Development in progress |
| Verify | In Review | QA testing in progress |
| SprintReview | In Review | Awaiting human approval |
| Release | Done | Shipped to production |

**Sync behavior:**
- When `isConfigured()` is true (all config fields non-zero): `moveCard()` and `setCustomField()` update the board
- When `isConfigured()` is false: all GitHub calls become no-ops; pipeline runs fully local

## Setup

**Prerequisites:**
1. GitHub Project exists with Status field (columns: Backlog, Ready, In Progress, In Review, Done) and custom fields (Phase Number, Runner State, PR Count, Last Sync). See `.github/PROJECT-CONFIG.md` for IDs.
2. `GITHUB_TOKEN` env var set with `project` and `repo` scopes
3. `plugin.json` contains config block:
   ```json
   {
     "github_project": {
       "owner": "cardinalconseils",
       "repo": "claude-starter",
       "number": 4
     }
   }
   ```

**Getting a Phase Item ID:** Call `getPhaseItems()` to list all items, find by `phaseNumber`, store result in `.prd/PRD-STATE.md` under `github_phase_item_id`.

## Release Node

**What happens at release:**
1. Card moves to Done (`moveCard(itemId, "Done")`)
2. Child issues auto-close via `gh issue close <number>` for each in PRD-STATE
3. Release comment posted: `commentOnPhaseItem(itemId, "Released: <url>")`

**Error handling:** `GitHubUnreachableError` is caught and logged. Release is **never blocked** by GitHub connectivity — workflow completes locally even if GitHub is unreachable.

## Opt-Out

To disable GitHub Projects integration, either remove the `github_project` block from `plugin.json` or set `number: 0`. After either change:
- `isConfigured()` returns false
- All GitHub sync calls become no-ops
- Pipeline runs fully local
- No GITHUB_TOKEN required

## Troubleshooting

| Issue | Check / Fix |
|-------|-----------|
| Card not moving | `GITHUB_TOKEN` set? Token has `project` scope? `plugin.json` has `number > 0`? `.prd/PRD-STATE.md` has `github_phase_item_id`? |
| Release comment failed | Expected — `GitHubUnreachableError` caught. Release not blocked. Manually move card if needed. |
| Issues not closing | GitHub CLI installed? `gh auth` active? Child issue numbers in `.prd/PRD-STATE.md` `child_issues`? |

## API Reference

Functions in `tools/github-project-sync.js`:
- `isConfigured()` → boolean
- `getPhaseItems()` → array of {id, phaseNumber, title, column, url}
- `moveCard(itemId, toColumn)` → void
- `setCustomField(itemId, fieldName, value)` → void
- `commentOnPhaseItem(itemId, body)` → void
- `getPriorArt()` → array of completed phase items
- `GitHubUnreachableError` — custom error for connectivity issues

See `.github/PROJECT-CONFIG.md` for all IDs and GraphQL examples.
