# Workflow: Handoff (Phase 5)

## Overview
Feeds all accumulated context and artifacts into `/bootstrap` to personalize the
`.claude/` ecosystem. The handoff provides rich context that makes bootstrap's
intake questions either pre-answered or much more targeted.

## Prerequisites
- `.kickstart/artifacts/PRD.md` must exist
- `.kickstart/artifacts/ERD.md` must exist
- `.kickstart/artifacts/ARCHITECTURE.md` must exist

## Steps

### Step 1: Prepare Bootstrap Context

Read all kickstart artifacts and synthesize the answers to bootstrap's intake questions:

| Bootstrap Question | Pre-filled From |
|-------------------|-----------------|
| Q1: Project name | `.kickstart/context.md` → Project name |
| Q2: What does this project do | `.kickstart/context.md` → One-liner + Problem Statement |
| Q3: Primary tech stack | `.kickstart/artifacts/ARCHITECTURE.md` → Stack Decision table |
| Q4: Key workflows | `.kickstart/artifacts/PRD.md` → Core Features + User Journey |
| Q5: Agents needed | Infer from architecture (e.g., reviewer, deployer, data processor) |
| Q6: Slash commands | Infer from stack + workflows (e.g., /deploy, /test, /migrate) |
| Q7: Skills needed | Infer from integrations + domain (e.g., stripe, supabase, ai-prompts) |
| Q8: Railway deployment | `.kickstart/artifacts/ARCHITECTURE.md` → Deployment Architecture |
| Q9: Environment variables | `.kickstart/context.md` → Integrations (each needs API keys) |
| Q10: Always-follow rules | `.kickstart/context.md` → Constraints + security requirements |

### Step 2: Confirm Handoff

Present the pre-filled answers to the user:

```
Ready to hand off to /bootstrap with this context:

  Project: {name}
  Stack: {stack summary}
  Workflows: {list}
  Agents: {inferred list}
  Commands: {inferred list}
  Deployment: {platform}

This will personalize your entire .claude/ folder — skills, agents,
commands, and CLAUDE.md — to your project.

Proceed? (yes / let me adjust / skip bootstrap)
```

If "let me adjust" → let user modify any of the pre-filled answers.
If "skip bootstrap" → save the handoff context and exit.

### Step 3: Execute Bootstrap

Invoke the `/bootstrap` command flow, but instead of running the intake questionnaire,
pass the pre-filled answers directly.

**How to pass context:**
Set up the context so that when bootstrap's intake runs, it can detect that
answers are already available in `.kickstart/bootstrap-context.md`:

Write `.kickstart/bootstrap-context.md`:

```markdown
# Bootstrap Context (from /kickstart)

**Generated:** {date}
**Source:** /kickstart handoff

## Pre-filled Intake Answers

**[1] Project name:** {name}
**[2] Description:** {description}
**[3] Tech stack:** {stack}
**[4] Key workflows:**
- {workflow 1}
- {workflow 2}
- {workflow 3}

**[5] Agents needed:**
- {agent 1} — {role description}
- {agent 2} — {role description}

**[6] Slash commands:**
- /{command 1} — {what it does}
- /{command 2} — {what it does}

**[7] Skills needed:**
- {skill 1} — {why}
- {skill 2} — {why}

**[8] Deployment:** {platform and service type}

**[9] Environment variables:**
- {VAR_1} — {purpose}
- {VAR_2} — {purpose}

**[10] Always-follow rules:**
- {rule 1}
- {rule 2}
```

Then trigger the bootstrap flow. The `/bootstrap` skill should detect
`.kickstart/bootstrap-context.md` and use it to skip or pre-fill its intake.

### Step 4: Initialize PRD State

After bootstrap completes, also initialize the PRD system:

1. Create `.prd/` directory structure (if not exists)
2. Write `PRD-PROJECT.md` from kickstart context
3. Copy `.kickstart/artifacts/PRD.md` as the first phase PRD
4. Update `PRD-ROADMAP.md` with Phase 01 from the PRD's MVP features
5. Set `PRD-STATE.md` to `project_initialized`

### Step 5: Final Report

```
/kickstart complete!

Artifacts generated:
  .kickstart/context.md              — Project context
  .kickstart/research.md             — Market research {if ran}
  .kickstart/artifacts/PRD.md        — Product requirements
  .kickstart/artifacts/ERD.md        — Entity relationship diagram
  .kickstart/artifacts/ARCHITECTURE.md — Architecture decisions
  .monetize/                          — Monetization strategy {if ran}

Ecosystem personalized:
  CLAUDE.md                           — Project instructions
  .claude/skills/                     — Adapted to {project name}
  .claude/agents/                     — {N} agents configured
  .claude/commands/                   — {N} commands adapted

PRD system initialized:
  .prd/PRD-PROJECT.md                — Project definition
  .prd/PRD-ROADMAP.md                — Phase roadmap

Your full lifecycle from here:

  /kickstart     ✅ done — idea discovered, artifacts generated
  /bootstrap     ✅ done — .claude/ personalized
      ↓
  /monetize      → Run anytime for revenue model analysis {if skipped}
  /prd:discuss   → Refine your first feature with deep Q&A
  /prd:plan      → Write the execution plan
  /prd:execute   → Build it
  /prd:verify    → Check acceptance criteria pass
  /prd:ship      → Commit, PR, deploy

  Or run /prd:autonomous to chain discuss → plan → execute → verify → ship automatically.

Quick start:
  1. Review CLAUDE.md — make sure it reflects your project
  2. Review .kickstart/artifacts/ERD.md — refine the data model
  3. Run /monetize if you skipped the monetization analysis {if skipped}
  4. Run /prd:discuss to start your first feature
  5. Run /deploy when ready to set up infrastructure
```

## Post-Conditions
- `.kickstart/bootstrap-context.md` exists
- `.claude/` folder is personalized to the project
- `CLAUDE.md` is generated and project-specific
- `.prd/` is initialized with project context
- User has a clear path forward with the full lifecycle documented
