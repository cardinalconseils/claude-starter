# Commands

Slash commands available via the CKS plugin. All commands use the `/cks:` prefix.

**47 commands total** — project setup, 5-phase lifecycle, daily development, monetize, research, and standalone tools.

## Project Setup

| Command | Purpose |
|---------|---------|
| `/cks:kickstart` | Project enabler — idea → research → monetize → brand → design → scaffold |
| `/cks:bootstrap` | Adapt project files — generate CLAUDE.md, .prd/, .context/, .claude/rules/ |
| `/cks:adopt` | Existing codebase — scan git history, generate CLAUDE.md, create feature at sprint phase, detect secrets |

## 5-Phase Feature Lifecycle

| Command | Phase | Purpose |
|---------|-------|---------|
| `/cks:new "feature"` | — | Create feature entry → enters Phase 1 |
| `/cks:discover` | 1 | Discovery — gather 11 Elements (problem, stories, scope, API, criteria, constraints, test plan, UAT, DoD, KPIs, cross-project deps) |
| `/cks:design` | 2 | Design — UX flows, API contract, screen generation, component specs |
| `/cks:sprint` | 3 | Sprint — plan → build → review → QA → UAT → merge |
| `/cks:review` | 4 | Review & retro — feedback → iteration decision (max 3 iterations) |
| `/cks:release` | 5 | Release — environment promotion (Dev → Staging → RC → Prod) |
| `/cks:next` | — | Auto-advance to next phase (respects iteration loop + state transitions) |
| `/cks:autonomous` | — | Run all 5 phases without stopping |
| `/cks:progress` | — | Show 5-phase dashboard + suggest next action |

## Quick Actions — Daily Development

| Command | Purpose |
|---------|---------|
| `/cks:go` | Build → commit → push → PR (the daily driver) |
| `/cks:go commit` | Stage + smart commit message |
| `/cks:go pr` | Commit + push + open PR |
| `/cks:go dev` | Auto-detect and start dev server |
| `/cks:go build` | Auto-detect and run build |

## Session Management

| Command | Purpose |
|---------|---------|
| `/cks:sprint-start` | Begin a work session — load full operating context (CLAUDE.md, rules, PRD state, git), validate guardrails |
| `/cks:sprint-close` | End a work session — adherence check, capture learnings, update CLAUDE.md if needed |
| `/cks:eod` | End of day — summarize today's work into a dated DEVLOG entry with state and next steps |
| `/cks:standup` | Morning standup — recap last DEVLOG entry, cross-reference current state, suggest next action |

## Monetize Commands

| Command | Purpose |
|---------|---------|
| `/cks:monetize` | Full evaluation: discover → research → cost analysis → evaluate → report → roadmap |
| `/cks:monetize-discover` | Discovery + context gathering |
| `/cks:monetize-research` | Market research (Perplexity API or WebSearch fallback) |
| `/cks:monetize-cost-analysis` | Cost analysis — research tech stack costs, build unit economics, calculate margins |
| `/cks:monetize-evaluate` | Model scoring + margin-aware projections |
| `/cks:monetize-report` | Generate assessment report |
| `/cks:monetize-roadmap` | Generate roadmap + PRD handoff |

## Research Commands

| Command | Purpose |
|---------|---------|
| `/cks:research` | Deep multi-hop recursive research (topic, competitive, tech eval) |
| `/cks:context` | Quick coding reference lookup → `.context/` |
| `/cks:retro` | Retrospective — analyze what worked, extract learnings |
| `/cks:retro --metrics` | Velocity dashboard |

## Standalone Tools

| Command | Purpose |
|---------|---------|
| `/cks:fix [error]` | Auto-detect and fix build/compile/runtime errors |
| `/cks:tdd "feature"` | Standalone TDD workflow (RED/GREEN/REFACTOR cycle) |
| `/cks:security` | Security scan — audit app code AND pipeline config (OWASP Top 10, secrets, deps) |
| `/cks:optimize` | Token/cost optimization — configure cost-saving defaults, audit context usage |
| `/cks:docs [type]` | Generate/refresh documentation (API, architecture, components, onboarding) |
| `/cks:doctor` | Project health diagnostic — env vars, TODOs, tests, PRD state, git hygiene |
| `/cks:changelog` | Auto-generate CHANGELOG.md from git history |
| `/cks:status` | Project status dashboard |
| `/cks:browse` | Browser automation |
| `/cks:seo-audit` | Full SEO audit |
| `/cks:decide` | Stop asking — diagnose and act |
| `/cks:refactor` | Refactor with safety checks and verification |
| `/cks:map-codebase` | Analyze codebase structure |
| `/cks:review-rules` | Adherence audit — check codebase against `.claude/rules/`, report per-rule compliance |
| `/cks:logs` | View and query CKS lifecycle logs — filter by feature, phase, severity, date |
| `/cks:help` | Show usage guide |

## Modules

| Command | Purpose |
|---------|---------|
| `/cks:deploy` | Deploy to Railway |
| `/cks:test` | Run test suite |
| `/cks:virginize` | Strip project-specific content for starter repo |

## Lifecycle Order

```
/cks:kickstart → /cks:bootstrap → /cks:new → /cks:discover → /cks:design → /cks:sprint → /cks:review → /cks:release → /cks:retro
```
