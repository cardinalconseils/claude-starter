---
name: kickstart
description: >
  Project enabler — takes a raw idea and transforms it into a fully scaffolded project
  with research-backed design artifacts (ERD, schema.sql, PRD, API contract, architecture) and a personalized .claude/
  ecosystem. Integrates deep market research via Perplexity API and monetization strategy
  via /monetize. Use this skill whenever the user pitches a new project idea, wants to
  start a project from scratch, says "kickstart", "new project idea", "I have an idea",
  "let's build", "project enabler", or any variation of going from idea to implementation-ready.
  Always use this skill before /bootstrap when starting from zero.
---

# Kickstart — From Idea to Implementation-Ready

Takes a raw project idea through guided discovery, optional market research & monetization
analysis, then generates design artifacts and hands off to `/bootstrap` to wire up the
full `.claude/` ecosystem.

## Flow

```
/kickstart → intake → compose → research? → monetize? → brand? → design → handoff → /cks:new → discover
```

Each phase is independently resumable. If interrupted, the next `/kickstart` detects
existing artifacts and offers to resume.

## MANDATORY GATES — READ THIS FIRST

**Phase 1b (Compose) is ALWAYS run after Intake. Phases 2 (Research), 3 (Monetize), and 4 (Brand) are OPTIONAL for the USER but the QUESTION is MANDATORY for YOU.**

You MUST call AskUserQuestion at each gate. You MUST NOT:
- Decide on the user's behalf whether to skip a phase
- Skip the question because you predict what they will say
- Skip the question because an API key is missing (WebSearch fallback exists)
- Skip the question because you think it's not relevant
- Skip the question because other artifacts already exist (e.g., .prd/ from bootstrap)

**The user's explicit response is what drives skip/proceed — never your inference.**

**Failure mode to avoid:** Claude sees no API key or sees .prd/ already exists and
decides "they probably don't want this" and skips the AskUserQuestion call entirely.
This is WRONG. Always ask. Every time. No exceptions.

## STATE FILE ENFORCEMENT

**STOP RULE:** After completing any phase (including marking it skipped), you MUST:
1. Write/update `.kickstart/state.md` BEFORE displaying the completion banner
2. Write/update `.kickstart/state.md` BEFORE starting the next phase
3. Never skip a state file write — the resume system depends on it

If you do not update the state file, the resume system breaks and phases get re-run
or skipped incorrectly on the next invocation.

## Progress Tracker

**CRITICAL:** Every phase displays a progress banner before AND after execution. The user
must always know exactly where they are, what just completed, and what's coming next.

### Progress Banner Format

Display this banner at the **start** of every phase:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 KICKSTART ► {PHASE_NAME}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 [1]  Intake          {✅ done | ▶ current | ○ pending | ⊘ skipped}
 [1b] Compose        {✅ done | ▶ current | ○ pending | ⊘ skipped}
 [2]  Research        {✅ done | ▶ current | ○ pending | ⊘ skipped}
 [3]  Monetize        {✅ done | ▶ current | ○ pending | ⊘ skipped}
 [4]  Brand           {✅ done | ▶ current | ○ pending | ⊘ skipped}
 [5]  Design          {✅ done | ▶ current | ○ pending | ⊘ skipped}
 [6]  Handoff         {✅ done | ▶ current | ○ pending | ⊘ skipped}
   [6a] Bootstrap    {✅ done | ▶ current | ○ pending | ⊘ skipped}
   [6b] Scaffold     {✅ done | ▶ current | ○ pending | ⊘ skipped}
   [6c] Observability{✅ done | ▶ current | ○ pending | ⊘ skipped}
   [6d] PRD Init     {✅ done | ▶ current | ○ pending | ⊘ skipped}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Phase Completion Banner

Display this after each phase completes:

```
  [N] {Phase Name}   ✅ done
      Output: {artifact file path(s)}
      Duration: {time or "instant"}
```

### Validation Check

Before advancing to the next phase, **validate the current phase produced its required output:**

