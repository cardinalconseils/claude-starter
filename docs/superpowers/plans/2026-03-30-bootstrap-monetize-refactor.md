# Bootstrap & Monetize Architecture Refactor — Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Migrate bootstrap and monetize processes to the v4.0 reference pattern: thin command orchestrators dispatching agents with `skills:` field loaded at startup.

**Architecture:** Bootstrap gets 2 new agents (scanner + generator). Monetize's 6 existing agents get `skills:` field added. All 8 commands are rewritten as thin dispatchers. Both SKILL.md files are trimmed to expertise-only.

**Tech Stack:** Claude Code plugin system (Markdown + YAML frontmatter)

**Spec:** `docs/superpowers/specs/2026-03-30-bootstrap-monetize-refactor-design.md`

---

## File Structure

### Files to Create (2)

| File | Responsibility |
|------|---------------|
| `agents/bootstrap-scanner.md` | Phase 1 — scan codebase + guided intake |
| `agents/bootstrap-generator.md` | Phase 2 — generate CLAUDE.md, .prd/, rules, config |

### Files to Modify (15)

| File | Change |
|------|--------|
| `commands/bootstrap.md` | Rewrite as thin orchestrator |
| `commands/monetize.md` | Rewrite as thin orchestrator |
| `commands/monetize-discover.md` | Rewrite as single-agent dispatcher |
| `commands/monetize-research.md` | Rewrite as single-agent dispatcher |
| `commands/monetize-cost-analysis.md` | Rewrite as single-agent dispatcher |
| `commands/monetize-evaluate.md` | Rewrite as single-agent dispatcher |
| `commands/monetize-report.md` | Rewrite as single-agent dispatcher |
| `commands/monetize-roadmap.md` | Rewrite as thin dispatcher |
| `skills/cicd-starter/SKILL.md` | Add phase map, remove execution line |
| `skills/monetize/SKILL.md` | Remove orchestration logic, keep expertise |
| `agents/monetize-researcher.md` | Add `skills: monetize` |
| `agents/cost-researcher.md` | Add `skills: monetize` |
| `agents/cost-analyzer.md` | Add `skills: monetize` |
| `agents/monetize-evaluator.md` | Add `skills: monetize` |
| `agents/monetize-reporter.md` | Add `skills: monetize` + `model: sonnet` |

---

## Chunk 1: Create bootstrap agents + add skills: to monetize agents

### Task 1: Create bootstrap-scanner agent

**Files:**
- Create: `agents/bootstrap-scanner.md`

- [ ] **Step 1: Write the agent file**

```markdown
---
name: bootstrap-scanner
subagent_type: bootstrap-scanner
description: "Bootstrap Phase 1 — scans codebase, detects stack, runs guided intake with pre-filled answers from scan results."
skills:
  - cicd-starter
tools:
  - Read
  - Write
  - Glob
  - Grep
  - Bash
  - AskUserQuestion
  - "mcp__*"
color: blue
---

# Bootstrap Scanner Agent

You are a codebase analysis specialist. Your job is to scan an existing project, detect its stack, and run a guided intake with the user to gather project context.

## Your Mission

Run Phase 1 of bootstrap. Produce `.bootstrap/scan-context.md` with everything the generator needs.

## Process

### Step 1: Scan the Codebase

Detect:
- **Languages**: Look for tsconfig.json, pyproject.toml, go.mod, Cargo.toml, requirements.txt, package.json
- **Frameworks**: next.config.*, django settings, express patterns, Flask, FastAPI, Hono
- **Test runners**: jest.config, vitest.config, pytest.ini, go test patterns
- **Database**: prisma/, drizzle.config, supabase/, mongoose, sqlalchemy, knex
- **Auth**: clerk, supabase-auth, next-auth, passport, lucia, JWT patterns
- **API routes**: app/api/, routes/, pages/api/
- **Deploy**: Dockerfile, railway.toml, vercel.json, fly.toml, render.yaml
- **Existing .claude/**: Check if CLAUDE.md or .prd/ already exist

Use Glob and Grep to detect patterns. Use Bash for `wc -l` and directory structure.

Read `${CLAUDE_PLUGIN_ROOT}/skills/cicd-starter/assets/` files for additional scan patterns.

### Step 2: Read Kickstart Artifacts (if they exist)

Check for `.kickstart/context.md` and `.kickstart/artifacts/ARCHITECTURE.md`. If found, pre-fill answers from kickstart data — don't re-ask what's already known.

### Step 3: Guided Intake

Ask questions **one at a time** using AskUserQuestion. Pre-fill from scan results where possible.

For each detection, confirm with the user:
```
"I detected {framework} with {test-runner} and {database}. Is this correct?"
```

Fill gaps:
- Project name and description (if no kickstart context)
- Dev/build/test commands
- Deploy target and production branch
- Any constraints or special patterns

### Step 4: Write Scan Context

Create `.bootstrap/` directory and write `.bootstrap/scan-context.md`:

```markdown
# Bootstrap Scan Context

