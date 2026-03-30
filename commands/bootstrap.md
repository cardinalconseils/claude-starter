---
description: "Scaffold project — .claude/, CLAUDE.md, .prd/, rules, deploy config"
argument-hint: "[--update]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
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
Agent(subagent_type="bootstrap-scanner", prompt="Scan the codebase and run guided intake. Read kickstart artifacts from .kickstart/ if they exist. Write scan results to .bootstrap/scan-context.md. Arguments: $ARGUMENTS")
```

Wait for completion. Verify `.bootstrap/scan-context.md` exists.

### Phase 2: Generate

```
Agent(subagent_type="bootstrap-generator", prompt="Generate all bootstrap outputs from .bootstrap/scan-context.md. Read kickstart artifacts from .kickstart/ if they exist. Generate: CLAUDE.md, .prd/, .context/, .claude/rules/, MCP config, deploy config.")
```

### Completion

Verify `CLAUDE.md` exists with project-specific content (no template placeholders).
Display summary of generated files and next steps.
