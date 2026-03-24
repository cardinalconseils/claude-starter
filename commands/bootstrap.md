---
name: bootstrap
description: "Scan an existing codebase, guided intake, then generate CLAUDE.md and initialize .prd/ lifecycle"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - AskUserQuestion
  - Skill
---

# /cks:bootstrap — Set Up CKS for an Existing Codebase

Scans your existing project, asks guided questions about what it finds, then generates `CLAUDE.md` and initializes the PRD lifecycle. This is the **first command you run** on an existing codebase.

For new projects from scratch, use `/cks:kickstart` instead.

## Flow

```
scan codebase → guided intake → generate CLAUDE.md → init .prd/ → first commit
```

## Re-run Check

Before starting, check if `CLAUDE.md` exists:
- If yes → ask: "CLAUDE.md already exists. **Update it**, **regenerate from scratch**, or **cancel**?"
  - Update: re-scan codebase, merge new findings with existing CLAUDE.md
  - Regenerate: full re-run
  - Cancel: stop
- If no → fresh run

---

## Step 1: Codebase Scan

Silently analyze the project before asking any questions. This makes the intake smarter — pre-fill what you can detect.

### Detect Stack

```bash
# Check for project manifest files
ls package.json pyproject.toml Cargo.toml go.mod composer.json Gemfile 2>/dev/null
```

**If `package.json` exists:**
- Read `dependencies` and `devDependencies` for framework detection
- Read `scripts` for available commands (dev, build, test, lint, start)
- Detect: Next.js, React, Vue, Svelte, Express, Fastify, Nest, etc.

**If `pyproject.toml` or `requirements.txt`:**
- Detect: Django, FastAPI, Flask, etc.

**If `Cargo.toml`:** Rust project
**If `go.mod`:** Go project

### Detect Patterns

```bash
# Auth patterns
grep -rl "clerk\|supabase.*auth\|next-auth\|passport\|jwt\|bcrypt" src/ app/ lib/ 2>/dev/null | head -5

# Database
grep -rl "prisma\|drizzle\|typeorm\|sequelize\|mongoose\|supabase\|firebase" src/ app/ lib/ 2>/dev/null | head -5

# API patterns
ls src/app/api/ app/api/ pages/api/ routes/ 2>/dev/null

# Testing
ls jest.config* vitest.config* pytest.ini .pytest_cache cypress.config* playwright.config* 2>/dev/null

# CI/CD
ls .github/workflows/*.yml Dockerfile docker-compose.yml railway.toml vercel.json netlify.toml 2>/dev/null

# Env vars
grep -roh 'process\.env\.\w\+\|import\.meta\.env\.\w\+\|os\.environ\[.\w\+.\]' src/ app/ lib/ 2>/dev/null | sort -u
```

### Detect Structure

```bash
# Directory layout
ls -d src/ app/ lib/ components/ pages/ routes/ utils/ hooks/ services/ api/ types/ 2>/dev/null

# Count source files
find . -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" -o -name "*.py" -o -name "*.rs" -o -name "*.go" | grep -v node_modules | wc -l
```

### Compile Scan Report

Store the findings internally (don't write a file). Build a picture:
- **Stack:** framework + language + major deps
- **Auth:** detected method or "none detected"
- **Database:** detected ORM/client or "none detected"
- **API routes:** count and pattern
- **Tests:** framework detected or "none"
- **CI/CD:** platform detected or "none"
- **Env vars:** list of referenced env var names
- **Code size:** file count + approximate lines

---

## Step 2: Guided Intake

Present the scan findings and ask questions **one at a time** using AskUserQuestion. Pre-fill answers from the scan — the user confirms or corrects.

### Q1: Project Identity

```
I scanned your codebase. Here's what I found:

  Stack:     {detected framework + language}
  Database:  {detected or "none detected"}
  Auth:      {detected or "none detected"}
  Files:     {count} source files
  Tests:     {detected framework or "none"}

Let's set up your project. First:

What's the project name?
```

### Q2: Description

```
What does {project_name} do? (1-3 sentences)
```

### Q3: Stack Confirmation

```
I detected: {stack details}

Is this correct, or should I adjust?
```
Options: `Correct` | `Let me adjust (describe)`

### Q4: Key Workflows

```
What are the main things you work on in this codebase?
(e.g., "add features", "fix bugs", "write API endpoints", "build UI components")
```
Options: suggest based on detected patterns + `Other (describe)`

### Q5: Env Vars

```
I found these env vars referenced in code:
  {list from scan}

Are any missing from this list? And which are required vs optional?
```

### Q6: Rules

```
Any rules Claude must always follow in this project?
(e.g., "always write tests", "use Tailwind only", "never modify database directly")
```
Options: `None` | `Let me list them`

### Q7: Deployment

```
I detected: {CI/CD platform or "no deployment config"}

Where does this deploy?
```
Options based on scan: `Railway` | `Vercel` | `Netlify` | `Docker` | `GitHub Actions` | `Not configured yet` | `Other`

---

## Step 3: Generate CLAUDE.md

Using scan results + intake answers, generate a complete `CLAUDE.md`:

```markdown
# {Project Name}

## What This Project Is
{Q2 answer}

## Stack
{From scan + Q3 confirmation, formatted as:}
- **{Framework}**: {How Claude should interact with it}
- **{Database}**: {Conventions, schema location}
- **{Auth}**: {Pattern detected}
- **{Testing}**: {Framework + how to run}
- **{Deployment}**: {Platform from Q7}

## Key Workflows

{From Q4, each as a section:}

### {Workflow Name}
{What Claude does, conventions to follow}

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
{From Q6}
- Do not commit secrets or env var values
- {User-provided rules}

## Environment Variables
{From Q5 — names + purpose, never values}

## Do Not
- Modify production database without explicit confirmation
- Commit secrets or env var values
- Deploy without passing health check
```

---

## Step 4: Initialize .prd/ Lifecycle

```bash
mkdir -p .prd
```

Create `.prd/PRD-STATE.md`:
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
| {today} | — | Project bootstrapped via /cks:bootstrap | CLAUDE.md generated |
```

Create `.prd/PRD-PROJECT.md` from scan + intake (project context).

Create `.prd/PRD-ROADMAP.md` (empty, ready for features).

---

## Step 5: Create .context/config.md (Optional)

If the scan detected specific technologies (Stripe, Supabase, etc.), create a config with preferred doc sites:

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
  {auto-populated from detected stack}
---

# Context Research Config
```

---

## Step 6: Report

```
✅ /cks:bootstrap complete!

Generated:
  CLAUDE.md                  — Project instructions ({N} rules, {N} workflows)
  .prd/PRD-STATE.md          — Lifecycle initialized
  .prd/PRD-PROJECT.md        — Project context
  .prd/PRD-ROADMAP.md        — Ready for features
  .context/config.md         — Research sources configured

Detected:
  Stack: {summary}
  Files: {count} source files
  Env vars: {count} referenced
  Tests: {framework or "none"}

Your lifecycle from here:
  /cks:go dev                — Start dev server
  /cks:discuss               — Plan your first feature
  /cks:go                    — Build + commit + push + PR
  /cks:help                  — See all commands
```

---

## Rules

1. **Scan first, ask second** — never ask what you can detect
2. **Pre-fill from scan** — user confirms, not types from scratch
3. **AskUserQuestion for all questions** — selectable options, not free text prompts
4. **Never write placeholder tokens** — every line in CLAUDE.md must be real content
5. **Idempotent** — safe to re-run, offers update/regenerate/cancel
6. **Don't touch source code** — only generate CLAUDE.md and .prd/ files
