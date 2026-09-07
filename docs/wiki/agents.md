# Agents Reference — the 18 roles

CKS v6 runs on eighteen roles instead of task agents. A role is a tool grant plus a model plus a
system prompt; roles differ by **what they may reach and write**, never by prompt alone. You do
not call roles directly — the chief of staff, a command, or an orchestrator skill dispatches them
with a brief that names a `Mode:` (which workflow to follow) or a `Persona:` (which voice to
take). Contract: `docs/v6-workforce.md`. Dispatch lookup: `skills/chief-of-staff/references/roster.md`.
Old v5 names: `docs/MIGRATION-v5-to-v6.md`.

Grant vocabulary used below — **ro** = Bash read-only (no redirects, `sed -i`, `tee`, heredocs,
`mkdir`); **rw** = Bash may write; **Write scope** = the paths a role may create; **no Write/Edit**
= decide/review/report role.

---

## chief-of-staff

**Purpose:** the session brain. Reads state, classifies intent (Converse / Dispatch / Clarify),
triages to ACT / DEFER / DROP / ESCALATE, dispatches at most three roles, returns one brief.
Never does the work.
**Grants:** Read, Grep, Glob, Bash ro, Agent, AskUserQuestion — no Write/Edit.
**Model:** opus. **Runs as:** top-level skill (`/cks:chief`, HQ first turn, routine sessions);
the agent file exists only for `claude --agent` mode.
**Skills:** chief-of-staff, decision-memo, operating-model.
**Absorbed:** concierge, session-loader.

## project-manager

**Purpose:** turns dispatched work into GitHub Issues and board state; sole writer of
`.prd/work-hierarchy.md`; writes handoffs and the DEVLOG pointer.
**Grants:** Read, Grep, Glob, Bash rw (git read, gh), Write (`.prd/` state only), AskUserQuestion,
GitHub MCP (all tools).
**Model:** sonnet.
**Skills:** github-issues, prd, core-behaviors, caveman.
**Absorbed:** work-hierarchy-manager, github-project-setup-agent (board side), session-journalist
(handoff/DEVLOG), reminder (issue-backed).

## assistant

**Purpose:** executive assistant — inbox triage, calendar review, reply drafts, meeting prep,
reminders, the morning brief. Drafts only; nothing is ever sent.
**Grants:** Read, Grep, Glob, Bash ro, Write (`$CKS_HQ/users/<slug>/` or `~/.cks/user/<slug>/`),
AskUserQuestion, Gmail read + draft tools only, Calendar read + create/update, Brain MCP. Never
`send_message`, `reply`, `forward`, `respond_to_event`.
**Model:** sonnet.
**Skills:** executive-assistant, user-memory, conversation-state, core-behaviors, caveman.
**Absorbed:** reminder, standup-reader.

## finops

**Purpose:** money on track — cost audits, unit economics, margin per client, invoice drafts
(gated send), budget burn, SR&ED evidence, payments advice.
**Grants:** Read, Grep, Glob, Bash ro, Write (`.finops/`, the finops dir), AskUserQuestion,
WebFetch, Stripe MCP, GitHub `list_commits`.
**Model:** sonnet.
**Skills:** finops, payments, pricing-strategy, revops, analytics-tracking, core-behaviors, caveman.
**Absorbed:** cost-analyzer, cost-researcher (cost side), token-optimizer (analysis),
loop-cost-monitor (ledger side), payment-advisor, luv-fin-ops.

## watchdog

**Purpose:** finds friction nobody reported — rules nothing enforces, assets never used, work that
silently stalled, spend without output, launch readiness, loop health and cost reports, skill
lifecycle review, agency KPIs.
**Grants:** Read, Grep, Glob, Bash ro — no Write/Edit, no AskUserQuestion.
**Model:** sonnet.
**Skills:** core-behaviors, caveman, launch-strategy.
**Absorbed:** health-checker, rules-auditor, launch-readiness, loop-health-checker (report side),
loop-cost-monitor (report side), gatekeeper.

## observer

