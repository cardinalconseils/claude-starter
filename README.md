# CKS — Claude Code Starter Kit

> **Version 3.2.20** | Built 2026-03-27 | `5f0a919`

A Claude Code plugin providing a 5-phase feature lifecycle — from idea to production. Discover, design, sprint, review, and release with structured workflows, AI agents, and quality gates.

---

## Install

```bash
claude /plugin add cardinalconseils/claude-starter
```

After install, all commands are available with the `/cks:` prefix.

CKS detects your project automatically on first session:

```
🆕 CKS — First time in this project
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  /cks:adopt       → Mid-development? Adopt CKS into your current work
  /cks:bootstrap   → Fresh start with CKS lifecycle for this project
  /cks:kickstart   → Got an idea? Go from idea to scaffolded project
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Getting Started

### New Project (From Scratch)

```
/cks:kickstart   → idea → research → monetize → brand → design (ERD, schema.sql, PRD, API, architecture) → scaffold
/cks:bootstrap   → scaffold → .claude/ → CLAUDE.md → .prd/ → .context/
/cks:new         → start first feature → enters Phase 1
```

### Existing Codebase (Mid-Development)

```
/cks:adopt       → scan codebase → generate CLAUDE.md → detect secrets → create feature at sprint phase
/cks:sprint      → pick up where you are → plan → build → review → QA → merge
```

`/cks:adopt` is for when you already have code and want CKS to help you ship what you're working on. It skips discovery and design, scans your git history and .env files, and drops you straight into sprint.

---

## Commands at a Glance

### Project Setup

```
/cks:kickstart   → idea → research → monetize → brand → design (ERD, schema.sql, PRD, API, architecture) → scaffold
/cks:bootstrap   → scaffold → .claude/ → CLAUDE.md → .prd/ → .context/
/cks:adopt       → existing codebase → CLAUDE.md → .prd/ → feature at sprint phase
```

### 5-Phase Feature Lifecycle

Each feature goes through 5 phases. Start with `/cks:new`, advance with `/cks:next`:

```
/cks:new "feature"  → creates feature entry → enters Phase 1

Phase 1: /cks:discover   → Discovery (10 Elements)
Phase 2: /cks:design     → Design (Stitch SDK screens + component specs)
Phase 3: /cks:sprint     → Sprint Execution (plan → build → review → QA → UAT → merge)
Phase 4: /cks:review     → Review & Retro (feedback → iteration decision)
Phase 5: /cks:release    → Release Management (Dev → Staging → RC → Production)
```

| Command | Phase | What It Does |
|---------|-------|-------------|
| `/cks:discover [phase]` | 1 | Gather 10 Elements: problem, stories, scope, API surface, criteria, constraints, test plan, UAT, DoD, KPIs |
| `/cks:design [phase]` | 2 | UX flows, API contract, screen generation (Stitch SDK), component specs, design review |
| `/cks:sprint [phase]` | 3 | Sprint planning, TDD, implementation, code review, QA validation, UAT, merge |
| `/cks:review [phase]` | 4 | Sprint review, retrospective, backlog refinement, iteration decision |
| `/cks:release [phase\|all]` | 5 | Environment promotion with quality gates: Dev → Staging → RC → Production |

**Phase 4 Iteration Loop:**
```
/cks:review → feedback →
  ├── "UX issues"     → back to Phase 2 (Design)
  ├── "Logic bugs"    → back to Phase 3 (Sprint)
  ├── "Scope changed" → back to Phase 1 (Discovery)
  └── "Ready"         → Phase 5 (Release)
