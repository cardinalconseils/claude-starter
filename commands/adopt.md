---
description: "Adopt CKS into an existing codebase mid-development — scans git history, generates CLAUDE.md, creates feature entry at sprint phase, detects secrets"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - AskUserQuestion
  - Agent
---

# /cks:adopt — Adopt CKS Mid-Development

Adds CKS lifecycle management to an existing codebase that's already in active development. Unlike `/cks:bootstrap` (which assumes a fresh start), adopt understands you're mid-work and meets you where you are.

## When to Use

- You have an existing codebase with code already written
- You're in the middle of building a feature
- You want CKS to help you finish and ship what you're working on
- You don't want to go through full discovery for something you already understand

## Step 1: Scan the Codebase

Read project signals:

```
Read package.json (or pyproject.toml, Cargo.toml, go.mod)
Read CLAUDE.md (if exists)
Read README.md
Read .env.example (if exists)
Read .env.local (if exists)
```

Scan git history for current work:

```bash
git log --oneline -20
git branch -a
git diff --stat HEAD~5..HEAD
git status
```

Detect:
- **Tech stack** from dependencies and file patterns
- **Current feature branch** (if not on main)
- **Recent changes** — what files are being actively modified
- **Existing secrets** from .env.example and .env.local

## Step 1b: Project Profile

Ask the user with AskUserQuestion:

```
What kind of project is this?
```
Options:
- `App / SaaS / Agent (Recommended)` — versioned, full release ceremony
- `Website / Landing Page` — no versioning, deploy-on-push
- `Library / Package` — strict versioning, publish to registry
- `API / Microservice` — versioned, endpoint-focused release

Auto-detect hint from Step 1 scan results:
- Has `.claude-plugin/` → suggest App
- Has `index.html` + no server framework → suggest Website
- Has `files` or `publishConfig` in package.json → suggest Library
- Has Express/FastAPI/Flask route patterns → suggest API
- Default → App

When writing `.prd/prd-config.json`, include the profile, versioning, and phases fields based on the selected profile (same defaults as bootstrap Step 5b).

## Step 2: Present Findings

```
AskUserQuestion({
  questions: [{
    question: "Here's what I found in your codebase. What are you currently working on?",
    header: "Current Work",
    multiSelect: false,
    options: [
      { label: "{detected from branch/commits}", description: "{summary of recent changes}" },
      { label: "Something else", description: "I'll describe what I'm building" }
    ]
  }]
})
```

If "Something else" → ask for a brief description of the current feature.

## Step 3: Generate CLAUDE.md

