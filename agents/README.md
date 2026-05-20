# Agents

Sub-agent definitions for specialized tasks. Each `.md` file defines one agent with its role, tools, triggers, and constraints.

## Available Agents

### PRD Lifecycle

| Agent | Phase | Role |
|-------|-------|------|
| `prd-orchestrator.md` | All | Drives the full 5-phase lifecycle autonomously |
| `prd-discoverer.md` | 1 — Discovery | Interactive requirements discovery (11 Elements) |
| `prd-designer.md` | 2 — Design | UX flows, screen generation (Stitch MCP), component specs |
| `prd-planner.md` | 3 — Sprint | Sprint planning + TDD strategy |
| `prd-executor.md` | 3 — Sprint | Implements planned phases |
| `prd-executor-worker.md` | 3 — Sprint | Lightweight worker — executes single task group (dispatched by prd-executor) |
| `reviewer.md` | 3 — Sprint | Reviews PRs and code changes |
| `tdd-runner.md` | 3 — Sprint | RED/GREEN/REFACTOR cycle specialist |
| `attractor-runner.md` | 3 — Sprint | Attractor pipeline runner — drives sprint lifecycle as a DOT graph |
| `prd-verifier.md` | 3 — Sprint | QA validation — checks acceptance criteria |
| `sprint-reviewer.md` | 4 — Review | Sprint review, feedback, iteration routing |
| `deployer.md` | 5 — Release | Manages Railway deployments + environment promotion |
| `prd-researcher.md` | Any | Investigates codebase architecture and tech options |
| `prd-refactorer.md` | Any | Refactors code with safety checks and verification |

### Database

| Agent | Role |
|-------|------|
| `db-investigator.md` | Audits Supabase schema, RLS policies, migrations, and security advisors |
| `db-debugger.md` | Traces Supabase errors, RLS failures, slow queries, and edge function DB issues |
| `db-fixer.md` | Proposes and applies fixes for RLS gaps, schema issues, and advisor warnings |
| `db-erd.md` | Creates Mermaid ERD diagrams from live Supabase schema |
| `db-migration.md` | Schema changes — validates migrations, tests rollbacks |

### Debug & Investigation

| Agent | Role |
|-------|------|
| `debugger.md` | Diagnoses app runtime errors, GitHub issues — traces, reads logs, identifies root causes |
| `debugger-worker.md` | Lightweight parallel fix worker — diagnoses a single GitHub issue and closes it |
| `investigator.md` | Broad issue scan — files each finding to GitHub, returns prioritized debug queue |
| `health-checker.md` | Project health diagnostic — env vars, TODOs, tests, PRD state, git hygiene |
| `assess-runner.md` | CKS assessment pipeline — health, code review, security, debug triage |
| `rules-auditor.md` | Adherence audit — scans codebase against `.claude/rules/` with per-rule grades |

### Bootstrap & Kickstart

| Agent | Phase | Role |
|-------|-------|------|
| `kickstart-orchestrator.md` | 0 | Sequences ideation → intake → research → brand → design → handoff |
| `kickstart-ideator.md` | 0 — Ideation | Idea brainstorming and refinement (SCAMPER, stress-testing) |
| `kickstart-intake.md` | 0 — Kickstart | Project Q&A and context gathering |
| `kickstart-brand.md` | 0 — Kickstart | Brand identity and positioning |
| `kickstart-designer.md` | 0 — Kickstart | Architecture, ERD, schema, API design |
| `kickstart-handoff.md` | 0 — Kickstart | Scaffold project from design artifacts |
| `bootstrap-scanner.md` | Bootstrap | Phase 1 — scans codebase, detects stack, runs guided intake |
| `bootstrap-generator.md` | Bootstrap | Phase 2 — generates CLAUDE.md, `.prd/`, `.claude/rules/`, MCP config |
| `feature-cataloger.md` | Adopt | Feature discovery — proposes feature clusters from routes and git history |

### Marketing & Growth

| Agent | Role |
|-------|------|
| `aeo-geo-specialist.md` | Answer Engine / Generative Engine Optimization |
| `seo-strategist.md` | SEO strategy and local lead generation |
| `ai-marketer.md` | AI-native content, AEO/GEO, llms.txt, AI directory presence |
| `online-marketer.md` | Keyword gap, funnel architecture, content calendar, CRO (Ahrefs + DataForSEO) |
| `brand-marketer.md` | Domain authority, backlink gap, citation building, brand voice (Ahrefs) |
| `product-marketer.md` | ICP, positioning, competitive narrative, GTM strategy (Ahrefs) |

### Monetization

