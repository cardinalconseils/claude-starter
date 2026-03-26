---
name: kickstart
description: >
  Project enabler — takes a raw idea and transforms it into a fully scaffolded project
  with research-backed design artifacts (PRD, ERD, architecture) and a personalized .claude/
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
/kickstart → intake → research? → monetize? → design → handoff → /bootstrap
```

Each phase is independently resumable. If interrupted, the next `/kickstart` detects
existing artifacts and offers to resume.

## Progress Tracker

**CRITICAL:** Every phase displays a progress banner before AND after execution. The user
must always know exactly where they are, what just completed, and what's coming next.

### Progress Banner Format

Display this banner at the **start** of every phase:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 KICKSTART ► {PHASE_NAME}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 [1] Intake          {✅ done | ▶ current | ○ pending | ⊘ skipped}
 [2] Research        {✅ done | ▶ current | ○ pending | ⊘ skipped}
 [3] Monetize        {✅ done | ▶ current | ○ pending | ⊘ skipped}
 [4] Brand           {✅ done | ▶ current | ○ pending | ⊘ skipped}
 [5] Design          {✅ done | ▶ current | ○ pending | ⊘ skipped}
 [6] Handoff         {✅ done | ▶ current | ○ pending | ⊘ skipped}
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
| Research | `.kickstart/research.md` | File exists AND has `## Competitor Landscape` section |
| Monetize | `.monetize/context.md` | File exists |
| Brand | `.kickstart/brand.md` | File exists AND has `## Visual Identity` section |
| Design | `.kickstart/artifacts/PRD.md` + `ERD.md` + `schema.sql` + `ARCHITECTURE.md` | All 4 files exist |
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
research_opted: {true|false|pending}
monetize_opted: {true|false|pending}
brand_opted: {true|false|pending}
---

# Kickstart Progress

| # | Phase | Status | Output | Completed |
|---|-------|--------|--------|-----------|
| 1 | Intake | {done/in_progress/pending} | .kickstart/context.md | {date or —} |
| 2 | Research | {done/skipped/pending} | .kickstart/research.md | {date or —} |
| 3 | Monetize | {done/skipped/pending} | .monetize/ | {date or —} |
| 4 | Brand | {done/skipped/pending} | .kickstart/brand.md | {date or —} |
| 5 | Design | {done/in_progress/pending} | .kickstart/artifacts/ | {date or —} |
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
      [1] Intake       ✅ done
      [2] Research      ✅ done
      [3] Monetize      ⊘ skipped
      [4] Brand         ✅ done
      [5] Design        ▶ in progress (interrupted)
      [6] Handoff       ○ pending

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
 [1] Intake          — Understand your idea (guided Q&A)
 [2] Research        — Market intelligence (optional)
 [3] Monetize        — Revenue strategy (optional)
 [4] Brand           — Brand guidelines (optional)
 [5] Design          — PRD, ERD, schema.sql, Architecture
 [6] Handoff         — Scaffold + personalize .claude/

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

### Phase 2: Research Gate

Display progress banner with `[2] Research ▶ current`.

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

Display progress banner with `[5] Design ▶ current`.

Read workflow: `workflows/design.md`

The design workflow consumes `.kickstart/brand.md` if it exists — pre-filling design tokens
(colors, typography, spacing) instead of making arbitrary choices.

**After completion:**
- Validate: all 4 artifact files exist (PRD.md, ERD.md, schema.sql, ARCHITECTURE.md)
- Update `state.md`: Design → `done`
- Display:
  ```
  [5] Design          ✅ done
      Output:
        .kickstart/artifacts/PRD.md           — {N} user stories, {N} features
        .kickstart/artifacts/ERD.md           — {N} entities, {N} relationships
        .kickstart/artifacts/schema.sql       — {N} tables, {DB dialect}
        .kickstart/artifacts/ARCHITECTURE.md  — Stack: {summary}
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

 [1] Intake          ✅ done    .kickstart/context.md
 [2] Research        {✅|⊘}    .kickstart/research.md
 [3] Monetize        {✅|⊘}    .monetize/
 [4] Brand           {✅|⊘}    .kickstart/brand.md
 [5] Design          ✅ done    .kickstart/artifacts/
 [6a] Bootstrap      ✅ done    CLAUDE.md + .claude/
 [6b] Scaffold       ✅ done    {stack} project
 [6c] Observability  ✅ done    .learnings/observability.md
 [6d] PRD Init       ✅ done    .prd/

 Project: {name}
 Stack: {stack summary}
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

1. After all handoff sub-steps complete → auto-invoke `/cks:new` with the first feature from the PRD:
   ```
   Skill(skill="cks:new", args="{first feature brief from .kickstart/artifacts/PRD.md}")
   ```

2. `/cks:new` creates the feature entry and sets PRD-STATE to `not_started`.
   After `/cks:new` completes → auto-invoke `/cks:next`:
   ```
   Skill(skill="cks:next")
   ```

3. `/cks:next` detects the state and invokes `/cks:discover` automatically.

4. Each subsequent phase ends with a **Context Reset** banner telling the user to
   run `/clear` then `/cks:next` to continue. This is intentional — it keeps context
   windows manageable across long lifecycles.

**The chain is:** kickstart → new → next → discover → (context reset) → next → design → ...

## Phase Validation

Before starting any phase, verify its prerequisites:

| Phase | Requires |
|-------|----------|
| Intake | Nothing (entry point) |
| Research | `.kickstart/context.md` + `PERPLEXITY_API_KEY` (or deep-research sources) |
| Monetize | `.kickstart/context.md` (Perplexity optional — falls back to WebSearch) |
| Brand | `.kickstart/context.md` (uses Canva MCP, WebFetch, or manual Q&A) |
| Design | `.kickstart/context.md` (research/monetize/brand optional but consumed if present) |
| Handoff | `.kickstart/artifacts/PRD.md` + `.kickstart/artifacts/ERD.md` + `.kickstart/artifacts/schema.sql` + `.kickstart/artifacts/ARCHITECTURE.md` |

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
| `.kickstart/research.md` | Market research with citations (if opted in) |
| `.kickstart/brand.md` | Brand guidelines — colors, typography, voice, UI prefs (if opted in) |
| `.kickstart/artifacts/PRD.md` | First-draft Product Requirements Document |
| `.kickstart/artifacts/ERD.md` | Entity Relationship Diagram (Mermaid) |
| `.kickstart/artifacts/schema.sql` | Database schema DDL (target DB dialect) |
| `.kickstart/artifacts/ARCHITECTURE.md` | Architecture decisions, stack, integrations |
| `.monetize/*` | Monetization artifacts (if opted in) |
| `.brand/guidelines.md` | Persisted brand guidelines for CKS design phase (copied from .kickstart/brand.md) |
| `.learnings/observability.md` | Deploy monitoring config (auto-detected from stack) |

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