**Purpose:** reads live signals — logs, Sentry, LangSmith, Vercel and Supabase advisors, canary
checks, control-plane and peer-session state — and reports. Never changes anything.
**Grants:** Read, Grep, Glob, Bash ro, WebFetch, Sentry auth tools, Vercel runtime/build logs,
Supabase `list_projects` / `get_advisors` / `list_tables`, Cloudflare workers analytics.
**Model:** sonnet.
**Skills:** observability, canary, control-plane (+ observability, coordination, hardening
sub-skills), core-behaviors, caveman.
**Absorbed:** sentry-observer, langsmith-observer, log-reader, observability-agent, canary-monitor,
coordination-agent, peer-coordinator, control-plane-agent (read side).

## researcher

**Purpose:** multi-hop research (`last30days` first), codebase and options research for a
feature, market and pricing research, infra pricing, ecosystem and threat intel.
**Grants:** Read, Grep, Glob, Bash rw (runs `last30days`), Write (`.research/`,
`.monetize/research.md`, `.kickstart/artifacts/research*`), WebSearch, WebFetch, Firecrawl,
Context7, Perplexity MCP.
**Model:** sonnet.
**Skills:** deep-research, ecosystem-watch, core-behaviors, caveman.
**Absorbed:** deep-researcher, prd-researcher, monetize-researcher, cost-researcher (market side),
ecosystem-learner, ecosystem-watcher, cccs-intel-monitor.

## strategist

**Purpose:** what to build and why — Phase 1 discovery (11 Elements), kickstart intake / ideation /
feature scope / validation / brand brief, monetize discovery / evaluation / report / roadmap,
concept pillar scoring, pivots, personas, grill-me, expert product/specialist personas, compliance
surface, client intake.
**Grants:** Read, Grep, Glob, Bash ro, Write (`.prd/` discovery artifacts, `.kickstart/`,
`.monetize/`, `.concept/`, `.preflight/`, persona files), AskUserQuestion, WebSearch, WebFetch.
**Model:** opus.
**Skills:** prd, kickstart, monetize, concept-evaluation, strategic-frameworks, kpi-architect,
market-mapping, strategic-options, compliance, core-behaviors, caveman, karpathy-guidelines.
**Absorbed:** prd-discoverer, kickstart-ideator / -intake / -feature-scope / -validate / -brand,
concept-pillar-worker, monetize-discoverer / -evaluator / -reporter / -roadmap, pivot-analyzer,
persona-interviewer, personas-agent, user-profiler (interview), grill-me-interviewer,
expert-product, expert-specialist, agile-eagle, feature-cataloger, luv-legal (strategy side).

## architect

**Purpose:** how to build it — Phase 2 design (DESIGN.md), Phase 3a planning (PLAN.md), TDD /
technical design, ARCHITECTURE.md and ADRs (incl. distributed-pattern ADRs), ERDs, design
systems (DESIGN.html), loop design, scaling advice, API and system design.
**Grants:** Read, Grep, Glob, Bash ro, Write + Edit (design docs: PLAN.md, DESIGN.md,
ARCHITECTURE.md, `.decisions/`, design-system files, ERDs), AskUserQuestion, Supabase
`list_tables` / `search_docs`.
**Model:** opus.
**Skills:** prd, architecture, database-design, design-system, design-fluency, agent-build-sequence,
ai-agent-projects, payments, core-behaviors, caveman, karpathy-guidelines.
**Absorbed:** prd-planner, prd-designer, architecture-generator, kickstart-designer,
design-system-generator, db-erd, expert-builder, scale-advisor, payment-advisor (advice),
loop-designer (design half), luv-api-designer, luv-tech-lead, luv-designer.

## builder

**Purpose:** writes the code — sprint implementation from PLAN.md (writes SUMMARY.md), TDD,
refactor, simplify, DB migrations, no-code automations, CLI generation, video code, loop runs.
**Grants:** Read, Grep, Glob, Bash rw, Write, Edit, AskUserQuestion, TodoWrite, Supabase MCP
(all tools). Dispatched with worktree isolation.
**Model:** sonnet.
**Skills:** prd, testing-discipline, code-excellence, database-design, no-code, cli-generation,
core-behaviors, caveman, karpathy-guidelines.
**Absorbed:** prd-executor, prd-executor-worker, tdd-runner, prd-refactorer, code-simplifier,
db-migration, no-code-specialist, remotion-specialist, printing-press-runner, loop-runner, luv-cto,
luv-frontend-dev / -backend-dev / -full-stack-dev / -mobile-app-dev / -landing-page-dev /
-database-auth-engineer / -ai-tooling-engineer / -data-engineer.

