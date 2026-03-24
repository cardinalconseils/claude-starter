# CKS Development Workflow — Complete Flow Diagram

> This document maps every command, hook, agent, skill, and artifact in the CKS plugin and how they connect.

---

## The Big Picture

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           CKS DEVELOPMENT LIFECYCLE                             │
│                                                                                 │
│  IDEA ──→ SCAFFOLD ──→ DEFINE ──→ BUILD ──→ TEST ──→ SHIP ──→ LEARN            │
│                                                                                 │
│  /kickstart  /bootstrap   /new     /execute  /verify  /ship   /retro            │
│               + scaffold  /discuss            /doctor          + CLAUDE.md       │
│                           /plan               /go              /changelog        │
│                           /context                                               │
│                           /research                                              │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## Phase 0: Session Start (Automatic)

```
┌──────────────────────────────────────────────┐
│  Hook: SessionStart                          │
│  Trigger: Claude Code opens                  │
│                                              │
│  ┌─ .prd/PRD-STATE.md exists?                │
│  │   YES → Display status banner:            │
│  │         Phase, Status, Last, Next, Run    │
│  │   NO  → Stay silent                       │
│  └───────────────────────────────────────────│
└──────────────────────────────────────────────┘
```

**Reads:** `.prd/PRD-STATE.md`
**Produces:** Console output (status banner) or nothing

---

## Phase 1: Kickstart — Idea to Scaffolded Project

```
/cks:kickstart ["idea pitch"]
        │
        ▼
┌───────────────────────┐
│  1. INTAKE             │  Guided Q&A about the idea
│     (workflows/        │  Domain, users, data, integrations
│      intake.md)        │
│                        │  → .kickstart/context.md
└───────┬───────────────┘
        │
        ▼
┌───────────────────────┐
│  2. RESEARCH           │  Market & competitor research
│     (optional)         │  Requires: PERPLEXITY_API_KEY
│     (workflows/        │
│      research.md)      │  → .kickstart/research.md
└───────┬───────────────┘
        │
        ▼
┌───────────────────────┐
│  3. MONETIZE           │  Revenue model scoring
│     (optional)         │  Invokes: Skill(skill="monetize")
│                        │
│                        │  → .monetize/*.md
└───────┬───────────────┘
        │
        ▼
┌───────────────────────┐
│  4. DESIGN             │  Generate artifacts
│     (workflows/        │  Reads: context + research + monetize
│      design.md)        │
│                        │  → .kickstart/artifacts/PRD.md
│                        │  → .kickstart/artifacts/ERD.md
│                        │  → .kickstart/artifacts/ARCHITECTURE.md
└───────┬───────────────┘
        │
        ▼
┌───────────────────────┐
│  5. HANDOFF            │
│     (workflows/        │  a. Invoke /bootstrap → personalize .claude/
│      handoff.md)       │  b. SCAFFOLD project based on ARCHITECTURE.md
│                        │     (npx create-next-app / django-admin / cargo init)
│                        │  c. Install integration deps
│                        │  d. Create .env.local template
│                        │  e. Initialize .prd/ state
│                        │  f. Initial git commit
│                        │
│                        │  → package.json (or pyproject.toml, Cargo.toml, etc.)
│                        │  → .env.local (template with empty keys)
│                        │  → CLAUDE.md (project-specific)
│                        │  → .prd/PRD-STATE.md
│                        │  → .prd/PRD-ROADMAP.md
│                        │  → .prd/PRD-PROJECT.md
└───────────────────────┘
```

**At this point:** Project is real, running, and PRD-initialized. `/cks:go dev` works.

---

## Phase 2: Define — What Are We Building?

### /cks:new (Full Autonomous) or /cks:discuss → /cks:plan (Step by Step)

