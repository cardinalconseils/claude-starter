# Commands

Slash commands available via the CKS plugin. All commands use the `/cks:` prefix.

**101 commands total** — project setup, 5-phase lifecycle, daily development, monetize, research, design system, quality, observability, collaboration, caveman mode, control plane, marketing agency, and standalone tools.

## Project Setup

| Command | Purpose |
|---------|---------|
| `/cks:ideate` | Brainstorm and refine a project idea — standalone or as kickstart Phase 0 |
| `/cks:kickstart` | Project enabler — ideate? → intake → research → monetize → brand → design → scaffold |
| `/cks:bootstrap` | Adapt project files — generate CLAUDE.md, .prd/, .context/, .claude/rules/ |
| `/cks:adopt` | Existing codebase — scan git history, generate CLAUDE.md, create feature at sprint phase, detect secrets |
| `/cks:preflight` | PRE-FLIGHT dependency map — position, risks, done criteria, gotchas, phase order, instrumentation before any build |

## 5-Phase Feature Lifecycle

| Command | Phase | Purpose |
|---------|-------|---------|
| `/cks:new "feature" [--role=R]` | — | Create feature entry → enters Phase 1. `--role=coder\|marketer\|analyst\|devops` loads role-specific skill set |
| `/cks:discover` | 1 | Discovery — gather 11 Elements (problem, stories, scope, API, criteria, constraints, test plan, UAT, DoD, KPIs, cross-project deps) |
| `/cks:design` | 2 | Design — UX flows, API contract, screen generation, component specs |
| `/cks:sprint [--role=R]` | 3 | Sprint — plan → build → review → QA → UAT → merge. `--role` scopes loaded skills |
| `/cks:review` [legacy] | 4 | Review & retro — feedback → iteration decision (max 3 iterations) |
| `/cks:release` [legacy] | 5 | Release — environment promotion (Dev → Staging → RC → Prod) |
| `/cks:rpi` | — | R-P-I sub-cycle status — quality gates, artifacts, next action |
| `/cks:work` | — | Manage Feature → Phase → Task hierarchy — `new \| move \| close \| activate \| list` |
| `/cks:next` | — | Auto-advance to next phase (respects iteration loop + state transitions) |
| `/cks:autonomous [--role=R]` | — | Run all 5 phases without stopping. `--role` scopes loaded skills end-to-end |
| `/cks:factory` | `[--label] [--dry-run] [--limit N]` | AFK software factory — drain GitHub Issue backlog autonomously |
| `/cks:schedule` | `[analytics\|sentiment\|assets\|custom] [--cadence]` | Set up a recurring agent — analytics, sentiment monitoring, or asset generation |
| `/cks:progress` | — | Show 5-phase dashboard + suggest next action |
| `/cks:model` | — | View or change model strategy (opus/sonnet/haiku per agent/tier) |
| `/cks:persona` | `[--scaffold <path>]` | Configure agent persona — role, reasoning style, and domain knowledge |

## Quick Actions — Daily Development

| Command | Purpose |
|---------|---------|
| `/cks:go` [legacy] | Build → commit → push → PR (the daily driver) |
| `/cks:go commit` [legacy] | Stage + smart commit message |
| `/cks:go pr` [legacy] | Commit + push + open PR |
| `/cks:go dev` [legacy] | Auto-detect and start dev server |
| `/cks:go build` [legacy] | Auto-detect and run build |

## Session Management

| Command | Purpose |
|---------|---------|
| `/cks:sprint-run` | Run the CKS sprint lifecycle via the Attractor pipeline engine (Discover → Plan → Implement → Verify → Release) |
| `/cks:sprint-start` [legacy] | Begin a work session — replaced by `/cks:standup` |
| ~~`/cks:sprint-close`~~ | Deleted — replaced by attractor-runner auto-close at Release node |
| `/cks:handoff` | Save session state to `.prd/HANDOFF.md` so the next session resumes without re-discovery |
| `/cks:eod` | End of day — summarize today's work into a dated DEVLOG entry with state and next steps |
| `/cks:standup` | Morning standup — recap DEVLOG + load session context + suggest next action (replaces sprint-start) |

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
| `/cks:pivot` | Strategic pivot — ingest research conversation, extract new direction, update CONTEXT.md + learnings |

## Design

| Command | Purpose |
|---------|---------|
| `/cks:design-system` | Generate a DESIGN.html — interactive HTML design system with rendered swatches, type specimens, and mini-site nav |

## Quality

| Command | Purpose |
|---------|---------|
| `/cks:assess` | Drop into any codebase — health, code review, security audit, and debug triage via Attractor pipeline |
| `/cks:uat` | End-of-feature UAT — reads PREFLIGHT.md AC + CONTEXT.md DoD, browser-automated testing, files GitHub issues for failures |
| `/cks:simplify` | Simplify recent code for clarity — preserves behavior, reduces complexity |
| `/cks:caveman [target] [level]` | Compress prose into caveman speak — `lite\|full\|ultra\|wenyan`. Cut ~65% tokens. Brain still big. Mouth small. |
| `/cks:launch-check` | Pre-launch readiness checklist — adapts quality gates to maturity stage (Prototype/Pilot/Candidate/Production) |

