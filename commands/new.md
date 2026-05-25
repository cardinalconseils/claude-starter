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

Kebab-normalize the feature name: `slug=$(echo "$ARGUMENTS" | tr '[:upper:]' '[:lower:]' | sed -e 's/[^a-z0-9]\+/-/g' -e 's/^-\|-$//g')`

**Pre-catalog detection** — if `.prd/PRD-ROADMAP.md` exists, grep for existing slots:

```bash
# PRD-ROADMAP.md table rows have the form: | NN | name | ...
# Extract NN and kebab(name), compare to $slug
matches=$(grep -E '^\| ?[0-9]{2} \|' .prd/PRD-ROADMAP.md 2>/dev/null \
  | awk -F'|' '{print $2, $3}' \
  | while read nn name; do
      k=$(echo "$name" | tr '[:upper:]' '[:lower:]' | sed -e 's/[^a-z0-9]\+/-/g' -e 's/^-\|-$//g')
      [ "$k" = "$slug" ] && echo "$nn $k"
    done)
count=$(echo "$matches" | grep -c '[^ ]' 2>/dev/null || echo 0)
```

- **Zero matches** → fall through to next-available NN (new slot path below).
- **Exactly one match** → extract `NN` + `kebab`; `mkdir -p .prd/phases/{NN}-{kebab}/` (idempotent); skip roadmap append; log `feature.reused`.
- **Two or more matches** → emit `❓ DECISION REQUIRED` block listing each candidate (NN + name); exit without state mutation.

**New slot path** (zero matches or no roadmap):
1. Determine `{NN}`: next available two-digit number from `PRD-ROADMAP.md` (or `01` if roadmap empty/absent).
2. Create `.prd/phases/{NN}-{slug}/` directory.
3. Append entry to `PRD-ROADMAP.md`.

**Both paths — after NN resolved:**
4. Update `PRD-STATE.md`: `active_phase = {NN}`, `status = discovering`
5. Update `PRD-ROADMAP.md`: set Phase `{NN}` status to "Discovering" (add if new, update if existing)

Validate: directory exists + `PRD-STATE.md` has `active_phase = {NN}` + `PRD-ROADMAP.md` has entry. Retry once on failure, then stop and report.

Log event after successful resolution:
- Reused slot: `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "feature.reused" "{NN}-{slug}" "Feature slot reused: {NN} — {name}"`
- New slot: `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "feature.created" "{NN}-{slug}" "Feature created: {NN} — {name}"`

## Step 3b: GitHub Project Phase Item (Attractor-mode only)

Read `${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json`. Check `attractor_mode` and `github_project.number`.

**If `attractor_mode` is false OR `github_project.number` is 0:** skip silently — no action.

**If configured (attractor_mode opt-in):**
1. Parse owner/repo from `git remote get-url origin`
2. Create GitHub Issue via `mcp__plugin_github_github__issue_write`: title `[Phase {NN}] {feature-name}`, labels `type:feature` and `phase:{NN}`, body: brief feature description
3. Link issue to GitHub Project: agent calls `moveCard` / `setCustomField` from `tools/github-project-sync.js` if available
4. Write `github_phase_item_id: {issue-number}` into the `Attractor State` table in `.prd/PRD-STATE.md`

## Step 3c: Wiki Prior-Art Lookup (if attractor_mode off)

If `attractor_mode` is false, search wiki for prior art:

`Agent(subagent_type="cks:wiki", prompt="search {slug} to find prior art from closed phases. Return a one-paragraph summary for the discoverer.")`

Capture the result as `prior_art`. If wiki returns nothing, set `prior_art = "(no prior art found)"`.

## Step 4: Enter Phase 1: Discovery

Parse `--role=<role>` from `$ARGUMENTS` (default `coder`). Pass role to discoverer so it records in `CONTEXT.md` for downstream skill loading. Include prior art summary in discoverer prompt:

`Agent(subagent_type="cks:prd-discoverer", prompt="Run Phase 1: Discovery for phase {NN}. Read .prd/PRD-STATE.md for context. Gather all 11 Elements. Read workflows/discover-phase.md for step-by-step process. Role: {parsed-role-or-coder} — record it in CONTEXT.md. Prior art from wiki: {prior_art}. You MUST use AskUserQuestion interactively — do NOT run in autonomous mode.")`

## Step 5: Completion

After discoverer returns:
1. Display: Feature `{NN} — {name}`, Discovery ✅ complete, Next → `/cks:design {NN}`.
2. Call `EnterPlanMode` — discovery is done; design will present its plan before executing.