## reviewer

**Purpose:** judges code and systems — code review, security (OWASP, CISO cross-repo), compliance
(incl. Canadian references), design fluency, DB audit, contract and claims review. Findings only.
**Grants:** Read, Grep, Glob, Bash ro, AskUserQuestion, GitHub `pull_request_read` /
`list_pull_requests`, Supabase `list_tables` / `get_advisors` — no Write/Edit.
**Model:** opus.
**Skills:** contracts, code-excellence, security-hardening, design-fluency, database-design,
compliance, ciso, core-behaviors, caveman.
**Absorbed:** reviewer (v5), security-auditor, ciso, compliance-advisor, design-fluency-reviewer,
db-investigator, luv-qa-engineer, luv-mythos, luv-legal (claims side).

## tester

**Purpose:** proves it works — verification loop (VERIFICATION.md + CONFIDENCE.md), UAT, browser
flows, LLM evals by tier, harness evals for hooks. Files GitHub issues for failures itself.
**Grants:** Read, Grep, Glob, Bash rw, Write (fixtures, `.evals/`, `.harness-evals/`,
VERIFICATION.md, CONFIDENCE.md), GitHub `issue_write`, Claude-in-Chrome browser tools.
**Model:** sonnet.
**Skills:** uat, evals, harness-evals, testing-discipline, github-issues, failure-taxonomy,
core-behaviors, caveman.
**Absorbed:** prd-verifier, uat-runner, browser, evals-runner, harness-eval-runner,
luv-uat-engineer, luv-agent-browser.

## debugger

**Purpose:** root cause first — classify, trace, fix; triage scans that become an issue queue;
issue-driven fixes; DB diagnose and fix. May edit existing files, never creates new ones.
**Grants:** Read, Grep, Glob, Bash rw, Edit (no Write), AskUserQuestion, GitHub `issue_write` /
`issue_read` / `list_issues`, Supabase `execute_sql` / `list_tables`, Sentry auth tools.
**Model:** opus.
**Skills:** debug, failure-taxonomy, github-issues, database-recovery, core-behaviors, caveman.
**Absorbed:** debugger (v5), debugger-worker, investigator, triage-runner, db-debugger, db-fixer,
expert-debugger, luv-debugger.

## shipper

**Purpose:** gets it out — go (build → commit → push → PR), plugin release, changelog, deploys
(production is a gated action returned to the chief of staff).
**Grants:** Read, Grep, Glob, Bash rw, Write, Edit (CHANGELOG.md, config files), AskUserQuestion,
GitHub MCP (all tools), Vercel MCP (all tools).
**Model:** sonnet.
**Skills:** shipping-checklist, environment-management, github-issues, migrations, core-behaviors,
caveman.
**Absorbed:** deployer, go-runner, ship-runner, changelog-generator, luv-devops, luv-cicd.

## historian

**Purpose:** remembers and learns — retrospectives, sprint review, learnings curation (PR, never
push to main), wiki pages (OKF), memory persistence (`REMEMBER`), DEVLOG journal, user profile
write, improvement proposals, sleep-cycle proposal review.
**Grants:** Read, Grep, Glob, Bash ro, Write + Edit (`memory/`, `.learnings/`,
`.cks/control-plane/memory/`, `$CKS_HQ/memory/`, user profile) — no AskUserQuestion.
**Model:** sonnet.
**Skills:** learnings, retrospective, user-memory, honcho-memory, sleep-cycle, core-behaviors,
caveman.
**Absorbed:** learnings-curator, wiki, memory-agent, improvement-agent, retrospective,
sprint-reviewer, sleep-runner (proposal side), ahe-evolution-agent, honcho-integrator,
user-profiler (profile write), session-journalist (journal), loop-triage-curator.

## marketer

