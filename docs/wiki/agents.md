# Agents Reference — the 18 roles

CKS v6 runs on eighteen roles instead of task agents. A role is a tool grant plus a model plus a
system prompt; roles differ by **what they may reach and write**, never by prompt alone. You do
not call roles directly — the chief of staff, a command, or an orchestrator skill dispatches them
with a brief that names a `Mode:` (which workflow to follow) or a `Persona:` (which voice to
take). Contract: `docs/v6-workforce.md`. Dispatch lookup: `skills/chief-of-staff/references/roster.md`.
Old v5 names: `docs/MIGRATION-v5-to-v6.md`.

The sections between the `generated:roles` markers are produced by `scripts/generate-docs.sh`
from each role's frontmatter, `scripts/agent-graph.sh --edges` and `scripts/agent-map.tsv` —
edit `agents/<role>.md`, then regenerate. **Writes** is inferred from the tool grant (`Write`,
`Edit`, both, or neither = decide/review/report role); the exact write scope and whether `Bash`
is read-only are stated in each role body.

---

<!-- generated:roles start -->
## chief-of-staff

**Purpose:** Chief of staff — triages inbound work, decides what deserves attention, dispatches
specialist agents, and enforces the three-priority limit. Decides and delegates; never executes. Use
at session start, when work is piling up, or when it is unclear what to do next.
**Model:** opus. **Writes:** read-only (no Write/Edit). **Runs as:** top-level skill
(`Skill(skill="cks:chief-of-staff")`); the agent file exists only for `claude --agent`.
**Grants:** Read, Grep, Glob, Bash; read-only (no Write/Edit); Agent, AskUserQuestion.
**Skills:** chief-of-staff, decision-memo, operating-model.
**Dispatched by:** none — loaded top-level via `Skill(skill="cks:chief-of-staff")`.
**Absorbed (v5):** none.

## project-manager

**Purpose:** Keeps the board true — every piece of work is a GitHub Issue with an owner, an outcome
and an honest state; sole writer of the work hierarchy, session handoffs and the DEVLOG; wires the
Kanban board; turns follow-ups into issues. Never invents work and never decides priority — the
chief of staff does that.
**Model:** sonnet. **Writes:** Write. **Runs as:** sub-agent.
**Grants:** Read, Grep, Glob, Bash; Write; AskUserQuestion; GitHub (all tools).
**Skills:** github-issues, prd, core-behaviors, caveman.
**Dispatched by:** /cks:new, /cks:work; skills: chief-of-staff, routines.
**Absorbed (v5):** work-hierarchy-manager.

## assistant

**Purpose:** Executive assistant — triages the inbox, keeps the calendar honest, drafts replies and
follow-ups in the owner's EN/FR voice, preps meetings, tracks reminders, runs the daily brief.
Prefers Brain 1 tools when connected, falls back to Gmail and Google Calendar MCP. Never sends;
every outbound comes back as a draft for approval.
**Model:** sonnet. **Writes:** Write. **Runs as:** sub-agent.
**Grants:** Read, Grep, Glob, Bash; Write; AskUserQuestion; Gmail: search_threads, get_thread,
get_message, list_drafts, get_draft, create_draft, update_draft, list_labels, label_thread; Google
Calendar: list_calendars, list_events, search_events, get_event, suggest_time, create_event,
update_event; Brain 1 (all tools).
**Skills:** executive-assistant, user-memory, conversation-state, core-behaviors, caveman.
**Dispatched by:** /cks:assistant, /cks:remind, /cks:standup.
**Absorbed (v5):** reminder, standup-reader.

## finops

**Purpose:** Keeps money on track — API/token/infra costs, margin per client and venture, budget
burn vs ceiling, Stripe invoicing (gated), SR&ED evidence from git history, Stripe integration
advice. Reports and drafts; never moves money without approval.
**Model:** sonnet. **Writes:** Write. **Runs as:** sub-agent.
**Grants:** Read, Grep, Glob, Bash; Write; AskUserQuestion, WebFetch; Stripe (all tools); GitHub:
list_commits.
**Skills:** finops, payments, pricing-strategy, revops, analytics-tracking, core-behaviors, caveman.
**Dispatched by:** /cks:cost, /cks:finops, /cks:optimize, /cks:payments.
**Absorbed (v5):** cost-analyzer, luv-fin-ops, payment-advisor, token-optimizer.

