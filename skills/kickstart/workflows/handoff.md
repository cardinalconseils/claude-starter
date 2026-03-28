# Workflow: Handoff (Phase 6)

## Overview
Feeds all accumulated context and artifacts into `/bootstrap` to personalize the
`.claude/` ecosystem. The handoff provides rich context that makes bootstrap's
intake questions either pre-answered or much more targeted.

## Prerequisites
- `.kickstart/manifest.md` must exist (from Compose phase)
- Design artifacts must exist (per-sub-project or flat depending on manifest)
  - Single SP: `.kickstart/artifacts/PRD.md`, `ERD.md`, `schema.sql`, `API.md`, `ARCHITECTURE.md`
  - Multi SP: `.kickstart/artifacts/sp-{NN}-{name}/` directories with artifacts per sub-project

## State-Aware Handoff

**CRITICAL:** This handoff is part of kickstart Phase 6. Before executing any sub-step,
read `.kickstart/state.md` to determine which sub-steps are already done.

**The key rule:** Do NOT use file existence as the sole indicator of completion.
A file might exist from a prior bootstrap run but lack kickstart context enrichment.
Always check `.kickstart/state.md` first. If state.md says a sub-step is still `pending`
or `in_progress`, run it regardless of whether output files exist.

### Bootstrap-Already-Ran Detection

Check if CLAUDE.md and .prd/ exist but `.kickstart/state.md` shows Phase 6a as `pending`:

- This means bootstrap was run independently BEFORE kickstart.
- In this case, do NOT invoke full `/bootstrap` again (it would trigger its re-run check
  and confuse the flow).
- Instead: **ENRICH** the existing CLAUDE.md with kickstart context (see Step 3 below).

## Steps

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "kickstart.phase.started" "_project" "Kickstart Phase 6: Handoff" '{"phase_number":"6","phase_name":"Handoff"}'`

### Step 1: Prepare Bootstrap Context

Read all kickstart artifacts and synthesize the answers to bootstrap's intake questions:

| Bootstrap Question | Pre-filled From |
|-------------------|-----------------|
| Q1: Project name | `.kickstart/context.md` → Project name |
| Q2: What does this project do | `.kickstart/context.md` → One-liner + Problem Statement |
| Q3: Primary tech stack | `.kickstart/artifacts/ARCHITECTURE.md` → Stack Decision table |
| Q4: Key workflows | `.kickstart/artifacts/PRD.md` → Core Features + `.kickstart/artifacts/API.md` → Endpoints |
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

**Determine bootstrap mode:**

**If CLAUDE.md does NOT exist** → Full bootstrap:
- Trigger the bootstrap flow. The `/bootstrap` skill should detect
  `.kickstart/bootstrap-context.md` and use it to skip or pre-fill its intake.

**If CLAUDE.md ALREADY exists** (bootstrap was run before kickstart) → Enrich mode:
- Do NOT invoke `/bootstrap` from scratch — it would trigger its re-run check
  ("Update / Regenerate / Cancel") and break the automated flow.
- Instead, read the existing CLAUDE.md and MERGE kickstart context into it:
  - Add/update `## Stack` with details from `.kickstart/artifacts/ARCHITECTURE.md`
  - Add/update `## Key Workflows` with features from `.kickstart/artifacts/PRD.md`
  - Add `## Design Artifacts` section referencing `.kickstart/artifacts/`
  - If `.kickstart/research.md` exists → add `## Market Context` section
  - If `.monetize/context.md` exists → add `## Monetization` section
  - If `.kickstart/brand.md` exists → add `## Brand Guidelines` reference to `.brand/guidelines.md`
- Still write `.kickstart/bootstrap-context.md` for the record.

**Validate [6a]:** Check CLAUDE.md exists and contains project-specific content (not template `[PROJECT_NAME]` tokens).

**Update state:**
```
Update .kickstart/state.md:
  Phase 6a (Bootstrap) → status: done, completed: {date}
```

**Report:**
```
  [6a] Bootstrap      ✅ done
       Output: CLAUDE.md + .claude/ personalized
       Agents: {N} configured | Commands: {N} adapted
```

### Step 4: Persist Brand Guidelines

If `.kickstart/brand.md` exists (brand phase was not skipped):

```bash
mkdir -p .brand
cp .kickstart/brand.md .brand/guidelines.md
```

This makes brand guidelines available at a well-known path (`.brand/guidelines.md`) that the
CKS design phase (Phase 2) reads to pre-fill design tokens. The kickstart copy stays as
the source-of-truth snapshot; `.brand/guidelines.md` is the living version that can be
updated independently.

If `.kickstart/brand.md` does not exist → skip this step silently.

### Step 5: Scaffold Project Files

After bootstrap personalizes `.claude/`, scaffold the actual project based on the stack decision from ARCHITECTURE.md.

Read `.kickstart/artifacts/ARCHITECTURE.md` → Stack Decision table. Then:

**Node.js (Next.js, React, Express, etc.):**
- If no `package.json` exists → run the appropriate scaffolder:
  - Next.js: `npx create-next-app@latest . --typescript --tailwind --eslint --app --src-dir --import-alias "@/*" --no-git`
  - React (Vite): `npm create vite@latest . -- --template react-ts`
  - Express: `npm init -y` then install express, typescript, etc.
- Install additional deps from ARCHITECTURE.md integrations (e.g., `@supabase/supabase-js`, `stripe`, `@clerk/nextjs`)
- Create `.env.local` with all env var keys from ARCHITECTURE.md (values empty, with comments)

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

