# Workflow: Bootstrap

## Overview

Lightweight scan, heavy configuration. Detects everything about an existing codebase, asks minimal questions (confirm/correct), then configures ALL CKS infrastructure for the project.

**No research. No monetization. No PRD/ERD/architecture.** Those are kickstart's job.

## Pre-Conditions

- Working directory has source code
- CKS plugin is installed

## Steps

### Step 1: Re-run Check

**1a. Kickstart Detection — check FIRST, before anything else:**

Check if `.kickstart/state.md` exists:
- Read it and check `last_phase` and `last_phase_status`
- If kickstart is **in progress** (last_phase_status is NOT `complete` and last_phase is NOT `complete`):

  **MANDATORY STOP:** Use AskUserQuestion:
  ```
  question: "A /kickstart session is in progress (Phase {N}: {name}). Bootstrap is part of kickstart's handoff (Phase 6a). Running bootstrap independently may conflict."
  options:
    - "Resume kickstart (/kickstart) — recommended"
    - "Run bootstrap anyway (will skip kickstart handoff enrichment)"
    - "Cancel"
  ```
  - If "Resume kickstart" → invoke `Skill(skill="cks:kickstart")` and return
  - If "Cancel" → stop
  - If "Run bootstrap anyway" → proceed below

- If kickstart is **complete** (last_phase is `complete`) → proceed normally
- If `.kickstart/state.md` does not exist → no kickstart in progress, proceed normally

**1b. CLAUDE.md Check:**

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

# API routes + style
ls -d src/app/api/ app/api/ pages/api/ routes/ server/ 2>/dev/null
grep -rl "GraphQL\|graphql\|ApolloServer\|type Query" src/ app/ lib/ server/ 2>/dev/null | head -3
grep -rl "createTRPCRouter\|trpc\|initTRPC" src/ app/ lib/ server/ 2>/dev/null | head -3

# State management
grep -rl "zustand\|redux\|recoil\|jotai\|mobx\|pinia\|vuex" src/ app/ lib/ 2>/dev/null | head -3

# Styling
grep -rl "tailwind\|styled-components\|emotion\|sass\|less" . --include="*.config.*" --include="*.css" 2>/dev/null | head -3

# Testing
ls jest.config* vitest.config* pytest.ini .pytest_cache cypress.config* playwright.config* 2>/dev/null

# Linting / formatting
ls .eslintrc* eslint.config* .prettierrc* biome.json 2>/dev/null