```
/cks:new "feature brief"
        │
        │  Sets up .prd/ then runs autonomous loop (all phases, no stopping)
        │
        ▼

/cks:discuss [phase]                          /cks:plan [phase]
        │                                             │
        ▼                                             ▼
┌────────────────────────┐                ┌────────────────────────┐
│  Step 2: AUTO-RESEARCH  │                │  Agent: prd-planner     │
│  Extract tech keywords  │                │                         │
│  from feature brief     │                │  Reads:                 │
│                         │                │    CONTEXT.md           │
│  For each technology:   │                │    PRD-PROJECT.md       │
│  Skill(skill="context") │                │    PRD-REQUIREMENTS.md  │
│                         │                │                         │
│  → .context/<slug>.md   │                │  Produces:              │
│    (if not exists)      │                │    .prd/phases/NN-PLAN.md│
│                         │                │    docs/prds/PRD-NNN.md │
│  Configurable via:      │                │    PRD-REQUIREMENTS.md  │
│  .context/config.md     │                │    PRD-ROADMAP.md       │
│    sources: [...]       │                │                         │
│    auto-research: true  │                │  Updates:               │
└────────┬───────────────┘                │    PRD-STATE → planned  │
         │                                 └────────────────────────┘
         ▼
┌────────────────────────┐
│  Step 4: DISCOVER       │
│  Agent: prd-discoverer  │
│                         │
│  Reads:                 │
│    PRD-PROJECT.md       │
│    PRD-REQUIREMENTS.md  │
│    CLAUDE.md            │
│    .context/*.md        │
│                         │
│  Produces:              │
│    .prd/phases/         │
│     NN-CONTEXT.md       │
│                         │
│  Updates:               │
│    PRD-STATE → discussed│
└────────────────────────┘
```

---

## Phase 3: Build — Write the Code

### /cks:execute [phase]

```
/cks:execute [phase]
        │
        ▼
┌─────────────────────────────┐
│  Agent: prd-executor         │
│                              │
│  Reads:                      │
│    .prd/phases/NN-PLAN.md    │
│    .prd/phases/NN-CONTEXT.md │
│    docs/prds/PRD-NNN.md      │
│    CLAUDE.md                 │
│    .context/*.md (matching)  │
│                              │
│  Does:                       │
│    Implements code changes    │
│    Follows project conventions│
│                              │
│  Produces:                   │
│    Source code changes        │
│    .prd/phases/NN-SUMMARY.md │
│                              │
│  Post-execution:             │
│    npm install / pip install  │
│    npm run build (verify)     │
│                              │
│  Updates:                    │
│    PRD-STATE → executed       │
└─────────────────────────────┘
```

### During execution — Daily actions with /cks:go

```
┌──────────────────────────────────────────────────────────────────────┐
│  /cks:go — PRD-Aware Daily Actions                                   │
│                                                                      │
│  Step 0: CONTEXT CHECK (every action)                                │
│  ┌─ .prd/PRD-STATE.md exists?                                        │
│  │   YES → Read phase + status, adapt hints                          │
│  │   NO  → Standalone mode (one-time /cks:new hint)                  │
│  └───────────────────────────────────────────────────────────────────│
│                                                                      │
│  ┌─────────────┐  ┌───────────┐  ┌──────────┐  ┌─────────────────┐  │
│  │ /cks:go dev  │  │ /cks:go   │  │ /cks:go  │  │ /cks:go         │  │
│  │              │  │ commit    │  │ pr       │  │ (no arg)        │  │
│  │ Auto-detect  │  │           │  │          │  │                 │  │
│  │ project type │  │ Stage     │  │ Commit   │  │ Build check     │  │
│  │ Install deps │  │ Smart msg │  │ Branch   │  │ Commit          │  │
│  │ Run dev cmd  │  │ Commit    │  │ Push     │  │ Branch          │  │
│  │              │  │           │  │ gh pr    │  │ Push            │  │
│  │ If planned → │  │ Update    │  │ create   │  │ PR              │  │
│  │ set executing│  │ PRD state │  │          │  │ CLAUDE.md check │  │
│  └──────┬──────┘  └─────┬─────┘  └────┬─────┘  └────────┬────────┘  │
│         │               │              │                  │           │
│         ▼               ▼              ▼                  ▼           │
│  ┌──────────────────────────────────────────────────────────────┐     │
│  │  PRD Hint (one line, after action):                          │     │
│  │  📋 PRD Phase NN (executing) — when ready: /cks:verify       │     │
│  └──────────────────────────────────────────────────────────────┘     │
│                                                                      │
│  PROJECT DETECTION:                                                  │
│  package.json → Node.js (read scripts.dev / scripts.build)           │
│  pyproject.toml → Python | manage.py → Django                        │
│  Cargo.toml → Rust | go.mod → Go | Makefile → Make                  │
└──────────────────────────────────────────────────────────────────────┘
```

---

## Phase 4: Test — Does It Work?

### /cks:verify [phase]

