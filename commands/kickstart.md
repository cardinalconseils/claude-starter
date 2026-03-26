# /kickstart

## What It Does
Takes a raw project idea and transforms it into a fully scaffolded, research-backed project
with design artifacts (PRD, ERD, architecture), a **high-level feature roadmap**, and a
personalized `.claude/` ecosystem.

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
Phase 5: FEATURE ROADMAP — Define high-level features and priority order
    ↓
Phase 6: HANDOFF — Feed everything into /bootstrap to wire up .claude/
```

## Phase 5: Feature Roadmap (NEW)

After architecture is defined, `/kickstart` produces a **high-level feature roadmap**:

```
AskUserQuestion — "What are the key features for your MVP?"
    ↓
Claude proposes features based on:
  - PRD requirements
  - Monetization strategy (which features drive revenue?)
  - User stories from intake
  - Technical dependencies (what must be built first?)
    ↓
User reviews, adds, removes, reorders
    ↓
Output: .kickstart/artifacts/FEATURE-ROADMAP.md
```

Example output:
```
Feature Roadmap — MVP

Priority | Feature                    | Monetization Impact | Dependencies
---------|----------------------------|--------------------|--------------
1        | User Auth & Onboarding     | Required for all   | None
2        | Core Invoice Builder       | Primary value      | Auth
3        | Payment Processing         | Revenue driver     | Invoice Builder
4        | PDF Export & Email          | Value add          | Invoice Builder
5        | Dashboard & Analytics      | Retention driver   | All above
```

This roadmap becomes the feature backlog in `.prd/PRD-ROADMAP.md` after `/bootstrap`.
Each feature becomes a `/cks:new` entry that runs through the 5-phase cycle.

## Full Product Lifecycle

`/kickstart` is step 1 of the complete idea-to-production pipeline:

```
/kickstart ──→ /bootstrap ──→ /cks:new ──→ 5-Phase Cycle per feature
 strategy       scaffold       feature      discover → design → sprint → review → release
```

After `/kickstart` completes, follow the chain. Each step builds on artifacts from the previous one.

## Requirements
- **Phase 2 (Research)** requires `PERPLEXITY_API_KEY` in `.env.local`
- **Phase 3 (Monetize)** requires `PERPLEXITY_API_KEY` in `.env.local`
- Phases 2, 3 & 5 are opt-in — Claude asks before running them (via AskUserQuestion)

## Output
- `.kickstart/context.md` — Full idea context from intake
- `.kickstart/research.md` — Market research (if opted in)
- `.kickstart/artifacts/PRD.md` — First-draft Product Requirements Document
- `.kickstart/artifacts/ERD.md` — Entity Relationship Diagram (Mermaid)
- `.kickstart/artifacts/ARCHITECTURE.md` — Architecture decisions & stack
- `.kickstart/artifacts/FEATURE-ROADMAP.md` — Prioritized feature roadmap
- `.monetize/*` — Monetization artifacts (if opted in)
- Fully personalized `.claude/` + `CLAUDE.md` via `/bootstrap` handoff

## AskUserQuestion Requirement

ALL user interactions during kickstart MUST use `AskUserQuestion` with selectable options.
No plain text terminal questions.

## Idempotent
Safe to re-run. If `.kickstart/` exists, Claude offers to resume, update, or start fresh.
