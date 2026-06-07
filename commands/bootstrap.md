---
description: "Scaffold project — .claude/, CLAUDE.md, .prd/, rules, deploy config"
argument-hint: "[--update]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
  - Bash
---

# /cks:bootstrap

Orchestrate project bootstrapping by dispatching phase agents.
Each agent has `skills: cicd-starter` loaded at startup for domain expertise.

## Re-run Detection

Check for existing bootstrap artifacts:
- If `CLAUDE.md` AND `.prd/PRD-STATE.md` exist → ask:
  ```
  AskUserQuestion:
    question: "Project already bootstrapped. How to proceed?"
    options:
      - "Update — re-scan and merge changes (Recommended)"
      - "Regenerate — archive existing and start fresh"
      - "Cancel"
  ```
  - Update: dispatch bootstrap-scanner with `--update` mode
  - Regenerate: archive existing files, then fresh run
  - Cancel: exit
- If `.bootstrap/scan-context.md` exists but `CLAUDE.md` does not → resume from Phase 2
- Otherwise → fresh run

## Phase Execution

### Phase 1: Scan & Intake

```
Agent(subagent_type="cks:bootstrap-scanner", prompt="Scan the codebase and run guided intake. Read kickstart artifacts from .kickstart/ if they exist. Write scan results to .bootstrap/scan-context.md. Arguments: $ARGUMENTS")
```

Wait for completion. Verify `.bootstrap/scan-context.md` exists.

### Phase 1.5: Feature Cataloging (when kickstart features exist)

If `.kickstart/artifacts/FEATURE-ROADMAP.md` exists:

```
Agent(subagent_type="cks:feature-cataloger", prompt="Scan codebase and catalog features. Kickstart feature roadmap detected at .kickstart/artifacts/FEATURE-ROADMAP.md — pre-populate candidates from that file, then confirm each with the user via AskUserQuestion. Write .bootstrap/features-catalog.md before completing.")
```

If `.kickstart/artifacts/FEATURE-ROADMAP.md` does not exist → skip this phase.

After cataloger returns: `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "bootstrap.cataloged" "bootstrap" "Feature catalog written"`

### Phase 2: Generate

```
Agent(subagent_type="cks:bootstrap-generator", prompt="Generate all bootstrap outputs from .bootstrap/scan-context.md. Read kickstart artifacts from .kickstart/ if they exist. Generate: CLAUDE.md, .prd/, .context/, .claude/rules/, MCP config, deploy config.")
```

### Phase 2.5: Create Phase Stubs

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/create-phase-stubs.sh
```

No-op when `.bootstrap/features-catalog.md` absent — script exits 0 silently. After script returns: `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "bootstrap.stubs_created" "bootstrap" "Phase stubs created"`

### Completion

Verify `CLAUDE.md` exists with project-specific content (no template placeholders).
Display summary of generated files and next steps.

Then offer the per-project conversational channel (optional, non-blocking):

```
· · · · · · · · · · · · · · · · · · · · · · · ·
💡 SUGGESTION
· · · · · · · · · · · · · · · · · · · · · · · ·
Give this project its own always-on Telegram agent: /cks:telegram setup
· · · · · · · · · · · · · · · · · · · · · · · ·
```