| Phase | Required Output | Validation |
|-------|----------------|------------|
| Intake | `.kickstart/context.md` | File exists AND has `## Problem Statement` section |
| Compose | `.kickstart/manifest.md` | File exists AND has `## Sub-Projects` section with at least 1 SP entry |
| Research | `.kickstart/research.md` | File exists AND has `## Competitor Landscape` section |
| Monetize | `.monetize/context.md` | File exists |
| Brand | `.kickstart/brand.md` | File exists AND has `## Visual Identity` section |
| Design: ERD | `.kickstart/artifacts/ERD.md` | File exists with valid `erDiagram` block |
| Design: Schema | `.kickstart/artifacts/schema.sql` | File exists with `CREATE TABLE` statements |
| Design: PRD | `.kickstart/artifacts/PRD.md` | File exists with `## User Stories` section |
| Design: API | `.kickstart/artifacts/API.md` | File exists with `## Endpoints` section |
| Design: Architecture | `.kickstart/artifacts/ARCHITECTURE.md` | File exists with `## Stack Decision` table |
| Handoff/Bootstrap | `CLAUDE.md` updated | CLAUDE.md has project-specific content (not template tokens) |
| Handoff/Scaffold | `package.json` or equivalent | Project file exists with deps installed |
| Handoff/Observability | `.learnings/observability.md` | File exists |
| Handoff/PRD Init | `.prd/PRD-STATE.md` | File exists |

**If validation fails:**
```
  [N] {Phase Name}   ✗ validation failed
      Expected: {what should exist}
      Missing: {what's missing}
      Action: Re-running this phase...
```

Retry the phase once. If it fails again, ask the user what to do.

## Kickstart State File

Persist progress to `.kickstart/state.md` so `/kickstart` can resume on interruption:

```markdown
---
started: {ISO date}
last_phase: {phase number}
last_phase_name: {name}
last_phase_status: {done|in_progress|failed|skipped}
compose_sub_projects: {count|pending}
research_opted: {true|false|pending}
monetize_opted: {true|false|pending}
brand_opted: {true|false|pending}
---

# Kickstart Progress

| # | Phase | Status | Output | Completed |
|---|-------|--------|--------|-----------|
| 1 | Intake | {done/in_progress/pending} | .kickstart/context.md | {date or —} |
| 1b | Compose | {done/in_progress/pending} | .kickstart/manifest.md | {date or —} |
| 2 | Research | {done/skipped/pending} | .kickstart/research.md | {date or —} |
| 3 | Monetize | {done/skipped/pending} | .monetize/ | {date or —} |
| 4 | Brand | {done/skipped/pending} | .kickstart/brand.md | {date or —} |
| 5a | Design: ERD | {done/in_progress/pending} | .kickstart/artifacts/ERD.md | {date or —} |
| 5b | Design: Schema | {done/in_progress/pending} | .kickstart/artifacts/schema.sql | {date or —} |
| 5c | Design: PRD | {done/in_progress/pending} | .kickstart/artifacts/PRD.md | {date or —} |
| 5d | Design: API | {done/in_progress/pending} | .kickstart/artifacts/API.md | {date or —} |
| 5e | Design: Architecture | {done/in_progress/pending} | .kickstart/artifacts/ARCHITECTURE.md | {date or —} |
| 6a | Bootstrap | {done/in_progress/pending} | CLAUDE.md | {date or —} |
| 6b | Scaffold | {done/in_progress/pending} | package.json | {date or —} |
| 6c | Observability | {done/in_progress/pending} | .learnings/ | {date or —} |
| 6d | PRD Init | {done/in_progress/pending} | .prd/ | {date or —} |
```

**Update this file after every phase transition.** This is how resume detection works.

## Mode Detection

| Condition | Behavior |
|-----------|----------|
| Argument provided | Use as the idea pitch, skip to Q&A |
| No argument | Ask for the idea pitch first |
| `.kickstart/state.md` exists | Offer: resume, update, or start fresh |
| `.kickstart/` exists (no state.md) | Legacy — read context.md date, offer resume/fresh |

