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
 [4] Design          {✅ done | ▶ current | ○ pending | ⊘ skipped}
 [5] Handoff         {✅ done | ▶ current | ○ pending | ⊘ skipped}
   [5a] Bootstrap    {✅ done | ▶ current | ○ pending | ⊘ skipped}
   [5b] Scaffold     {✅ done | ▶ current | ○ pending | ⊘ skipped}
   [5c] Observability{✅ done | ▶ current | ○ pending | ⊘ skipped}
   [5d] PRD Init     {✅ done | ▶ current | ○ pending | ⊘ skipped}

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
| Design | `.kickstart/artifacts/PRD.md` + `ERD.md` + `ARCHITECTURE.md` + `SCHEMA.sql` + `FEATURE-ROADMAP.md` | All 5 files exist |
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
---

# Kickstart Progress

| # | Phase | Status | Output | Completed |
|---|-------|--------|--------|-----------|
| 1 | Intake | {done/in_progress/pending} | .kickstart/context.md | {date or —} |
| 2 | Research | {done/skipped/pending} | .kickstart/research.md | {date or —} |
| 3 | Monetize | {done/skipped/pending} | .monetize/ | {date or —} |
| 4 | Design | {done/in_progress/pending} | .kickstart/artifacts/ | {date or —} |
| 5a | Bootstrap | {done/in_progress/pending} | CLAUDE.md | {date or —} |
| 5b | Scaffold | {done/in_progress/pending} | package.json | {date or —} |
| 5c | Observability | {done/in_progress/pending} | .learnings/ | {date or —} |
| 5d | PRD Init | {done/in_progress/pending} | .prd/ | {date or —} |
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
      [4] Design        ▶ in progress (interrupted)
      [5] Handoff       ○ pending

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
 [4] Design          — PRD, ERD, Architecture
 [5] Handoff         — Scaffold + personalize .claude/

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

**Pre-check: Validate API key availability before showing options.**

```bash
export $(grep -v '^#' .env.local 2>/dev/null | xargs) 2>/dev/null
echo "${PERPLEXITY_API_KEY:+set}"
```

Build the options list dynamically based on what's available:

- If `PERPLEXITY_API_KEY` is set → show all 3 options
- If `PERPLEXITY_API_KEY` is NOT set → only show "Deep research" (uses WebSearch, no key needed) and "Skip research"

Ask with AskUserQuestion:
```
question: "Want me to research the market for this idea?"
options:
  - "Yes — deep research (multi-hop, multi-source)" → uses /cks:research if available
  - "Yes — standard research (Perplexity API)" → uses workflows/research.md {ONLY IF PERPLEXITY_API_KEY is set}
  - "Skip research" → mark as skipped
```