```
/cks:verify [phase]
        │
        ▼
┌────────────────────────────────┐
│  Agent: prd-verifier            │
│                                 │
│  Reads:                         │
│    .prd/phases/NN-PLAN.md       │
│    .prd/phases/NN-SUMMARY.md    │
│    docs/prds/PRD-NNN.md         │
│    verification-patterns.md     │
│                                 │
│  Does:                          │
│    Check each acceptance criterion│
│    Run tests if available        │
│    Verify code quality           │
│                                 │
│  Produces:                      │
│    .prd/phases/                  │
│     NN-VERIFICATION.md          │
│      verdict: PASS or FAIL      │
│                                 │
│  If PASS:                       │
│    PRD-STATE → verified          │
│    PRD-ROADMAP → phase complete  │
│                                 │
│  If FAIL:                       │
│    PRD-STATE → verification_failed│
│    → Re-execute (max 1 retry)    │
└────────────────────────────────┘
```

---

## Phase 5: Ship — Full Ceremony

### /cks:ship [phase|all]

```
/cks:ship [phase|all]
        │
        ▼
┌──── Step 0: DOCTOR ─────────────────────────────────────┐
│  Skill(skill="doctor")                                   │
│  Checks: env vars, TODOs/FIXMEs, tests, PRD state,      │
│          git hygiene, dependencies                        │
│  Score < 50 → warn + ask | 50-79 → warn | ≥ 80 → go     │
│  Skip with: --skip-doctor                                │
└─────────────────────────┬───────────────────────────────┘
                          │
                          ▼
┌──── Step 1: PREFLIGHT ──────────────────────────────────┐
│  Verification status, git state, branch, remote, gh CLI  │
│  Dependency sync (npm install / pip install)              │
└─────────────────────────┬───────────────────────────────┘
                          │
                          ▼
┌──── Step 2: E2E TESTING ────────────────────────────────┐
│  If frontend changes detected:                           │
│    Skill(skill="browse") → browser tests + screenshots   │
│    PASS → continue | FAIL → ask: fix / ship anyway / abort│
│  If no frontend: skip                                    │
└─────────────────────────┬───────────────────────────────┘
                          │
                          ▼
┌──── Step 3-6: COMMIT → BRANCH → PUSH → PR ─────────────┐
│  git add + commit (conventional message, per phase)      │
│  Create feat/ branch if on main                          │
│  git push -u origin                                      │
│  gh pr create (body from SUMMARY + VERIFICATION)         │
└─────────────────────────┬───────────────────────────────┘
                          │
                          ▼
┌──── Step 7: CODE REVIEW ────────────────────────────────┐
│  Try in order:                                           │
│    Skill(skill="pr-review-toolkit:review-pr")            │
│    Skill(skill="code-review:code-review")                │
│    Skill(skill="coderabbit:review")                      │
│  Skip if none available                                  │
└─────────────────────────┬───────────────────────────────┘
                          │
                          ▼
┌──── Step 7b: CHANGELOG ─────────────────────────────────┐
│  Skill(skill="changelog")                                │
│  Reads git log since last tag, categorizes commits        │
│  Writes/updates CHANGELOG.md, commits + pushes           │
└─────────────────────────┬───────────────────────────────┘
                          │
                          ▼
┌──── Step 8: DEPLOY ─────────────────────────────────────┐
│  Skill(skill="deploy") or Skill(skill="vercel:deploy")   │
│  Skip if not configured                                  │
└─────────────────────────┬───────────────────────────────┘
                          │
                          ▼
┌──── Step 9: UPDATE CLAUDE.MD ───────────────────────────┐
│  Scan shipped phases for:                                │
│    New dependencies, env vars, conventions, workflows     │
│  Update relevant CLAUDE.md sections                      │
│  Skill(skill="claude-md-management:revise-claude-md")    │
│  Commit + push                                           │
└─────────────────────────┬───────────────────────────────┘
                          │
                          ▼
┌──── Step 10: UPDATE STATE ──────────────────────────────┐
│  PRD-ROADMAP.md → phases marked "Complete"               │
│  PRD-STATE.md → shipped                                  │
│  PRD document → status "Complete"                        │
└─────────────────────────┬───────────────────────────────┘
                          │
                          ▼
┌──── Step 12: RETROSPECTIVE ─────────────────────────────┐
│  Skill(skill="retro", args="--auto")                     │
│  Analyzes: git history, verification results, commit      │
│            patterns, velocity metrics                     │
│  Extracts: conventions, gotchas, patterns                │
│  Proposes: CLAUDE.md updates, process improvements       │
│  → .learnings/<date>-retro.md                            │
│  Skip silently if not available                          │
└─────────────────────────┬───────────────────────────────┘
                          │
                          ▼
┌──── Step 13: CONTEXT RESET ─────────────────────────────┐
│  "Run /clear then /cks:next"                             │
│  All state is on disk — nothing lost                     │
└─────────────────────────────────────────────────────────┘
```

