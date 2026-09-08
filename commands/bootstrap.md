---
description: "Scaffold project — .claude/, CLAUDE.md, .prd/, rules, deploy config"
argument-hint: "[--update] [--dismiss <id>]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
  - Bash
---
# /cks:bootstrap
Orchestrate project bootstrapping by dispatching phase agents. Each agent has `skills: cicd-starter` loaded at startup.
## Dismiss Mode
If `$ARGUMENTS` contains `--dismiss <id>` (check BEFORE Re-run Detection and the phases). Known detector IDs: `fastapi-frontend`.
1. Parse `<id>`. If not a known ID → print `Unknown detector ID: <id>. Known IDs: fastapi-frontend` and exit.
2. `mkdir -p .bootstrap`. If `.bootstrap/DISMISSED-DETECTION.md` is absent, create it with the header `# Bootstrap Detection Dismissals`, one paragraph (`This file records detector suggestions you've dismissed. Bootstrap reads this on every run to suppress re-emit. Delete an entry (or this file) to re-enable a suggestion.`), an `## Entries` heading and the table header `| Detector ID | Dismissed On | Notes |` / `|---|---|---|`.
3. If `<id>` already appears in the file → print `Already dismissed: <id>` and exit 0.
4. Append `| <id> | $(date +%Y-%m-%d) | Dismissed via --dismiss flag |`, print `Dismissed: <id>. Suggestion will not appear on future bootstrap runs.`, and exit — do NOT proceed further.
## Re-run Detection
- `CLAUDE.md` AND `.prd/PRD-STATE.md` exist → `AskUserQuestion: "Project already bootstrapped. How to proceed?"` with options `Update — re-scan and merge changes (Recommended)` (dispatch `cks:operator` scan mode with `--update`), `Regenerate — archive existing and start fresh`, `Cancel` (exit).
- `.bootstrap/scan-context.md` exists but `CLAUDE.md` does not → resume from Phase 2.
- Otherwise → fresh run.
## Phase 1: Scan & Intake
```
Agent(subagent_type="cks:operator", prompt="Scan the codebase and run guided intake. Read kickstart artifacts from .kickstart/ if they exist. Write scan results to .bootstrap/scan-context.md. Arguments: $ARGUMENTS")
```
Wait for completion. Verify `.bootstrap/scan-context.md` exists.
## Phase 1.5: Feature Cataloging (only when `.kickstart/artifacts/FEATURE-ROADMAP.md` exists)
```
Agent(subagent_type="cks:strategist", prompt="Scan codebase and catalog features. Kickstart feature roadmap detected at .kickstart/artifacts/FEATURE-ROADMAP.md — pre-populate candidates from that file, then confirm each with the user via AskUserQuestion. Write .bootstrap/features-catalog.md before completing.")
```
After cataloger returns: `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "bootstrap.cataloged" "bootstrap" "Feature catalog written"`
## Phase 2: Generate
```
Agent(subagent_type="cks:operator", prompt="Generate all bootstrap outputs from .bootstrap/scan-context.md. Read kickstart artifacts from .kickstart/ if they exist. Generate: CLAUDE.md, .prd/, .context/, .claude/rules/, MCP config, deploy config. (7) Write .prd/NORTH-STAR.md and .finops/BUDGET.md from the templates if absent; never overwrite existing ones.")
```
## Phase 2.5: Create Phase Stubs
`bash ${CLAUDE_PLUGIN_ROOT}/scripts/create-phase-stubs.sh` — no-op (exit 0, silent) when `.bootstrap/features-catalog.md` is absent. Then: `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "bootstrap.stubs_created" "bootstrap" "Phase stubs created"`
## Completion
Verify `CLAUDE.md` exists with project-specific content (no template placeholders). Display the generated files and next steps.
Check for the `last30days` plugin: `ls -d ~/.claude/plugins/*/*last30days* ~/.claude/plugins/*/*/*last30days* ~/.claude/skills/last30days* 2>/dev/null | grep -q .` — if it does NOT match, show:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
▶ ACTION REQUIRED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Run:    /plugin marketplace add mvanhorn/last30days-skill
Why:    the researcher role uses it for social and market signals
Then:   continue
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
Then two optional `💡 SUGGESTION` blocks (one per box, format per `.claude/rules/human-intervention.md`):
- `Give this project its own always-on Telegram agent: /cks:telegram setup`
- `Speed up exploration: /cks:codegraph install — cuts ~47% tokens and ~58% tool calls on codebase queries across Discover and Sprint phases. Opt-in, fully reversible.`
## Quick Reference
`/cks:bootstrap` (fresh or resume) · `/cks:bootstrap --update` (re-scan and merge) · `/cks:bootstrap --dismiss fastapi-frontend`