**Generated:** {date}
**Project:** {name}

## Detected Stack
| Category | Detected | Confidence | User Confirmed |
|----------|----------|-----------|----------------|
| Language | {lang} | {high/medium/low} | {yes/no} |
| Framework | {framework} | ... | ... |
| Test Runner | {runner} | ... | ... |
| Database | {db} | ... | ... |
| Auth | {auth} | ... | ... |
| API Style | {style} | ... | ... |
| Deploy | {platform} | ... | ... |

## Project Info
- **Name:** {name}
- **Description:** {description}
- **Dev command:** {dev}
- **Build command:** {build}
- **Test command:** {test}
- **Production branch:** {branch}

## Scan Details
{has_api_routes, has_auth, has_tests, has_database flags}
{test_framework, db_client, auth_method, api_style, api_directory values}

## Kickstart Context
{summary from .kickstart/ if available, or "No kickstart artifacts found"}
```

## Constraints

- **Scan first, ask second** — detect everything before asking
- **Pre-fill from scan** — user confirms, not types from scratch
- **Always use AskUserQuestion** — never plain text prompts
- **Write .bootstrap/scan-context.md BEFORE reporting completion**
```

- [ ] **Step 2: Commit**

```bash
git add agents/bootstrap-scanner.md
git commit -m "feat(agents): create bootstrap-scanner for Phase 1 scan + intake"
```

### Task 2: Create bootstrap-generator agent

**Files:**
- Create: `agents/bootstrap-generator.md`

- [ ] **Step 1: Write the agent file**

