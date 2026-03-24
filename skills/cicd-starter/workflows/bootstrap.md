# Workflow: Bootstrap

## Overview

Lightweight scan, heavy configuration. Detects everything about an existing codebase, asks minimal questions (confirm/correct), then configures ALL CKS infrastructure for the project.

**No research. No monetization. No PRD/ERD/architecture.** Those are kickstart's job.

## Pre-Conditions

- Working directory has source code
- CKS plugin is installed

## Steps

### Step 1: Re-run Check

Check if `CLAUDE.md` exists:

- **If exists** → ask: "Update", "Regenerate", or "Cancel"
- **If not** → fresh run

---

### Step 2: Codebase Scan

Silently detect everything. Store findings — don't write files yet.

**2a. Project manifest:**
```bash
ls package.json pyproject.toml Cargo.toml go.mod composer.json Gemfile pom.xml 2>/dev/null
```

If `package.json`: read `dependencies`, `devDependencies`, `scripts`. Detect framework.
If `pyproject.toml` / `requirements.txt`: detect Python framework.
If `Cargo.toml`: Rust. If `go.mod`: Go.

**2b. Framework + patterns:**
```bash
# Auth
grep -rl "clerk\|supabase.*auth\|next-auth\|passport\|jwt\|bcrypt\|lucia\|authjs" src/ app/ lib/ 2>/dev/null | head -5

# Database / ORM
grep -rl "prisma\|drizzle\|typeorm\|sequelize\|mongoose\|supabase\|firebase\|knex" src/ app/ lib/ 2>/dev/null | head -5

# API routes
ls -d src/app/api/ app/api/ pages/api/ routes/ server/ 2>/dev/null

# State management
grep -rl "zustand\|redux\|recoil\|jotai\|mobx\|pinia\|vuex" src/ app/ lib/ 2>/dev/null | head -3

# Styling
grep -rl "tailwind\|styled-components\|emotion\|sass\|less" . --include="*.config.*" --include="*.css" 2>/dev/null | head -3

# Testing
ls jest.config* vitest.config* pytest.ini .pytest_cache cypress.config* playwright.config* 2>/dev/null

# Linting / formatting
ls .eslintrc* eslint.config* .prettierrc* biome.json 2>/dev/null

# CI/CD + deploy
ls .github/workflows/*.yml Dockerfile docker-compose.yml railway.toml vercel.json netlify.toml fly.toml 2>/dev/null

# Existing docs
ls README.md CONTRIBUTING.md CHANGELOG.md LICENSE 2>/dev/null
```

**2c. Env vars:**
```bash
# Referenced in code
grep -roh 'process\.env\.\w\+\|import\.meta\.env\.\w\+\|os\.environ\[.\w\+.\]\|env\(\"\w\+\"\)' src/ app/ lib/ 2>/dev/null | sort -u

# Defined in env files
cat .env .env.local .env.example .env.development 2>/dev/null | grep -v '^#' | grep '=' | cut -d= -f1 | sort -u

# Missing: referenced but not defined
comm -23 <(referenced) <(defined)
```

**2d. Project structure:**
```bash
ls -d src/ app/ lib/ components/ pages/ routes/ utils/ hooks/ services/ types/ api/ public/ static/ 2>/dev/null

# File count by extension
find . -not -path '*/node_modules/*' -not -path '*/.git/*' -type f | sed 's/.*\.//' | sort | uniq -c | sort -rn | head -10

# Total source files
find . -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" -o -name "*.py" -o -name "*.rs" -o -name "*.go" | grep -v node_modules | wc -l
```

**2e. Git state:**
```bash
git log --oneline -5 2>/dev/null
git remote -v 2>/dev/null | head -2
git branch --show-current 2>/dev/null
```

---

### Step 3: Guided Intake (minimal)

Present scan findings. Ask **only what can't be detected.** Use AskUserQuestion with selectable options.

**Q1: Confirm scan**

```
📊 Codebase Scan Results
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Stack:      {framework} + {language}
  Database:   {ORM/client or "none detected"}
  Auth:       {method or "none detected"}
  Styling:    {framework or "none detected"}
  Testing:    {framework or "none detected"}
  Linting:    {tools or "none detected"}
  Deploy:     {platform or "none detected"}
  Files:      {count} source files ({breakdown})
  Env vars:   {count} referenced, {count} defined, {count} missing
  Git:        {branch} | {remote or "no remote"}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Is this accurate?
```
Options: `Yes, looks right` | `Let me correct something`

**Q2: Project name + description**
```
What's the project name and what does it do? (1-3 sentences)
```

**Q3: Workflows** (only if not obvious from scan)
```
What do you mainly work on?
```
Options (generated from scan): e.g., `Build UI` | `API endpoints` | `Data pipelines` | `Other`

**Q4: Rules**
```
Any rules Claude must always follow in this project?
```
Options: `None — use defaults` | `Let me add some`

That's it. 4 questions max.

---

### Step 4: Generate CLAUDE.md

Write a complete, project-specific CLAUDE.md. **Every line must be real content — zero placeholders.**

