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
Parse `$ARGUMENTS`. `--type feature` or `--type task` → `Agent(subagent_type="cks:project-manager", prompt="Subcommand: new. Args: --type {feature|task} --title \"{brief}\" [--parent {ID}]")` and stop. `--type phase` or no `--type` → continue. With `--parent F-XX`, register the phase as `P-NN` under that Feature after the discoverer returns.

## Step 0: Open Issues Soft Warning
`git remote get-url origin` → owner/repo. List open issues labeled `cks:auto-filed` via `mcp__plugin_github_github__list_issues`; show titles + numbers, never block. GitHub MCP unavailable → skip silently.

## Step 1: Initialize Project (if needed)
Read `.prd/PRD-STATE.md`. If `.prd/` is missing → create `PRD-STATE.md`, `PRD-PROJECT.md`, `PRD-ROADMAP.md`; read `CLAUDE.md` and `package.json` for context. `PRD-STATE.md` needs an `## Attractor State` section (template `tools/prd-state.md`: `attractor_mode`, `current_node`, `node_history`, `github_phase_item_id`, `run_id`, `last_sync`, all `—`, `attractor_mode` mirroring `.claude-plugin/plugin.json`) — append it if absent.

## Step 2: Select or Create Feature
`$ARGUMENTS` → feature brief. None → `AskUserQuestion` listing features from `PRD-ROADMAP.md` plus "New feature — describe something not on the roadmap".

## Step 3: Create Feature Entry
`slug=$(echo "$ARGUMENTS" | tr '[:upper:]' '[:lower:]' | sed -e 's/[^a-z0-9]\+/-/g' -e 's/^-\|-$//g')`

**Pre-catalog detection** — if `.prd/PRD-ROADMAP.md` exists: for each row `| NN | name |` (`grep -E '^\| ?[0-9]{2} \|'`), kebab-normalize `name` the same way and compare to `$slug`; count matches.
- Zero → new slot: `{NN}` = next two-digit number in `PRD-ROADMAP.md` (`01` if empty/absent); `mkdir -p .prd/phases/{NN}-{slug}/`; append the roadmap entry.
- One → reuse `NN` + kebab: `mkdir -p .prd/phases/{NN}-{kebab}/` (idempotent); no roadmap append.
- Two or more → `❓ DECISION REQUIRED` listing each candidate (NN + name); exit without state mutation.

Both paths: set `PRD-STATE.md` `active_phase = {NN}`, `status = discovering`; set Phase `{NN}` to "Discovering" in `PRD-ROADMAP.md`. Validate directory + both files; retry once, then stop and report. Log: `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "feature.created|feature.reused" "{NN}-{slug}" "Feature {created|slot reused}: {NN} — {name}"`.

## Step 3b: GitHub Project Phase Item (Attractor-mode only)
Read `${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json`. `attractor_mode` false OR `github_project.number` 0 → skip silently. Otherwise: create the issue via `mcp__plugin_github_github__issue_write` (title `[Phase {NN}] {feature-name}`, labels `type:feature`, `phase:{NN}`, body = brief); link it with `moveCard` / `setCustomField` from `tools/github-project-sync.js` if available; write `github_phase_item_id: {issue-number}` into the `Attractor State` table.

## Step 3c: Wiki Prior-Art Lookup (if attractor_mode off)
`Agent(subagent_type="cks:historian", prompt="search {slug} to find prior art from closed phases. Return a one-paragraph summary for the discoverer.")` → `prior_art`, or `"(no prior art found)"`.

## Step 3.5: Pre-flight Gate (mandatory — `.claude/rules/preflight.md`)
Glob `.preflight/{NN}-*/PREFLIGHT.md` and read its `Cleared for takeoff` line. `AskUserQuestion` (`header: "Phase 1 Gate"`): missing or `NO` → `Run pre-flight (Recommended)` / `Stop — I'll come back`; found with `YES` → `Skip — already done (Recommended)` / `Re-run pre-flight`. No "proceed without" option. On Run / Re-run:
`Agent(subagent_type="cks:architect", prompt="Mode: preflight — feature {slug}, phase {NN}. Read skills/agile-eagle/workflows/preflight.md; write .preflight/{NN}-{slug}/PREFLIGHT.md; return the Cleared for takeoff verdict.")`
Re-read the verdict from disk. `NO` → `▶ ACTION REQUIRED` naming each BLOCK gotcha, `Then: re-run /cks:preflight {NN}`; stop. Stop → end here. Only a `YES` on disk reaches Step 4.

## Step 4: Enter Phase 1: Discovery
Parse `--role=<role>` (default `coder`). `Agent(subagent_type="cks:strategist", prompt="Mode: discover. Run Phase 1: Discovery for phase {NN}. Read .prd/PRD-STATE.md for context. Gather all 11 Elements. Read workflows/discover-phase.md for step-by-step process. PREFLIGHT.md at {path} — read §R and §F before asking about dependencies and risks. Role: {role} — record it in CONTEXT.md. Prior art from wiki: {prior_art}. You MUST use AskUserQuestion interactively — do NOT run in autonomous mode.")`

## Step 5: Completion
After the discoverer returns: display Feature `{NN} — {name}`, Discovery ✅ complete, Next → `/cks:design {NN}`; then call `EnterPlanMode` — design presents its plan before executing.

## Quick Reference
`/cks:new "add Stripe webhook retry"` · `/cks:new --role=marketer` · `/cks:new --type task --parent F-03 "…"`
