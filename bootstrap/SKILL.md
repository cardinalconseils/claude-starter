---
name: cicd-starter
description: >
  Bootstrap and adapt the full .claude/ architecture (skills, agents, commands, CLAUDE.md) to any new project — then deploy it via Railway with a single command. Use this skill whenever the user wants to set up a project scaffold, initialize a .claude/ folder, create project-specific agents or commands, generate a CLAUDE.md, or deploy an automation stack to Railway. Triggers on phrases like "set up .claude", "scaffold my project", "initialize architecture", "create CLAUDE.md", "deploy to Railway", "cicd setup", or "project structure". Always use this skill when a new project needs AI tooling wired up from scratch.
---

# CICD Starter Skill

Bootstrap and adapt the full `.claude/` architecture to any project via a structured intake — then deploy to Railway with a single command.

## What This Skill Produces

```
.claude/
├── CLAUDE.md              ← Project-specific Claude instructions
├── skills/                ← Reusable skill files adapted to the project
│   └── *.md
├── agents/                ← Specialized sub-agent definitions
│   └── *.md
└── commands/              ← Slash commands adapted to the project
    └── *.md
railway.toml               ← Railway deployment config
deploy.sh                  ← Single deploy command
```

---

## Step 1: Run the Intake Questionnaire

Ask the user these questions sequentially. Do NOT skip any. Capture answers before proceeding to generation.

```
CICD Claude — Project Setup
───────────────────────────

[1] Project name?
    (Used in CLAUDE.md header and Railway service name)

[2] What does this project do?
    (1–3 sentences. This becomes the project description in CLAUDE.md)

[3] What is the primary tech stack?
    (e.g., Next.js + Supabase, Python FastAPI, n8n + Node, etc.)

[4] What are the key workflows Claude will support in this project?
    (List tasks: e.g., "generate reports", "process webhooks", "draft emails")

[5] What agents are needed?
    (e.g., "a code reviewer agent", "a deployment agent", "a QA agent")
    Type "none" if no custom agents needed.

[6] What slash commands should exist?
    (e.g., /deploy, /test, /review, /summarize)
    Type "none" to skip or "suggest" for Claude to recommend based on your stack.

[7] What skills should be included?
    (e.g., "docx generation", "n8n workflows", "supabase schema")
    Type "suggest" for Claude to recommend based on your stack.

[8] Railway deployment: what service does this deploy?
    (e.g., "Node API", "Python worker", "n8n instance", "static site")
    Type "none" if no Railway deployment needed.

[9] Environment variables this project needs?
    (List names only, no values: e.g., OPENAI_KEY, SUPABASE_URL, DATABASE_URL)
    Type "none" if unknown yet.

[10] Any specific instructions Claude must always follow in this project?
     (e.g., "always use French", "never modify production DB directly", "always add tests")
     Type "none" to skip.
```

Wait for all answers before proceeding.

---

## Step 2: Generate the .claude/ Architecture

Using intake answers, generate each file. All content must be **adapted to the project** — no generic placeholders.

### CLAUDE.md

See `references/claude-md-template.md` for the full template.

Key adaptation rules:
- Replace all `[PROJECT_*]` tokens with intake answers
- Workflows section = answer to Q4, written as imperative instructions
- Always-follow rules = answer to Q10
- Stack section = answer to Q3 with specific tool callouts

### skills/

For each skill in Q7:
- If the skill exists in `/mnt/skills/`, copy and adapt it — rewrite the description and any project-specific references
- If it doesn't exist, create a minimal SKILL.md scoped to the project's needs
- Name files as `[skill-name].md`

### agents/

For each agent in Q5:
- Create `[agent-name].md` using the template in `references/agent-template.md`
- Scope the agent's role, tools, and constraints to the project
- If Q5 = "none", skip this directory

### commands/

For each command in Q6:
- Create `[command-name].md` using the template in `references/command-template.md`
- If Q6 = "suggest", generate commands appropriate to the stack (e.g., Next.js → /build /test /deploy /lint)
- If Q6 = "none", skip this directory

---

## Step 3: Generate Railway Deployment Files

Only if Q8 ≠ "none".

See `references/railway-deploy.md` for platform-specific configs.

Generate:
1. `railway.toml` — adapted to the service type from Q8
2. `deploy.sh` — single command that:
   - Validates environment variables from Q9
   - Builds the project
   - Deploys to Railway
   - Reports success/failure with service URL

