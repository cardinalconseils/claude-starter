# Agents Reference

Agents are isolated workers dispatched by commands and skills. Each runs in its own context with a scoped tool list. You don't call agents directly — commands dispatch them automatically.

## 5-Phase Lifecycle Agents

| Agent | Phase | Role |
|-------|-------|------|
| `prd-orchestrator` | All | Drives the full 5-phase lifecycle autonomously |
| `prd-discoverer` | 1 — Discovery | Interactive requirements gathering (11 Elements) |
| `prd-designer` | 2 — Design | UX flows, screen generation (Stitch MCP), component specs |
| `prd-planner` | 3 — Sprint | Sprint planning and TDD strategy |
| `prd-executor` | 3 — Sprint | Implements planned phases — coordinates workers |
| `prd-executor-worker` | 3 — Sprint | Lightweight worker executing a single task group (dispatched by executor) |
| `reviewer` | 3 — Sprint | Reviews PRs and code changes |
| `prd-verifier` | 3 — Sprint | QA validation — checks acceptance criteria |
| `sprint-reviewer` | 4 — Review | Sprint review, feedback capture, and iteration routing |
| `deployer` | 5 — Release | Railway deployments and environment promotion |

## Kickstart Agents

| Agent | Role |
|-------|------|
| `kickstart-orchestrator` | Coordinates the full kickstart flow |
| `kickstart-ideator` | Idea brainstorming and refinement |
| `kickstart-intake` | Project Q&A and context gathering |
| `kickstart-brand` | Brand identity and positioning |
| `kickstart-designer` | Architecture, ERD, schema, API design |
| `kickstart-handoff` | Scaffolds project from design artifacts |

## Research and Analysis

| Agent | Role |
|-------|------|
| `prd-researcher` | Investigates codebase architecture and tech options |
| `deep-researcher` | Multi-hop recursive research across configurable sources |
| `repo-explorer` | Investigates external repositories for adoptable patterns |
| `standup-reader` | Reads DEVLOG and surfaces what's next |
| `session-loader` | Loads full operating context at session start |

## Monetize Agents

| Agent | Role |
|-------|------|
| `monetize-discoverer` | Scans codebase and gathers business context |
| `monetize-researcher` | Market intelligence via Perplexity or WebSearch |
| `cost-researcher` | Researches real-world tech stack pricing |
| `cost-analyzer` | Builds unit economics models from raw pricing data |
| `monetize-evaluator` | Scores 12 revenue models with margin-aware projections |
| `monetize-reporter` | Combines all artifacts into business case |

## Database Agents

| Agent | Role |
|-------|------|
| `db-erd` | Entity-relationship diagram generation |
| `db-migration` | Schema changes — validates migrations, tests rollbacks |
| `db-fixer` | Fixes database errors and inconsistencies |
| `db-investigator` | Diagnoses database issues |
| `db-debugger` | Debugging database query and connection problems |

## Observability Agents

| Agent | Role |
|-------|------|
| `log-reader` | Pulls and filters live logs from the auto-detected platform |
| `sentry-observer` | Triages Sentry error feed — unresolved issues, stack traces |
| `langsmith-observer` | Analyzes LangSmith traces — errors, latency, token costs |

## Quality and Security Agents

| Agent | Role |
|-------|------|
| `security-auditor` | OWASP Top 10, secrets detection, dependency audit |
| `ciso` | Personal CISO audit — supply chain, RLS, webhook exposure, GitHub Actions |
| `prd-refactorer` | Refactors code with safety checks and verification |
| `code-simplifier` | Simplifies recent code for clarity without changing behavior |
| `tdd-runner` | RED/GREEN/REFACTOR cycle specialist |
| `health-checker` | Project health diagnostic — env vars, TODOs, tests, PRD state |
| `launch-readiness` | Pre-launch readiness checklist |
| `rules-auditor` | Adherence audit against `.claude/rules/` |
| `sandbox-agent` | Generates minimal-privilege Cedar policy |
| `investigator` | Scans for issues, classifies, files to GitHub |

## Marketing and Growth Agents

| Agent | Role |
|-------|------|
| `seo-strategist` | SEO strategy and analysis |
| `aeo-geo-specialist` | Answer Engine / Generative Engine Optimization |
| `brand-marketer` | Brand identity, voice, domain authority |
| `ai-marketer` | AI-native content strategy, AEO/GEO optimization |
| `product-marketer` | ICP definition, positioning, GTM strategy |
| `online-marketer` | Keyword discovery, content gap, funnel architecture |

## Utility and Session Agents

| Agent | Role |
|-------|------|
| `migrator` | Version-aware project state migration |
| `changelog-generator` | Generates CHANGELOG.md from git history |
| `doc-generator` | Generates API docs, architecture docs, component docs |
| `design-system-generator` | Creates DESIGN.md plain-text design system |
| `session-journalist` | End-of-day DEVLOG composer |
| `token-optimizer` | Audits token usage and configures cost-saving defaults |
| `go-runner` | Handles build → commit → push → PR flow |
| `factory-runner` | Drains GitHub Issue backlog autonomously |
| `sprint-runner` | Runs sprint via Attractor pipeline engine |
| `assess-runner` | Full project assessment via Attractor pipeline |
| `bootstrap-generator` | Generates CLAUDE.md and .prd/ scaffolding |
| `bootstrap-scanner` | Scans existing codebase during adopt/bootstrap |
| `peer-coordinator` | Session awareness and conflict detection |
| `persona-interviewer` | Configures agent persona and domain knowledge |
| `no-code-specialist` | Builds and debugs workflows in n8n, Make, Workato, Zapier |
| `agentic-os-builder` | Scaffolds Agentic OS — domain taxonomy, memory layer, dashboard |
| `remotion-specialist` | Programmatic video creation with Remotion |
| `debugger` | Diagnoses errors — read-only, no edits |
| `debugger-worker` | Executes targeted fixes identified by the debugger |
| `browser` | Browser automation |
| `retrospective` | Extracts conventions, metrics, and CLAUDE.md proposals post-ship |