## watchdog

**Purpose:** Finds friction nobody reported — rules nothing enforces, automation that stopped,
assets never used, work that silently stalled, spend without output, and agency KPIs drifting; also
runs the health check, rules audit, launch-readiness gate, loop health and cost estimates, and the
skill-quarantine review. Reports only; never fixes.
**Model:** sonnet. **Writes:** read-only (no Write/Edit). **Runs as:** sub-agent.
**Grants:** Read, Grep, Glob, Bash; read-only (no Write/Edit).
**Skills:** core-behaviors, caveman, launch-strategy.
**Dispatched by:** /cks:doctor, /cks:launch-check, /cks:review-rules; skills: loop; pipelines:
assess.
**Absorbed (v5):** gatekeeper, health-checker, launch-readiness, rules-auditor.

## observer

**Purpose:** Reads runtime signals and reports — Sentry errors, Vercel and Cloudflare logs, Supabase
advisors, LangSmith traces, control-plane session metrics, coordination locks, and post-deploy
canaries. Reports only; never fixes, never files issues.
**Model:** sonnet. **Writes:** read-only (no Write/Edit). **Runs as:** sub-agent.
**Grants:** Read, Grep, Glob, Bash; read-only (no Write/Edit); WebFetch; Sentry: authenticate,
complete_authentication; Vercel: get_runtime_logs, get_deployment_build_logs; Supabase:
list_projects, get_advisors, list_tables; Cloudflare: workers_analytics_search.
**Skills:** observability, canary, control-plane, control-plane/observability,
control-plane/coordination, control-plane/hardening, core-behaviors, caveman.
**Dispatched by:** /cks:agents, /cks:canary, /cks:control-plane, /cks:observe, /cks:peers; skills:
loop.
**Absorbed (v5):** canary-monitor, coordination-agent, langsmith-observer, log-reader,
observability-agent, peer-coordinator, sentry-observer.

## researcher

**Purpose:** External research — social and market signal first via last30days, then multi-hop web
research across Perplexity, Context7, Firecrawl and the web; competitor and tech evaluations, market
and pricing research, codebase questions for planning, ecosystem bulletins, and CCCS threat intel.
Writes reports under .research/; never decides.
**Model:** sonnet. **Writes:** Write. **Runs as:** sub-agent.
**Grants:** Read, Grep, Glob, Bash; Write; WebSearch, WebFetch; Firecrawl (all tools); Context7 (all
tools); Perplexity (all tools).
**Skills:** deep-research, ecosystem-watch, core-behaviors, caveman.
**Dispatched by:** /cks:cccs-intel, /cks:learn, /cks:research; skills: kickstart.
**Absorbed (v5):** cccs-intel-monitor, cost-researcher, deep-researcher, ecosystem-learner,
ecosystem-watcher, monetize-researcher, prd-researcher.

## strategist

**Purpose:** Discovery and strategy — client intake and scoping, the 11-element feature discovery,
kickstart intake and gates, ideation, feature scope, concept feasibility scoring, monetization
evaluation and roadmap, pivots, personas and profiles, plan interrogation, pre-flight, compliance
surface and Canadian legal risk checks. Interviews with AskUserQuestion; writes discovery artifacts;
never plans the build.
**Model:** opus. **Writes:** Write. **Runs as:** sub-agent.
**Grants:** Read, Grep, Glob, Bash; Write; AskUserQuestion, WebSearch, WebFetch.
**Skills:** prd, kickstart, monetize, concept-evaluation, strategic-frameworks, kpi-architect,
market-mapping, strategic-options, compliance, core-behaviors, caveman, karpathy-guidelines.
**Dispatched by:** /cks:adopt, /cks:bootstrap, /cks:brainstorm, /cks:discover, /cks:grill,
/cks:ideate, /cks:me, /cks:new, /cks:next, /cks:persona, /cks:personas, /cks:pivot; skills:
concept-evaluation, kickstart, loop, prd; pipelines: sprint; rules: scheduling.
**Absorbed (v5):** agile-eagle, concept-pillar-worker, expert-product, expert-specialist,
feature-cataloger, grill-me-interviewer, kickstart-brand, kickstart-feature-scope,
kickstart-ideator, kickstart-intake, kickstart-validate, monetize-discoverer, monetize-evaluator,
monetize-reporter, monetize-roadmap, persona-interviewer, personas-agent, pivot-analyzer,
prd-discoverer.