**If scaffolding fails** → report the error, save what was created, continue to next sub-step.

**Validate [6b]:** Check that the project file exists (`package.json`, `pyproject.toml`, `Cargo.toml`, or `go.mod`).

**Update state:**
```
Update .kickstart/state.md:
  Phase 6b (Scaffold) → status: done, completed: {date}
```

**Report:**
```
  [6b] Scaffold       ✅ done
       Output: {stack} project scaffolded
       Deps: {N} packages installed | Build: {pass/fail}
```

### Step 6: Configure Observability for Retro

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

**Validate [6c]:** Check `.learnings/observability.md` exists.

**Update state:**
```
Update .kickstart/state.md:
  Phase 6c (Observability) → status: done, completed: {date}
```

**Report:**
```
  [6c] Observability  ✅ done
       Output: .learnings/observability.md
       Platform: {detected} | Sources: {N} enabled
```

### Step 7: Initialize CKS Project Structure (Shell Script)

**Run this immediately — guarantees all CKS files are created:**

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/init-project.sh "{project_name}"
```

This creates: `.prd/`, `.context/config.md`, `.env.example`, `.gitignore` updates, `.learnings/`.

**Then enrich `.prd/PRD-PROJECT.md`** with the full kickstart context:
- Copy relevant sections from `.kickstart/context.md`
- Add stack details from `.kickstart/artifacts/ARCHITECTURE.md`
- Reference the PRD: `.kickstart/artifacts/PRD.md`

**Validate [6d]:** Check `.prd/PRD-STATE.md` exists.

**Update state:**
```
Update .kickstart/state.md:
  Phase 6d (PRD Init) → status: done, completed: {date}
  last_phase: complete
  last_phase_status: done
```

**Report:**
```
  [6d] PRD Init       ✅ done
       Output: .prd/ initialized + .context/ + .learnings/
       Roadmap: ready for /cks:new
```

### Step 8: Final Report

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "kickstart.phase.completed" "_project" "Kickstart Phase 6 complete" '{"phase_number":"6"}'`

```
/kickstart complete!

Artifacts generated:
  .kickstart/context.md              — Project context
  .kickstart/manifest.md             — Project composition ({N} sub-projects)
  .kickstart/research.md             — Market research {if ran}
  .kickstart/artifacts/              — Design artifacts {per sub-project if multi-SP}
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

▶ Auto-advancing to feature lifecycle...
```

### Step 9: Copy Manifest to PRD

Copy the project manifest into the PRD directory so the feature lifecycle can reference it:

```bash
cp .kickstart/manifest.md .prd/PROJECT-MANIFEST.md
```

### Step 10: Auto-Chain to Feature Lifecycle

**CRITICAL:** Do NOT stop here. Automatically invoke the feature lifecycle.

**Read `.kickstart/manifest.md`** to determine mode:

#### Single Sub-Project Mode (1 SP in manifest)

1. Extract the first feature from `.kickstart/artifacts/PRD.md` — look for the first
   MVP user story or core feature listed. Use it as the feature brief.

2. Auto-invoke `/cks:new`:
   ```
   Skill(skill="cks:new", args="{first feature brief}")
   ```

3. Proceed to validation gate (below).

#### Multi Sub-Project Mode (2+ SPs in manifest)

1. Read the build order from the manifest.
2. For the **first sub-project** in build order, extract its feature brief from
   `.kickstart/artifacts/sp-{NN}-{name}/PRD.md`.

3. Auto-invoke `/cks:new` for the first sub-project:
   ```
   Skill(skill="cks:new", args="{first SP name}: {feature brief}")
   ```

4. **After creating the first feature**, update `PRD-ROADMAP.md` with ALL sub-projects:
   ```markdown
   ## Active Work

   | Phase | Sub-Project | Status | Depends On | Source |
   |-------|-------------|--------|------------|--------|
   | 01 | {SP-01 name} | Discovering | — | .kickstart/artifacts/sp-01-{name}/ |
   | 02 | {SP-02 name} | Pending | Phase 01 | .kickstart/artifacts/sp-02-{name}/ |
   | 03 | {SP-03 name} | Pending | Phase 01 | .kickstart/artifacts/sp-03-{name}/ |
   | ... | ... | ... | ... | ... |
   ```

   Only the first sub-project enters the lifecycle immediately. Others are queued in the
   roadmap and will be started via `/cks:new` when their dependencies are met.

5. Proceed to validation gate (below).

#### Validation Gate (both modes)

**VALIDATION GATE — MANDATORY:** After `/cks:new` returns, IMMEDIATELY verify:
- `.prd/phases/{NN}-{name}/` directory exists
- `PRD-STATE.md` has `active_phase` set

If EITHER check fails:
```
Auto-chain validation failed:
  Expected: .prd/phases/{NN}-{name}/ to exist
  Action: Retrying /cks:new...
```
Retry once. If it fails again, stop and tell the user:
"Run `/cks:new` manually to create your first feature."
Do NOT invoke `/cks:next` without a valid feature.

Only after validation passes, invoke `/cks:next`:
```
Skill(skill="cks:next")
```

`/cks:next` will detect the state and invoke `/cks:discover` automatically.

After discover completes, the phase will end with a **Context Reset** banner.
The user runs `/clear` then `/cks:next` to continue through design → sprint → etc.

When a sub-project's full lifecycle completes (released), `/cks:next` should check
`PROJECT-MANIFEST.md` and `PRD-ROADMAP.md` for the next pending sub-project whose
dependencies are met, and suggest starting it via `/cks:new`.

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
- First feature created via `/cks:new` and discovery started automatically