If no CLAUDE.md exists (or it's the template), generate a project-specific one:

- Project name and description from README/package.json
- Tech stack from dependencies
- Key workflows detected from scripts
- Conventions detected from codebase patterns (linting, testing, file structure)

If CLAUDE.md already exists and has project-specific content, skip this step.

## Step 3b: Generate Rules (.claude/rules/)

Using the scan data from Step 1, generate scoped rule files — same process as bootstrap Step 6.

**3b-i. Language Rules:**
Load `${CLAUDE_PLUGIN_ROOT}/skills/language-rules/SKILL.md`. For each detected language, write `.claude/rules/{language}.md`.

**3b-ii. Domain Guardrails:**
Load `${CLAUDE_PLUGIN_ROOT}/skills/guardrails/SKILL.md`. Pass the scan context:
```
has_api_routes:  {from Step 1 — API route directories found}
has_auth:        {from Step 1 — auth patterns detected}
has_tests:       {from Step 1 — test framework detected}
has_database:    {from Step 1 — ORM/DB client detected}
test_framework:  {detected or "none"}
db_client:       {detected or "none"}
auth_method:     {detected or "none"}
api_style:       {REST|GraphQL|tRPC or "none"}
api_directory:   {detected path or "none"}
```

Write only the guardrails relevant to the detected stack. Always write `.claude/rules/docs.md`.

If `.claude/rules/` already contains rule files, skip this step.

## Step 4: Initialize .prd/

If `.prd/` doesn't exist, create the scaffold:

```
.prd/PRD-PROJECT.md       — filled from codebase analysis
.prd/PRD-REQUIREMENTS.md  — starts empty
.prd/PRD-ROADMAP.md       — starts with current feature
.prd/PRD-STATE.md         — points to current feature
```

If `.prd/` already exists, skip this step.

## Step 5: Create Feature Entry at Sprint Phase

Create the feature entry, but **skip discovery and design** — you already know what you're building:

```
mkdir -p .prd/phases/{NN}-{kebab-name}/
```

Create a lightweight `{NN}-CONTEXT.md` from the scan:

```markdown
# Discovery: {Feature Name}

**Phase:** {NN}
**Date:** {today}
**Status:** Complete (adopted mid-development)
**Elements:** Adopted — generated from codebase analysis

---

## 1. Problem Statement & Value Proposition

{Inferred from the feature brief and recent git history}

## 2. User Stories

| ID | Story | Priority |
|----|-------|----------|
| US-{NN}-01 | {Inferred from feature brief} | Must Have |

## 3. Scope (In / Out)

**In scope:** {What the recent commits and changes indicate}
**Out of scope:** To be defined during first review

## Adoption Notes

This feature was adopted mid-development via `/cks:adopt`.
Discovery was inferred from codebase analysis, not gathered interactively.
Consider running `/cks:review` after the first sprint to refine scope.
```

Create a `{NN}-DESIGN.md` marker:

```markdown
# Design: {Feature Name}

> Phase 2: Design — SKIPPED (adopted mid-development via /cks:adopt)
> Date: {today}

Design was not conducted separately. Implementation is already in progress.
```

## Step 6: Detect and Record Secrets

Scan `.env.example` and `.env.local` for existing secrets:

```
Read .env.example → extract variable names
Read .env.local → check which have values (resolved vs empty)
```

Cross-reference with the known-secrets table in `secrets/hook-discover.md`.

Create `{NN}-SECRETS.md`:
- Variables found in .env.example with values in .env.local → `resolved`
- Variables found in .env.example without values → `pending`
- Variables found only in .env.local → `resolved` (not in example)

```
AskUserQuestion({
  questions: [{
    question: "These secrets were detected from your .env files. Any missing?",
    header: "Secrets",
    multiSelect: true,
    options: [
      { label: "{SECRET_NAME} — {status}", description: "{provider if detected}" },
      { label: "Add custom secret", description: "I need a secret not detected" }
    ]
  }]
})
```

## Step 7: Set State to Sprint-Ready

Update PRD-STATE.md:

```yaml
active_phase: {NN}
phase_name: {name}
phase_status: designed
last_action: "Adopted via /cks:adopt — ready for sprint"
last_action_date: {today}
next_action: "Run /cks:sprint to plan and execute"
suggested_command: "/cks:sprint {NN}"
```

## Step 8: Report

```
CKS Adopted
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Project: {name}
Stack: {detected technologies}
Feature: {NN} — {name}
Status: Ready for sprint (discovery + design inferred)
Secrets: {N} detected ({R} resolved, {P} pending)

Created:
  CLAUDE.md               — project-specific instructions
  .claude/rules/          — {N} guardrail files (from scan)
  .prd/                   — lifecycle state
  {NN}-CONTEXT.md         — adopted discovery (from codebase)
  {NN}-DESIGN.md          — skipped marker
  {NN}-SECRETS.md         — secrets from .env files

Session ritual:
  /cks:sprint-start       — Load context at session start
  /cks:sprint-close       — Audit rules + capture learnings at session end

Next: /cks:sprint {NN}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Rules

1. **Never overwrite existing CLAUDE.md** with project-specific content — only generate if template or missing
2. **Never run full discovery** — adopt is fast, infer from codebase
3. **Always create SECRETS.md** from .env files — even if empty
4. **Set state to `designed`** so /cks:sprint picks it up directly
5. **AskUserQuestion for feature description** — don't guess what the user is building
6. **Idempotent** — safe to run again (skips existing artifacts)