## architect

**Purpose:** Turns discovery into buildable design — PRD and execution plan, UX flows, API
contracts, screens and component specs, ARCHITECTURE.md and ADRs, Supabase/pgvector data design and
ERDs, DESIGN.html, scaling and payment-integration advice, and agent-system design via the 15-stage
build sequence. Writes design docs only; never implements.
**Model:** opus. **Writes:** Write + Edit. **Runs as:** sub-agent.
**Grants:** Read, Grep, Glob, Bash; Write + Edit; AskUserQuestion; Supabase: list_tables,
search_docs.
**Skills:** prd, architecture, database-design, design-system, design-fluency, agent-build-sequence,
ai-agent-projects, payments, core-behaviors, caveman, karpathy-guidelines.
**Dispatched by:** /cks:adopt, /cks:architecture, /cks:db, /cks:design, /cks:design-system,
/cks:next, /cks:preflight, /cks:scale; skills: kickstart, loop, prd; pipelines: sprint; rules:
arch-patterns, loops.
**Absorbed (v5):** architecture-generator, db-erd, design-system-generator, kickstart-designer,
luv-api-designer, luv-designer, luv-tech-lead, prd-designer, prd-planner, scale-advisor.

## builder

**Purpose:** Builder — writes application code from a PLAN.md task group with a TDD loop, refactors
with behavior preserved, generates and rollback-tests schema migrations, scaffolds no-code workflows
and API CLIs, and writes SUMMARY.md before returning. Use for "sprint", "build", "implement",
"execute", "code it", "refactor", "migrate the schema", "TDD".
**Model:** sonnet. **Writes:** Write + Edit. **Runs as:** sub-agent.
**Grants:** Read, Grep, Glob, Bash; Write + Edit; AskUserQuestion, TodoWrite; Supabase (all tools).
**Skills:** prd, testing-discipline, code-excellence, database-design, no-code, cli-generation,
core-behaviors, caveman, karpathy-guidelines.
**Dispatched by:** /cks:marketing-build, /cks:marketing-dev, /cks:next, /cks:print-cli,
/cks:refactor, /cks:remotion, /cks:simplify, /cks:tdd, /cks:test; skills: autoresearch, evals, loop,
no-code, prd, sleep-cycle; pipelines: sprint; rules: dispatch-first.
**Absorbed (v5):** code-simplifier, db-migration, expert-builder, luv-ai-tooling-engineer,
luv-backend-dev, luv-cto, luv-data-engineer, luv-database-auth-engineer, luv-frontend-dev,
luv-full-stack-dev, luv-landing-page-dev, luv-mobile-app-dev, no-code-specialist, prd-executor,
prd-executor-worker, prd-refactorer, printing-press-runner, remotion-specialist, tdd-runner.

## reviewer

**Purpose:** Reviewer — static review with no write path: code review against the checklist, OWASP
security audit with secrets and dependency scans, design-fluency lint, Supabase RLS audit, contract
review, and Canadian compliance surface. Returns findings as a severity table with file:line and
names every blocking finding. Use for "review the code", "security", "OWASP", "compliance",
"contract review", "design fluency", "RLS audit".
**Model:** opus. **Writes:** read-only (no Write/Edit). **Runs as:** sub-agent.
**Grants:** Read, Grep, Glob, Bash; read-only (no Write/Edit); AskUserQuestion; GitHub:
pull_request_read, list_pull_requests; Supabase: list_tables, get_advisors.
**Skills:** contracts, code-excellence, security-hardening, design-fluency, database-design,
compliance, ciso, core-behaviors, caveman.
**Dispatched by:** /cks:ciso, /cks:compliance, /cks:db, /cks:design, /cks:security; skills:
attractor; pipelines: assess, db, sprint.
**Absorbed (v5):** ciso, compliance-advisor, db-investigator, design-fluency-reviewer, luv-legal,
luv-mythos, security-auditor.

## tester

