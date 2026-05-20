# Commands Reference

All commands use the `/cks:` prefix. 90 commands total.

## Project Setup

| Command | Description |
|---------|-------------|
| `/cks:kickstart` | Project enabler — idea → research → monetize → brand → design → scaffold |
| `/cks:bootstrap` | Adapt project files — generate CLAUDE.md, .prd/, .context/, .claude/rules/ |
| `/cks:adopt` | Existing codebase — scan git history, generate CLAUDE.md, create feature at sprint phase |
| `/cks:ideate` | Brainstorm and refine a project idea — standalone or as kickstart Phase 0 |

## 5-Phase Feature Lifecycle

| Command | Phase | Description |
|---------|-------|-------------|
| `/cks:new "feature"` | — | Create feature entry and enter Phase 1. `--role=coder\|marketer\|analyst\|devops` loads role-specific skills |
| `/cks:discover` | 1 | Gather 11 Elements: problem, stories, scope, API, criteria, constraints, test plan, UAT, DoD, KPIs, cross-project deps |
| `/cks:design` | 2 | UX flows, API contract, screen generation, component specs |
| `/cks:sprint` | 3 | Plan → build → review → QA → UAT → merge |
| `/cks:review` | 4 | Sprint review and retro — feedback and iteration decision |
| `/cks:release` | 5 | Environment promotion: Dev → Staging → RC → Production |
| `/cks:next` | — | Auto-advance to the next phase (respects iteration loop) |
| `/cks:autonomous` | — | Run all 5 phases without stopping |
| `/cks:progress` | — | Show 5-phase dashboard and suggest next action |
| `/cks:rpi` | — | R-P-I sub-cycle status — quality gates, artifacts, next action |
| `/cks:factory` | — | AFK software factory — drain GitHub Issue backlog autonomously |
| `/cks:model` | — | View or change model strategy per agent tier |
| `/cks:persona` | — | Configure agent persona — role, reasoning style, domain knowledge |

## Quick Actions — Daily Development

| Command | Description |
|---------|-------------|
| `/cks:go` | Build → commit → push → PR (the daily driver) |
| `/cks:go commit` | Stage and write a smart commit message |
| `/cks:go pr` | Commit + push + open PR |
| `/cks:go dev` | Auto-detect and start the dev server |
| `/cks:go build` | Auto-detect and run the build |

## Session Management

| Command | Description |
|---------|-------------|
| `/cks:sprint-start` | Begin a work session — load CLAUDE.md, rules, PRD state, git context |
| `/cks:sprint-close` | End a work session — adherence check, capture learnings |
| `/cks:handoff` | Write a structured session handoff — branch state, diff summary, open decisions, next steps |
| `/cks:sprint-run` | Run the CKS sprint lifecycle via the Attractor pipeline engine |
| `/cks:eod` | End of day — summarize work into a dated DEVLOG entry |
| `/cks:standup` | Morning standup — recap last DEVLOG, suggest next action |

## Research

| Command | Description |
|---------|-------------|
| `/cks:research` | Deep multi-hop recursive research (topic, competitive, tech eval) |
| `/cks:context` | Quick coding reference lookup → `.context/` |
| `/cks:retro` | Retrospective — analyze what worked, extract learnings |
| `/cks:retro --metrics` | Velocity dashboard |

## Monetize

| Command | Description |
|---------|-------------|
| `/cks:monetize` | Full evaluation: discover → research → cost analysis → evaluate → report → roadmap |
| `/cks:monetize-discover` | Discovery and context gathering |
| `/cks:monetize-research` | Market research (Perplexity API or WebSearch fallback) |
| `/cks:monetize-cost-analysis` | Research tech stack costs and calculate unit economics |
| `/cks:monetize-evaluate` | Score 12 revenue models with margin-aware projections |
| `/cks:monetize-report` | Generate assessment report |
| `/cks:monetize-roadmap` | Generate roadmap and PRD handoff |

## Design

| Command | Description |
|---------|-------------|
| `/cks:design-system` | Generate DESIGN.md — plain-text design system for AI agents (Stitch, v0, Lovable, Cursor) |

## Quality

| Command | Description |
|---------|-------------|
| `/cks:assess` | Drop into any codebase — health, code review, security audit, debug triage |
| `/cks:simplify` | Simplify recent code for clarity — preserves behavior, reduces complexity |
| `/cks:launch-check` | Pre-launch readiness checklist — adapts gates to maturity stage |
| `/cks:fix [error]` | Auto-detect and fix build/compile/runtime errors |
| `/cks:tdd "feature"` | Standalone TDD workflow (RED/GREEN/REFACTOR) |
| `/cks:security` | Security scan — OWASP Top 10, secrets, dependency audit |
| `/cks:ciso` | Personal CISO audit — supply chain, secrets, RLS, webhook, GitHub Actions |
| `/cks:refactor` | Refactor with safety checks and verification |
| `/cks:review-rules` | Adherence audit — check codebase against `.claude/rules/` |
| `/cks:sandbox` | Generate minimal-privilege Cedar policy for the current project |
| `/cks:investigate [area]` | Scan for issues → classify → file to GitHub → return debug queue |
| `/cks:investigate --issue N` | Debug and fix a specific GitHub issue, close when resolved |

## Observability

| Command | Description |
|---------|-------------|
| `/cks:observe` | Query live observability sources — logs, errors, LLM traces |
| `/cks:observe --logs` | Pull and filter live logs from the auto-detected platform |
| `/cks:observe --errors` | Triage Sentry error feed — unresolved issues, stack traces, regressions |
| `/cks:observe --traces` | Analyze LangSmith traces — errors, latency outliers, token cost anomalies |

## Collaboration

| Command | Description |
|---------|-------------|
| `/cks:peers` | Session dashboard — what is every Claude Code session doing? |

## Standalone Tools

| Command | Description |
|---------|-------------|
| `/cks:optimize` | Token/cost optimization — audit plugins, configure cost-saving defaults |
| `/cks:docs [type]` | Generate/refresh documentation (API, architecture, components, onboarding) |
| `/cks:doctor` | Project health diagnostic — env vars, TODOs, tests, PRD state, git hygiene |
| `/cks:migrate` | Upgrade project state files to match current CKS plugin version |
| `/cks:changelog` | Auto-generate CHANGELOG.md from git history |
| `/cks:status` | Project status dashboard |
| `/cks:board` | Kanban dashboard — multi-project command center with live sessions |
| `/cks:map-codebase` | Analyze codebase structure |
| `/cks:logs` | View and query CKS lifecycle logs — filter by feature, phase, severity, date |
| `/cks:version` | Show installed plugin version, project version, and migration status |
| `/cks:evaluate` | Evaluate and score a decision, proposal, or approach |
| `/cks:decide` | Stop asking — diagnose and act |
| `/cks:explore` | Autonomous codebase or repo exploration |
| `/cks:help` | Show usage guide |

## Modules

| Command | Description |
|---------|-------------|
| `/cks:agentic-os` | Scaffold and manage an Agentic OS — architecture, memory, observability |
| `/cks:deploy` | Deploy to Railway |
| `/cks:test` | Run test suite |
| `/cks:browse` | Browser automation |
| `/cks:seo-audit` | Full SEO audit |
| `/cks:virginize` | Strip project-specific content for starter repo |

## Lifecycle Order

```
/cks:kickstart → /cks:bootstrap → /cks:new → /cks:discover → /cks:design
  → /cks:sprint → /cks:review → /cks:release → /cks:retro
```

After a plugin update, run `/cks:migrate` to upgrade project state files.