```markdown
# {Project Name}

## What This Project Is
{description}

## Stack
- **{Framework}** ({version}): {specific conventions from scan — e.g., "App Router, server components by default"}
- **{Language}**: {version, strict mode, etc.}
- **{Database}**: {ORM, schema location, migration command}
- **{Auth}**: {provider, pattern, where config lives}
- **{Styling}**: {framework, config file, conventions}
- **{Testing}**: {framework, run command, test file pattern}
- **{Linting}**: {tools, run command}
- **{Deployment}**: {platform, config file}

## Project Structure
```
{actual directory tree from scan, annotated}
```

## Key Workflows
{from Q3 + detected patterns, each as a subsection:}

### Adding a New Feature
{based on detected stack — e.g., "Create component in src/components/, add route in app/api/, write test in __tests__/"}

### Running the Project
- Dev: `{detected dev command}`
- Build: `{detected build command}`
- Test: `{detected test command}`
- Lint: `{detected lint command}`

## Commands Available
- `/cks:go dev` — Start dev server (`{actual command}`)
- `/cks:go build` — Build (`{actual command}`)
- `/cks:go` — Build + commit + push + PR
- `/cks:ship` — Full ceremony: doctor → PR → changelog → review → deploy
- `/cks:discuss` — Plan a new feature
- `/cks:doctor` — Health check
- `/cks:status` — Dashboard
- `/cks:help` — All commands

## Always Follow These Rules
{from Q4 + these defaults:}
- Do not commit secrets or env var values
- Do not modify production database without explicit confirmation
- {stack-specific rules from scan — e.g., "Use server components by default, client components only when needed"}
- {detected linting rules — e.g., "All code must pass ESLint before commit"}

## Environment Variables
{from scan — every referenced var with detected purpose:}
| Variable | Purpose | Required | Defined |
|----------|---------|----------|---------|
| {VAR_NAME} | {inferred from context} | {yes/no} | {yes/missing} |

## Do Not
- Modify production database without explicit confirmation
- Commit secrets or env var values
- Deploy without passing health check
- {stack-specific — e.g., "Use `any` type in TypeScript"}
```

---

### Step 5: Initialize .prd/

Create the lifecycle state directory:

```bash
mkdir -p .prd
```

**Write `.prd/PRD-STATE.md`:**
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
| {today} | — | Bootstrap | CLAUDE.md + .prd/ + .context/ configured |
```

**Write `.prd/PRD-PROJECT.md`** — project context from scan + intake:
```markdown
# Project: {name}

**Bootstrapped:** {today}
**Stack:** {full stack summary}
**Description:** {Q2 answer}

## Technical Context
{Everything detected in the scan — framework versions, directory structure, key patterns}

## Conventions
{Detected from linting config, existing code patterns, package.json scripts}
```

**Write `.prd/PRD-ROADMAP.md`** — empty, ready for features:
```markdown
# Roadmap

**Project:** {name}
**Last Updated:** {today}

## Active Features
| # | Feature | Status | Phases |
|---|---------|--------|--------|

## Completed Features
| # | Feature | Completed | Phases |
|---|---------|-----------|--------|
```

---

### Step 6: Configure .context/

```bash
mkdir -p .context
```

**Write `.context/config.md`** with preferred doc sites based on detected stack:

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
{auto-populated from detected stack, e.g.:}
  - nextjs.org/docs
  - supabase.com/docs
  - tailwindcss.com/docs
  - prisma.io/docs
---
# Context Research Config — auto-generated by /cks:bootstrap
```

---

### Step 7: Configure .gitignore

Check `.gitignore` exists. If it does, ensure these CKS-relevant entries are present (add missing ones):

```
# CKS
.env
.env.*
!.env.example
```

If `.gitignore` doesn't exist, create one appropriate for the detected stack.

---

### Step 8: Create .env.example (if missing)

If `.env.example` doesn't exist but env vars were detected:

```bash
# Generate from detected env vars
```

Write `.env.example` with all detected var names, empty values, and comments:
```
# {Project Name} — Environment Variables
# Copy to .env.local and fill in values

# {category: Auth}
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=
CLERK_SECRET_KEY=

# {category: Database}
DATABASE_URL=

# {category: External Services}
STRIPE_SECRET_KEY=
```

---

### Step 9: Completion Report

```
✅ /cks:bootstrap complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  CONFIGURED:
    CLAUDE.md                Project instructions (stack, workflows, rules)
    .prd/PRD-STATE.md        Lifecycle: idle, ready for /cks:discuss
    .prd/PRD-PROJECT.md      Project context from scan
    .prd/PRD-ROADMAP.md      Empty roadmap, ready for features
    .context/config.md       Research sources: {N} preferred sites
    .env.example             {N} env vars documented
    .gitignore               CKS entries added

  DETECTED:
    {framework} + {language}
    {database} | {auth} | {styling}
    {N} source files | {N} env vars | {test framework}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  ┌─────────────────────────────────────────────┐
  │  NEXT STEPS                                 │
  │                                             │
  │  1. /cks:go dev        Start dev server     │
  │  2. /cks:discuss       Plan your 1st feature│
  │  3. /cks:help          See all commands     │
  │                                             │
  │  Or: /cks:autonomous   Run full lifecycle   │
  └─────────────────────────────────────────────┘
```

---

## CRITICAL: Execute ALL Steps

This workflow MUST create ALL files listed above. Do NOT stop after generating CLAUDE.md.

**Checklist — verify before showing the completion report:**
- [ ] `CLAUDE.md` exists with zero placeholders
- [ ] `.prd/PRD-STATE.md` exists
- [ ] `.prd/PRD-PROJECT.md` exists
- [ ] `.prd/PRD-ROADMAP.md` exists
- [ ] `.context/config.md` exists
- [ ] `.env.example` exists (if env vars were detected)
- [ ] `.gitignore` has CKS entries

If any file is missing, create it before reporting completion. **Do not report success with missing files.**

## Post-Conditions
- 7 files created/updated minimum
- No source code modified
- No research, monetization, or design artifacts — that's /cks:kickstart
