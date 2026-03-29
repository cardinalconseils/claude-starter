---
name: prd
description: >
  Product Requirement Document creation and feature lifecycle management — 5-phase cycle from
  discovery through design, sprint execution, review, and release management with a living roadmap.
  Use this skill whenever: creating a new feature, starting a new piece of work, building a PRD,
  planning implementation, discussing requirements, updating the project roadmap, checking project
  progress, or when the user says "new feature", "add feature", "I want to build", "let's plan",
  "create a PRD", "what's the roadmap", "what's next", "update progress", "discover this feature",
  or any variation of feature planning and tracking. Also trigger when the user references existing
  PRDs, wants to modify scope, reprioritize work, or asks about project status.
---

# PRD — Product Requirement Document & 5-Phase Feature Lifecycle

This skill manages the full feature lifecycle through 5 phases:
**Discover → Design → Sprint → Review → Release**

With a living roadmap, state tracking, iteration loops, and session persistence.

## The Complete Hierarchy

```
PROJECT LEVEL (one-time):
  /kickstart    → idea → research → monetize → feature roadmap → stack → architecture
  /bootstrap    → scaffold → .claude/ → CLAUDE.md → .prd/ → .context/ → deploy config

FEATURE LEVEL (repeatable):
  /new "feature" → creates feature entry → enters Phase 1

PHASE LEVEL (the 5-phase cycle):
  /discover     → Phase 1: Discovery (11 Elements)
  /design       → Phase 2: Design (Stitch SDK)
  /sprint       → Phase 3: Sprint Execution (plan → build → review → QA → UAT → merge)
  /review       → Phase 4: Review & Retro (+ iteration loop)
  /release      → Phase 5: Release Management (Dev → Staging → RC → Production)
```

## Architecture

```
Commands (entry points)          Workflows (logic)              Agents (specialists)
─────────────────────           ─────────────────              ──────────────────────

Project Level:
/kickstart ───────────→ kickstart skill ───────────→ (intake → research → monetize → roadmap)
/bootstrap ───────────→ cicd-starter skill ────────→ (scaffold → .claude/ → .prd/)

Feature Level:
/cks:new ─────────────→ new-project + discover ────→ prd-discoverer
/cks:autonomous ──────→ autonomous.md ─────────────→ (all agents, 5 phases)

Phase Level:
/cks:discover ────────→ discover-phase.md ─────────→ prd-discoverer (9 elements)
/cks:design ──────────→ design-phase.md ───────────→ prd-designer (Stitch SDK)
/cks:sprint ──────────→ sprint-phase.md ───────────→ prd-planner + prd-executor + prd-verifier
/cks:review ──────────→ review-phase.md ───────────→ (feedback + retro + iteration decision)
/cks:release ─────────→ release-phase.md ──────────→ (env promotion + quality gates)

Routing:
/cks:next ────────────→ next.md ───────────────────→ (auto-chains via Skill())
/cks:progress ────────→ progress.md ───────────────→ (read-only dashboard)
/cks:status ──────────→ (inline) ──────────────────→ (read-only)

Daily Actions (PRD-aware):
/cks:go ──────────────→ go.md ─────────────────────→ build → commit → push → PR
/cks:go commit|pr|dev|build → sub-actions (all read PRD state, hint next step)

Utility (integrated into lifecycle):
/cks:context ─────────→ context-research/SKILL.md ──→ (auto-runs in discover)
/cks:doctor ──────────→ (inline diagnostics) ───────→ (auto-runs pre-release)
/cks:changelog ───────→ (inline git analysis) ──────→ (auto-runs post-release)
/cks:retro ───────────→ retrospective/SKILL.md ─────→ (auto-runs in review phase)

Deprecated (redirect):
/cks:discuss ─────────→ redirects to /cks:discover
/cks:plan ────────────→ redirects to /cks:sprint
/cks:execute ─────────→ redirects to /cks:sprint
/cks:verify ──────────→ redirects to /cks:sprint
/cks:ship ────────────→ redirects to /cks:release

Hooks (automatic):
SessionStart ─────────→ Show PRD status if .prd/ exists
Stop ─────────────────→ Warn about uncommitted changes
```

