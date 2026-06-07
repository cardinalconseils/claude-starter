# Skills

Domain expertise loaded by agents via `skills:` frontmatter. Each subdirectory is a self-contained skill with a `SKILL.md` entry point.

## Available Skills

### PRD Lifecycle

| Skill | Purpose | Key Commands |
|-------|---------|-------------|
| `prd/` | 5-phase feature lifecycle — discover, design, sprint, review, release | `/cks:new`, `/cks:discover`, `/cks:sprint`, etc. |
| `kickstart/` | Project enabler — idea → research → brand → design → scaffold | `/cks:kickstart` |
| `cicd-starter/` | Bootstrap project architecture + Railway deploy | `/cks:bootstrap`, `/cks:virginize` |
| `ideation/` | Brainstorming frameworks — SCAMPER, problem-first, solution-first, stress-testing | `/cks:ideate` |
| `rpi/` | Research-Plan-Implement sub-cycle — quality gates and artifact contracts per phase | Sprint phases |
| `incremental-implementation/` | Thin vertical slices — drives features through incremental steps | Sprint phases |
| `product-maturity/` | Maturity stage gates — Prototype → Pilot → Candidate → Production | Any phase |
| `retrospective/` | Post-ship learning — conventions, metrics, CLAUDE.md proposals | `/cks:retro` |
| `handoff/` | Compact current session into a pickup document for the next session | `/cks:handoff` |
| `shipping-checklist/` | Pre-launch readiness — blocking issues by maturity stage | `/cks:launch-check` |

### Database

| Skill | Purpose | Key Commands |
|-------|---------|-------------|
| `database-design/` | Schema design, migration discipline, RLS, type selection, backup strategy | `/cks:db` |
| `database-recovery/` | Backup and recovery strategy — WAL, point-in-time restore, backup schedules | `/cks:db` |
| `migrations/` | Version-aware state file migration — detects version gaps, applies structural changes | `/cks:migrate` |

### Engineering Discipline

| Skill | Purpose | Key Commands |
|-------|---------|-------------|
| `core-behaviors/` | Non-negotiable agent behaviors — surface assumptions, push back, enforce simplicity | Always active |
| `karpathy-guidelines/` | Behavioral guardrails from Karpathy's LLM coding pitfall observations | Always active |
| `incremental-implementation/` | Thin vertical slices implementation discipline | Sprint phases |
| `failure-taxonomy/` | Classify failures into categories and select recovery recipes | Debug / sprint |
| `testing-discipline/` | TDD discipline — RED-GREEN-REFACTOR, Prove-It Pattern for bug fixes | Sprint / debug |
| `code-simplification/` | Simplify code for clarity while preserving exact behavior | Post-sprint |
| `github-issues/` | Auto-file GitHub issues at lifecycle events; gate deploy on open blocking issues | Any phase |

### Security & Compliance

| Skill | Purpose | Key Commands |
|-------|---------|-------------|
| `security-hardening/` | OWASP Top 10, secrets management, CSP headers, dependency audit | `/cks:security` |
| `authentication/` | Auth patterns — login, OAuth2, JWT, RBAC, MFA, session management | Sprint phases |
| `agent-safety/` | Leash container security — Cedar policy generation, minimal-privilege patterns | `/cks:sandbox` |
| `ciso/` | CISO expertise — supply chain, RLS, secrets hygiene, GitHub Actions hardening | `/cks:ciso` |

### Infrastructure & Operations

| Skill | Purpose | Key Commands |
|-------|---------|-------------|
| `environment-management/` | Env separation, config management, dev/staging/prod setup | Bootstrap / deploy |
| `caching/` | Caching strategy — Redis, write-through/write-behind, CDN, cache invalidation | Sprint phases |
| `monitoring/` | Error tracking, logging, health endpoints, alerting | Sprint phases |
| `observability/` | Live signal queries — logs, Sentry, LangSmith traces, production debugging | `/cks:observe` |
| `scheduled-agents/` | Recurring agent patterns — analytics with memory, sentiment monitoring, asset generation | `/cks:schedule` |
| `performance/` | Core Web Vitals, bundle size, query optimization, load testing | Sprint phases |
| `evals/` | LLM output quality evaluation — memory/RAG, API responses, tool-use, prompt regression, safety, structured output. Smoke/standard/comprehensive tiers. | `/cks:evals` |

### Research & Exploration

| Skill | Purpose | Key Commands |
|-------|---------|-------------|
| `deep-research/` | Multi-hop recursive research with configurable sources | `/cks:research` |
| `context-research/` | Quick library/API reference lookup → `.context/` | `/cks:context` |
| `repo-exploration/` | Evaluate external repos for CKS-compatible concepts | `/cks:explore` |
| `api-design/` | REST API conventions — routes, schemas, pagination, versioning, error handling | Sprint phases |
| `api-docs/` | Auto-generate API docs from codebase analysis | `/cks:docs` |

### Marketing & Growth

| Skill | Purpose | Key Commands |
|-------|---------|-------------|
| `aeo-geo/` | Answer Engine / Generative Engine Optimization | `/cks:seo-audit` |
| `seo-local/` | Local SEO for rank-and-rent sites | — |
| `ai-marketing/` | AI-native content, AEO/GEO, llms.txt, AI search citations, AI directory presence | `/cks:market` |
| `online-marketing/` | Keyword gaps, funnel architecture, email sequences, paid ads, CRO (Ahrefs) | `/cks:market` |
| `brand-marketing/` | Domain authority, backlink gap, citation building, brand voice (Ahrefs) | `/cks:market` |
| `product-marketing/` | ICP, positioning, competitive narrative, GTM strategy, messaging hierarchy | `/cks:market` |