---

## Automation: /cks:next and /cks:autonomous

### /cks:next — One Step at a Time

```
/cks:next
    │
    ├─ Read .prd/PRD-STATE.md + PRD-ROADMAP.md
    │
    ├─ Decision tree:
    │   ├─ No .prd/           → Skill(skill="new")
    │   ├─ No active phase    → Find next undone, set active
    │   ├─ No CONTEXT.md      → Skill(skill="discuss")
    │   ├─ No PLAN.md         → Skill(skill="plan")
    │   ├─ No SUMMARY.md      → Skill(skill="execute")
    │   ├─ No VERIFICATION.md → Skill(skill="verify")
    │   ├─ Verified + more    → Advance to next phase → Skill(skill="discuss")
    │   ├─ All phases done    → Skill(skill="ship", args="all")
    │   └─ Verification fail  → Skill(skill="execute") (retry)
    │
    └─ Invokes ONE phase → Context Reset → stop
```

### /cks:autonomous — Full Run

```
/cks:autonomous [--from N] [--skip-verify]
    │
    ├─ FOR EACH incomplete phase:
    │   ├─ Auto-research technologies  → .context/*.md
    │   ├─ Agent(prd-discoverer)       → NN-CONTEXT.md
    │   ├─ Agent(prd-planner)          → NN-PLAN.md + PRD
    │   ├─ Agent(prd-executor)         → NN-SUMMARY.md + code
    │   ├─ Agent(prd-verifier)         → NN-VERIFICATION.md
    │   │   └─ FAIL? → retry executor once → re-verify → continue
    │   ├─ git commit (atomic per phase)
    │   └─ Update PRD-STATE + PRD-ROADMAP
    │
    └─ ALL PHASES DONE:
        └─ Skill(skill="ship") → full ship ceremony
```

---

## Utility Commands

### /cks:context — Quick Research

```
/cks:context "Stripe subscriptions"
    │
    ├─ Slugify topic → "stripe-subscriptions"
    ├─ Check .context/stripe-subscriptions.md exists?
    │   YES + no --refresh → show existing
    │   NO or --refresh → research
    │
    ├─ Read .context/config.md for source priority
    │   Default: [context7, firecrawl, websearch, webfetch]
    │
    ├─ Research (in priority order, skip unavailable):
    │   ├─ Context7: resolve-library-id → query-docs
    │   ├─ Firecrawl: scrape official docs
    │   ├─ WebSearch: best practices, gotchas
    │   └─ WebFetch: specific doc URLs
    │
    └─ → .context/stripe-subscriptions.md
         (concepts, API patterns, gotchas, code examples, links)
```

### /cks:research — Deep Intelligence

```
/cks:research "topic"
    │
    ├─ Configure sources (Perplexity, Context7, Firecrawl, etc.)
    ├─ Plan query tree (multi-hop)
    ├─ Execute recursively (follow leads, compare sources)
    ├─ Synthesize with confidence scores + contradiction flags
    │
    └─ → .research/<slug>.md
         (strategic intelligence report)
```

### /cks:doctor — Health Check

```
/cks:doctor
    │
    ├─ Environment vars:  referenced in code vs defined in .env
    ├─ Code markers:      TODO / FIXME / HACK counts
    ├─ Test suite:        detect framework → run → pass/fail
    ├─ PRD state:         stale phases? inconsistencies?
    ├─ Git hygiene:       uncommitted files, stale branches
    ├─ Dependencies:      npm audit / outdated check
    │
    └─ Health Score: 0-100
       Recommendations: specific actions to fix each issue
```

### /cks:status — Unified Dashboard

```
/cks:status
    │
    ├─ Git: branch, clean/dirty, recent commits
    ├─ Build: auto-detect + quick build check
    ├─ PRD: current phase, status, roadmap progress
    ├─ Code: TODO/FIXME/HACK counts
    │
    └─ Console output (dashboard format)
```

---

## Hook: Stop (Automatic)

```
┌──────────────────────────────────────────────┐
│  Hook: Stop                                  │
│  Trigger: Claude finishes responding          │
│                                              │
│  ┌─ git status --porcelain                   │
│  │   Non-empty → "⚠ N file(s) modified.     │
│  │                Consider /cks:go commit"    │
│  │   Clean    → Stay silent                  │
│  └───────────────────────────────────────────│
└──────────────────────────────────────────────┘
```