## Commands

### Phase Commands

| Command | Phase | Description |
|---------|-------|-------------|
| `/cks:discover [phase]` | Phase 1 | Discovery — 11 Elements (problem, stories, scope, API surface, criteria, constraints, test plan, UAT, DoD, KPIs, cross-project deps) |
| `/cks:design [phase]` | Phase 2 | Design — UX research, screen generation (Stitch SDK), component specs |
| `/cks:sprint [phase]` | Phase 3 | Sprint — planning [3a], TDD [3b], implement [3c], code review [3d], QA [3e], UAT [3f], merge [3g] |
| `/cks:review [phase]` | Phase 4 | Review — sprint review [4a], retro [4b], backlog refinement [4c], iteration decision [4d] |
| `/cks:release [phase\|all]` | Phase 5 | Release — Dev [5a], Staging [5b], RC + E2E [5c], Production [5d], Post-deploy [5e] |

### Lifecycle Commands

| Command | Description |
|---------|-------------|
| `/cks:new [brief]` | Create new feature → enter Phase 1 |
| `/cks:next` | Auto-advance to next step (respects iteration loops) |
| `/cks:autonomous [--from N]` | Run all 5 phases without stopping |
| `/cks:progress` | Show 5-phase progress dashboard + suggest next action |
| `/cks:status` | Quick project status overview |

### Utility Commands

| Command | Description |
|---------|-------------|
| `/cks:go [commit\|pr\|dev\|build]` | Daily quick actions (PRD-aware) |
| `/cks:context [topic]` | Research technology → `.context/` (auto-runs in discover) |
| `/cks:doctor` | Health diagnostic (auto-runs pre-release) |
| `/cks:changelog` | Generate CHANGELOG.md (auto-runs post-release) |
| `/cks:retro [--auto]` | Retrospective (auto-runs in review phase) |
| `/cks:research [topic]` | Deep multi-hop research → `.research/` |
| `/cks:logs [flags]` | View and query lifecycle logs — filter by feature, phase, severity, date |

## Agent Team

| Agent | File | Role |
|-------|------|------|
| **prd-orchestrator** | `agents/prd-orchestrator.md` | Drives full lifecycle — dispatches all other agents |
| **prd-discoverer** | `agents/prd-discoverer.md` | Phase 1: Discovery — 11 elements, codebase research, manifest-aware |
| **prd-designer** | `agents/prd-designer.md` | Phase 2: Design — Stitch SDK screens, component specs |
| **prd-planner** | `agents/prd-planner.md` | Phase 3 [3a-3b]: Sprint planning + technical design |
| **prd-executor** | `agents/prd-executor.md` | Phase 3 [3c]: Implementation |
| **prd-verifier** | `agents/prd-verifier.md` | Phase 3 [3e]: QA validation |
| **prd-researcher** | `agents/prd-researcher.md` | Utility: codebase + technology investigation |

## The Iteration Loop

Phase 4 (Review) contains the **iteration decision** [4d] that routes back to the correct phase:

```
Phase 4: Review
  [4d] Iteration Decision
    ├── "UX issues"           → back to Phase 2 (Design)
    ├── "Logic bugs"          → back to Phase 3 (Sprint)
    ├── "Requirements changed" → back to Phase 1 (Discovery)
    └── "Ready to release"    → forward to Phase 5 (Release)
```

`/cks:next` respects this routing — it reads `phase_status` from STATE.md:
- `iterating_design` → invokes `/cks:design`
- `iterating_sprint` → invokes `/cks:sprint`
- `iterating_discover` → invokes `/cks:discover`
- `reviewed` → invokes `/cks:release`

## AskUserQuestion Rule

**CRITICAL:** All user interactions across ALL phases MUST use `AskUserQuestion` with selectable options. No plain text terminal questions. This applies to:
- Discovery Q&A (all 9 elements)
- Design decisions (screen approval, variants, sign-off)
- Sprint scope confirmation
- QA failure routing
- UAT approval
- Review feedback
- Iteration decisions
- Release quality gates