## Re-run Check

Before starting, check if `.kickstart/state.md` exists:
- If yes → read it, determine where to resume:
  ```
  Previous kickstart found:

    Started: {date}
    Progress:
      [1]  Intake       ✅ done
      [1b] Compose      ✅ done (3 sub-projects)
      [2]  Research     ✅ done
      [3]  Monetize     ⊘ skipped
      [4]  Brand        ✅ done
      [5]  Design       ▶ in progress (interrupted at sub-step 5x)
      [6]  Handoff      ○ pending

    Resume from [4] Design? (yes / start fresh / update intake answers)
  ```
  - Resume: continue from the last incomplete phase
  - Start fresh: `mkdir -p .kickstart/archive/{date} && mv .kickstart/*.md .kickstart/archive/{date}/`
  - Update: re-run intake with pre-filled answers, then continue from design
- If no `.kickstart/` → fresh run

## Full Flow Execution

When `/kickstart` is invoked:

### Phase 0: Initialize

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 KICKSTART ► Starting
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 Taking your idea from concept to implementation-ready.

 What's ahead:
 [1]  Intake          — Understand your idea (guided Q&A)
 [1b] Compose        — Identify sub-projects, shared concerns & build order
 [2]  Research        — Market intelligence (optional)
 [3]  Monetize        — Revenue strategy (optional)
 [4]  Brand           — Brand guidelines (optional)
 [5]  Design          — ERD → schema.sql → PRD → API → Architecture (per sub-project)
 [6]  Handoff         — Scaffold + personalize .claude/

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

1. **Re-run check** (above)
2. Create `.kickstart/state.md` with all phases as `pending`

### Phase 1: Intake

Display progress banner with `[1] Intake ▶ current`, all others `○ pending`.

Read workflow: `workflows/intake.md`

**After completion:**
- Validate: `.kickstart/context.md` exists with required sections
- Update `state.md`: Intake → `done`
- Display completion:
  ```
  [1] Intake          ✅ done
      Output: .kickstart/context.md
      Entities: {N} identified | Auth: {model} | Integrations: {N}
  ```

### Phase 1b: Compose

Display progress banner with `[1b] Compose ▶ current`.

Read workflow: `workflows/compose.md`

The compose workflow reads `.kickstart/context.md` and guides the user through identifying:
- Deployment targets (backend, frontend, admin, marketing, mobile, workers)
- Shared concerns (auth, payments, notifications, storage, search)
- Infrastructure (database, queue, CDN, monitoring)

It builds a dependency graph, determines build order, and defines cross-project contracts.

**After completion:**
- Validate: `.kickstart/manifest.md` exists with `## Sub-Projects` section
- Update `state.md`: Compose → `done`, `compose_sub_projects: {count}`
- Display completion:
  ```
  [1b] Compose        ✅ done
       Output: .kickstart/manifest.md
       Sub-Projects: {N} | Shared: {N} | Infra: {N} | Build Groups: {N}
  ```

**Single sub-project optimization:** If only 1 deployment target is identified with no shared concerns, the compose phase produces a minimal manifest and completes quickly. Downstream phases handle it normally — no special branching needed.

### Phase 2: Research Gate

Display progress banner with `[2] Research ▶ current`.

**MANDATORY STOP: You MUST call AskUserQuestion here. Do NOT skip this question. Do NOT infer the user's preference. Do NOT skip because an API key is missing. Wait for their explicit answer.**

Ask with AskUserQuestion:
```
question: "Want me to research the market for this idea?"
options:
  - "Yes — deep research (multi-hop, multi-source)" → uses /cks:research if available
  - "Yes — standard research (Perplexity API)" → uses workflows/research.md
  - "Skip research" → mark as skipped
```

- If yes (deep) → `Skill(skill="research", args="--competitive \"{project_description}\" --depth medium")`, then copy key findings into `.kickstart/research.md`
- If yes (standard) → Read workflow: `workflows/research.md`
- If skip → update `state.md`: Research → `skipped`