### Monetization

| Skill | Purpose | Key Commands |
|-------|---------|-------------|
| `monetize/` | Business model evaluation — 12 models scored with margin-aware projections | `/cks:monetize:*` |
| `payments/` | Checkout flows, Stripe, idempotency, subscription billing, PCI DSS, webhooks | Sprint phases |
| `openrouter/` | AI gateway — model selection, cost optimization across providers | Sprint phases |

### Session & Workflow

| Skill | Purpose | Key Commands |
|-------|---------|-------------|
| `peers/` | Session awareness — deconfliction and status broadcast via claude-peers-mcp | `/cks:peers` |
| `auto-mode/` | Claude Code Auto mode — classifier-based safety, hands-off execution | Autonomous tasks |
| `guardrails/` | Scoped `.claude/rules/` files — security, testing, DB, docs guardrails | `/cks:bootstrap` |
| `language-rules/` | Stack-specific coding rules — generated at bootstrap time | `/cks:bootstrap` |
| `library-skills/` | Install official AI skills from packages (FastAPI, Streamlit) into `.claude/skills/` | `/cks:bootstrap` |
| `ultrareview/` | Cloud-based deep code review — verified findings for high-stakes code | `/cks:ultrareview` |

### Strategy

| Skill | Purpose | Key Commands |
|-------|---------|-------------|
| `mckinsey-strategy-os/` | McKinsey Strategy OS router — maps 6 modules to 12 skills; routes diagnosis, market mapping, options, operating model, KPIs, and exec comms | `/cks:strategy` |
| `situation-assessment/` | M01 Diagnosis — situation framing, growth barrier identification, assumption audit | Strategy OS |
| `market-mapping/` | M02 Market & Competitive — player landscape, profit pool, customer segmentation, white space | Strategy OS |
| `strategic-options/` | M03 Options & Business Case — WHERE/HOW to WIN, distinct options, business case skeleton, portfolio signal | Strategy OS |
| `operating-model/` | M04 Execution — operating model design, initiative prioritization, phased plan, kill criteria | Strategy OS |
| `kpi-architect/` | M05 KPIs & Risk — leading/lagging indicators, war-gaming, risk register, governance trigger | Strategy OS |
| `decision-memo/` | M06 Exec Comms — Pyramid Principle, SCR spine, governing thought, MECE arguments, the ask | Strategy OS |

### Specialized

| Skill | Purpose | Key Commands |
|-------|---------|-------------|
| `accessibility/` | WCAG 2.1 AA — UI components, forms, ARIA, keyboard nav, screen readers | Sprint phases |
| `design-system/` | Design tokens, component specs, DESIGN.md for AI-agent consumption | `/cks:design-system` |
| `remotion/` | Programmatic video in React — compositions, timing, audio, captions | `/cks:remotion` |
| `no-code/` | No-code automation — n8n, Make.com, Workato, Zapier | `/cks:no-code` |
| `agentic-os-builder/` | Three-layer Agentic OS — domains, memory, observability dashboard | `/cks:agentic-os` |
| `agent-persona/` | Agent persona cards — behavior rules, knowledge index, identity definition | `/cks:persona` |
| `caveman/` | Compress output to caveman speak — drops filler, preserves technical accuracy | `/cks:caveman` |
| `skill-creator/` | Create and write CKS skills — Anthropic + Matt Pocock best practices | `/cks:skill` |
| `rpi/` | Research-Plan-Implement sub-cycle methodology | Sprint phases |

## Skill Structure

```
skill-name/
├── SKILL.md              Entry point — frontmatter + orchestration logic
├── workflows/            Phase-specific workflow definitions
│   ├── phase.md          Orchestrator — thin router to sub-steps (<80 lines)
│   ├── phase/            Sub-step directory
│   │   ├── _shared.md    Shared context (banner template, variables)
│   │   ├── step-0-*.md   Individual steps (<100 lines each)
│   │   └── step-N-*.md
│   └── secrets/          Cross-cutting hooks (secrets lifecycle)
├── references/           Static reference data (templates, catalogs, glossaries)
│   └── reference.md
└── templates/            Output templates (optional)
    └── template.md
```

## How Skills Work

1. A command (e.g., `/cks:sprint`) triggers an agent with the skill in its `skills:` frontmatter
2. `SKILL.md` is loaded into the agent's context at startup
3. The skill contains orchestration logic or pointers to workflow files
4. Workflow files are read on demand via `Read + execute`
5. Each step produces artifacts (`.md` files in project directories)

## Environment Variables

| Variable | Used By | Required? |
|----------|---------|-----------|
| `PERPLEXITY_API_KEY` | `kickstart/`, `monetize/`, `deep-research/` | Optional — falls back to WebSearch |

## Customization

Skills are opinionated starting points, not immutable rules. After installing CKS:

1. **SKILL.md frontmatter** — Adjust `allowed-tools` and `model` per skill
2. **Workflow files** (`workflows/`) — Edit process steps, gate criteria, phase logic
3. **Reference files** (`references/`) — Tune domain knowledge, templates, rule catalogs
4. **Templates** (`templates/`) — Change output document formats

After installation, these files are yours. Customize freely.