## Progress Tracker

Every phase displays a progress banner with sub-steps:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PRD ► Phase {NN}: {name} ► {PHASE_NAME}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 [1] Discover    {✅ done | ▶ current | ○ pending}
 [2] Design      {✅ done | ▶ current | ○ pending}
 [3] Sprint      {✅ done | ▶ current | ○ pending}
 [4] Review      {✅ done | ▶ current | ○ pending}
 [5] Release     {✅ done | ▶ current | ○ pending}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Derive status from filesystem artifacts:
- Discover done: `{NN}-CONTEXT.md` exists
- Design done: `{NN}-DESIGN.md` exists
- Sprint done: `{NN}-SUMMARY.md` + `{NN}-VERIFICATION.md` exist
- Review done: `{NN}-REVIEW.md` exists
- Release done: `phase_status == "released"` in STATE.md

## Context Reset Between Phases

Each phase ends with:
```
━━━ Context Reset ━━━
Phase artifacts saved. Clear context and continue:
  /clear
  /cks:next
State is on disk — nothing is lost.
━━━━━━━━━━━━━━━━━━━━━
```

All state lives in `.prd/` — nothing is lost on `/clear`.

## State Machine

```
not_started → discovering → discovered → designing → designed →
  sprinting → sprinted → reviewing → reviewed → releasing → released
                ↑            ↑           ↑
                └────────────┴───────────┘
                   iteration loop (from Phase 4)

iterating_design  → designing (back to Phase 2)
iterating_sprint  → sprinting (back to Phase 3)
iterating_discover → discovering (back to Phase 1)
```

## File System

```
.prd/                               # Planning state
├── PRD-PROJECT.md                  # Project context
├── PRD-REQUIREMENTS.md             # Tracked requirements with REQ-IDs
├── PRD-STATE.md                    # Session continuity + progress
├── PRD-ROADMAP.md                  # Feature roadmap + phase status
├── PROJECT-MANIFEST.md             # Project composition — sub-projects, deps, build order (from kickstart)
├── logs/
│   ├── lifecycle.jsonl             # Structured event log (append-only JSONL)
│   ├── .current_session_id         # Session correlation (gitignored)
│   ├── features/                   # Per-feature log extracts (optional)
│   └── metrics.json                # Cached velocity metrics
└── phases/
    ├── 01-feature-name/
    │   ├── 01-CONTEXT.md           # Phase 1: Discovery output (11 elements)
    │   ├── 01-DESIGN.md            # Phase 2: Design summary
    │   ├── design/                 # Phase 2: Design artifacts
    │   │   ├── ux-flows.md
    │   │   ├── screens/
    │   │   └── component-specs.md
    │   ├── 01-PLAN.md              # Phase 3: Sprint plan
    │   ├── 01-TDD.md              # Phase 3: Technical design document
    │   ├── 01-SUMMARY.md           # Phase 3: Implementation summary
    │   ├── 01-VERIFICATION.md      # Phase 3: QA results
    │   ├── 01-REVIEW.md            # Phase 4: Review feedback + retro
    │   └── 01-BACKLOG.md           # Phase 4: Iteration backlog (if any)
    └── 02-feature-name/
        └── ...

.context/                           # Persistent research briefs
docs/prds/                          # Individual PRD documents
docs/ROADMAP.md                     # Public roadmap
CHANGELOG.md                        # Auto-generated
```

## Rules

1. **AskUserQuestion for ALL interactions** — no plain text questions, ever
2. **No interruptions in autonomous mode** — Discoverer/Designer use autonomous mode
3. **Commit after each sprint phase** — Atomic history, recoverable
4. **Max 1 iteration in autonomous** — Prevents infinite loops
5. **State after every step** — STATE.md updated constantly
6. **Filesystem is truth** — re-scan artifacts, don't trust stale state
7. **Agents stay in their lane** — Discoverer discovers, Designer designs, Executor codes
8. **Design before code** — Phase 2 must complete before Phase 3 starts
9. **Quality gates in release** — not skipped even in autonomous mode