**After completion (if not skipped):**
- Validate: `.kickstart/research.md` exists
- Update `state.md`: Research → `done`
- Display:
  ```
  [2] Research        ✅ done
      Output: .kickstart/research.md
      Competitors: {N} found | Market: {TAM summary} | Gaps: {N}
  ```

**If skipped:**
  ```
  [2] Research        ⊘ skipped
      Tip: Run /cks:research anytime for deep market intelligence
  ```

### Phase 3: Monetize Gate

Display progress banner with `[3] Monetize ▶ current`.

**MANDATORY STOP: You MUST call AskUserQuestion here. Do NOT skip this question. Do NOT infer the user's preference. Wait for their explicit answer.**

Ask with AskUserQuestion:
```
question: "Want a monetization strategy?"
options:
  - "Yes — full analysis" → invokes /monetize
  - "Skip for now" → mark as skipped
```

- If yes → Invoke `/monetize` skill in Mode C with the idea description from intake
- If skip → update `state.md`: Monetize → `skipped`

**After completion (if not skipped):**
- Validate: `.monetize/context.md` exists
- Update `state.md`: Monetize → `done`
- Display:
  ```
  [3] Monetize        ✅ done
      Output: .monetize/
      Model: {recommended model} | Revenue: {projection}
  ```

**If skipped:**
  ```
  [3] Monetize        ⊘ skipped
      Tip: Run /cks:monetize anytime for revenue model analysis
  ```

### Phase 4: Brand Gate

Display progress banner with `[4] Brand ▶ current`.

**MANDATORY STOP: You MUST call AskUserQuestion here. Do NOT skip this question. Do NOT infer the user's preference. Wait for their explicit answer.**

Ask with AskUserQuestion:
```
question: "Want to define brand guidelines? (colors, typography, voice, UI preferences)"
options:
  - "Yes — set up my brand identity"
  - "Skip for now"
```

- If yes → Read workflow: `workflows/brand.md`
- If skip → update `state.md`: Brand → `skipped`

**After completion (if not skipped):**
- Validate: `.kickstart/brand.md` exists with `## Visual Identity` section
- Update `state.md`: Brand → `done`
- Display:
  ```
  [4] Brand           ✅ done
      Output: .kickstart/brand.md
      Source: {Canva | Website | Manual | Generated}
      Colors: {N} tokens | Fonts: {heading} + {body} | Voice: {tone}
  ```

**If skipped:**
  ```
  [4] Brand           ⊘ skipped
      Tip: Define brand guidelines anytime by creating .brand/guidelines.md
  ```

### Phase 5: Design

Display progress banner with `[5] Design ▶ current` and sub-steps all `○ pending`.

Read workflow: `workflows/design.md`

The design workflow consumes:
- `.kickstart/manifest.md` — iterates over sub-projects in build order, generating artifacts per sub-project
- `.kickstart/brand.md` if it exists — pre-filling design tokens (colors, typography, spacing)

**Multi-sub-project behavior:** When the manifest contains multiple sub-projects:
1. Generate **shared artifacts first** (`.kickstart/artifacts/shared/`) — auth design, shared schema, cross-project contracts
2. Then iterate over sub-projects in build order, generating per-sub-project artifacts under `.kickstart/artifacts/sp-{NN}-{name}/`
3. Each sub-project's design references the shared artifacts and its dependencies from the manifest

**Single sub-project behavior:** When the manifest has only 1 sub-project, artifacts are generated flat in `.kickstart/artifacts/` (current behavior — no sub-directories).

**Design has 5 sub-steps per sub-project, each independently tracked (like Handoff). Each sub-step MUST complete and validate before the next begins:**

**[5a] ERD — Entity Relationship Diagram**
- Validate: `.kickstart/artifacts/ERD.md` exists with valid `erDiagram` block
- Update `state.md`: Design: ERD → `done`
- Display:
  ```
  [5a] ERD             ✅ done
       Output: .kickstart/artifacts/ERD.md — {N} entities, {N} relationships
  ```

