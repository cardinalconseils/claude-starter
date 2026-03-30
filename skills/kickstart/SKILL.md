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

# Kickstart — Domain Knowledge

This skill is loaded into kickstart agents via the `skills: kickstart` frontmatter field.
It provides domain expertise — not execution instructions. Agents read workflow files
in `workflows/` for step-by-step process via progressive disclosure.

## Overview

Takes a raw project idea through guided discovery, optional market research & monetization
analysis, then generates design artifacts and hands off to `/bootstrap` to wire up the
full `.claude/` ecosystem.

## Phase Map

```
/kickstart → intake → compose → research? → monetize? → brand? → design → handoff → /cks:new → discover
```

Each phase is independently resumable. The command reads `.kickstart/state.md` to determine
where to resume and dispatches the appropriate agent.

| Phase | Agent | Required? | Output |
|-------|-------|-----------|--------|
| 1 — Intake | kickstart-intake | Yes | `.kickstart/context.md` |
| 1b — Compose | kickstart-intake | Yes | `.kickstart/manifest.md` |
| 2 — Research | deep-researcher | Optional | `.kickstart/research.md` |
| 3 — Monetize | monetize-discoverer | Optional | `.monetize/` |
| 4 — Brand | kickstart-brand | Optional | `.kickstart/brand.md` |
| 5 — Design | kickstart-designer | Yes | `.kickstart/artifacts/` |
| 6 — Handoff | kickstart-handoff | Yes | `CLAUDE.md`, `.prd/`, scaffold |

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

## State File Format

For the full state file template and validation rules per phase, read `references/validation-and-state.md`.

## Progress Banners

Display a progress banner at the **start** of every phase showing all phases and their status:

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

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

After each phase completes, display:
```
  [N] {Phase Name}   ✅ done
      Output: {artifact file path(s)}
```

## Multi Sub-Project Rules

Read `.kickstart/manifest.md` to determine mode:
- **Single sub-project:** Artifacts written flat to `.kickstart/artifacts/`
- **Multiple sub-projects:**
  - Shared artifacts → `.kickstart/artifacts/shared/`
  - Per-SP artifacts → `.kickstart/artifacts/sp-{NN}-{name}/`
  - Build order follows dependency graph from manifest

## Phase Prerequisites

| Phase | Requires |
|-------|----------|
| Intake | Nothing (entry point) |
| Compose | `.kickstart/context.md` |
| Research | `.kickstart/context.md` + `PERPLEXITY_API_KEY` (or deep-research sources) |
| Monetize | `.kickstart/context.md` (Perplexity optional — falls back to WebSearch) |
| Brand | `.kickstart/context.md` (uses Canva MCP, WebFetch, or manual Q&A) |
| Design | `.kickstart/context.md` + `.kickstart/manifest.md` (research/monetize/brand optional but consumed if present) |
| Handoff | `.kickstart/manifest.md` + design artifacts per sub-project |

## Output Artifacts

| File | Purpose |
|------|---------|
| `.kickstart/state.md` | Progress tracker — resume point on interruption |
| `.kickstart/context.md` | Full idea context from intake Q&A |
| `.kickstart/manifest.md` | Project composition — sub-projects, dependencies, build order |
| `.kickstart/research.md` | Market research with citations (if opted in) |
| `.kickstart/brand.md` | Brand guidelines — colors, typography, voice, UI prefs (if opted in) |
| `.kickstart/artifacts/` | Design artifacts (ERD, schema, PRD, API, Architecture, Feature Roadmap) |
| `.monetize/*` | Monetization artifacts (if opted in) |
| `.prd/PROJECT-MANIFEST.md` | Manifest copy for feature lifecycle (created during handoff) |

## Environment Variables

| Variable | Required By | Phase | Fallback |
|----------|-------------|-------|----------|
| `PERPLEXITY_API_KEY` | Research (standard), Monetize | 2, 3 | WebSearch (Claude built-in) |

If the key is missing, research and monetize phases **automatically fall back to WebSearch**.

## Error Handling

| Failure | Behavior |
|---------|----------|
| `PERPLEXITY_API_KEY` missing | Fall back to WebSearch, note source in output |
| Perplexity rate limit | Retry once, then save partial results and continue |
| User abandons mid-intake | Save partial context + state.md, next run offers to resume |
| `/bootstrap` not available | Generate artifacts only, print manual bootstrap instructions |
| Phase validation fails | Retry once, then ask user what to do |
| Scaffold build fails | Report error, save what was created, continue to next sub-step |

## Educational Mode

During Q&A, when the user mentions AI/tech concepts, briefly explain using the glossary
in `references/ai-glossary.md`:

```
> **{Term}** — {one-line definition from glossary}
```

Only surface when natural — don't force explanations.

## Reference Files

| File | When to Read |
|------|-------------|
| `workflows/intake.md` | Phase 1 — intake Q&A steps |
| `workflows/compose.md` | Phase 1b — sub-project identification |
| `workflows/brand.md` | Phase 4 — brand extraction steps |
| `workflows/design.md` | Phase 5 — artifact generation steps |
| `workflows/handoff.md` | Phase 6 — scaffolding steps |
| `workflows/auto-chain.md` | After Phase 6 — feature lifecycle handoff |
| `references/validation-and-state.md` | Validation rules + state file format |
| `references/phase-banners.md` | Sub-step validation banners for Phase 5/6 |
| `references/ai-glossary.md` | During intake Q&A — surface relevant definitions |

## Customization

This skill ships with opinionated defaults. Review and adapt to your needs:

- **Optional phases**: Which phases users are offered (research/monetize/brand) — edit gate questions in agents
- **Validation rules**: What each phase must produce — edit `references/validation-and-state.md`
- **Design artifacts**: Which artifacts are generated per sub-project — edit `workflows/design.md`
- **Auto-chain behavior**: What happens after kickstart completes — edit `workflows/auto-chain.md`
- **Educational mode**: AI glossary references during Q&A — edit `references/ai-glossary.md`

## Rules

1. **Always show the progress banner** before starting each phase
2. **Always validate output** before marking a phase as done
3. **Always update state.md** after every phase transition
4. **Never skip validation** — if an artifact is missing, the phase is not done
5. **Show completion details** — not just "done" but what was produced (counts, summaries)
6. **Respect user choices** — if they skip research/monetize, mark as skipped, not pending
7. **Resume gracefully** — on re-run, show full progress and offer to continue