```

### Quick Actions — Daily Development

```
/cks:go              build → commit → push → PR    (the daily driver)
/cks:go commit       stage + smart commit message
/cks:go pr           commit + push + open PR
/cks:go dev          auto-detect and start dev server
/cks:go build        auto-detect and run build
```

### Automation

| Command | What It Does |
|---------|-------------|
| `/cks:next` | Auto-advance to the next phase (respects iteration loop) |
| `/cks:autonomous` | Run all 5 phases without stopping |
| `/cks:progress` | Show 5-phase dashboard + suggest next action |

### Standalone Tools

| Command | What It Does |
|---------|-------------|
| `/cks:fix [error]` | Auto-detect and fix build errors |
| `/cks:tdd "feature"` | Standalone TDD workflow (RED/GREEN/REFACTOR) |
| `/cks:security` | Security audit — OWASP Top 10, secrets, deps, config |
| `/cks:optimize` | Token/cost optimization audit |
| `/cks:docs [type]` | Generate/refresh documentation (API, architecture, components, onboarding) |
| `/cks:context "topic"` | Research a library/API → `.context/` |
| `/cks:research "topic"` | Deep multi-hop strategic research |
| `/cks:doctor` | Project health diagnostic |
| `/cks:changelog` | Auto-generate CHANGELOG.md from git history |
| `/cks:retro [--auto]` | Retrospective — extract learnings, propose conventions |
| `/cks:status` | Project status dashboard |

### Modules

| Command | What It Does |
|---------|-------------|
| `/cks:monetize` | Business model evaluation — scores 12 revenue models |
| `/cks:deploy` | Deploy to Railway |
| `/cks:test` | Run test suite |
| `/cks:browse` | Browser automation |
| `/cks:seo-audit` | Full SEO audit |
| `/cks:decide` | Stop asking — diagnose and act |
| `/cks:virginize` | Strip project-specific content for starter repo |

---

## Hooks — Automatic Behaviors

No commands to run — these fire on their own:

| Event | What Happens |
|-------|-------------|
| **Session Start** | Shows current phase + status + next action (if `.prd/` exists) |
| **Pre-Commit Guard** | Blocks commits containing secrets, debug code, .env files, or large files |
| **Post-Edit Guard** | Warns about console.log and TODO markers after file edits |
| **Session Learnings** | Captures session context to `.learnings/` on stop |
| **Stop** | Reminds about uncommitted changes |

---

## The Escalation Ladder

Pick the level of ceremony that matches the moment:

```
/cks:go commit       → save my work                                          (5 sec)
/cks:go              → build + commit + push + PR                              (15 sec)
/cks:release         → quality gates + env promotion + deploy + monitoring      (full ceremony)
```

---

## What's Inside

```
cks/
├── .claude-plugin/        ← Plugin manifest (version tracked here)
├── commands/              ← Slash commands (one .md per command)
├── agents/                ← Sub-agent definitions (17 agents)
│   ├── prd-discoverer     ← Phase 1: Discovery (10 Elements)
│   ├── prd-designer       ← Phase 2: Design (Stitch SDK)
│   ├── prd-planner        ← Phase 3: Sprint Planning + TDD
│   ├── prd-executor       ← Phase 3: Implementation (team lead + workers)
│   ├── prd-verifier       ← Phase 3: QA Validation
│   ├── reviewer           ← Phase 3: Code Review
│   ├── deployer           ← Phase 5: Release Management
│   ├── security-auditor   ← Phase 3/5: Security Scanning
│   ├── db-migration       ← Phase 3/5: Schema Management
│   ├── doc-generator      ← Phase 3/5: Documentation Generation
│   └── ...                ← orchestrator, researcher, refactorer, retro
├── skills/                ← Skills with workflows & references
│   ├── prd/               ← 5-phase lifecycle (discover → release)
│   │   └── workflows/
│   │       ├── discover-phase.md      ← Orchestrator (chunked)
│   │       ├── discover-phase/        ← Sub-steps (10 files, <100 lines each)
│   │       ├── sprint-phase.md        ← Sprint execution
│   │       ├── secrets/               ← Secrets lifecycle hooks
│   │       │   ├── hook-discover.md   ← Identify secrets from tech stack
│   │       │   ├── hook-plan.md       ← Inject pre-conditions
│   │       │   └── hook-sprint.md     ← Blocking retrieval tasks
│   │       └── ...
│   ├── api-docs/          ← API documentation generator
│   ├── language-rules/    ← Stack-specific coding rules
│   ├── kickstart/         ← Idea → scaffolded project
│   ├── context-research/  ← Technology research briefs
│   ├── deep-research/     ← Multi-hop recursive research
│   ├── retrospective/     ← Post-ship learning + conventions
│   ├── cicd-starter/      ← Bootstrap + deploy + virginize
│   ├── monetize/          ← Business model evaluation
│   ├── aeo-geo/           ← Answer Engine Optimization
│   └── seo-local/         ← Local SEO
├── hooks/                 ← 4 hooks (session, commit guard, edit guard, learnings)
└── scripts/               ← Version bump, init, SEO audit
```

### Chunked Workflow Architecture

Workflows use a **thin orchestrator + sub-step files** pattern to keep each file under 100 lines:

```
discover-phase.md (61 lines)     ← Orchestrator: reads sub-steps sequentially
  discover-phase/
    _shared.md                   ← Banner template, shared variables
    step-0-progress.md           ← Display lifecycle progress
    step-1-target.md             ← Determine target phase
    step-4-elements.md           ← Dispatch discoverer agent
    step-4b-secrets.md           ← Identify required secrets
    step-5-validate.md           ← Validate output
    ...