```markdown
---
name: bootstrap-generator
subagent_type: bootstrap-generator
description: "Bootstrap Phase 2 — generates CLAUDE.md, .prd/, .claude/rules/, .context/, MCP config, and deploy config from scan context and kickstart artifacts."
skills:
  - cicd-starter
  - language-rules
  - guardrails
tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
  - Skill
model: sonnet
color: green
---

# Bootstrap Generator Agent

You are a project scaffolding specialist. Your job is to take scan context and generate all bootstrap output files.

## Your Mission

Run Phase 2 of bootstrap. Read `.bootstrap/scan-context.md` and produce:
- `CLAUDE.md` — project-specific instructions
- `.prd/PRD-STATE.md`, `PRD-PROJECT.md`, `PRD-ROADMAP.md` — lifecycle init
- `.context/config.md` — research source configuration
- `.claude/rules/*.md` — language + domain guardrails
- MCP and deploy configuration

## Process

### Step 1: Read Context

Read `.bootstrap/scan-context.md` for all scan findings and user answers.
Read `.kickstart/` artifacts if they exist for richer context.

### Step 2: Generate CLAUDE.md

Read the template from `${CLAUDE_PLUGIN_ROOT}/skills/cicd-starter/references/claude-md-template.md`.

Replace ALL placeholders with project-specific content from scan context:
- `[PROJECT_NAME]` → project name
- `[PROJECT_DESCRIPTION]` → description
- `[Primary framework]` → detected framework
- `[dev command]` → detected dev command
- etc.

**No placeholders may remain.** Every line must be real content.

### Step 3: Initialize .prd/

Create:
- `.prd/PRD-STATE.md` — initialized to idle state
- `.prd/PRD-PROJECT.md` — project context from scan
- `.prd/PRD-ROADMAP.md` — empty or imported from `.kickstart/artifacts/FEATURE-ROADMAP.md`

If feature roadmap exists, import each feature as a roadmap entry with "Planned" status.

### Step 4: Research Stack Technologies

For each technology in the detected stack:
```
Skill(skill="cks:context", args="{technology}")
```

This creates `.context/{slug}.md` briefs that inform future coding sessions.

### Step 5: Generate Rules

Using your loaded `language-rules` and `guardrails` skill knowledge:

**Language rules** (Step 6a): For each detected language, generate `.claude/rules/{language}.md`.
**Domain guardrails** (Step 6b): Based on scan context flags (has_api_routes, has_auth, has_tests, has_database), generate scoped rule files.

### Step 6: Configure MCP and Deploy

Based on detected stack:
- If Supabase detected → configure Supabase MCP
- If deploy platform detected → generate deploy config (railway.toml, vercel.json, etc.)

## Constraints

- **No placeholders** — every line in CLAUDE.md must be real content
- **Don't touch source code** — only generate config and documentation files
- **Idempotent** — if files exist, update rather than overwrite blindly
```

- [ ] **Step 2: Commit**

```bash
git add agents/bootstrap-generator.md
git commit -m "feat(agents): create bootstrap-generator for Phase 2 file generation"
```

### Task 3: Add skills: field to 5 monetize agents

**Files:**
- Modify: `agents/monetize-researcher.md`
- Modify: `agents/cost-researcher.md`
- Modify: `agents/cost-analyzer.md`
- Modify: `agents/monetize-evaluator.md`
- Modify: `agents/monetize-reporter.md`

- [ ] **Step 1: Add skills: monetize to monetize-researcher**

Read `agents/monetize-researcher.md`. Add before the closing `---`:
```yaml
skills:
  - monetize
```

- [ ] **Step 2: Add skills: monetize to cost-researcher**

Read `agents/cost-researcher.md`. Add before `---`:
```yaml
skills:
  - monetize
```

- [ ] **Step 3: Add skills: monetize to cost-analyzer**

Read `agents/cost-analyzer.md`. Add before `---`:
```yaml
skills:
  - monetize
```

- [ ] **Step 4: Add skills: monetize to monetize-evaluator**

Read `agents/monetize-evaluator.md`. Add before `---`:
```yaml
skills:
  - monetize
```

- [ ] **Step 5: Add skills: monetize + model: sonnet to monetize-reporter**

Read `agents/monetize-reporter.md`. Add before `---`:
```yaml
skills:
  - monetize
model: sonnet
```

- [ ] **Step 6: Commit**

```bash
git add agents/monetize-researcher.md agents/cost-researcher.md agents/cost-analyzer.md agents/monetize-evaluator.md agents/monetize-reporter.md
git commit -m "feat(agents): add skills: monetize to all 5 monetize agents"
```

---

## Chunk 2: Rewrite all 8 commands as thin dispatchers

### Task 4: Rewrite commands/bootstrap.md

**Files:**
- Modify: `commands/bootstrap.md`

- [ ] **Step 1: Replace entire file**

Read `commands/bootstrap.md`, then replace with:

```markdown
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
```

- [ ] **Step 2: Commit**

```bash
git add commands/bootstrap.md
git commit -m "refactor(commands): rewrite bootstrap as thin agent orchestrator"
```

### Task 5: Rewrite commands/monetize.md

**Files:**
- Modify: `commands/monetize.md`

- [ ] **Step 1: Replace entire file**

Read `commands/monetize.md`, then replace with:

```markdown
---
description: "Run full monetization evaluation: discover → research → cost → evaluate → report → roadmap"
argument-hint: "[path | \"description\"] (optional)"
allowed-tools:
  - Read
  - Write
  - Agent
  - AskUserQuestion
---

# /cks:monetize

Orchestrate the full monetization evaluation by dispatching agents in sequence.
Each agent has `skills: monetize` loaded at startup for domain expertise.

## Mode Detection

Parse `$ARGUMENTS`:
- No arguments → Mode A (self-analyze current project codebase)
- Local directory path → Mode B (analyze target project codebase)
- Quoted text / description → Mode C (business description, no code scan)

## Re-run Check

Read `.monetize/context.md`. If exists:
```
AskUserQuestion:
  question: "Previous assessment found. How to proceed?"
  options:
    - "Archive and start fresh (Recommended)"
    - "Update — skip discovery, re-run from research"
    - "Cancel"
```
- Archive: `mkdir -p .monetize/archive/$(date +%Y%m%d) && mv .monetize/*.md .monetize/archive/$(date +%Y%m%d)/`
- Update: skip Phase 1, start from Phase 2

## Phase Execution

### Phase 1: Discover

```
Agent(subagent_type="monetize-discoverer", prompt="Gather business context. Mode: {detected_mode}. Arguments: $ARGUMENTS. Scan codebase if Mode A or B. Write to .monetize/context.md.")
```

### Phase 2: Research

```
Agent(subagent_type="monetize-researcher", prompt="Research the market for this project. Read .monetize/context.md for context. Write findings to .monetize/research.md.")
```

### Phase 3a: Cost Research

```
Agent(subagent_type="cost-researcher", prompt="Research real-world tech stack costs. Read .monetize/context.md for the stack. Write raw pricing data to .monetize/cost-research-raw.md.")
```

### Phase 3b: Cost Analysis

```
Agent(subagent_type="cost-analyzer", prompt="Build unit economics from cost research. Read .monetize/cost-research-raw.md and .monetize/context.md. Write to .monetize/cost-analysis.md.")
```

### Phase 4: Evaluate

```
Agent(subagent_type="monetize-evaluator", prompt="Evaluate monetization models using evidence-based tiers. Read .monetize/context.md, research.md, cost-analysis.md. Write to .monetize/evaluation.md.")
```

### Phase 5: Report

```
Agent(subagent_type="monetize-reporter", prompt="Generate the business case report. Read .monetize/evaluation.md and all .monetize/ artifacts. Write to docs/monetization-assessment.md.")
```

### Phase 6: Roadmap

Read `.monetize/evaluation.md`. Extract recommended models and create:
- `.monetize/phases/*.md` — PRD-ready phase briefs for each recommended model
- Update `.prd/PRD-ROADMAP.md` with monetization phases (if .prd/ exists)

### Completion

Display summary: recommended model, revenue projection, and next steps.
```

- [ ] **Step 2: Commit**

```bash
git add commands/monetize.md
git commit -m "refactor(commands): rewrite monetize as thin agent orchestrator"
```

### Task 6: Rewrite 6 monetize sub-commands

**Files:**
- Modify: `commands/monetize-discover.md`
- Modify: `commands/monetize-research.md`
- Modify: `commands/monetize-cost-analysis.md`
- Modify: `commands/monetize-evaluate.md`
- Modify: `commands/monetize-report.md`
- Modify: `commands/monetize-roadmap.md`

- [ ] **Step 1: Rewrite monetize-discover.md**

Replace entire content:
```markdown
---
description: "Monetization discovery — gather business context"
argument-hint: "[path | \"description\"] (optional)"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:monetize-discover

Dispatch the monetize-discoverer agent to gather business context.

## Mode Detection

Parse `$ARGUMENTS`:
- No arguments → Mode A (self-analyze current project)
- Local path → Mode B (analyze target project)
- Quoted text → Mode C (business description)

## Execution

```
Agent(subagent_type="monetize-discoverer", prompt="Gather business context. Mode: {detected_mode}. Arguments: $ARGUMENTS. Write to .monetize/context.md.")
```
```

- [ ] **Step 2: Rewrite monetize-research.md**

Replace entire content:
```markdown
---
description: "Monetization market research"
allowed-tools:
  - Read
  - Agent
---

# /cks:monetize-research

Dispatch the monetize-researcher agent for market intelligence.

## Prerequisite

Verify `.monetize/context.md` exists. If not, tell user to run `/cks:monetize-discover` first.

## Execution

```
Agent(subagent_type="monetize-researcher", prompt="Research the market. Read .monetize/context.md for context. Write to .monetize/research.md.")
```
```

- [ ] **Step 3: Rewrite monetize-cost-analysis.md**

Replace entire content:
```markdown
---
description: "Monetization cost analysis — tech stack costs and unit economics"
allowed-tools:
  - Read
  - Agent
---

# /cks:monetize-cost-analysis

Dispatch cost-researcher then cost-analyzer in sequence.

## Prerequisite

Verify `.monetize/context.md` exists. If not, tell user to run `/cks:monetize-discover` first.

## Execution

### Step 1: Cost Research
```
Agent(subagent_type="cost-researcher", prompt="Research tech stack costs. Read .monetize/context.md. Write to .monetize/cost-research-raw.md.")
```

### Step 2: Cost Analysis
```
Agent(subagent_type="cost-analyzer", prompt="Build unit economics. Read .monetize/cost-research-raw.md and .monetize/context.md. Write to .monetize/cost-analysis.md.")
```
```

- [ ] **Step 4: Rewrite monetize-evaluate.md**

Replace entire content:
```markdown
---
description: "Monetization model evaluation — evidence-based tier scoring"
allowed-tools:
  - Read
  - Agent
---

# /cks:monetize-evaluate

Dispatch the monetize-evaluator agent.

## Prerequisite

Verify `.monetize/context.md`, `.monetize/research.md`, and `.monetize/cost-analysis.md` exist.

## Execution

```
Agent(subagent_type="monetize-evaluator", prompt="Evaluate monetization models. Read all .monetize/ artifacts. Write to .monetize/evaluation.md.")
```
```

- [ ] **Step 5: Rewrite monetize-report.md**

Replace entire content:
```markdown
---
description: "Generate monetization assessment report"
allowed-tools:
  - Read
  - Agent
---

# /cks:monetize-report

Dispatch the monetize-reporter agent.

## Prerequisite

Verify `.monetize/evaluation.md` exists. If not, tell user to run `/cks:monetize-evaluate` first.

## Execution

```
Agent(subagent_type="monetize-reporter", prompt="Generate the business case report. Read all .monetize/ artifacts. Write to docs/monetization-assessment.md.")
```
```

- [ ] **Step 6: Rewrite monetize-roadmap.md**

Replace entire content:
```markdown
---
description: "Generate monetization roadmap and PRD handoff"
allowed-tools:
  - Read
  - Write
---

# /cks:monetize-roadmap

Generate phase briefs and update the project roadmap from evaluation results.

## Prerequisite

Verify `docs/monetization-assessment.md` and `.monetize/evaluation.md` exist.

## Execution

Read `.monetize/evaluation.md`. For each recommended monetization model:
1. Create `.monetize/phases/{NN}-{model-name}.md` with a PRD-ready phase brief
2. If `.prd/PRD-ROADMAP.md` exists, append monetization phases as "Planned" entries

Display summary of created phase briefs and next steps.
```

- [ ] **Step 7: Commit**

```bash
git add commands/monetize-discover.md commands/monetize-research.md commands/monetize-cost-analysis.md commands/monetize-evaluate.md commands/monetize-report.md commands/monetize-roadmap.md
git commit -m "refactor(commands): rewrite 6 monetize sub-commands as thin dispatchers"
```

---

## Chunk 3: Refactor both SKILL.md files + version bump

### Task 7: Refactor skills/cicd-starter/SKILL.md

**Files:**
- Modify: `skills/cicd-starter/SKILL.md`

- [ ] **Step 1: Read current file and update**

Read `skills/cicd-starter/SKILL.md`. Make two changes:

1. Replace the "## Workflow" section:
```markdown
## Workflow

Read and execute: `workflows/bootstrap.md`
```

With:
```markdown
## Agents

| Phase | Agent | Role |
|-------|-------|------|
| 1 — Scan & Intake | `bootstrap-scanner` | Scans codebase, detects stack, runs guided Q&A |
| 2 — Generate | `bootstrap-generator` | Produces CLAUDE.md, .prd/, rules, config from scan context |

Agents load this skill via `skills: cicd-starter` and read workflow files for step-by-step process.
```

2. Keep everything else unchanged (Flow, When to Use, What It Produces, Reference Files, Customization, Rules).

- [ ] **Step 2: Commit**

```bash
git add skills/cicd-starter/SKILL.md
git commit -m "refactor(skills): update cicd-starter with agent phase map"
```

### Task 8: Refactor skills/monetize/SKILL.md

**Files:**
- Modify: `skills/monetize/SKILL.md`

- [ ] **Step 1: Read current file and update**

Read `skills/monetize/SKILL.md`. Remove the "Full Flow Execution" section (lines 66-78) which describes sequential dispatch — this orchestration logic now lives in the command. Replace with:

```markdown
## Execution

The `/cks:monetize` command orchestrates the flow by dispatching agents in sequence.
Each agent loads this skill via `skills: monetize` for domain expertise.
Individual phases can be invoked via `/cks:monetize-{phase}` sub-commands.
```

Keep everything else unchanged (Flow diagram, Agents table, Mode Detection, Re-run Check, Phase Validation, Reference Files, Error Handling, Customization, Output Artifacts).

- [ ] **Step 2: Commit**

```bash
git add skills/monetize/SKILL.md
git commit -m "refactor(skills): remove orchestration from monetize SKILL.md, keep expertise"
```

### Task 9: Version bump + changelog

**Files:**
- Modify: `.claude-plugin/plugin.json`
- Modify: `CHANGELOG.md`

- [ ] **Step 1: Bump version to 4.1.0**

In `.claude-plugin/plugin.json`, change `"version"` to `"4.1.0"`.

- [ ] **Step 2: Add changelog entry**

Add at the top of changelog (after `---`):

```markdown
## [4.1.0] - 2026-03-30

### Added
- 2 new bootstrap agents: `bootstrap-scanner` (scan + intake), `bootstrap-generator` (file generation)
- `skills: monetize` field to 5 monetize agents (researcher, cost-researcher, cost-analyzer, evaluator, reporter)
- `model: sonnet` to `monetize-reporter` agent

### Changed
- `/cks:bootstrap` rewritten as thin agent orchestrator (123 → ~45 lines)
- `/cks:monetize` rewritten as thin agent orchestrator (37 → ~70 lines)
- 6 monetize sub-commands rewritten as single-agent dispatchers
- `skills/cicd-starter/SKILL.md` updated with agent phase map
- `skills/monetize/SKILL.md` orchestration logic removed (now in command)

### Architecture
- Bootstrap and monetize now follow the v4.0 reference pattern:
  Command → Agent(skills: loaded) → Hook(logs)
```

- [ ] **Step 3: Commit**

```bash
git add .claude-plugin/plugin.json CHANGELOG.md
git commit -m "chore: bump to v4.1.0 — bootstrap + monetize architecture refactor"
```

---

## Verification

After all tasks complete:

- [ ] **1.** New agents exist: `ls agents/bootstrap-scanner.md agents/bootstrap-generator.md`
- [ ] **2.** All monetize agents have skills: `grep -l 'skills:' agents/monetize-*.md agents/cost-*.md | wc -l` → expect 6
- [ ] **3.** Bootstrap command is thin: `wc -l commands/bootstrap.md` → expect ~45 lines, `grep -c 'SKILL.md' commands/bootstrap.md` → expect 0
- [ ] **4.** Monetize command is thin: `wc -l commands/monetize.md` → expect ~70 lines, `grep -c 'SKILL.md' commands/monetize.md` → expect 0
- [ ] **5.** Sub-commands are thin: `grep -c '@.*SKILL.md' commands/monetize-*.md` → expect 0
- [ ] **6.** cicd-starter SKILL.md has agent phase map: `grep -c 'bootstrap-scanner' skills/cicd-starter/SKILL.md` → expect 1
- [ ] **7.** monetize SKILL.md has no orchestration: `grep -c 'Full Flow Execution' skills/monetize/SKILL.md` → expect 0
- [ ] **8.** Version is 4.1.0: `grep '"version"' .claude-plugin/plugin.json`