The deploy command must be self-describing — run it with `--help` and it explains what it will do for this specific project.

---

## Step 4: Output

1. Write all files to `/mnt/user-data/outputs/.claude/` (and railway files to root)
2. Show the user a summary tree of what was generated
3. Call `present_files` with the output directory
4. Print the one-line deploy command for Railway if applicable

---

## Adaptation Rules (Critical)

Every file generated must pass these checks before output:

- [ ] No generic placeholder text (`[PROJECT_NAME]`, `TODO`, `example.com`)
- [ ] CLAUDE.md references the actual stack, not "your stack"
- [ ] Commands are named and scoped to real project workflows
- [ ] Agents have specific role descriptions, not "this agent helps with tasks"
- [ ] Skills have adapted descriptions referencing the project context
- [ ] Railway config matches the actual service type (not a generic Node template)

If any check fails, revise before presenting.

---

## Reference Files

Read these when generating the corresponding output:

| File | When to read |
|------|-------------|
| `references/claude-md-template.md` | Always — generating CLAUDE.md |
| `references/agent-template.md` | When Q5 has agent names |
| `references/command-template.md` | When Q6 has command names |
| `references/railway-deploy.md` | When Q8 ≠ "none" |
| `references/bootstrap-command.md` | When /bootstrap is invoked in an existing .claude/ folder |
| `references/starter-repo-sync.md` | When user asks about syncing, updating, or contributing back to the starter repo |

---

## /bootstrap Mode

**Trigger:** User runs `/bootstrap` inside a project that already has a `.claude/` folder (pulled from `claude-starter` via git subtree or submodule).

This mode does NOT generate from scratch. It **adapts what already exists**.

### Detection

Before running the intake, scan the current `.claude/` directory:

```
Existing components found:
  Skills:   docx.md, n8n-workflows.md, supabase.md
  Agents:   reviewer.md, deployer.md
  Commands: deploy.md, test.md
  Tools:    railway.md
  CLAUDE.md: ❌ not found (template only)
```

Report the scan to the user, then run a **shortened intake** (Q1, Q2, Q3, Q4, Q10 only — skip Q5/Q6/Q7/Q8/Q9 unless user wants to add new components).

### Bootstrap Intake (short form)

```
/bootstrap — Adapting .claude/ to this project
───────────────────────────────────────────────
Found: [N] skills, [N] agents, [N] commands, [N] tools

[1] Project name?
[2] What does this project do? (2–3 sentences)
[3] Primary tech stack?
[4] Key workflows Claude will support?
[10] Any always-follow rules for this project?

Want to add any NEW components not in the starter? (skills / agents / commands / tools / none)
```

If user says "none" to new components → skip to adaptation.
If user lists new items → run the relevant sections of the full intake for those items only.

### Bootstrap Adaptation Rules

For each **existing** file in `.claude/`:

1. **Skills** — rewrite the `description:` frontmatter to reference this project's stack and context. Keep the skill body unchanged.
2. **Agents** — rewrite `Role` and `Triggers` sections to match project workflows. Keep structure.
3. **Commands** — rewrite `What It Does` and `Steps` to match the actual project stack. Rename args if needed.
4. **Tools** — rewrite any project-specific references (URLs, service names, env var names).
5. **CLAUDE.md** — generate fresh from `references/claude-md-template.md` using intake answers.

**Never delete existing files** during bootstrap. Only adapt.

### Bootstrap Output

```
✓ CLAUDE.md generated
✓ 3 skills adapted (descriptions updated to [PROJECT_NAME] context)
✓ 2 agents adapted (roles scoped to [PROJECT_NAME] workflows)
✓ 2 commands adapted (steps updated for [STACK])
+ 1 new skill added: [new-skill].md
```

See `references/bootstrap-command.md` for detailed per-file adaptation logic.

---

## Starter Repo Sync

See `references/starter-repo-sync.md` for the full git subtree workflow.

Quick reference:

```bash
# Pull latest from claude-starter into this project
git subtree pull --prefix .claude \
  https://github.com/[you]/claude-starter.git main --squash

# Push a new component back to claude-starter
git subtree push --prefix .claude \
  https://github.com/[you]/claude-starter.git main
```

When user asks "how do I update my starter" or "how do I contribute this back", read `references/starter-repo-sync.md` and walk them through the right command for their situation.