# CI/CD + deploy (see references/deploy-platforms.md for config templates)
ls .github/workflows/*.yml Dockerfile docker-compose.yml railway.toml vercel.json netlify.toml fly.toml wrangler.toml wrangler.jsonc next.config.* 2>/dev/null

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

### Step 2b: Check for Kickstart Pre-filled Context

Before intake, check if `/kickstart` already ran and prepared answers:

```bash
ls .kickstart/bootstrap-context.md 2>/dev/null
```

**If `.kickstart/bootstrap-context.md` exists:**
- Read it — it contains pre-filled answers from kickstart's 10-question intake
- Map kickstart fields to bootstrap questions:
  - Kickstart Q1 (project name) + Q2 (description) → Bootstrap Q2
  - Kickstart Q3 (tech stack) → Bootstrap Q1 (scan confirmation pre-fill)
  - Kickstart Q10 (project type) → Bootstrap Q0 (profile)
  - Kickstart Q4-Q9 (domain, users, data, integrations, constraints, MVP) → CLAUDE.md enrichment in Step 4
- Present the mapped answers to the user for confirmation (not re-entry)
- Skip to Step 4 (Generate CLAUDE.md) after confirmation
- This is the normal path when coming from `/cks:kickstart` handoff

**If NOT found:**
- Continue to Step 3 (Guided Intake) below

---

### Step 3: Guided Intake (minimal)

Present scan findings. Ask **only what can't be detected.** Use AskUserQuestion with selectable options.

**Q0: Project profile**

```
What kind of project is this?
```
Options:
- `App / SaaS / Agent (Recommended)` — versioned, full release ceremony
- `Website / Landing Page` — no versioning, deploy-on-push
- `Library / Package` — strict versioning, publish to registry
- `API / Microservice` — versioned, endpoint-focused release

Auto-detection hint (suggest as default based on scan):
- Has `.claude-plugin/` → suggest App
- Has `index.html` + no server framework → suggest Website
- Has `files` or `publishConfig` in package.json → suggest Library
- Has Express/FastAPI/Flask route patterns → suggest API
- Default → App

Store the answer as `{profile}` for use in Step 5.

**Q1: Confirm scan**

```
📊 Codebase Scan Results
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Stack:      {framework} + {language}
  API:        {REST | GraphQL | tRPC or "none detected"} — {route directory}
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

That's it. 5 questions max.

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

## API Conventions
{Only include this section if API routes were detected in scan step 2b}
- **Style:** {REST | GraphQL | tRPC — detected from scan}
- **Route location:** {detected API directory, e.g., "app/api/ (Next.js App Router)"}
- **Naming:** {detected or default — e.g., "plural resources, kebab-case paths: /api/invoice-items"}
- **Error format:** {detected from existing error handling, or standard:}
  ```json
  {"error": "ERROR_CODE", "message": "Human-readable message", "details": []}
  ```
- **Auth pattern:** {detected — e.g., "middleware auth check on all /api/ routes"}
- **Validation:** {detected — e.g., "Zod schemas for request validation"}

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
- `/cks:new` — Plan a new feature
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

### Step 5: Initialize Project Structure (Shell Script)

**Run this IMMEDIATELY after writing CLAUDE.md — before doing anything else:**

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/init-project.sh "{project_name}" "{project_description}" "{profile}" "{stack}"
```

- `{project_name}` — from Q2
- `{project_description}` — from Q2 (brief, 1-2 sentences)
- `{profile}` — from Q0: `app`, `website`, `library`, or `api`
- `{stack}` — detected framework from Step 2: `nextjs`, `react`, `express`, `fastapi`, etc.

**If no source manifest exists** (no package.json, requirements.txt, etc.), the script scaffolds directories and a package manifest appropriate for the profile + stack combination. If source files already exist, scaffolding is skipped.

This script creates ALL CKS infrastructure files:
- `.prd/PRD-STATE.md` — lifecycle initialized
- `.prd/PRD-PROJECT.md` — project context
- `.prd/PRD-ROADMAP.md` — ready for features
- `.prd/PRD-REQUIREMENTS.md` — empty requirements traceability table
- `.prd/logs/` — session logging directory
- `.prd/phases/` — feature phase directories (empty until `/cks:new`)
- `.context/config.md` — research sources (auto-detects preferred sites from package.json)
- `.claude/settings.local.json` — agent teams enabled (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`)
- `.env.example` — all env vars from code (if detected)
- `.env.local` — copy of .env.example with PERPLEXITY_API_KEY (ready for user to fill)
- `.gitignore` — CKS entries added
- `.learnings/` — ready for retrospectives

**The script is idempotent** — it skips files that already exist.

**Do NOT skip this step. Do NOT try to create these files manually. Run the script.**

**5b. Create prd-config.json with profile settings:**

init-project.sh creates the `.prd/` directory but does NOT create `prd-config.json`. Create it now with the profile settings from Q0:

| Profile | versioning.enabled | versioning.strategy | versioning.changelog | phases.sprint.mode | phases.release.mode |
|---------|-------------------|--------------------|--------------------|-------------------|-------------------|
| app | true | auto-patch | true | auto | gated |
| website | false | skip | false | auto | auto |
| library | true | manual | true | auto | gated |
| api | true | auto-patch | true | auto | gated |

All profiles set: `phases.discover.mode` = `interactive`, `phases.design.mode` = `interactive`, `phases.review.mode` = `gated`.

Auto-detect `versioning.source` from available files:
- `.claude-plugin/plugin.json` exists → `plugin.json`
- `package.json` exists → `package.json`
- `pyproject.toml` exists → `pyproject.toml`
- `Cargo.toml` exists → `Cargo.toml`
- Otherwise → `null`

Write the config to `.prd/prd-config.json`.

### Step 6: Generate Rules (.claude/rules/)

After init-project.sh completes, generate scoped rule files from scan data. This step has two sub-steps that run in sequence.

**6a. Language Rules**

Load the catalog from `${CLAUDE_PLUGIN_ROOT}/skills/language-rules/SKILL.md`.

Using the languages/frameworks detected in Step 2:
```
For each detected language:
  Load the matching catalog section (TypeScript, Python, Go, Rust)
  Write to .claude/rules/{language}.md with proper globs: frontmatter
  Only generate for languages actually found in the codebase
```

**6b. Domain Guardrails**

Load the skill from `${CLAUDE_PLUGIN_ROOT}/skills/guardrails/SKILL.md`.

Using the concerns detected in Step 2, pass the scan context:
```
has_api_routes:  {true if API route directories found in 2b}
has_auth:        {true if auth patterns detected in 2b}
has_tests:       {true if test framework detected in 2b}
has_database:    {true if ORM/DB client detected in 2b}
test_framework:  {detected framework or "none"}
db_client:       {detected ORM/client or "none"}
auth_method:     {detected auth method or "none"}
api_style:       {REST|GraphQL|tRPC or "none"}
api_directory:   {detected API route path or "none"}
```

The guardrails skill reads the matching catalogs and writes:
- `.claude/rules/security.md` — if API routes or auth detected
- `.claude/rules/testing.md` — if test framework detected
- `.claude/rules/database.md` — if ORM/DB client detected
- `.claude/rules/docs.md` — always (every project has docs)

Each file has `globs:` frontmatter so Claude Code only loads it when relevant files are touched.

**6c. Report**

After both sub-steps complete, report what was generated:
```
Rules generated:
  .claude/rules/{language}.md   ← Language: {detected}
  .claude/rules/security.md    ← API + auth detected
  .claude/rules/testing.md     ← {test_framework} detected
  .claude/rules/database.md    ← {db_client} detected
  .claude/rules/docs.md        ← Always included
```

Only list files that were actually generated. If no concerns were detected beyond docs, only docs.md and language rules are listed.

---

### Step 7: Enrich PRD-PROJECT.md

After the script creates the boilerplate, enrich `.prd/PRD-PROJECT.md` with the full scan + intake context:

```markdown
# Project: {name}

**Bootstrapped:** {today}
**Stack:** {full stack summary from scan}
**Description:** {Q2 answer}

## Technical Context
{Framework versions, directory structure, key patterns from Step 2}

## Conventions
{Detected from linting config, existing code patterns, package.json scripts}
```

This is the ONE file Claude enriches beyond what the script creates.

### Step 8: Completion Report

```
/cks:bootstrap complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  CONFIGURED:
    CLAUDE.md                       Project instructions (stack, workflows, rules)
    .claude/rules/                  {N} rule files (language + guardrails)
    .prd/prd-config.json            Profile: {profile} | Versioning: {enabled/disabled}
    .prd/PRD-STATE.md               Lifecycle: idle, ready for /cks:new
    .prd/PRD-PROJECT.md             Project context from scan
    .prd/PRD-ROADMAP.md             Empty roadmap, ready for features
    .context/config.md              Research sources: {N} preferred sites
    .claude/settings.local.json     Agent teams enabled (experimental)
    .env.example                    {N} env vars documented
    .gitignore                      CKS entries added

  DETECTED:
    {framework} + {language}
    {database} | {auth} | {styling}
    {N} source files | {N} env vars | {test framework}

  GUARDRAILS:
    {list each generated .claude/rules/ file with trigger reason}

  SCAFFOLDED:
    {list created directories and manifest file, or "Existing project — skipped"}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  SESSION RITUAL:
    /cks:sprint-start    ← Run at the start of every session
    /cks:sprint-close    ← Run at the end of every session

  ▶ Auto-advancing to feature lifecycle...
```

### Step 9: Auto-Chain to Feature Lifecycle

**CRITICAL:** Do NOT stop here. Automatically ask the user for their first feature and start the lifecycle.

1. **MANDATORY STOP:** Ask with AskUserQuestion:
   ```
   question: "What's the first feature you want to build?"
   ```
   Wait for the user's response. Do NOT skip this question.

2. Auto-invoke `/cks:new` with their answer:
   ```
   Skill(skill="cks:new", args="{user's feature brief}")
   ```

3. **VALIDATION GATE — MANDATORY:** After `/cks:new` completes, verify:
   - `.prd/phases/{NN}-{name}/` directory exists
   - `PRD-STATE.md` has `active_phase` set

   If validation fails:
   ```
   Feature creation did not complete successfully.
     Expected: .prd/phases/01-{name}/ directory
     Action: Retrying /cks:new...
   ```
   Retry once. If it fails again, stop and tell the user: "Run `/cks:new` manually."
   Do NOT invoke `/cks:next` without a valid feature.

4. Only after validation passes, invoke `/cks:next`:
   ```
   Skill(skill="cks:next")
   ```

5. `/cks:next` will detect the state and invoke `/cks:discover` automatically.

6. After discover completes, the phase will end with a **Context Reset** banner.
   The user runs `/clear` then `/cks:next` to continue through design → sprint → etc.

---

## Execution Order (CRITICAL)

```
Step 1: Re-run check           (5 seconds)
Step 2: Codebase scan           (10 seconds — bash commands)
Step 3: Guided intake           (user interaction — 4 questions)
Step 4: Generate CLAUDE.md      (Claude writes this)
Step 5: Run init-project.sh     (bash script — creates .prd/, .context/, .env.example, .gitignore)
Step 6: Generate rules           (6a: language rules, 6b: domain guardrails, 6c: report)
Step 7: Enrich PRD-PROJECT.md   (Claude enriches with scan data)
Step 8: Completion report       (display results)
Step 9: Auto-chain              (ask for first feature → /cks:new → /cks:next → /cks:discover)
```

**Step 5 is a shell script, not Claude-generated files.** This guarantees .prd/ and .context/ are always created, even if Claude loses focus after CLAUDE.md.

**Step 6 uses scan data from Step 2** — no new scans needed. It reads the catalogs from `skills/language-rules/` and `skills/guardrails/` and writes customized rule files to `.claude/rules/`.

## Post-Conditions
- `CLAUDE.md` — Claude-generated, zero placeholders
- `.claude/rules/` — generated from scan data (language + domain guardrails)
- `.prd/` — script-created (PRD-STATE, PRD-PROJECT, PRD-ROADMAP, PRD-REQUIREMENTS, prd-config.json)
- `.prd/logs/` — session logging directory
- `.prd/phases/` — feature phase directory (populated by `/cks:new`)
- `.context/config.md` — script-created (preferred sites from package.json)
- `.claude/settings.local.json` — script-created (agent teams enabled)
- `.env.example` — script-created (if env vars detected)
- `.env.local` — script-created (copy of .env.example + PERPLEXITY_API_KEY)
- `.gitignore` — script-updated
- `.learnings/` — script-created (empty, ready for /cks:retro)
- No source code modified
- No research, monetization, or design artifacts — that's /cks:kickstart
