# Skills Reference

Skills are domain expertise loaded by agents at startup. They define what an agent knows and how it behaves. You don't invoke skills directly — agents declare which skills they need in their frontmatter.

## Feature Lifecycle

| Skill | What It Provides |
|-------|-----------------|
| `prd` | 5-phase feature lifecycle — discovery, design, sprint, review, release with living roadmap |
| `rpi` | Research-Plan-Implement sub-cycle methodology with quality gates between stages |
| `incremental-implementation` | Drives development through thin vertical slices, prevents building everything at once |
| `product-maturity` | Quality gates for Prototype, Pilot, Candidate, and Production stages |

## Project Setup

| Skill | What It Provides |
|-------|-----------------|
| `kickstart` | Idea → scaffolded project: research, brand, ERD, schema, API, architecture |
| `cicd-starter` | Bootstrap CI/CD, Railway deploy, virginize for starter repo |
| `guardrails` | Domain guardrail rules for `.claude/rules/` — security, testing, database, docs |
| `language-rules` | Stack-specific coding rules generated at bootstrap time |
| `migrations` | Version-aware state file migration across plugin versions |
| `library-skills` | Installs official AI skills from Python/JS packages into `.claude/skills/` |

## Research

| Skill | What It Provides |
|-------|-----------------|
| `deep-research` | Multi-hop recursive research across Perplexity, Context7, Firecrawl, WebSearch, aHref |
| `context-research` | Quick single-hop library/API research → `.context/` briefs |
| `ideation` | Brainstorming frameworks: SCAMPER, 5 Whys, How Might We, angle variation, stress testing |
| `repo-exploration` | Evaluates external repos for CKS-adoptable concepts and patterns |
| `retrospective` | Self-learning post-ship: conventions, metrics, CLAUDE.md proposals |

## Business

| Skill | What It Provides |
|-------|-----------------|
| `monetize` | Business model evaluation — scores 12 revenue models with margin-aware projections |

## Design

| Skill | What It Provides |
|-------|-----------------|
| `design-system` | DESIGN.md generation — plain-text design system for AI agents (Stitch, v0, Lovable, Cursor) |
| `api-design` | REST API and interface design conventions for production applications |

## Engineering

| Skill | What It Provides |
|-------|-----------------|
| `testing-discipline` | TDD discipline: RED-GREEN-REFACTOR, Prove-It Pattern for bug fixes |
| `database-design` | Schema design, migration discipline, data modeling for production |
| `authentication` | Auth patterns: login, OAuth2, JWT, MFA, role-based access |
| `environment-management` | Dev/staging/production environment separation and secrets management |
| `performance` | Core Web Vitals, bundle size, N+1 queries, caching, Lighthouse audits |
| `monitoring` | Error tracking, logging, health endpoints, alerting for production |
| `api-docs` | Auto-generates API documentation from codebase analysis |
| `accessibility` | WCAG 2.1 AA — forms, navigation, color contrast, screen readers |

## Code Quality

| Skill | What It Provides |
|-------|-----------------|
| `code-simplification` | Simplifies code for clarity while preserving exact behavior |
| `karpathy-guidelines` | Guardrails against LLM coding pitfalls: over-engineering, silent assumptions, scope creep |
| `core-behaviors` | Non-negotiable agent behaviors: surface assumptions, push back on bad patterns, verify with evidence |
| `failure-taxonomy` | Classifies failures and selects recovery recipes |
| `ultrareview` | Deep code review for high-stakes code (auth, payments, RLS) — verified findings only |

## Security

| Skill | What It Provides |
|-------|-----------------|
| `security-hardening` | OWASP Top 10 prevention, secrets hygiene, input handling, CSP, dependency audit |
| `ciso` | Personal CISO expertise — supply chain, RLS, webhook exposure, GitHub Actions hardening |
| `agent-safety` | Cedar policy generation for minimal-privilege AI agent sandboxing |

## Observability

| Skill | What It Provides |
|-------|-----------------|
| `observability` | Live signal triage — logs, Sentry errors, LangSmith traces |
| `debug` | Language-agnostic debugging methodology — code tracing, strategic logging |

## Marketing and Growth

| Skill | What It Provides |
|-------|-----------------|
| `brand-marketing` | Brand voice, identity, domain authority, backlink gap analysis |
| `product-marketing` | ICP definition, positioning, competitive narrative, GTM strategy |
| `online-marketing` | Keyword discovery, content gap, funnel architecture, paid ads briefs |
| `ai-marketing` | AI-native content strategy, AEO/GEO optimization, llms.txt |
| `aeo-geo` | Answer Engine Optimization and Generative Engine Optimization |
| `seo-local` | Local SEO for rank-and-rent sites |

## Collaboration

| Skill | What It Provides |
|-------|-----------------|
| `peers` | Session awareness via claude-peers-mcp — conflict detection, session directives |

## Advanced

| Skill | What It Provides |
|-------|-----------------|
| `agentic-os-builder` | Three-layer architecture: domain taxonomy, memory layer, observability dashboard |
| `no-code` | Build, debug, migrate workflows in n8n, Make.com, Workato, Zapier |
| `openrouter` | OpenRouter AI gateway — model selection, cost optimization, fallback routing |
| `remotion` | Best practices for programmatic video creation in React with Remotion |
| `github-issues` | Auto-file GitHub issues at lifecycle events, gate deploy on open blocking issues |
| `auto-mode` | Claude Code Auto mode permissions — classifier-based safety for hands-off execution |
| `agent-persona` | Project-specific agent persona — role identity, reasoning posture, domain knowledge |
| `shipping-checklist` | Pre-launch readiness checklist for production deployment |
