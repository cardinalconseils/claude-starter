---
description: "Generate or update project documentation — API docs, architecture, component docs, onboarding guide"
argument-hint: "[api | arch | components | onboarding | all | --diff]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - Agent
  - Skill
  - AskUserQuestion
---

# /cks:docs — Documentation Generator

Generate or refresh project documentation from codebase analysis.

## Argument Handling

- No args or `all`: Generate/refresh all documentation types
- `api`: API endpoint documentation only
- `arch`: Architecture documentation only
- `components`: Component/module documentation only
- `onboarding`: Developer onboarding guide only
- `--diff`: Only document new/changed code since last tag

## Steps

### Step 1: Detect What Exists

```bash
# Check for existing docs
ls docs/api/ docs/architecture/ docs/components/ docs/onboarding.md 2>/dev/null
```

Read `.prd/PRD-STATE.md` if it exists — note the current phase for context.

### Step 2: Determine Scope

Based on `$ARGUMENTS`:
- `all` or no args → run all 4 doc types
- Specific type → run only that type
- `--diff` → check `git diff --name-only $(git describe --tags --abbrev=0 2>/dev/null || git rev-list --max-parents=0 HEAD)..HEAD` and only document changed files

### Step 3: Dispatch doc-generator Agent

```
Agent(subagent_type="doc-generator", prompt={
  project_root: {project_root},
  scope: {api|arch|components|onboarding|all},
  diff_only: {true|false},
  existing_docs: {list of existing doc files},
  claude_md: {CLAUDE.md content},
  prd_context: {PRD-PROJECT.md content if exists}
})
```

The agent handles all detection, scanning, and generation. See `agents/doc-generator.md` for details.

### Step 4: Report

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 DOCS ► Documentation Updated
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 Generated:
   {✅|⏭} API docs         — {N} endpoints documented
   {✅|⏭} Architecture     — layers, patterns, data flow
   {✅|⏭} Components       — {N} modules documented
   {✅|⏭} Onboarding       — getting started guide

 Location: docs/
 Stale docs removed: {N}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Output Structure

```
docs/
├── api/
│   ├── README.md              — API overview, auth guide, base URL
│   ├── endpoints/
│   │   ├── {resource}.md      — One file per resource group
│   │   └── ...
│   └── openapi.yaml           — OpenAPI 3.0 spec (if requested)
├── architecture/
│   ├── README.md              — Architecture overview
│   ├── data-flow.md           — How data moves through the system
│   └── decisions.md           — Key architectural decisions (ADRs)
├── components/
│   ├── README.md              — Component/module index
│   └── {module}.md            — One file per major module
└── onboarding.md              — Developer getting started guide
```

## When to Run

- Explicitly via `/cks:docs`
- Auto-triggered after Sprint [3g] if endpoints or architecture changed
- Auto-triggered during Release [5e] post-deploy
- Before onboarding a new developer
