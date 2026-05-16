---
description: "Create a new feature and start the 5-phase lifecycle — discover → design → sprint → review → release"
argument-hint: "[feature description] [--role=coder|marketer|analyst|devops] [--type feature|phase|task] [--parent ID]"
allowed-tools:
  - Read
  - Write
  - Agent
  - AskUserQuestion
  - Bash
  - EnterPlanMode
  - "mcp__plugin_github_github__list_issues"
  - "mcp__plugin_github_github__issue_write"
---

# /cks:new — New Feature → 5-Phase Lifecycle

## Step -1: Hierarchy Routing (--type / --parent)

Parse `$ARGUMENTS`. If `--type feature` or `--type task` → dispatch `Agent(subagent_type="cks:work-hierarchy-manager", prompt="Subcommand: new. Args: --type {feature|task} --title \"{brief}\" [--parent {ID}]")` and stop. If `--type phase` or no `--type` → continue (Steps 0–5). When `--parent F-XX` present, register phase as `P-NN` under that Feature after discoverer returns.

## Step 0: Open Issues Soft Warning

Run `git remote get-url origin` to parse owner/repo. List open issues labeled `cks:auto-filed` via `mcp__plugin_github_github__list_issues`. If any → show titles + numbers (do NOT block). If GitHub MCP unavailable → skip silently.

## Step 1: Initialize Project (if needed)

Read `.prd/PRD-STATE.md`. If `.prd/` missing → create `PRD-STATE.md`, `PRD-PROJECT.md`, `PRD-ROADMAP.md`. Read `CLAUDE.md` and `package.json` for context.

When creating `PRD-STATE.md`, scaffold an `## Attractor State` section so the runner's `readState`/`writeState`/`enterNode` helpers find a table to read/write. See `tools/prd-state.md` for the template — required fields: `attractor_mode`, `current_node`, `node_history`, `github_phase_item_id`, `run_id`, `last_sync` (all default to `—`, with `attractor_mode` mirroring `.claude-plugin/plugin.json`). If `PRD-STATE.md` already exists but lacks the section, append it before continuing.

## Step 2: Select or Create Feature

If `$ARGUMENTS` → use as feature brief. If none → `AskUserQuestion` listing features from `PRD-ROADMAP.md` plus "New feature — describe something not on the roadmap".

## Step 3: Create Feature Entry

If the selected feature already exists in `PRD-ROADMAP.md` with an assigned `{NN}` (e.g., from a prior bootstrap or adopt run):
- Use that existing `{NN}` — do NOT increment to a new number
- Check if `.prd/phases/{NN}-{kebab-name}/` already exists (created by bootstrap)
- If it exists: skip `mkdir`, go directly to steps 3 and 4 below
- If it does not exist: create as normal (step 2 below)

1. Determine phase number `{NN}`: reuse existing NN from roadmap if present, otherwise use next available number
2. Create `.prd/phases/{NN}-{kebab-name}/` (skip if already exists)
3. Update `PRD-STATE.md`: `active_phase = {NN}`, `status = discovering`
4. Update `PRD-ROADMAP.md`: set Phase `{NN}` status to "Discovering" (add entry if new, update if existing)

Validate: directory exists + `PRD-STATE.md` has `active_phase = {NN}` + `PRD-ROADMAP.md` has entry. Retry once on failure, then stop and report.

`bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "feature.created" "{NN}-{kebab-name}" "Feature created: {NN} — {name}"`

## Step 3b: GitHub Project Phase Item (Attractor-mode only)

Read `${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json`. Check `attractor_mode` and `github_project.number`.

**If `attractor_mode` is false OR `github_project.number` is 0:** skip silently — no action.

**If configured (attractor_mode opt-in):**
1. Parse owner/repo from `git remote get-url origin`
2. Create GitHub Issue via `mcp__plugin_github_github__issue_write`: title `[Phase {NN}] {feature-name}`, labels `type:feature` and `phase:{NN}`, body: brief feature description
3. Link issue to GitHub Project: agent calls `moveCard` / `setCustomField` from `tools/github-project-sync.js` if available
4. Write `github_phase_item_id: {issue-number}` into the `Attractor State` table in `.prd/PRD-STATE.md`

## Step 4: Enter Phase 1: Discovery

Parse `--role=<role>` from `$ARGUMENTS` (default `coder`). Pass role to discoverer so it records in `CONTEXT.md` for downstream skill loading.

`Agent(subagent_type="cks:prd-discoverer", prompt="Run Phase 1: Discovery for phase {NN}. Read .prd/PRD-STATE.md for context. Gather all 11 Elements. Read workflows/discover-phase.md for step-by-step process. Role: {parsed-role-or-coder} — record it in CONTEXT.md. You MUST use AskUserQuestion interactively — do NOT run in autonomous mode.")`

## Step 5: Completion

After discoverer returns:
1. Display: Feature `{NN} — {name}`, Discovery ✅ complete, Next → `/cks:design {NN}`.
2. Call `EnterPlanMode` — discovery is done; design will present its plan before executing.