**Purpose:** Tester — runs the verification that proves work is done: test suites against acceptance
criteria, browser UAT with human sign-off, LLM evals (smoke/standard/comprehensive/red-team), and
hook harness evals. Writes VERIFICATION.md with the Evidence Bundle front-matter and CONFIDENCE.md,
and files GitHub issues for failures. Use for "test", "verify", "UAT", "evals", "run the suite",
"browser check", "red team".
**Model:** sonnet. **Writes:** Write. **Runs as:** sub-agent.
**Grants:** Read, Grep, Glob, Bash; Write; GitHub: issue_write; Claude in Chrome: tabs_context_mcp,
tabs_create_mcp, tabs_close_mcp, navigate, find, form_input, get_page_text, read_page,
javascript_tool, gif_creator, read_console_messages, read_network_requests.
**Skills:** uat, evals, harness-evals, testing-discipline, github-issues, failure-taxonomy,
core-behaviors, caveman.
**Dispatched by:** /cks:browse, /cks:evals, /cks:harness-eval, /cks:next, /cks:uat; skills:
attractor, autoresearch, prd, routines, sleep-cycle; pipelines: sprint.
**Absorbed (v5):** browser, evals-runner, harness-eval-runner, luv-agent-browser, luv-qa-engineer,
luv-uat-engineer, prd-verifier, uat-runner.

## debugger

**Purpose:** Debugger — root-cause diagnosis and the minimal fix: classifies the failure, traces the
causal chain to where bad state was introduced, applies a scoped edit, verifies, and closes the
issue. Triage mode scans, files every finding to GitHub, and returns a queue; db-fix mode traces and
repairs Supabase RLS, query, and pool problems. Cannot create files. Use for "fix", "debug",
"broken", "error", "bug", "triage the issues", "RLS failing".
**Model:** opus. **Writes:** Edit (no Write). **Runs as:** sub-agent.
**Grants:** Read, Grep, Glob, Bash; Edit (no Write); AskUserQuestion; GitHub: issue_write,
issue_read, list_issues; Supabase: execute_sql, list_tables; Sentry: authenticate,
complete_authentication.
**Skills:** debug, failure-taxonomy, github-issues, database-recovery, core-behaviors, caveman.
**Dispatched by:** /cks:db, /cks:debug, /cks:fix, /cks:investigate, /cks:triage; skills: attractor,
debug, evals, routines; pipelines: assess, db, sprint.
**Absorbed (v5):** db-debugger, db-fixer, debugger-worker, expert-debugger, investigator,
luv-debugger, triage-runner.

## shipper

**Purpose:** Shipper — takes verified work to users: build, commit, push, PR, CI watch, changelog
and version bump, environment promotion dev → staging → RC → production with quality gates and
health checks. Production deploys are drafted and returned as GATED, never executed alone. Use for
"deploy", "release", "ship", "go live", "push to prod", "go", "push", "PR", "commit and push",
"changelog".
**Model:** sonnet. **Writes:** Write + Edit. **Runs as:** sub-agent.
**Grants:** Read, Grep, Glob, Bash; Write + Edit; AskUserQuestion; GitHub (all tools); Vercel (all
tools).
**Skills:** shipping-checklist, environment-management, github-issues, migrations, core-behaviors,
caveman.
**Dispatched by:** /cks:changelog, /cks:deploy, /cks:go, /cks:next, /cks:setup-webhooks, /cks:ship;
skills: debug, prd; pipelines: sprint.
**Absorbed (v5):** changelog-generator, deployer, go-runner, luv-cicd, luv-devops, ship-runner.

## historian

**Purpose:** Historian — the workforce's memory: persists REMEMBER blocks, maintains the wiki with
OKF frontmatter, curates validated learnings by PR, runs retrospectives, drafts improvement
proposals from dispatch traces, reviews sleep-cycle proposals, and writes the session journal and
user profile. Writes only inside memory directories. Use for "remember this", "retro", "learnings",
"journal", "wiki", "what did we build", "improve the agents".
**Model:** sonnet. **Writes:** Write + Edit. **Runs as:** sub-agent.
**Grants:** Read, Grep, Glob, Bash; Write + Edit.
**Skills:** learnings, retrospective, user-memory, honcho-memory, sleep-cycle, core-behaviors,
caveman.
**Dispatched by:** /cks:cks-wiki, /cks:eod, /cks:evolve, /cks:gate, /cks:handoff, /cks:honcho,
/cks:improve, /cks:memory, /cks:new, /cks:retro, /cks:review, /cks:save-context; skills:
chief-of-staff, loop.
**Absorbed (v5):** ahe-evolution-agent, honcho-integrator, improvement-agent, learnings-curator,
memory-agent, retrospective, session-journalist, sprint-reviewer, user-profiler, wiki.

