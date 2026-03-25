# /kickstart

## What It Does
Takes a raw project idea and transforms it into a fully scaffolded, research-backed project
with design artifacts (PRD, ERD, architecture) and a personalized `.claude/` ecosystem.

This is the **first command you run** on a new project — before `/bootstrap`, before `/cks:new`.

## Usage
```
/kickstart
/kickstart "An AI-powered invoice processing tool for freelancers"
```

Optional argument: your idea pitch in quotes. If omitted, Claude will ask for it.

## Flow

```
Idea Pitch
    ↓
Phase 1: INTAKE — Deep Q&A to understand domain, users, data, integrations
    ↓
Phase 2: RESEARCH (optional) — Perplexity-powered market & competitor research
    ↓
Phase 3: MONETIZE (optional) — Revenue model evaluation via /monetize
    ↓
Phase 4: DESIGN — Generate PRD, ERD, architecture decisions, stack recommendation
    ↓
Phase 5: HANDOFF — Feed everything into /bootstrap to wire up .claude/
```

## Full Product Lifecycle

`/kickstart` is step 1 of the complete idea-to-production pipeline:

```
/kickstart ──→ /bootstrap ──→ /cks:new ──→ /cks:plan ──→ /cks:execute ──→ /cks:verify ──→ /cks:ship
 discover       scaffold       define        plan           build           test            deliver
```

After `/kickstart` completes, follow the chain. Each step builds on artifacts from the previous one.

## Requirements
- **Phase 2 (Research)** requires `PERPLEXITY_API_KEY` in `.env.local`
- **Phase 3 (Monetize)** requires `PERPLEXITY_API_KEY` in `.env.local`
- Phases 2 & 3 are opt-in — Claude asks before running them

## Output
- `.kickstart/context.md` — Full idea context from intake
- `.kickstart/research.md` — Market research (if opted in)
- `.kickstart/artifacts/PRD.md` — First-draft Product Requirements Document
- `.kickstart/artifacts/ERD.md` — Entity Relationship Diagram (Mermaid)
- `.kickstart/artifacts/ARCHITECTURE.md` — Architecture decisions & stack
- `.monetize/*` — Monetization artifacts (if opted in)
- Fully personalized `.claude/` + `CLAUDE.md` via `/bootstrap` handoff

## Educational Mode
During Q&A, Claude explains relevant AI/tech concepts from the glossary when they
come up naturally — turning project setup into a learning experience.

## Idempotent
Safe to re-run. If `.kickstart/` exists, Claude offers to resume, update, or start fresh.