**[5b] Schema — Database schema DDL (MANDATORY — do NOT skip)**
- **Gate:** `.kickstart/artifacts/ERD.md` MUST exist before starting this step. If missing, go back to 5a.
- Validate: `.kickstart/artifacts/schema.sql` exists with `CREATE TABLE` statements matching ERD entities
- Update `state.md`: Design: Schema → `done`
- Display:
  ```
  [5b] Schema          ✅ done
       Output: .kickstart/artifacts/schema.sql — {N} tables, {DB dialect} ({N} indexes)
  ```

**[5c] PRD — Product Requirements Document**
- **Gate:** `.kickstart/artifacts/schema.sql` MUST exist before starting this step. If missing, go back to 5b.
- Validate: `.kickstart/artifacts/PRD.md` exists with `## User Stories` and `## Functional Requirements`
- Update `state.md`: Design: PRD → `done`
- Display:
  ```
  [5c] PRD             ✅ done
       Output: .kickstart/artifacts/PRD.md — {N} user stories, {N} features
  ```

**[5d] API Design — Endpoint contracts and resource map (MANDATORY — do NOT skip)**
- **Gate:** `.kickstart/artifacts/PRD.md` MUST exist before starting this step. If missing, go back to 5c.
- Validate: `.kickstart/artifacts/API.md` exists with `## Endpoints` section containing endpoint tables
- Update `state.md`: Design: API → `done`
- Display:
  ```
  [5d] API Design      ✅ done
       Output: .kickstart/artifacts/API.md — {N} endpoints, {API style}
  ```

**[5e] Architecture — Architecture decisions**
- **Gate:** `.kickstart/artifacts/API.md` MUST exist before starting this step. If missing, go back to 5d.
- Validate: `.kickstart/artifacts/ARCHITECTURE.md` exists with `## Stack Decision` table
- Update `state.md`: Design: Architecture → `done`
- Display:
  ```
  [5e] Architecture    ✅ done
       Output: .kickstart/artifacts/ARCHITECTURE.md — Stack: {summary}
  ```

### Phase 6: Handoff

Display progress banner with `[6] Handoff ▶ current` and sub-steps all `○ pending`.

Read workflow: `workflows/handoff.md`

The handoff has 4 sub-steps, each independently tracked:

**[6a] Bootstrap — Personalize .claude/**
- Validate: CLAUDE.md updated with project-specific content
- Update `state.md`: Bootstrap → `done`
- Display:
  ```
  [6a] Bootstrap      ✅ done
       Output: CLAUDE.md + .claude/ personalized
       Agents: {N} configured | Commands: {N} adapted
  ```

**[6b] Scaffold — Create project files**
- Validate: `package.json` (or equivalent) exists
- Update `state.md`: Scaffold → `done`
- Display:
  ```
  [6b] Scaffold       ✅ done
       Output: {stack} project scaffolded
       Deps: {N} packages installed | Build: {pass/fail}
  ```

**[6c] Observability — Configure deploy monitoring**
- Validate: `.learnings/observability.md` exists
- Update `state.md`: Observability → `done`
- Display:
  ```
  [6c] Observability  ✅ done
       Output: .learnings/observability.md
       Platform: {detected} | Sources: {N} enabled
  ```

**[6d] PRD Init — Initialize lifecycle tracking**
- Validate: `.prd/PRD-STATE.md` exists
- Update `state.md`: PRD Init → `done`
- Display:
  ```
  [6d] PRD Init       ✅ done
       Output: .prd/ initialized
       Roadmap: Phase 01 ready
  ```

### Final Summary

After all phases complete, display:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 KICKSTART ► COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 [1]  Intake          ✅ done    .kickstart/context.md
 [1b] Compose        ✅ done    .kickstart/manifest.md ({N} sub-projects)
 [2]  Research        {✅|⊘}    .kickstart/research.md
 [3]  Monetize        {✅|⊘}    .monetize/
 [4]  Brand           {✅|⊘}    .kickstart/brand.md
 [5]  Design          ✅ done    .kickstart/artifacts/
 [6a] Bootstrap       ✅ done    CLAUDE.md + .claude/
 [6b] Scaffold        ✅ done    {stack} project
 [6c] Observability   ✅ done    .learnings/observability.md
 [6d] PRD Init        ✅ done    .prd/

 Project: {name}
 Sub-Projects: {N} | Stack: {stack summary}
 Entities: {N} | Features: {N} | Integrations: {N}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 ▶ Auto-advancing to feature lifecycle...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Update `state.md` with all phases as `done`/`skipped` and `last_phase: complete`.

### Auto-Chain: Kickstart → Feature Lifecycle

**CRITICAL:** After displaying the final summary, automatically invoke the feature lifecycle.
Do NOT stop and wait for the user. The whole point of `/kickstart` is to go from idea to
implementation — stopping after scaffold defeats the purpose.

**Auto-chain sequence:**

1. Read `.kickstart/manifest.md` to get the list of sub-projects and build order.
   Copy the manifest to `.prd/PROJECT-MANIFEST.md`.

2. **Multi-sub-project mode:** For each sub-project in build order, create a feature entry.
   Extract the feature brief from the per-sub-project PRD (`.kickstart/artifacts/sp-{NN}-{name}/PRD.md`).
   If per-sub-project PRDs don't exist (single sub-project), fall back to `.kickstart/artifacts/PRD.md`.

3. Invoke `/cks:new` for the **first sub-project** in build order:
   ```
   Skill(skill="cks:new", args="{first sub-project brief}")
   ```

4. **VALIDATION GATE — MANDATORY:** After `/cks:new` returns, IMMEDIATELY verify:
   - `.prd/phases/{NN}-{name}/` directory exists
   - `PRD-STATE.md` has `active_phase` set to a phase number

   If EITHER check fails:
   ```
   Auto-chain validation failed:
     Expected: .prd/phases/{NN}-{name}/ to exist
     Found: {what actually exists}
     Action: Retrying /cks:new...
   ```
   Retry `/cks:new` once. If it fails again, stop and tell the user:
   "Run `/cks:new` manually to create your first feature."
   Do NOT proceed to step 5.

5. Update PRD-ROADMAP.md with ALL sub-projects from the manifest (not just the first):
   ```markdown
   | Phase | Sub-Project | Status | Depends On |
   |-------|-------------|--------|------------|
   | 01 | {first SP name} | Discovering | — |
   | 02 | {second SP name} | Pending | Phase 01 |
   | ... | ... | ... | ... |
   ```
   Only the first sub-project enters the lifecycle immediately. Others are queued.

6. Only after validation passes, invoke `/cks:next`:
   ```
   Skill(skill="cks:next")
   ```

7. `/cks:next` detects the state and invokes `/cks:discover` automatically.

8. Each subsequent phase ends with a **Context Reset** banner telling the user to
   run `/clear` then `/cks:next` to continue. This is intentional — it keeps context
   windows manageable across long lifecycles.

**The chain is:** kickstart → manifest copy → new (first SP, validated) → roadmap (all SPs) → next → discover → (context reset) → next → design → ...

## Phase Validation

Before starting any phase, verify its prerequisites:

| Phase | Requires |
|-------|----------|
| Intake | Nothing (entry point) |
| Compose | `.kickstart/context.md` (reads intake output to suggest sub-projects) |
| Research | `.kickstart/context.md` + `PERPLEXITY_API_KEY` (or deep-research sources) |
| Monetize | `.kickstart/context.md` (Perplexity optional — falls back to WebSearch) |
| Brand | `.kickstart/context.md` (uses Canva MCP, WebFetch, or manual Q&A) |
| Design | `.kickstart/context.md` + `.kickstart/manifest.md` (research/monetize/brand optional but consumed if present) |
| Handoff | `.kickstart/manifest.md` + design artifacts per sub-project (PRD, ERD, schema, API, Architecture) |

## Educational Mode

During Q&A, when the user mentions or the conversation touches on AI/tech concepts,
briefly explain the relevant term using the glossary in `references/ai-glossary.md`.

Format inline explanations as:
```
> **{Term}** — {one-line definition from glossary}
```

Don't force explanations. Only surface them when:
- User uses a term that might benefit from context
- A question naturally relates to a glossary concept
- The design artifacts involve a concept worth explaining (e.g., RAG, embeddings, vector DB)

## Environment Variables

The skill checks `.env.local` for API keys needed by optional phases:

```bash
# Load from .env.local
export $(grep -v '^#' .env.local 2>/dev/null | xargs) 2>/dev/null
```

| Variable | Required By | Phase | Fallback |
|----------|-------------|-------|----------|
| `PERPLEXITY_API_KEY` | Research (standard), Monetize | 2, 3 | WebSearch (Claude built-in) |

If the key is missing, research and monetize phases **automatically fall back to WebSearch**.
No need to halt or prompt — just note the source in the output.

For richer results with citations, the user can add to `.env.local`:
```
PERPLEXITY_API_KEY=your-key-here
```

## Output Artifacts

| File | Purpose |
|------|---------|
| `.kickstart/state.md` | Progress tracker — resume point on interruption |
| `.kickstart/context.md` | Full idea context from intake Q&A |
| `.kickstart/manifest.md` | Project composition — sub-projects, dependencies, build order |
| `.kickstart/research.md` | Market research with citations (if opted in) |
| `.kickstart/brand.md` | Brand guidelines — colors, typography, voice, UI prefs (if opted in) |
| `.kickstart/artifacts/shared/` | Shared design artifacts (auth, shared schema, contracts) — multi-SP only |
| `.kickstart/artifacts/sp-{NN}-{name}/` | Per-sub-project design artifacts (ERD, schema, PRD, API, architecture) — multi-SP only |
| `.kickstart/artifacts/PRD.md` | First-draft Product Requirements Document (single-SP fallback) |
| `.kickstart/artifacts/ERD.md` | Entity Relationship Diagram (single-SP fallback) |
| `.kickstart/artifacts/schema.sql` | Database schema DDL (single-SP fallback) |
| `.kickstart/artifacts/API.md` | API endpoint contracts (single-SP fallback) |
| `.kickstart/artifacts/ARCHITECTURE.md` | Architecture decisions (single-SP fallback) |
| `.monetize/*` | Monetization artifacts (if opted in) |
| `.brand/guidelines.md` | Persisted brand guidelines for CKS design phase (copied from .kickstart/brand.md) |
| `.learnings/observability.md` | Deploy monitoring config (auto-detected from stack) |
| `.prd/PROJECT-MANIFEST.md` | Manifest copy for feature lifecycle (created during handoff) |

## Error Handling

| Failure | Behavior |
|---------|----------|
| `PERPLEXITY_API_KEY` missing | Skip research/monetize, inform user how to add it, continue to design |
| Perplexity rate limit | Retry once, then save partial results and continue |
| User abandons mid-intake | Save partial context + state.md, next run offers to resume |
| `/bootstrap` not available | Generate artifacts only, print manual bootstrap instructions |
| Phase validation fails | Retry once, then ask user what to do |
| Scaffold build fails | Report error, save what was created, continue to next sub-step |

## Reference Files

| File | When to Read |
|------|-------------|
| `references/ai-glossary.md` | During intake Q&A — surface relevant definitions |

## Rules

1. **Always show the progress banner** before starting each phase
2. **Always validate output** before marking a phase as done
3. **Always update state.md** after every phase transition
4. **Never skip validation** — if an artifact is missing, the phase is not done
5. **Show completion details** — not just "done" but what was produced (counts, summaries)
6. **Respect user choices** — if they skip research/monetize, mark as skipped, not pending
7. **Resume gracefully** — on re-run, show full progress and offer to continue