## marketer

**Purpose:** One marketing role — loads the persona the brief needs (copy, brand, paid, SEO/GEO/AEO,
creative, analytics, outbound prospecting, claims compliance) and runs campaigns end to end. Writes
only under .campaign/ and .marketing/; every send, load, post, or spend comes back as a draft for
approval.
**Model:** opus. **Writes:** Write. **Runs as:** sub-agent.
**Grants:** Read, Grep, Glob, Bash; Write; AskUserQuestion, WebSearch, WebFetch; Ahrefs (all tools);
Apollo.io (all tools); Vibe Prospecting (all tools).
**Skills:** marketing, luv-model-routing, campaign, copywriting, aeo-geo, marketing-psychology,
launch-strategy, analytics-tracking, sales-enablement, market-mapping, content-strategy,
ad-creative, cold-email, paid-ads, copy-editing, social-content, photo-direction,
video-ai-direction, positioning, product-marketing, customer-research, ab-test-setup,
core-behaviors, caveman.
**Dispatched by:** /cks:analytics, /cks:copy, /cks:creative, /cks:luv, /cks:market, /cks:marketing,
/cks:marketing-analytics, /cks:marketing-build, /cks:seo-audit; skills: campaign, kickstart.
**Absorbed (v5):** aeo-geo-specialist, ai-marketer, analytics-tracker, brand-marketer,
campaign-orchestrator, copywriter, launch-strategist, luv-ads-copywriter, luv-alan-sharpe,
luv-brand-strategist, luv-ceo, luv-cmo, luv-data-scientist, luv-growth-revenue-strategist,
luv-linkedin-ads-specialist, luv-long-form-copywriter, luv-meta-ads-specialist,
luv-paid-media-manager, luv-photo-creator, luv-seo-geo-aeo, luv-strategist, luv-video-creator,
luv-video-producer, online-marketer, product-marketer, seo-strategist, social-content.

## operator

**Purpose:** Setup and integrations — bootstrap and adopt scaffolding, Agentic OS, channels
(Telegram, Slack), voice via Telnyx, schedules and heartbeats, sandbox policy, control-plane writes,
migrations, plugin dependencies. Writes project config and scaffolds only; never application code,
never a Routine without approval.
**Model:** sonnet. **Writes:** Write + Edit. **Runs as:** sub-agent.
**Grants:** Read, Grep, Glob, Bash; Write + Edit; AskUserQuestion, CronCreate; Telnyx (all tools);
Supabase (all tools).
**Skills:** routines, cicd-starter, guardrails, language-rules, channel-setup, voice, slack,
agentic-os-builder, scheduled-agents, migrations, control-plane, core-behaviors, caveman.
**Dispatched by:** /cks:adopt, /cks:agentic-os, /cks:bootstrap, /cks:caveman, /cks:codegraph,
/cks:control-plane, /cks:heartbeat, /cks:hermes, /cks:hq, /cks:migrate, /cks:peers, /cks:sandbox,
/cks:schedule, /cks:slack, /cks:telegram, /cks:virginize, /cks:voice; skills: kickstart, loop,
sleep-cycle.
**Absorbed (v5):** agentic-os-builder, bootstrap-generator, bootstrap-scanner, caveman-speaker,
control-plane-agent, github-project-setup-agent, heartbeat-agent, hermes-readiness,
kickstart-handoff, luv-n8n-automation, migrator, sandbox-agent, scheduler, slack-integrator,
telegram-integrator, voice-setup.

## writer

**Purpose:** Writer — generates project documentation from the codebase (API, architecture,
components, onboarding, coding-agent llms.txt) and drafts contracts (MSA, SOW, NDA) from templates.
Every contract is a draft for the reviewer; every doc cites real paths. Use for "docs", "document
this", "write the guide", "README", "hand-off manual", "draft the SOW", "NDA".
**Model:** haiku. **Writes:** Write. **Runs as:** sub-agent.
**Grants:** Read, Grep, Glob, Bash; Write.
**Skills:** contracts, api-docs, core-behaviors, caveman.
**Dispatched by:** /cks:docs; skills: prd.
**Absorbed (v5):** doc-generator.
<!-- generated:roles end -->

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
