# Workflow: Handoff (Phase 5)

## Overview
Feeds all accumulated context and artifacts into `/bootstrap` to personalize the
`.claude/` ecosystem. The handoff provides rich context that makes bootstrap's
intake questions either pre-answered or much more targeted.

## Prerequisites
- `.kickstart/artifacts/PRD.md` must exist
- `.kickstart/artifacts/ERD.md` must exist
- `.kickstart/artifacts/ARCHITECTURE.md` must exist
- `.kickstart/artifacts/SCHEMA.sql` must exist
- `.kickstart/artifacts/FEATURE-ROADMAP.md` must exist

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

**Validate [5a]:** Check CLAUDE.md exists and contains project-specific content (not template `[PROJECT_NAME]` tokens).

**Update state:**
```
Update .kickstart/state.md:
  Phase 5a (Bootstrap) → status: done, completed: {date}
```

**Report:**
```
  [5a] Bootstrap      ✅ done
       Output: CLAUDE.md + .claude/ personalized
       Agents: {N} configured | Commands: {N} adapted
```

### Step 4: Scaffold Project Files

After bootstrap personalizes `.claude/`, scaffold the actual project based on the stack decision from ARCHITECTURE.md.

Read `.kickstart/artifacts/ARCHITECTURE.md` → Stack Decision table. Then:

**Node.js (Next.js, React, Express, etc.):**
- If no `package.json` exists → run the appropriate scaffolder:
  - Next.js: `npx create-next-app@latest . --typescript --tailwind --eslint --app --src-dir --import-alias "@/*" --no-git`
  - React (Vite): `npm create vite@latest . -- --template react-ts`
  - Express: `npm init -y` then install express, typescript, etc.
- Install additional deps from ARCHITECTURE.md integrations (e.g., `@supabase/supabase-js`, `stripe`, `@clerk/nextjs`)
- Create `.env.local` with all env var keys from ARCHITECTURE.md (values empty, with comments)
  - Always include `PERPLEXITY_API_KEY` with comment: "# Optional — enables /monetize and /research deep market intelligence"
  - Always include `# Get keys at:` hints for each service (e.g., Stripe, Supabase, etc.)

**Python (Django, FastAPI, Flask):**
- If no `requirements.txt` / `pyproject.toml` exists:
  - Django: `django-admin startproject {name} .`
  - FastAPI: create `pyproject.toml` with fastapi, uvicorn deps
  - Flask: create `requirements.txt` with flask deps
- Create `.env` template with required vars

**Rust:**
- If no `Cargo.toml` → `cargo init .`

**Go:**
- If no `go.mod` → `go mod init {module_name}`

**Rules for scaffolding:**
1. **Never overwrite existing files** — if `package.json` exists, skip scaffolding
2. **Use the official scaffolder** when available (create-next-app, django-admin, cargo init)
3. **Install integration deps** from ARCHITECTURE.md — don't leave them for later
4. **Create env template** with all required keys (empty values, comments explaining each)
5. **Run initial build** after scaffolding to verify everything works
6. **Commit the scaffold** as the first commit: `chore: scaffold {stack} project via /kickstart`

**If stack is unrecognized or ambiguous:**
```
AskUserQuestion({
  questions: [{
    question: "Could not auto-detect a scaffold command from ARCHITECTURE.md. What should I run?",
    header: "Scaffold Setup",
    multiSelect: false,
    options: [
      { label: "Let me provide a command", description: "I'll type the scaffold command" },
      { label: "Skip scaffolding", description: "I'll set up the project manually" },
      { label: "Use npm init", description: "Start with a basic Node.js project" }
    ]
  }]
})
```

**If scaffolding fails** → report the error, save what was created, continue to next sub-step.

**Validate [5b]:** Check that the project file exists (`package.json`, `pyproject.toml`, `Cargo.toml`, or `go.mod`).

**Update state:**
```
Update .kickstart/state.md:
  Phase 5b (Scaffold) → status: done, completed: {date}
```

**Report:**
```
  [5b] Scaffold       ✅ done
       Output: {stack} project scaffolded
       Deps: {N} packages installed | Build: {pass/fail}
```

### Step 5: Configure Observability for Retro

After scaffolding, set up the observability config so the retrospective agent knows how to
check deployment health and logs. This is derived from the stack decision in ARCHITECTURE.md.

**Auto-detect from stack and integrations:**

```
Create .learnings/observability.md with YAML frontmatter based on:
  - Deployment platform (from ARCHITECTURE.md → Deployment Architecture)
  - AI/LLM integrations (if any — e.g., OpenAI, Anthropic → enable LangSmith)
  - Database (Supabase → enable Supabase logs)
  - Edge/CDN (Cloudflare → enable Cloudflare analytics)
```

**Platform detection rules:**

| ARCHITECTURE.md Signals | Observability Source | Auto-Enable |
|------------------------|---------------------|-------------|
| "Railway", "railway.toml" | `railway` | Yes |
| "Vercel", "vercel.json", Next.js | `vercel` | Yes |
| "Cloudflare Workers", "wrangler" | `cloudflare` | Yes |
| "Supabase" in integrations | `supabase` | Yes |
| "OpenAI", "Anthropic", "LLM", "AI" in stack | `langsmith` | Yes (disabled by default, add env var hint) |
| Custom deploy script / Docker | `webhook` | Template only (URL blank) |
| Fly.io, Render, AWS, GCP, or unrecognized | `generic` | Generic template — user fills in endpoints |

