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
---

# /cks:new — New Feature → 5-Phase Lifecycle

Create a new feature entry, then dispatch Phase 1: Discovery.

## Step -1: Hierarchy Routing (--type / --parent)

Parse `$ARGUMENTS` for `--type` and `--parent`.

- `--type feature` or `--type task` → delegate to the hierarchy manager and return. Do NOT enter the 5-phase lifecycle. Dispatch:
  ```
  Agent(subagent_type="cks:work-hierarchy-manager", prompt="Subcommand: new. Args: --type {feature|task} --title \"{brief}\" [--parent {ID}]")
  ```
  Display the agent's result and stop.

- `--type phase` or no `--type` → existing behavior (Steps 0–5 below). When `--parent F-XX` is present, also dispatch the manager to register the new phase as a `P-NN` under that Feature *after* the discoverer returns.

## Step 0: Open Issues Soft Warning

Before anything else, check for open CKS issues in the current repo:

```bash
git remote get-url origin  # parse owner/repo
```

Then list open issues labeled `cks:auto-filed` via `mcp__plugin_github_github__list_issues`.

If any open issues exist → display a brief warning (titles + numbers). Do NOT block. Continue to Step 1.
If GitHub MCP unavailable → skip silently.

## Step 1: Initialize Project (if needed)

Read `.prd/PRD-STATE.md`. If `.prd/` does not exist, initialize it:
- Create `.prd/PRD-STATE.md`, `PRD-PROJECT.md`, `PRD-ROADMAP.md`
- Read `CLAUDE.md` and `package.json` for project context

If `.prd/` exists, read existing state.

## Step 2: Select or Create Feature

If `$ARGUMENTS` provided → use as the feature brief.

If no arguments → read `PRD-ROADMAP.md` for available features:
```
AskUserQuestion:
  question: "Which feature would you like to build?"
  options:
    - "{PRD-001: feature name}" (from roadmap)
    - "{PRD-002: feature name}" (from roadmap)
    - "New feature — describe something not on the roadmap"
```

## Step 3: Create Feature Entry

1. Determine next phase number `{NN}` from PRD-ROADMAP.md
2. Create directory: `.prd/phases/{NN}-{kebab-name}/`
3. Update `PRD-STATE.md`: `active_phase = {NN}`, `status = discovering`
4. Update `PRD-ROADMAP.md`: add phase as "Discovering"

**Validation — mandatory:** Verify before proceeding:
- `.prd/phases/{NN}-{kebab-name}/` directory exists
- `PRD-STATE.md` has `active_phase` set to `{NN}`
- `PRD-ROADMAP.md` has entry for Phase `{NN}`

If validation fails, retry once. If it fails again, stop and report.

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "feature.created" "{NN}-{kebab-name}" "Feature created: {NN} — {name}"`

## Step 4: Enter Phase 1: Discovery

Parse `--role=<role>` from `$ARGUMENTS` if present (default `coder`). Pass it to the discoverer so the downstream sprint loads role-appropriate skills.

Role mapping:
- `coder` → prd, incremental-implementation, testing-discipline, debug, code-simplification
- `marketer` → ai-marketing, brand-marketing, online-marketing, product-marketing
- `analyst` → repo-exploration, deep-research, observability, monitoring
- `devops` → cicd-starter, shipping-checklist, environment-management, security-hardening, ciso

```
Agent(subagent_type="cks:prd-discoverer", prompt="Run Phase 1: Discovery for phase {NN}. Read .prd/PRD-STATE.md for context. Gather all 11 Elements. Read workflows/discover-phase.md for step-by-step process. Role: {parsed-role-or-coder} — record it in CONTEXT.md so downstream phases load only that role's skills. You MUST use AskUserQuestion interactively — do NOT run in autonomous mode.")
```

## Step 5: Completion & Next Step

After the discoverer agent returns, read `.prd/PRD-STATE.md` and display:

```
/cks:new complete
━━━━━━━━━━━━━━━━━
  Feature: {NN} — {name}
  Directory: .prd/phases/{NN}-{kebab-name}/
  Discovery: ✅ complete

  Next → /cks:design {NN}
  (Run /compact first if the conversation is long)
```
