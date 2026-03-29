# Agents

Sub-agent definitions for specialized tasks. Each `.md` file defines one agent with its role, tools, triggers, and constraints.

## Available Agents

| Agent | Phase | Role |
|-------|-------|------|
| `prd-discoverer.md` | 1 — Discovery | Interactive requirements discovery (11 Elements) |
| `prd-designer.md` | 2 — Design | UX flows, screen generation (Stitch MCP), component specs |
| `prd-planner.md` | 3 — Sprint | Sprint planning + TDD strategy |
| `prd-executor.md` | 3 — Sprint | Implements planned phases |
| `reviewer.md` | 3 — Sprint | Reviews PRs and code changes |
| `prd-verifier.md` | 3 — Sprint | QA validation — checks acceptance criteria |
| `deployer.md` | 5 — Release | Manages Railway deployments + environment promotion |
| `prd-orchestrator.md` | All | Drives the full 5-phase lifecycle autonomously |
| `prd-researcher.md` | Any | Investigates codebase architecture and tech options |
| `prd-refactorer.md` | Any | Refactors code with safety checks and verification |
| `db-migration.md` | 3/5 | Database schema changes — validates migrations, tests rollbacks |
| `doc-generator.md` | 3/5 | Generates API docs, architecture docs, component docs |
| `security-auditor.md` | 3/5 | OWASP Top 10, secrets detection, dependency audit |
| `deep-researcher.md` | Any | Multi-hop recursive research across configurable sources |
| `retrospective.md` | Post-ship | Extracts conventions, metrics, and CLAUDE.md proposals |
| `monetize-discoverer.md` | Monetize — Discovery | Scans codebase, gathers business context interactively |
| `monetize-researcher.md` | Monetize — Research | Market intelligence via Perplexity/WebSearch |
| `cost-researcher.md` | Monetize — Cost Analysis | Researches real-world tech stack pricing |
| `cost-analyzer.md` | Monetize — Cost Analysis | Builds unit economics models from raw pricing |
| `monetize-evaluator.md` | Monetize — Evaluate | Scores 12 models with margin-aware projections |
| `monetize-reporter.md` | Monetize — Report | Combines all artifacts into business case |
| `no-code-specialist.md` | Standalone | No-code automation — builds/debugs/migrates workflows (n8n, Make, Workato, Zapier) |
| `prd-executor-worker.md` | 3 — Sprint | Lightweight implementation worker — executes single task group (dispatched by prd-executor) |
| `aeo-geo-specialist.md` | Standalone | Answer Engine / Generative Engine Optimization |
| `seo-strategist.md` | Standalone | SEO strategy and analysis |

## How Agents Are Used

Agents are dispatched by skills and commands via the `Agent()` tool. For example, `/cks:discuss` dispatches `prd-discoverer`, and `/cks:autonomous` orchestrates multiple agents in sequence.

## Creating New Agents

Add a `.md` file here with:
- **Role** — what the agent does
- **Triggers** — when it activates
- **Tools** — which tools it can use
- **Constraints** — what it must not do
- **Handoff** — what it produces and who receives it