If user selects standard research but key is missing (race condition), show:
```
PERPLEXITY_API_KEY not found. To enable standard research, add to .env.local:
  PERPLEXITY_API_KEY=your-key-here

Get a key at: https://www.perplexity.ai/settings/api
Falling back to deep research (WebSearch-based)...
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
- Validate ALL expected monetize outputs:
  - `.monetize/context.md` — must exist (business context)
  - `.monetize/evaluation.md` — should exist (model scoring)
  - `docs/monetization-assessment.md` — should exist (final report)
- If `.monetize/context.md` is missing → monetize skill failed silently. Log warning and mark as `failed`:
  ```
  ⚠ Monetize skill completed but .monetize/context.md not found.
    The monetization analysis may not have completed successfully.
    You can re-run later with: /cks:monetize
    Continuing to design phase...
  ```
- If context.md exists but evaluation.md is missing → partial success, still mark as `done` with note
- Update `state.md`: Monetize → `done` (or `failed` if context.md missing)
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

### Phase 3→4 Compaction Point

After research and monetize gates resolve (done or skipped), suggest compaction before design:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Research and monetization phases complete.
Context captured in .kickstart/ files. Consider running
/compact before design to free context for artifact generation.

  /compact
  (then /kickstart will resume from Phase 4)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Phase 4: Design

Display progress banner with `[4] Design ▶ current`.

Read workflow: `workflows/design.md`

**After completion:**
- Validate: all 5 artifact files exist (PRD.md, ERD.md, ARCHITECTURE.md, SCHEMA.sql, FEATURE-ROADMAP.md)
- Update `state.md`: Design → `done`
- Display:
  ```
  [4] Design          ✅ done
      Output:
        .kickstart/artifacts/PRD.md           — {N} user stories, {N} features
        .kickstart/artifacts/ERD.md           — {N} entities, {N} relationships
        .kickstart/artifacts/ARCHITECTURE.md  — Stack: {summary}
        .kickstart/artifacts/SCHEMA.sql       — {N} tables, {N} relationships
  ```

### Phase 5: Handoff

Display progress banner with `[5] Handoff ▶ current` and sub-steps all `○ pending`.

Read workflow: `workflows/handoff.md`

The handoff has 4 sub-steps, each independently tracked:

**[5a] Bootstrap — Personalize .claude/**
- Validate: CLAUDE.md updated with project-specific content
- Update `state.md`: Bootstrap → `done`
- Display:
  ```
  [5a] Bootstrap      ✅ done
       Output: CLAUDE.md + .claude/ personalized
       Agents: {N} configured | Commands: {N} adapted
  ```

**[5b] Scaffold — Create project files**
- Validate: `package.json` (or equivalent) exists
- Update `state.md`: Scaffold → `done`
- Display:
  ```
  [5b] Scaffold       ✅ done
       Output: {stack} project scaffolded
       Deps: {N} packages installed | Build: {pass/fail}
  ```

**[5c] Observability — Configure deploy monitoring**
- Validate: `.learnings/observability.md` exists
- Update `state.md`: Observability → `done`
- Display:
  ```
  [5c] Observability  ✅ done
       Output: .learnings/observability.md
       Platform: {detected} | Sources: {N} enabled
  ```

**[5d] PRD Init — Initialize lifecycle tracking**
- Validate: `.prd/PRD-STATE.md` exists
- Update `state.md`: PRD Init → `done`
- Display:
  ```
  [5d] PRD Init       ✅ done
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
 [4] Design          ✅ done    .kickstart/artifacts/
 [5a] Bootstrap      ✅ done    CLAUDE.md + .claude/
 [5b] Scaffold       ✅ done    {stack} project
 [5c] Observability  ✅ done    .learnings/observability.md
 [5d] PRD Init       ✅ done    .prd/

 Project: {name}
 Stack: {stack summary}
 Entities: {N} | Features: {N} | Integrations: {N}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 What's next:

 /cks:new       → Define your first feature
 /cks:go dev    → Start the dev server
 /cks:autonomous → Full auto: discuss → plan → execute → verify → ship

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Update `state.md` with all phases as `done`/`skipped` and `last_phase: complete`.

## Phase Validation

Before starting any phase, verify its prerequisites:

| Phase | Requires |
|-------|----------|
| Intake | Nothing (entry point) |
| Research | `.kickstart/context.md` + `PERPLEXITY_API_KEY` (or deep-research sources) |
| Monetize | `.kickstart/context.md` + `PERPLEXITY_API_KEY` |
| Design | `.kickstart/context.md` (research/monetize optional but consumed if present) |
| Handoff | `.kickstart/artifacts/PRD.md` + `ERD.md` + `ARCHITECTURE.md` + `SCHEMA.sql` + `FEATURE-ROADMAP.md` |

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

| Variable | Required By | Phase |
|----------|-------------|-------|
| `PERPLEXITY_API_KEY` | Research (standard), Monetize | 2, 3 |

If a key is missing when the user opts into that phase, show:
```
To enable {phase_name}, add to .env.local:
  PERPLEXITY_API_KEY=your-key-here

Get a key at: https://www.perplexity.ai/settings/api

Then re-run: /kickstart (will resume from this phase)
```

## Output Artifacts

| File | Purpose |
|------|---------|
| `.kickstart/state.md` | Progress tracker — resume point on interruption |
| `.kickstart/context.md` | Full idea context from intake Q&A |
| `.kickstart/research.md` | Market research with citations (if opted in) |
| `.kickstart/artifacts/PRD.md` | First-draft Product Requirements Document |
| `.kickstart/artifacts/ERD.md` | Entity Relationship Diagram (Mermaid) |
| `.kickstart/artifacts/ARCHITECTURE.md` | Architecture decisions, stack, integrations |
| `.kickstart/artifacts/SCHEMA.sql` | Database schema (SQL DDL) generated from ERD |
| `.kickstart/artifacts/FEATURE-ROADMAP.md` | Prioritized feature backlog for PRD-ROADMAP.md import |
| `.monetize/*` | Monetization artifacts (if opted in) |
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