**Purpose:** the whole marketing bench as personas (`skills/marketing/personas/`) — campaigns,
copy, SEO / AEO / GEO, brand, product marketing, paid media, social, analytics, launch, outbound,
photo and video direction. Text generation may route through OpenRouter per `luv-model-routing`.
**Grants:** Read, Grep, Glob, Bash ro (+ the OpenRouter `curl` form), Write (`.campaign/`,
`.marketing/`), AskUserQuestion, WebSearch, WebFetch, Ahrefs, Apollo.io, Vibe Prospecting MCP.
**Model:** opus.
**Skills:** marketing, luv-model-routing, campaign, copywriting, aeo-geo, marketing-psychology,
launch-strategy, analytics-tracking, sales-enablement, market-mapping, content-strategy,
ad-creative, cold-email, paid-ads, copy-editing, social-content, photo-direction,
video-ai-direction, positioning, product-marketing, customer-research, ab-test-setup,
core-behaviors, caveman.
**Absorbed:** campaign-orchestrator (persona half), seo-strategist, aeo-geo-specialist, ai-marketer,
brand-marketer, product-marketer, online-marketer, copywriter, social-content, analytics-tracker,
launch-strategist, luv-ceo, luv-cmo, and the Luv personas (ads-copywriter, alan-sharpe,
brand-strategist, data-scientist, growth-revenue-strategist, linkedin-ads-specialist,
long-form-copywriter, meta-ads-specialist, paid-media-manager, photo-creator, seo-geo-aeo,
strategist, video-creator, video-producer).

## operator

**Purpose:** sets things up — bootstrap scan and generate, agentic OS, kickstart scaffold handoff,
migrations, Telegram / Slack / voice integrations, routines and schedules, sandbox policy,
control-plane writes, hermes readiness, board setup, caveman rewrites.
**Grants:** Read, Grep, Glob, Bash rw, Write (project config, scaffolds), Edit, AskUserQuestion,
CronCreate, Telnyx MCP, Supabase MCP (all tools).
**Model:** sonnet.
**Skills:** routines, cicd-starter, guardrails, language-rules, channel-setup, voice, slack,
agentic-os-builder, scheduled-agents, migrations, control-plane, core-behaviors, caveman.
**Absorbed:** bootstrap-scanner, bootstrap-generator, agentic-os-builder, kickstart-handoff,
migrator, telegram-integrator, slack-integrator, voice-setup, scheduler, heartbeat-agent,
sandbox-agent, caveman-speaker, control-plane-agent (write side), hermes-readiness,
github-project-setup-agent (setup side), luv-n8n-automation.

## writer

**Purpose:** documentation and contracts — API, architecture, component and onboarding docs;
MSA / SOW / NDA drafts from `skills/contracts/templates/`.
**Grants:** Read, Grep, Glob, Bash ro, Write — no Edit, no AskUserQuestion.
**Model:** haiku.
**Skills:** contracts, api-docs, core-behaviors, caveman.
**Absorbed:** doc-generator.

---

## Orchestrators that became skills

These v5 agents needed `Agent` themselves. A sub-agent cannot dispatch, so each is now a
`skills/<domain>/SKILL-ORCHESTRATOR.md` loaded top-level with `Skill(skill="cks:<domain>")`:

| v5 agent | Skill |
|---|---|
| attractor-runner, assess-runner, prd-orchestrator | `cks:attractor` |
| kickstart-orchestrator | `cks:kickstart` |
| loop-orchestrator, loop-runner, loop-designer, loop-health-checker, loop-cost-monitor, loop-triage-curator | `cks:loop` |
| concept-orchestrator | `cks:concept-evaluation` |
| factory-runner | `cks:github-issues` |
| autoresearch-runner | `cks:autoresearch` |
| sleep-runner | `cks:sleep-cycle` |
| campaign-orchestrator (chaining half) | `cks:campaign` |
| session-loader | `cks:chief-of-staff` |

## Where a role runs

Every role except the chief of staff is a sub-agent dispatched by the chief of staff or by an
orchestrator skill. When the work is on a project repo other than the session's, the chief of
staff opens a Claude Code Remote session on that repo and the role runs there; routines
(`skills/routines/`) do the same on a schedule.
