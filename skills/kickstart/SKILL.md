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

## Mode Detection

| Condition | Behavior |
|-----------|----------|
| Argument provided | Use as the idea pitch, skip to Q&A |
| No argument | Ask for the idea pitch first |
| `.kickstart/` exists | Offer: resume, update, or start fresh |

## Re-run Check

Before starting, check if `.kickstart/` exists:
- If yes → read `.kickstart/context.md` for the date. Ask: "Previous kickstart found (dated {date}). **Resume where you left off**, **update with new info**, or **start fresh**?"
  - Resume: check which phase completed last, continue from next
  - Update: re-run intake with pre-filled answers, then re-generate artifacts
  - Fresh: `mkdir -p .kickstart/archive/{date} && mv .kickstart/*.md .kickstart/archive/{date}/`
- If no → fresh run

## Full Flow Execution

When `/kickstart` is invoked:

1. **Re-run check** (above)
2. **Intake** → Read workflow: `workflows/intake.md`
3. **Research gate** → Ask: "Want me to research the market for this idea? (requires PERPLEXITY_API_KEY in .env.local)"
   - If yes → Read workflow: `workflows/research.md`
   - If no → skip, note in context
4. **Monetize gate** → Ask: "Want a monetization strategy? (uses /monetize — also requires PERPLEXITY_API_KEY)"
   - If yes → Invoke `/monetize` skill in Mode C with the idea description from intake
   - If no → skip, note in context
5. **Design** → Read workflow: `workflows/design.md`
6. **Handoff** → Read workflow: `workflows/handoff.md`

## Phase Validation

Before starting any phase, verify its prerequisites:

| Phase | Requires |
|-------|----------|
| Intake | Nothing (entry point) |
| Research | `.kickstart/context.md` + `PERPLEXITY_API_KEY` |
| Monetize | `.kickstart/context.md` + `PERPLEXITY_API_KEY` |
| Design | `.kickstart/context.md` (research/monetize optional but consumed if present) |
| Handoff | `.kickstart/artifacts/PRD.md` + `.kickstart/artifacts/ERD.md` |

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
| `PERPLEXITY_API_KEY` | Research, Monetize | 2, 3 |

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
| `.kickstart/context.md` | Full idea context from intake Q&A |
| `.kickstart/research.md` | Market research with citations (if opted in) |
| `.kickstart/artifacts/PRD.md` | First-draft Product Requirements Document |
| `.kickstart/artifacts/ERD.md` | Entity Relationship Diagram (Mermaid) |
| `.kickstart/artifacts/ARCHITECTURE.md` | Architecture decisions, stack, integrations |
| `.monetize/*` | Monetization artifacts (if opted in) |

## Error Handling

| Failure | Behavior |
|---------|----------|
| `PERPLEXITY_API_KEY` missing | Skip research/monetize, inform user how to add it, continue to design |
| Perplexity rate limit | Retry once, then save partial results and continue |
| User abandons mid-intake | Save partial context, next run offers to resume |
| `/bootstrap` not available | Generate artifacts only, print manual bootstrap instructions |

## Reference Files

| File | When to Read |
|------|-------------|
| `references/ai-glossary.md` | During intake Q&A — surface relevant definitions |