| Agent | Role |
|-------|------|
| `monetize-discoverer.md` | Scans codebase and gathers business context interactively |
| `monetize-researcher.md` | Market intelligence via Perplexity/WebSearch |
| `cost-researcher.md` | Real-world tech stack pricing research |
| `cost-analyzer.md` | Unit economics models from raw pricing data |
| `monetize-evaluator.md` | Scores 12 monetization models with margin-aware projections |
| `monetize-reporter.md` | Combines all artifacts into a business case |

### Observability & Ops

| Agent | Role |
|-------|------|
| `log-reader.md` | Queries logs from Vercel, Railway, Cloudflare, GCP, Docker, local files |
| `sentry-observer.md` | Triages Sentry errors — unresolved issues, stack traces, regressions |
| `langsmith-observer.md` | Analyzes LangSmith traces — latency, token cost, errors in LLM apps |
| `launch-readiness.md` | Pre-launch checklist — blocking issues by maturity stage before deploy |
| `token-optimizer.md` | Token budget audit — context, plugins, MCP servers, compaction strategy |
| `payment-advisor.md` | Idempotent payment flows, Stripe integration, PCI compliance, webhook handling |

### Session & Workflow

| Agent | Role |
|-------|------|
| `session-loader.md` | Session context loader — reads project state, guardrails, git context |
| `session-journalist.md` | End-of-day DEVLOG composer |
| `standup-reader.md` | Morning standup — reads DEVLOG, suggests where to pick up |
| `go-runner.md` | Quick action runner — commit, PR, dev, build, start (PRD-aware) |
| `factory-runner.md` | AFK factory — reads labeled GitHub Issues, runs full CKS pipeline per issue |
| `scheduler.md` | Recurring agent setup — interviews user, selects template, writes state file, registers CronCreate |
| `peer-coordinator.md` | Session awareness — shows all repo sessions, detects conflicts |
| `work-hierarchy-manager.md` | Sole writer for `.prd/work-hierarchy.md` — Feature/Phase/Task nodes |
| `changelog-generator.md` | Auto-generates CHANGELOG.md from git history with commit categorization |
| `migrator.md` | Version-aware project state migration |

### Specialized

| Agent | Role |
|-------|------|
| `deep-researcher.md` | Multi-hop recursive research with configurable sources |
| `doc-generator.md` | Generates API docs, architecture docs, component docs |
| `security-auditor.md` | OWASP Top 10, secrets detection, dependency audit |
| `code-simplifier.md` | Simplifies code for clarity while preserving exact behavior |
| `design-system-generator.md` | Generates DESIGN.md (canonical) + DESIGN.html (rendered view) — design system with rendered components and mini-site nav |
| `remotion-specialist.md` | Remotion video specialist — programmatic video in React |
| `no-code-specialist.md` | No-code automation — n8n, Make.com, Workato, Zapier |
| `agentic-os-builder.md` | Scaffolds Agentic OS — `.agentic-os/`, `memory/`, `dashboard/` |
| `repo-explorer.md` | Clones external repos, evaluates for CKS-compatible concepts |
| `sandbox-agent.md` | Leash sandbox — generates minimal-privilege Cedar policy file |
| `browser.md` | Browser automation — open URLs, fill forms, screenshot, extract data |
| `persona-interviewer.md` | Populates agent-persona skill cards via Q&A |
| `caveman-speaker.md` | Rewrites prose into caveman speak — preserves 100% technical accuracy |
| `ciso.md` | Personal CISO — supply chain, secrets, RLS, webhooks, GitHub Actions hardening |
| `retrospective.md` | Post-ship learning — conventions, metrics, CLAUDE.md proposals |

## How Agents Are Used

Agents are dispatched by commands and other agents via the `Agent()` tool. For example:
- `/cks:new` dispatches `prd-discoverer` for discovery
- `/cks:sprint` dispatches `attractor-runner` to drive the sprint pipeline
- `/cks:factory` dispatches `factory-runner` for AFK issue processing

## Creating New Agents

Add a `.md` file here with YAML frontmatter:

```yaml
---
name: my-agent
subagent_type: cks:my-agent
description: One-line description — used for auto-triggering
tools: [Read, Write, Edit, Bash, Glob, Grep]
model: sonnet
color: blue
skills:
  - my-skill
---
```

Body is the system prompt. Write instructions, not documentation.

## Customization

1. **tools** — Scope what the agent can do. Remove to restrict, add to expand.
2. **model** — Use `sonnet` for mechanical tasks, omit (defaults to opus) for reasoning-heavy work.
3. **description** — Controls when Claude Code auto-selects this agent.
4. **System prompt** (body) — Change behavior, constraints, and output format.
5. **skills** — Add domain expertise the agent needs. Agents don't inherit parent skills.