```

### Secrets Lifecycle

Secrets are tracked across the entire feature lifecycle:

| Phase | What Happens |
|-------|-------------|
| Discovery | Tech stack analyzed → required secrets identified → `{NN}-SECRETS.md` created |
| Planning | Unresolved secrets injected as pre-conditions in PLAN.md |
| Sprint | Blocking tasks prompt user to retrieve each secret before coding |
| Release | Deferred secrets block production deployment |

---

## Configuration

### Research Sources (optional)

Create `.context/config.md` to customize how `/cks:context` researches topics:

```yaml
sources: [context7, firecrawl, websearch, webfetch]  # priority order
auto-research: true   # auto-research during /cks:discuss
max-lines: 200        # max lines per context brief
```

### API Keys (optional)

Add to `.env.local` for enhanced research quality (Perplexity provides richer citations and synthesis).
Without it, `/cks:monetize` and `/cks:research` fall back to WebSearch automatically.
```
PERPLEXITY_API_KEY=your-key-here
```

---

## Adding Components

Just add files to the right directory — no config changes needed:

| To add | Create |
|--------|--------|
| Command | `commands/my-command.md` → `/cks:my-command` |
| Agent | `agents/my-agent.md` |
| Skill | `skills/my-skill/SKILL.md` |
| Hook | Add entry to `hooks/hooks.json` |

Then `git push` and `/reload-plugins` on any machine.

---

## Developing This Plugin

When working on the CKS plugin source code itself, disable the installed version to avoid conflicts:

```bash
# Start dev session (load local files, not installed version)
claude plugin disable cks@cks-marketplace
claude --plugin-dir .

# Test your changes...

# When done, re-enable the installed version
claude plugin enable cks@cks-marketplace
```

After pushing changes, update the installed plugin on any machine:

```bash
git push
claude plugin marketplace update cks-marketplace
claude plugin update cks@cks-marketplace
```

---

## Versioning

Version is tracked in 4 files, all updated automatically by `scripts/bump-version.sh`:

| File | What Gets Updated |
|------|------------------|
| `.claude-plugin/plugin.json` | `"version": "X.Y.Z"` |
| `.claude-plugin/marketplace.json` | `"version": "X.Y.Z"` |
| `README.md` | Version line at top |
| `docs/WORKFLOW.md` | Version line at top |

**Auto-bump on every `/cks:go`:**
```
v3.0.0 tag + 0 commits = 3.0.0
v3.0.0 tag + 5 commits = 3.0.5
```

Patch versions happen automatically. For minor or major releases, tag before pushing:

```bash
git tag v3.1.0 && git push --tags   # New feature set
git tag v4.0.0 && git push --tags   # Breaking changes
```

Check installed version: `claude plugin list`

---

## Design Principles

- **Plugin format** — install once, works in every project on every machine
- **Auto-discovery** — add files, they're immediately available
- **One namespace** — everything is `/cks:{action}`, flat and consistent
- **PRD-aware** — quick actions know where you are in the lifecycle
- **Auto-detect** — project type detected from `package.json` / `pyproject.toml` / `Cargo.toml` / `go.mod`
- **Hints not gates** — lifecycle suggestions after actions, never blocking
- **Full lifecycle** — idea → scaffold → build → test → ship in one toolkit
