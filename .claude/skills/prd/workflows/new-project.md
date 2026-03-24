# Workflow: New Project Initialization

## Overview
Initializes the `.prd/` directory with all state files, gathers project context, and optionally starts the first feature discovery.

## Pre-Conditions
- Called from `/prd:new`
- May or may not have a `.prd/` directory already

## Steps

### Step 1: Check Existing State

```
Read .prd/PRD-PROJECT.md
Read .prd/PRD-STATE.md
```

- If `.prd/` exists and has a PROJECT.md → this is an existing project
  - Ask: "Project already initialized. Do you want to start a new feature, or reinitialize?"
  - If new feature → jump to Step 4
  - If reinitialize → warn about overwriting, proceed with confirmation

- If `.prd/` doesn't exist → fresh project, proceed to Step 2

### Step 2: Gather Project Context

Ask the user (adapt based on what you can detect from the codebase):

1. **What is this project?** (name, purpose, one-line description)
2. **Who are the users?** (primary audience, use cases)
3. **What's the tech stack?** (read from package.json, CLAUDE.md, or ask)
4. **What are the high-level goals?** (what are we building toward?)
5. **Any constraints?** (timeline, technical limitations, must-haves)

Proactively read these files to pre-fill context:
- `CLAUDE.md` — project conventions
- `package.json` — dependencies, scripts
- `README.md` — project description
- `tsconfig.json` or similar — tech stack signals

### Step 3: Create Planning Directory

Create `.prd/` with these files using the templates from `.claude/skills/prd/templates/`:

**PRD-PROJECT.md** — Read template from `.claude/skills/prd/templates/project.md`
Fill in from the gathered context.

**PRD-REQUIREMENTS.md** — Read template from `.claude/skills/prd/templates/requirements.md`
Start empty (populated as features are discussed).

**PRD-ROADMAP.md** — Read template from `.claude/skills/prd/templates/roadmap.md`
Start with empty sections. Also create/update `docs/ROADMAP.md` as a copy.

**PRD-STATE.md** — Read template from `.claude/skills/prd/templates/state.md`
Set initial state: `project_initialized`, no active phase.

Create the phase directory:
```
mkdir -p .prd/phases/
mkdir -p docs/prds/
```

### Step 4: Start First Feature (Optional)

Ask: "Would you like to start discussing your first feature now?"

If the user provided a feature brief as an argument to `/prd:new`:
- Create phase directory: `.prd/phases/01-{kebab-name}/`
- Update PRD-STATE.md: active_phase = 01, status = discussing
- Update PRD-ROADMAP.md: add Phase 01 as "Discussing"
- Dispatch the **prd-discoverer** agent with the brief

If no argument:
- Show the initialized project structure
- Suggest: "Run `/prd:discuss` when you're ready to start your first feature"

### Step 5: Report

Show the user:
```
Project initialized: {name}

Created:
  .prd/PRD-PROJECT.md     — Project context
  .prd/PRD-REQUIREMENTS.md — Requirements tracking
  .prd/PRD-ROADMAP.md     — Phase roadmap
  .prd/PRD-STATE.md       — Session state
  docs/ROADMAP.md          — Public roadmap

Next: Run /prd:discuss to start your first feature
```

## Post-Conditions
- `.prd/` directory exists with all 4 state files
- `docs/ROADMAP.md` exists
- PRD-STATE.md reflects current position