**Generate the config:**

Write `.learnings/observability.md` with:
- Detected sources **enabled** based on the stack
- Non-detected sources listed but **commented out**
- `LANGSMITH_API_KEY` added to `.env.local` template if LLM integration detected
- Custom webhook template if deploy target is non-standard

**Add env var hints:**

If LangSmith was detected, add to `.env.local`:
```
# LLM Observability (optional — enables post-deploy trace analysis in /cks:retro)
# LANGSMITH_API_KEY=your-key-here
# Get a key at: https://smith.langchain.com/settings
```

**Validate [5c]:** Check `.learnings/observability.md` exists.

**Update state:**
```
Update .kickstart/state.md:
  Phase 5c (Observability) → status: done, completed: {date}
```

**Report:**
```
  [5c] Observability  ✅ done
       Output: .learnings/observability.md
       Platform: {detected} | Sources: {N} enabled
```

### Step 6: Initialize CKS Project Structure (Shell Script)

**Run this immediately — guarantees all CKS files are created:**

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/init-project.sh "{project_name}"
```

This creates: `.prd/`, `.context/config.md`, `.env.example`, `.gitignore` updates, `.learnings/`.

**Then enrich `.prd/PRD-PROJECT.md`** with the full kickstart context:
- Copy relevant sections from `.kickstart/context.md`
- Add stack details from `.kickstart/artifacts/ARCHITECTURE.md`
- Reference the PRD: `.kickstart/artifacts/PRD.md`

**Import feature roadmap into `.prd/PRD-ROADMAP.md`:**
- Read `.kickstart/artifacts/FEATURE-ROADMAP.md`
- For each MVP feature: add entry to PRD-ROADMAP.md with status "Planned"
- For each post-MVP feature: add entry with status "Backlog"
- Validate: PRD-ROADMAP.md has at least one feature entry

**Validate [5d]:** Check `.prd/PRD-STATE.md` exists.

**Update state:**
```
Update .kickstart/state.md:
  Phase 5d (PRD Init) → status: done, completed: {date}
  last_phase: complete
  last_phase_status: done
```

**Report:**
```
  [5d] PRD Init       ✅ done
       Output: .prd/ initialized + .context/ + .learnings/
       Roadmap: ready for /cks:new
```

### Step 7: Final Report

```
/kickstart complete!

Artifacts generated:
  .kickstart/context.md              — Project context
  .kickstart/research.md             — Market research {if ran}
  .kickstart/artifacts/PRD.md        — Product requirements
  .kickstart/artifacts/ERD.md        — Entity relationship diagram
  .kickstart/artifacts/ARCHITECTURE.md — Architecture decisions
  .monetize/                          — Monetization strategy {if ran}

Project scaffolded:
  package.json / pyproject.toml       — {stack} project initialized
  .env.local                          — Env vars template ({N} keys)
  {framework files}                   — Scaffolded via {scaffolder}

Ecosystem personalized:
  CLAUDE.md                           — Project instructions
  .claude/skills/                     — Adapted to {project name}
  .claude/agents/                     — {N} agents configured
  .claude/commands/                   — {N} commands adapted

PRD system initialized:
  .prd/PRD-PROJECT.md                — Project definition
  .prd/PRD-ROADMAP.md                — Phase roadmap

Observability configured:
  .learnings/observability.md        — Deploy monitoring for /cks:retro
  Platform: {detected_platform}      — {sources enabled}
  LLM tracing: {status}

Everything is set up. Here's what to do next:

  ┌─────────────────────────────────────────────┐
  │  NEXT STEPS                                 │
  │                                             │
  │  1. /cks:new "brief"   Define features +    │
  │                         create phases       │
  │  2. /cks:go dev        Start dev server     │
  │  3. /cks:help          See all commands     │
  │                                             │
  │  Or: /cks:autonomous   Run full lifecycle   │
  └─────────────────────────────────────────────┘

  Optional:
  - Review CLAUDE.md — make sure it reflects your project
  - Review .kickstart/artifacts/ERD.md — refine the data model
  - Run /cks:monetize if you skipped monetization analysis {if skipped}
```

### Step 8: Git Configuration

Ensure `.kickstart/` artifacts are committed but session state is not:

```bash
# .kickstart/state.md is session state — don't commit
if [ -f ".gitignore" ] && ! grep -q ".kickstart/state.md" ".gitignore"; then
  echo "" >> .gitignore
  echo "# CKS kickstart session state (resumable, not source)" >> .gitignore
  echo ".kickstart/state.md" >> .gitignore
fi
```

The design artifacts (PRD.md, ERD.md, ARCHITECTURE.md, FEATURE-ROADMAP.md) SHOULD be committed — they're project documentation.

## Post-Conditions
- `.kickstart/state.md` shows all phases as `done` or `skipped`
- `.kickstart/bootstrap-context.md` exists
- Project scaffolded: `package.json` / `pyproject.toml` / `Cargo.toml` / `go.mod` exists with deps installed
- `.env.local` template created with required keys
- `.claude/` folder is personalized to the project
- `CLAUDE.md` is generated and project-specific
- `.learnings/observability.md` configured for deploy monitoring
- `.prd/` is initialized with project context
- Initial commit created with scaffolded project
- User has a clear path forward with the full lifecycle documented