## Collaboration

| Command | Purpose |
|---------|---------|
| `/cks:peers` | Discover and coordinate with other Claude Code sessions via claude-peers-mcp |

## Observability

| Command | Purpose |
|---------|---------|
| `/cks:observe` | Query live observability sources — logs, errors, and LLM traces |
| `/cks:observe --logs` | Pull and filter live logs from the auto-detected platform |
| `/cks:observe --errors` | Triage Sentry error feed — unresolved issues, stack traces, regressions |
| `/cks:observe --traces` | Analyze LangSmith traces — errors, latency outliers, token cost anomalies |

## Standalone Tools

| Command | Purpose |
|---------|---------|
| `/cks:bg [command] [args]` | Launch any CKS command as a background session (Agent View) |
| `/cks:investigate [area]` | Scan for issues → classify → file to GitHub → return debug queue |
| `/cks:investigate --issue N` | Debug and fix a specific GitHub issue, close it when resolved |
| `/cks:fix [error]` | Auto-detect and fix build/compile/runtime errors |
| `/cks:tdd "feature"` | Standalone TDD workflow (RED/GREEN/REFACTOR cycle) |
| `/cks:security` | Security scan — audit app code AND pipeline config (OWASP Top 10, secrets, deps) |
| `/cks:payments [design\|review\|idempotency\|webhooks\|subscriptions\|pci]` | Payment systems — idempotency, webhooks, Stripe, PCI compliance, subscriptions |
| `/cks:sandbox` | Generate Leash Cedar policy — sandbox Claude Code with minimal-privilege file, process, and network rules |
| `/cks:optimize` | Token/cost optimization — configure cost-saving defaults, audit context usage |
| `/cks:architecture [refresh\|adr "title"]` | Generate or refresh ARCHITECTURE.md — topology diagram, component table, ADR index |
| `/cks:docs [type]` | Generate/refresh documentation (API, architecture, components, onboarding) |
| `/cks:doctor` | Project health diagnostic — env vars, TODOs, tests, PRD state, git hygiene |
| `/cks:migrate` | Upgrade project state files to match current CKS plugin version |
| `/cks:changelog` | Auto-generate CHANGELOG.md from git history |
| `/cks:status` | Project status dashboard |
| `/cks:board` [legacy] | Launch Kanban dashboard — board UI decommissioned in Wave 6; board data now in CKS Console |
| `/cks:setup-webhooks` | Onboard GitHub webhook → Kanban automation — register hook, set secret, verify |
| `/cks:browse` | Browser automation |
| `/cks:seo-audit` | Full SEO audit |
| `/cks:decide` | Stop asking — diagnose and act |
| `/cks:refactor` | Refactor with safety checks and verification |
| `/cks:map-codebase` | Analyze codebase structure |
| `/cks:review-rules` | Adherence audit — check codebase against `.claude/rules/`, report per-rule compliance |
| `/cks:logs` | View and query CKS lifecycle logs — filter by feature, phase, severity, date |
| `/cks:version` | Show installed CKS plugin version, project version, and migration status |
| `/cks:help` | Show usage guide |

## Control Plane (v6)

| Command | Purpose |
|---------|---------|
| `/cks:control-plane init` | Scaffold `.cks/control-plane/` with config, personas, and RAID log |
| `/cks:personas` | View and manage control plane team roster (list / --add / --edit) |
| `/cks:heartbeat init <agent-id> [--interval <s>]` | Register heartbeat agent in DB + create schedule |
| `/cks:heartbeat status` | Show all agents: last beat, status, cycles missed |
## Marketing Agency

| Command | Purpose |
|---------|---------|
| `/cks:luv [task]` | Luv Marketing CEO — open-ended marketing or engineering task, full org delegation |
| `/cks:marketing [brief]` | Any marketing task — CMO routes to right specialist automatically |
| `/cks:marketing-build [brief]` | Build a site, page, or app — CEO coordinates CMO (content) + CTO (engineering) |
| `/cks:marketing-analytics [brief]` | Campaign performance, A/B tests, attribution, dashboards, tracking setup |
| `/cks:marketing-dev [brief]` | Technical marketing engineering — tracking, automation, integrations, infra |


## Modules

| Command | Purpose |
|---------|---------|
| `/cks:agentic-os` | Scaffold and manage an Agentic OS — architecture + memory + observability |
| `/cks:deploy` | Deploy to Railway |
| `/cks:test` | Run test suite |
| `/cks:evals [--type=memory\|api\|tool\|regression\|safety] [--tier=smoke\|standard\|comprehensive]` | LLM output quality evals — run smoke/standard/comprehensive eval suites per type |
| `/cks:virginize` | Strip project-specific content for starter repo |

## Maintenance

| Command | Purpose |
|---------|---------|
| `/cks:triage` | Triage open PRs, stale branches, and GitHub issues — ACTION REQUIRED blocks for each |

## Lifecycle Order

```
/cks:kickstart → /cks:bootstrap → /cks:new → /cks:discover → /cks:design → /cks:sprint → /cks:review → /cks:release → /cks:retro
(after plugin update: /cks:migrate to upgrade project state)
```
