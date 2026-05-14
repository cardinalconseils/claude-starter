---
description: "Create a new feature and start the 5-phase lifecycle — discover → design → sprint → review → release"
argument-hint: "[feature description] [--role=coder|marketer|analyst|devops] [--type feature|phase|task] [--parent ID]"
allowed-tools:
  - Read
  - Write
  - Agent
  - AskUserQuestion
  - Bash
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

## Step 2: Select or Create Feature

If `$ARGUMENTS` → use as feature brief. If none → `AskUserQuestion` listing features from `PRD-ROADMAP.md` plus "New feature — describe something not on the roadmap".

## Step 3: Create Feature Entry

1. Determine next phase number `{NN}` from `PRD-ROADMAP.md`
2. Create `.prd/phases/{NN}-{kebab-name}/`
3. Update `PRD-STATE.md`: `active_phase = {NN}`, `status = discovering`
4. Update `PRD-ROADMAP.md`: add Phase `{NN}` as "Discovering"

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

After discoverer returns, display: Feature `{NN} — {name}`, Discovery ✅ complete, Next → `/cks:design {NN}`.
