# Workflow: Bootstrap

## Overview

Scan an existing codebase, run a guided intake with pre-filled answers, generate CLAUDE.md, and initialize the .prd/ lifecycle.

## Pre-Conditions

- Working directory is a project with source code
- No specific file requirements — the scan detects what exists

## Steps

### Step 1: Re-run Check

Check if `CLAUDE.md` exists:

- **If exists** → ask via AskUserQuestion:
  - "Update it" → re-scan, merge new findings
  - "Regenerate from scratch" → full re-run
  - "Cancel" → stop
- **If not** → fresh run, proceed to Step 2

### Step 2: Codebase Scan

Silently analyze the project. Store findings internally — don't write files yet.

**Detect stack:**
```bash
ls package.json pyproject.toml Cargo.toml go.mod composer.json Gemfile 2>/dev/null
```

If `package.json`: read `dependencies`, `devDependencies`, `scripts`. Detect framework (Next.js, React, Vue, Express, etc.)
If `pyproject.toml` or `requirements.txt`: detect framework (Django, FastAPI, Flask, etc.)
If `Cargo.toml`: Rust. If `go.mod`: Go.

**Detect patterns:**
```bash
# Auth
grep -rl "clerk\|supabase.*auth\|next-auth\|passport\|jwt\|bcrypt" src/ app/ lib/ 2>/dev/null | head -5

# Database
grep -rl "prisma\|drizzle\|typeorm\|sequelize\|mongoose\|supabase\|firebase" src/ app/ lib/ 2>/dev/null | head -5

# API routes
ls src/app/api/ app/api/ pages/api/ routes/ 2>/dev/null

# Testing
ls jest.config* vitest.config* pytest.ini cypress.config* playwright.config* 2>/dev/null

# CI/CD
ls .github/workflows/*.yml Dockerfile docker-compose.yml railway.toml vercel.json netlify.toml 2>/dev/null

# Env vars referenced
grep -roh 'process\.env\.\w\+\|import\.meta\.env\.\w\+' src/ app/ lib/ 2>/dev/null | sort -u
```

**Detect structure:**
```bash
ls -d src/ app/ lib/ components/ pages/ routes/ utils/ hooks/ services/ 2>/dev/null
find . -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.py" -o -name "*.rs" -o -name "*.go" | grep -v node_modules | wc -l
```

### Step 3: Guided Intake

Present scan findings. Ask questions **one at a time** using AskUserQuestion with selectable options. Pre-fill from scan.

**Q1: Project Identity**

Show the scan summary first:
```
I scanned your codebase:

  Stack:     {detected framework + language}
  Database:  {detected or "none detected"}
  Auth:      {detected or "none detected"}
  Files:     {count} source files
  Tests:     {detected framework or "none"}

What's the project name?
```

**Q2: Description**
```
What does {project_name} do? (1-3 sentences)
```

**Q3: Stack Confirmation**
```
I detected: {stack details}

Is this correct?
```
Options: `Correct` | `Let me adjust`

**Q4: Key Workflows**
```
What do you mainly work on in this codebase?
```
Options (generated from detected patterns): e.g., `Build UI components` | `Write API endpoints` | `Add features` | `Fix bugs` | `Other`

**Q5: Env Vars**
```
I found these env vars in code: {list}

Any missing? Which are required vs optional?
```

**Q6: Rules**
```
Any rules Claude must always follow?
```
Options: `None` | `Let me list them`

**Q7: Deployment**
```
I detected: {CI/CD platform or "no deployment config"}

Where does this deploy?
```
Options: `Railway` | `Vercel` | `Netlify` | `Docker` | `Not configured yet` | `Other`

### Step 4: Generate CLAUDE.md

Read `references/claude-md-template.md` for structure. Fill every section with real content from scan + intake:

```markdown
# {Project Name}

## What This Project Is
{Q2 answer}

## Stack
- **{Framework}**: {How Claude should interact — from scan}
- **{Database}**: {ORM/client detected, conventions}
- **{Auth}**: {Pattern detected}
- **{Testing}**: {Framework + run command from package.json scripts}
- **{Deployment}**: {Platform from Q7}

## Key Workflows
{From Q4, each as a subsection with what Claude does}

## Commands Available
- `/cks:go dev` — Start development server
- `/cks:go build` — Run build
- `/cks:go` — Build + commit + push + PR
- `/cks:ship` — Full ship ceremony
- `/cks:discuss` — Plan a new feature
- `/cks:doctor` — Health check
- `/cks:status` — Project dashboard
- `/cks:help` — All available commands

## Always Follow These Rules
{From Q6 + defaults}
- Do not commit secrets or env var values
- Do not modify production database without explicit confirmation

## Environment Variables
{From Q5 — names with purpose, never values}

## Do Not
- Modify production database without explicit confirmation
- Commit secrets or env var values
- Deploy without passing health check
```

**Validation:** Before writing, check:
- Zero `[PLACEHOLDER]` tokens
- Every section has real content
- Stack section matches detected framework

### Step 5: Initialize .prd/

```bash
mkdir -p .prd
```

Write `.prd/PRD-STATE.md`:
```markdown
# PRD Session State

**Last Updated:** {today}

## Current Position
- **Active Phase:** —
- **Phase Name:** —
- **Phase Status:** idle
- **Last Action:** Project bootstrapped
- **Last Action Date:** {today}
- **Next Action:** Start first feature
- **Suggested Command:** /cks:discuss

## Feature History
| PRD | Feature | Phases | Status |
|-----|---------|--------|--------|

## Session History
| Date | Phase | Action | Result |
|------|-------|--------|--------|
| {today} | — | Project bootstrapped | CLAUDE.md generated |
```

Write `.prd/PRD-PROJECT.md` from scan + intake context.
Write `.prd/PRD-ROADMAP.md` (empty structure, ready for features).

### Step 6: Create .context/config.md

If technologies detected, create `.context/config.md` with preferred doc sites:

```bash
mkdir -p .context
```

```markdown
---
sources:
  - context7
  - firecrawl
  - websearch
  - webfetch
auto-research: true
max-lines: 200
preferred-sites:
  {auto-populated: e.g., nextjs.org/docs, supabase.com/docs based on stack}
---
# Context Research Config
```

Skip if no specific technologies detected.

### Step 7: Report

```
✅ /cks:bootstrap complete!

Generated:
  CLAUDE.md                  Project instructions
  .prd/PRD-STATE.md          Lifecycle initialized
  .prd/PRD-PROJECT.md        Project context
  .prd/PRD-ROADMAP.md        Ready for features
  .context/config.md         Research sources configured

Detected:
  Stack:    {summary}
  Files:    {count} source files
  Env vars: {count} referenced
  Tests:    {framework or "none"}

Next:
  /cks:go dev      Start dev server
  /cks:discuss     Plan your first feature
  /cks:help        See all commands
```

## Post-Conditions
- `CLAUDE.md` exists with zero placeholders
- `.prd/` initialized with idle state
- `.context/config.md` created (if technologies detected)
- No source code was modified