---

## Artifact Map — What Lives Where

```
PROJECT ROOT
├── CLAUDE.md                          ← Project instructions (auto-updated on ship)
├── CHANGELOG.md                       ← Auto-generated from git history
│
├── .prd/                              ← Lifecycle state
│   ├── PRD-STATE.md                   ← Current phase + status (the cursor)
│   ├── PRD-ROADMAP.md                 ← All phases + completion status
│   ├── PRD-PROJECT.md                 ← Project definition
│   ├── PRD-REQUIREMENTS.md            ← Tracked requirements (REQ-IDs)
│   └── phases/
│       └── NN-feature-name/
│           ├── NN-CONTEXT.md          ← Discovery output       (/cks:discuss)
│           ├── NN-PLAN.md             ← Execution plan          (/cks:plan)
│           ├── NN-SUMMARY.md          ← Implementation summary  (/cks:execute)
│           └── NN-VERIFICATION.md     ← Pass/fail results       (/cks:verify)
│
├── .context/                          ← Research briefs (persist across sessions)
│   ├── config.md                      ← Source priority + preferences
│   └── <topic-slug>.md               ← One file per researched topic
│
├── .research/                         ← Deep research reports
│   └── <topic-slug>.md               ← Strategic intelligence reports
│
├── .learnings/                        ← Retrospective insights
│   └── <date>-retro.md               ← Post-ship learnings
│
├── .kickstart/                        ← Kickstart artifacts
│   ├── context.md                     ← Intake Q&A output
│   ├── research.md                    ← Market research
│   ├── bootstrap-context.md           ← Handoff to /bootstrap
│   └── artifacts/
│       ├── PRD.md                     ← First-draft PRD
│       ├── ERD.md                     ← Entity relationship diagram
│       └── ARCHITECTURE.md            ← Stack + architecture decisions
│
├── .monetize/                         ← Monetization analysis
│   └── *.md                           ← Revenue model evaluations
│
└── docs/
    └── prds/
        └── PRD-NNN-feature.md         ← Published PRD documents
```

---

## Agent Dispatch Map

| Agent | Dispatched By | Reads | Produces |
|-------|--------------|-------|----------|
| **prd-orchestrator** | `/cks:new`, `/cks:autonomous` | Everything | Coordinates all agents |
| **prd-discoverer** | `/cks:discuss` | PROJECT, REQUIREMENTS, CLAUDE.md, .context/ | CONTEXT.md |
| **prd-planner** | `/cks:plan` | CONTEXT.md, PROJECT, REQUIREMENTS | PLAN.md, PRD doc, ROADMAP |
| **prd-executor** | `/cks:execute` | PLAN.md, CONTEXT.md, PRD, CLAUDE.md, .context/ | Code + SUMMARY.md |
| **prd-verifier** | `/cks:verify` | PLAN.md, SUMMARY.md, PRD | VERIFICATION.md |
| **prd-researcher** | Various | Codebase | Technology analysis |
| **prd-refactorer** | `/cks:refactor` | Codebase, CLAUDE.md | Refactored code |
| **deep-researcher** | `/cks:research` | External sources | .research/*.md |
| **retrospective** | `/cks:retro`, `/cks:ship` | Git history, artifacts | .learnings/*.md |

---

## State Machine

```
                    ┌─────────────────────────────────────────┐
                    │                                         │
                    ▼                                         │
not_started → discussing → discussed → planning → planned     │
                                                    │         │
                                                    ▼         │
                                                executing     │
                                                    │         │
                                                    ▼         │
                                                executed      │
                                                    │         │
                                                    ▼         │
                                         ┌──── verifying      │
                                         │         │          │
                                         │         ▼          │
                                    FAIL │    verified        │
                                    (retry)       │           │
                                         │        ▼           │
                                         └── shipping         │
                                                  │           │
                                                  ▼           │
                                              shipped ────────┘
                                                        (next phase)
```

---

## The Escalation Ladder

```
SPEED                              CEREMONY
  ◄────────────────────────────────────►

  /cks:go commit     Just save          5 sec
  /cks:go            Build+commit+PR    15 sec
  /cks:ship          Full ceremony      minutes
                     doctor → E2E → PR → changelog
                     → review → deploy → CLAUDE.md → retro
```
