# Roster — the 18 roles, and where every v5 agent landed

The chief of staff resolves every ACT item against this file. Two tables: the **role table**
(who to dispatch, what they may touch, where they run) and the **v5 → v6 lookup** generated from
`scripts/agent-map.tsv`, so a legacy ask ("run the prd-executor") still resolves. Roles are
`agents/*.md`; the contract is `docs/v6-workforce.md`.

Every dispatch is `Agent(subagent_type="cks:<role>", prompt="Mode: <mode> | Persona: <name>. …")`.
The first line of the brief names the mode or persona; the role reads the matching workflow.
Orchestrator skills (`Skill(skill="cks:<domain>")`) cannot be dispatched from a sub-agent — the
founder runs the command, or you load the skill yourself when you are the top-level session.

**Where it runs.** `chief-of-staff` is the top-level skill (`/cks:chief`, the HQ first turn,
routine sessions); its agent file exists only for `claude --agent`. Every other role is a
sub-agent you dispatch in this session. When the work belongs to a project repo other than the
session's, open a Claude Code Remote session on that repo and dispatch the role there
(`skills/routines/workflows/routine-run.md` does the same on a schedule).

## Role table

<!-- generated:roster start -->
| Role | Purpose | Grant | Model | Dispatched by | Runs |
|---|---|---|---|---|---|
| `cks:chief-of-staff` | Triages inbound work, decides what deserves attention, dispatches specialist agents, and enforces the three-priority limit | read-only (no Write/Edit); Agent, AskUserQuestion | opus | none — loaded top-level via `Skill(skill="cks:chief-of-staff")` | top-level skill |
| `cks:project-manager` | Keeps the board true — every piece of work is a GitHub Issue with an owner, an outcome and an honest state; sole writer of the work hierarchy, session handoffs and the DEVLOG; wires the Kanban board; turns follow-ups into issues | Write; AskUserQuestion; GitHub (all tools) | sonnet | /cks:new, /cks:work; skills: chief-of-staff, routines | sub-agent |
| `cks:assistant` | Executive assistant — triages the inbox, keeps the calendar honest, drafts replies and follow-ups in the owner's EN/FR voice, preps meetings, tracks reminders, runs the daily brief | Write; AskUserQuestion; Gmail: search_threads, get_thread, get_message, list_drafts, get_draft, create_draft, update_draft, list_labels, label_thread; Google Calendar: list_calendars, list_events, search_events, get_event, suggest_time, create_event, update_event; Brain 1 (all tools) | sonnet | /cks:assistant, /cks:remind, /cks:standup | sub-agent |
| `cks:finops` | Keeps money on track — API/token/infra costs, margin per client and venture, budget burn vs ceiling, Stripe invoicing (gated), SR&ED evidence from git history, Stripe integration advice | Write; AskUserQuestion, WebFetch; Stripe (all tools); GitHub: list_commits | sonnet | /cks:cost, /cks:finops, /cks:optimize, /cks:payments | sub-agent |
| `cks:watchdog` | Finds friction nobody reported — rules nothing enforces, automation that stopped, assets never used, work that silently stalled, spend without output, and agency KPIs drifting; also runs the health check, rules audit, launch-readiness gate, loop health and cost estimates, and the skill-quarantine review | read-only (no Write/Edit) | sonnet | /cks:doctor, /cks:launch-check, /cks:review-rules; skills: loop; pipelines: assess | sub-agent |
| `cks:observer` | Reads runtime signals and reports — Sentry errors, Vercel and Cloudflare logs, Supabase advisors, LangSmith traces, control-plane session metrics, coordination locks, and post-deploy canaries | read-only (no Write/Edit); WebFetch; Sentry: authenticate, complete_authentication; Vercel: get_runtime_logs, get_deployment_build_logs; Supabase: list_projects, get_advisors, list_tables; Cloudflare: workers_analytics_search | sonnet | /cks:agents, /cks:canary, /cks:control-plane, /cks:observe, /cks:peers; skills: loop | sub-agent |
| `cks:researcher` | External research — social and market signal first via last30days, then multi-hop web research across Perplexity, Context7, Firecrawl and the web; competitor and tech evaluations, market and pricing research, codebase questions for planning, ecosystem bulletins, and CCCS threat intel | Write; WebSearch, WebFetch; Firecrawl (all tools); Context7 (all tools); Perplexity (all tools) | sonnet | /cks:cccs-intel, /cks:learn, /cks:research; skills: kickstart | sub-agent |
| `cks:strategist` | Discovery and strategy — client intake and scoping, the 11-element feature discovery, kickstart intake and gates, ideation, feature scope, concept feasibility scoring, monetization evaluation and roadmap, pivots, personas and profiles, plan interrogation, pre-flight, compliance surface and Canadian legal risk checks | Write; AskUserQuestion, WebSearch, WebFetch | opus | /cks:adopt, /cks:bootstrap, /cks:brainstorm, /cks:discover, /cks:grill, /cks:ideate, /cks:me, /cks:new, /cks:next, /cks:persona, /cks:personas, /cks:pivot; skills: concept-evaluation, kickstart, loop, prd; pipelines: sprint; rules: scheduling | sub-agent |
| `cks:architect` | Turns discovery into buildable design — PRD and execution plan, UX flows, API contracts, screens and component specs, ARCHITECTURE.md and ADRs, Supabase/pgvector data design and ERDs, DESIGN.html, scaling and payment-integration advice, and agent-system design via the 15-stage build sequence | Write + Edit; AskUserQuestion; Supabase: list_tables, search_docs | opus | /cks:adopt, /cks:architecture, /cks:db, /cks:design, /cks:design-system, /cks:next, /cks:preflight, /cks:scale; skills: kickstart, loop, prd; pipelines: sprint; rules: arch-patterns, loops | sub-agent |
| `cks:builder` | Writes application code from a PLAN.md task group with a TDD loop, refactors with behavior preserved, generates and rollback-tests schema migrations, scaffolds no-code workflows and API CLIs, and writes SUMMARY.md before returning | Write + Edit; AskUserQuestion, TodoWrite; Supabase (all tools) | sonnet | /cks:marketing-build, /cks:marketing-dev, /cks:next, /cks:print-cli, /cks:refactor, /cks:remotion, /cks:simplify, /cks:tdd, /cks:test; skills: autoresearch, evals, loop, no-code, prd, sleep-cycle; pipelines: sprint; rules: dispatch-first | sub-agent |
| `cks:reviewer` | Static review with no write path: code review against the checklist, OWASP security audit with secrets and dependency scans, design-fluency lint, Supabase RLS audit, contract review, and Canadian compliance surface | read-only (no Write/Edit); AskUserQuestion; GitHub: pull_request_read, list_pull_requests; Supabase: list_tables, get_advisors | opus | /cks:ciso, /cks:compliance, /cks:db, /cks:design, /cks:security; skills: attractor; pipelines: assess, db, sprint | sub-agent |
| `cks:tester` | Runs the verification that proves work is done: test suites against acceptance criteria, browser UAT with human sign-off, LLM evals (smoke/standard/comprehensive/red-team), and hook harness evals | Write; GitHub: issue_write; Claude in Chrome: tabs_context_mcp, tabs_create_mcp, tabs_close_mcp, navigate, find, form_input, get_page_text, read_page, javascript_tool, gif_creator, read_console_messages, read_network_requests | sonnet | /cks:browse, /cks:evals, /cks:harness-eval, /cks:next, /cks:uat; skills: attractor, autoresearch, prd, routines, sleep-cycle; pipelines: sprint | sub-agent |
| `cks:debugger` | Root-cause diagnosis and the minimal fix: classifies the failure, traces the causal chain to where bad state was introduced, applies a scoped edit, verifies, and closes the issue | Edit (no Write); AskUserQuestion; GitHub: issue_write, issue_read, list_issues; Supabase: execute_sql, list_tables; Sentry: authenticate, complete_authentication | opus | /cks:db, /cks:debug, /cks:fix, /cks:investigate, /cks:triage; skills: attractor, debug, evals, routines; pipelines: assess, db, sprint | sub-agent |
| `cks:shipper` | Takes verified work to users: build, commit, push, PR, CI watch, changelog and version bump, environment promotion dev → staging → RC → production with quality gates and health checks | Write + Edit; AskUserQuestion; GitHub (all tools); Vercel (all tools) | sonnet | /cks:changelog, /cks:deploy, /cks:go, /cks:next, /cks:setup-webhooks, /cks:ship; skills: debug, prd; pipelines: sprint | sub-agent |
| `cks:historian` | The workforce's memory: persists REMEMBER blocks, maintains the wiki with OKF frontmatter, curates validated learnings by PR, runs retrospectives, drafts improvement proposals from dispatch traces, reviews sleep-cycle proposals, and writes the session journal and user profile | Write + Edit | sonnet | /cks:cks-wiki, /cks:eod, /cks:evolve, /cks:gate, /cks:handoff, /cks:honcho, /cks:improve, /cks:memory, /cks:new, /cks:retro, /cks:review, /cks:save-context; skills: chief-of-staff, loop | sub-agent |
| `cks:marketer` | One marketing role — loads the persona the brief needs (copy, brand, paid, SEO/GEO/AEO, creative, analytics, outbound prospecting, claims compliance) and runs campaigns end to end | Write; AskUserQuestion, WebSearch, WebFetch; Ahrefs (all tools); Apollo.io (all tools); Vibe Prospecting (all tools) | opus | /cks:analytics, /cks:copy, /cks:creative, /cks:luv, /cks:market, /cks:marketing, /cks:marketing-analytics, /cks:marketing-build, /cks:seo-audit; skills: campaign, kickstart | sub-agent |
| `cks:operator` | Setup and integrations — bootstrap and adopt scaffolding, Agentic OS, channels (Telegram, Slack), voice via Telnyx, schedules and heartbeats, sandbox policy, control-plane writes, migrations, plugin dependencies | Write + Edit; AskUserQuestion, CronCreate; Telnyx (all tools); Supabase (all tools) | sonnet | /cks:adopt, /cks:agentic-os, /cks:bootstrap, /cks:caveman, /cks:codegraph, /cks:control-plane, /cks:heartbeat, /cks:hermes, /cks:hq, /cks:migrate, /cks:peers, /cks:sandbox, /cks:schedule, /cks:slack, /cks:telegram, /cks:virginize, /cks:voice; skills: kickstart, loop, sleep-cycle | sub-agent |
| `cks:writer` | Generates project documentation from the codebase (API, architecture, components, onboarding, coding-agent llms.txt) and drafts contracts (MSA, SOW, NDA) from templates | Write | haiku | /cks:docs; skills: prd | sub-agent |
<!-- generated:roster end -->

The table is generated by `scripts/generate-docs.sh` from `agents/*.md` frontmatter and the
dispatch graph; intent words live in the verb table below. Autonomy is per routine
(`skills/routines/SKILL.md`): a role suggests, drafts or edits inside its write scope and never
executes a gated action. A message that matches several rows ("plan and sprint") is low
confidence: clarify before dispatching.

## Role-first verb table

| Intent words | Dispatch | Brief opens with |
|---|---|---|
| "status", "what's happening", "where are we", "progress" | none — read `.prd/PRD-STATE.md`, answer (Converse) | — |
| "track this", "open an issue", "board", "what's on the board" | `cks:project-manager` | `Mode: issues` |
| "remind me", "inbox", "calendar", "meeting prep", "follow up with", "standup" | `cks:assistant` | `Mode: reminders` / `inbox` / `calendar` / `prep` / `daily brief` |
| "cost", "margin", "burn", "budget", "invoice", "pricing model", "payments" | `cks:finops` | `Mode: audit` / `margin` / `invoice` / `burn` / `payments advice` |
| "what's stalling", "audit the rules", "friction", "launch readiness", "health check" | `cks:watchdog` | `Hunt: rules` / `health` / `launch readiness` |
| "logs", "errors in prod", "sentry", "traces", "canary", "who else is working on this" | `cks:observer` | `Mode: logs` / `sentry` / `langsmith` / `canary` |
| "research", "what's out there", "compare", "market", "threats", "news" | `cks:researcher` | `Mode: deep` / `codebase + options` / `market/pricing` / `infra pricing` |
| "create", "start", "new", "build a", "scope", "idea", "concept", "monetize", "pivot" | `cks:strategist` | `Mode: discover` / `intake` / `ideate` / `monetize evaluate` / `pivot` |
| "plan", "design", "architect", "spec out", "ERD", "schema", "design system" | `cks:architect` | `Mode: plan` / `design` / `ERD` / `design system` / `pattern-adr` |
| "sprint", "build", "proceed", "implement", "code it", "refactor", "migrate the schema", "TDD" | `cks:builder` | `Mode: sprint` / `refactor` / `migration` / `TDD` |
| "review the code", "security", "OWASP", "compliance", "contract review", "design fluency" | `cks:reviewer` | `Mode: review` / `security` / `compliance` / `db audit` |
| "test", "verify", "UAT", "evals", "run the suite", "browser check" | `cks:tester` | `Mode: verify` / `UAT` / `evals --tier` / `harness evals` |
| "fix", "debug", "broken", "error", "bug", "triage the issues", "RLS failing" | `cks:debugger` | `Mode: root cause` / `triage` / `fix` / `db diagnose` |
| "deploy", "release", "ship", "go live", "push to prod", "go", "PR", "changelog" | `cks:shipper` | `Mode: go` / `deploy` (gated) / `changelog` / `ship` |
| "retro", "what did we build", "learnings", "remember this", "journal", "wiki" | `cks:historian` | `Mode: retro` / `curate` / `persist REMEMBER` / `handoff/DEVLOG` / `wiki` |
| "campaign", "copy", "ads", "SEO", "launch plan", "content calendar", "brand", "outbound" | `cks:marketer` | `Persona: <skills/marketing/personas>` |
| "set up", "bootstrap", "adopt", "integrate", "telegram", "slack", "voice", "schedule", "sandbox" | `cks:operator` | `Mode: bootstrap` / `scan` / `telegram setup` / `schedule` / `sandbox policy` |
| "docs", "document this", "write the guide", "README", "draft the contract" | `cks:writer` | `workflows/generate.md` / `contracts` |
| "full lifecycle", "run everything", "autonomous", "run the pipeline" | not dispatchable — `/cks:sprint` loads `Skill(skill="cks:attractor")` top-level | — |

## v5 agent → v6 role

Generated from `scripts/agent-map.tsv`. Any spelling (`cks:x`, `x`, `luv:y`) resolves to the
same row. `Skill(...)` targets are orchestrators the founder runs as a command.

<!-- generated:lookup start -->
| v5 `subagent_type` | v6 target | Brief hint |
|---|---|---|
| `cks:aeo-geo-specialist` | `cks:marketer` | Persona: seo-geo-aeo |
| `cks:agentic-os-builder` | `cks:operator` | Mode: agentic-os init |
| `cks:agile-eagle` | `cks:strategist` |  |
| `cks:ahe-evolution-agent` | `cks:historian` |  |
| `cks:ai-marketer` | `cks:marketer` |  |
| `cks:analytics-tracker` | `cks:marketer` | Mode: analytics |
| `cks:architecture-generator` | `cks:architect` |  |
| `cks:assess-runner` | `Skill(skill="cks:attractor")` |  |
| `cks:attractor-runner` | `Skill(skill="cks:attractor")` |  |
| `cks:autoresearch-runner` | `Skill(skill="cks:autoresearch")` |  |
| `cks:bootstrap-generator` | `cks:operator` | Mode: bootstrap (HQ MODE for /cks:hq) |
| `cks:bootstrap-scanner` | `cks:operator` | Mode: scan |
| `cks:brand-marketer` | `cks:marketer` | Persona: brand-strategist |
| `cks:browser` | `cks:tester` | Mode: browser flows |
| `cks:campaign-orchestrator` | `cks:marketer` | workflows/campaign.md |
| `cks:canary-monitor` | `cks:observer` | Mode: canary |
| `cks:caveman-speaker` | `cks:operator` |  |
| `cks:cccs-intel-monitor` | `cks:researcher` |  |
| `cks:changelog-generator` | `cks:shipper` | Mode: changelog |
| `cks:chief-of-staff` | `cks:chief-of-staff` | unchanged (v6 role) |
| `cks:ciso` | `cks:reviewer` | Mode: security, cross-repo |
| `cks:code-simplifier` | `cks:builder` | Mode: simplify |
| `cks:compliance-advisor` | `cks:reviewer` | Mode: compliance (references/canada.md) |
| `cks:concept-orchestrator` | `Skill(skill="cks:concept-evaluation")` |  |
| `cks:concept-pillar-worker` | `cks:strategist` | Mode: concept pillar (one per dispatch) |
| `cks:control-plane-agent` | `cks:operator` | Mode: control plane |
| `cks:coordination-agent` | `cks:observer` |  |
| `cks:copywriter` | `cks:marketer` | Persona: long-form-copywriter or ads-copywriter |
| `cks:cost-analyzer` | `cks:finops` | workflows/cost-audit.md |
| `cks:cost-researcher` | `cks:researcher` | Mode: infra pricing |
| `cks:db-debugger` | `cks:debugger` | Mode: db diagnose |
| `cks:db-erd` | `cks:architect` | Mode: ERD |
| `cks:db-fixer` | `cks:debugger` | Mode: db-fix |
| `cks:db-investigator` | `cks:reviewer` | Mode: db audit (workflows/supabase-audit.md) |
| `cks:db-migration` | `cks:builder` | Mode: migration |
| `cks:debugger` | `cks:debugger` | unchanged (v6 role) |
| `cks:debugger-worker` | `cks:debugger` | Mode: fix, one file-scope group |
| `cks:deep-researcher` | `cks:researcher` | multi-hop; last30days first |
| `cks:deployer` | `cks:shipper` | Mode: deploy (gated) |
| `cks:design-fluency-reviewer` | `cks:reviewer` | Mode: design fluency |
| `cks:design-system-generator` | `cks:architect` |  |
| `cks:doc-generator` | `cks:writer` | workflows/generate.md |
| `cks:ecosystem-learner` | `cks:researcher` |  |
| `cks:ecosystem-watcher` | `cks:researcher` |  |
| `cks:evals-runner` | `cks:tester` | Mode: evals --tier |
| `cks:expert-builder` | `cks:builder` |  |
| `cks:expert-debugger` | `cks:debugger` | Mode: root cause |
| `cks:expert-product` | `cks:strategist` |  |
| `cks:expert-specialist` | `cks:strategist` |  |
| `cks:factory-runner` | `Skill(skill="cks:github-issues")` |  |
| `cks:feature-cataloger` | `cks:strategist` | Mode: catalog features |
| `cks:gatekeeper` | `cks:watchdog` |  |
| `cks:github-project-setup-agent` | `cks:operator` | Mode: board setup |
| `cks:go-runner` | `cks:shipper` | workflows/go.md |
| `cks:grill-me-interviewer` | `cks:strategist` | Mode: grill |
| `cks:harness-eval-runner` | `cks:tester` | Mode: harness evals |
| `cks:health-checker` | `cks:watchdog` | Hunt: health |
| `cks:heartbeat-agent` | `cks:operator` | → skills/routines |
| `cks:hermes-readiness` | `cks:operator` | Mode: hermes readiness |
| `cks:honcho-integrator` | `cks:historian` |  |
| `cks:improvement-agent` | `cks:historian` | Mode: improvement proposals |
| `cks:investigator` | `cks:debugger` | Mode: triage scan → issue queue |
| `cks:kickstart-brand` | `cks:strategist` | Mode: brand brief |
| `cks:kickstart-designer` | `cks:architect` | Mode: design system |
| `cks:kickstart-feature-scope` | `cks:strategist` | Mode: feature scope |
| `cks:kickstart-handoff` | `cks:operator` | Mode: scaffold handoff |
| `cks:kickstart-ideator` | `cks:strategist` | Mode: ideate |
| `cks:kickstart-intake` | `cks:strategist` | Mode: intake |
| `cks:kickstart-orchestrator` | `Skill(skill="cks:kickstart")` |  |
| `cks:kickstart-validate` | `cks:strategist` | Mode: validate |
| `cks:langsmith-observer` | `cks:observer` | Mode: langsmith |
| `cks:launch-readiness` | `cks:watchdog` | Hunt: launch readiness |
| `cks:launch-strategist` | `cks:marketer` | Mode: launch |
| `cks:learnings-curator` | `cks:historian` | Mode: curate (PR) |
| `cks:log-reader` | `cks:observer` | Mode: logs |
| `cks:loop-cost-monitor` | `Skill(skill="cks:loop")` |  |
| `cks:loop-designer` | `Skill(skill="cks:loop")` |  |
| `cks:loop-health-checker` | `Skill(skill="cks:loop")` |  |
| `cks:loop-orchestrator` | `Skill(skill="cks:loop")` |  |
| `cks:loop-runner` | `Skill(skill="cks:loop")` |  |
| `cks:loop-triage-curator` | `Skill(skill="cks:loop")` |  |
| `cks:luv-ads-copywriter` | `cks:marketer` | Persona: ads-copywriter |
| `cks:luv-agent-browser` | `cks:tester` |  |
| `cks:luv-ai-tooling-engineer` | `cks:builder` |  |
| `cks:luv-alan-sharpe` | `cks:marketer` | Persona: alan-sharpe |
| `cks:luv-api-designer` | `cks:architect` |  |
| `cks:luv-backend-dev` | `cks:builder` |  |
| `cks:luv-brand-strategist` | `cks:marketer` | Persona: brand-strategist |
| `cks:luv-ceo` | `cks:marketer` | Persona: marketing-director |
| `cks:luv-cicd` | `cks:shipper` |  |
| `cks:luv-cmo` | `cks:marketer` | Persona: campaign-lead |
| `cks:luv-cto` | `cks:builder` |  |
| `cks:luv-data-engineer` | `cks:builder` |  |
| `cks:luv-data-scientist` | `cks:marketer` | Persona: data-scientist |
| `cks:luv-database-auth-engineer` | `cks:builder` |  |
| `cks:luv-debugger` | `cks:debugger` |  |
| `cks:luv-designer` | `cks:architect` | Persona: designer |
| `cks:luv-devops` | `cks:shipper` |  |
| `cks:luv-fin-ops` | `cks:finops` | finops |
| `cks:luv-frontend-dev` | `cks:builder` |  |
| `cks:luv-full-stack-dev` | `cks:builder` |  |
| `cks:luv-growth-revenue-strategist` | `cks:marketer` | Persona: growth-revenue-strategist |
| `cks:luv-landing-page-dev` | `cks:builder` |  |
| `cks:luv-legal` | `cks:reviewer` | Persona: claims-compliance |
| `cks:luv-linkedin-ads-specialist` | `cks:marketer` | Persona: linkedin-ads-specialist |
| `cks:luv-long-form-copywriter` | `cks:marketer` | Persona: long-form-copywriter |
| `cks:luv-meta-ads-specialist` | `cks:marketer` | Persona: meta-ads-specialist |
| `cks:luv-mobile-app-dev` | `cks:builder` |  |
| `cks:luv-mythos` | `cks:reviewer` | Persona: brand-security |
| `cks:luv-n8n-automation` | `cks:operator` |  |
| `cks:luv-paid-media-manager` | `cks:marketer` | Persona: paid-media-manager |
| `cks:luv-photo-creator` | `cks:marketer` | Persona: photo-creator |
| `cks:luv-qa-engineer` | `cks:tester` |  |
| `cks:luv-seo-geo-aeo` | `cks:marketer` | Persona: seo-geo-aeo |
| `cks:luv-strategist` | `cks:marketer` | Persona: strategist |
| `cks:luv-tech-lead` | `cks:architect` |  |
| `cks:luv-uat-engineer` | `cks:tester` |  |
| `cks:luv-video-creator` | `cks:marketer` | Persona: video-creator |
| `cks:luv-video-producer` | `cks:marketer` | Persona: video-producer |
| `cks:memory-agent` | `cks:historian` | Mode: persist REMEMBER |
| `cks:migrator` | `cks:operator` | Mode: migrate |
| `cks:monetize-discoverer` | `cks:strategist` | Mode: monetize discover |
| `cks:monetize-evaluator` | `cks:strategist` | Mode: monetize evaluate |
| `cks:monetize-reporter` | `cks:strategist` | Mode: monetize report |
| `cks:monetize-researcher` | `cks:researcher` | Mode: market/pricing research |
| `cks:monetize-roadmap` | `cks:strategist` | Mode: monetize roadmap |
| `cks:no-code-specialist` | `cks:builder` |  |
| `cks:observability-agent` | `cks:observer` | Mode: cost/latency |
| `cks:online-marketer` | `cks:marketer` |  |
| `cks:payment-advisor` | `cks:finops` | Mode: payments advice |
| `cks:peer-coordinator` | `cks:observer` |  |
| `cks:persona-interviewer` | `cks:strategist` |  |
| `cks:personas-agent` | `cks:strategist` |  |
| `cks:pivot-analyzer` | `cks:strategist` | Mode: pivot |
| `cks:prd-designer` | `cks:architect` | Mode: design (DESIGN.md) |
| `cks:prd-discoverer` | `cks:strategist` | Mode: discover (skills/prd/workflows/discover-phase) |
| `cks:prd-executor` | `cks:builder` | Mode: sprint from PLAN.md; writes SUMMARY.md |
| `cks:prd-executor-worker` | `cks:builder` | one task group per dispatch |
| `cks:prd-orchestrator` | `Skill(skill="cks:attractor")` |  |
| `cks:prd-planner` | `cks:architect` | Mode: plan (PLAN.md) |
| `cks:prd-refactorer` | `cks:builder` | Mode: refactor |
| `cks:prd-researcher` | `cks:researcher` | Mode: codebase + options research |
| `cks:prd-verifier` | `cks:tester` | Mode: verify; writes VERIFICATION.md + CONFIDENCE.md |
| `cks:printing-press-runner` | `cks:builder` |  |
| `cks:product-marketer` | `cks:marketer` | Persona: strategist |
| `cks:project-manager` | `cks:project-manager` | unchanged (v6 role) |
| `cks:reminder` | `cks:assistant` | Mode: reminders |
| `cks:remotion-specialist` | `cks:builder` |  |
| `cks:retrospective` | `cks:historian` | Mode: retro |
| `cks:reviewer` | `cks:reviewer` | unchanged (v6 role) |
| `cks:rules-auditor` | `cks:watchdog` | Hunt: rules |
| `cks:sandbox-agent` | `cks:operator` | Mode: sandbox policy |
| `cks:scale-advisor` | `cks:architect` |  |
| `cks:scheduler` | `cks:operator` | → skills/routines (register via chief of staff) |
| `cks:security-auditor` | `cks:reviewer` | Mode: security (OWASP) |
| `cks:sentry-observer` | `cks:observer` | Mode: sentry |
| `cks:seo-strategist` | `cks:marketer` | Persona: seo-geo-aeo |
| `cks:session-journalist` | `cks:historian` | Mode: handoff/DEVLOG |
| `cks:session-loader` | `Skill(skill="cks:chief-of-staff")` |  |
| `cks:ship-runner` | `cks:shipper` | Mode: ship |
| `cks:slack-integrator` | `cks:operator` | Mode: slack setup |
| `cks:sleep-runner` | `Skill(skill="cks:sleep-cycle")` | proposal review via historian |
| `cks:social-content` | `cks:marketer` | Mode: social |
| `cks:sprint-reviewer` | `cks:historian` |  |
| `cks:standup-reader` | `cks:assistant` | Mode: daily brief |
| `cks:tdd-runner` | `cks:builder` | Mode: TDD |
| `cks:telegram-integrator` | `cks:operator` | Mode: telegram setup |
| `cks:token-optimizer` | `cks:finops` | workflows/cost-audit.md |
| `cks:triage-runner` | `cks:debugger` | Mode: triage |
| `cks:uat-runner` | `cks:tester` | Mode: UAT |
| `cks:user-profiler` | `cks:historian` |  |
| `cks:voice-setup` | `cks:operator` | Mode: voice setup |
| `cks:watchdog` | `cks:watchdog` | unchanged (v6 role) |
| `cks:wiki` | `cks:historian` | Mode: wiki (OKF) |
| `cks:work-hierarchy-manager` | `cks:project-manager` | sole writer of .prd/work-hierarchy.md |
<!-- generated:lookup end -->

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll glob the agents dir and pick by description" | The lookup is this file. Globbing at run time is what produced misrouted dispatches. |
| "The task needs a specialist that no role covers" | Every v5 specialist is a row in the lookup above. Dispatch the role with the hint as the first line of the brief. |
| "The orchestrator skill is the closest match, dispatch it" | Orchestrators cannot be dispatched from a sub-agent. Route to the leaf role or tell the founder to run the command. |
| "No exact match, so general-purpose with no brief" | Step 2 of the dispatch order: a domain skill run by `general-purpose` with an explicit brief. Never a bare dispatch. |
| "This role has Write, so it can also send the email" | Send, invite, post, invoice, pay, production deploy, delete, Routine changes are `GATED:` — the role drafts, you route the gate. |

## Verification

- [ ] Every ACT dispatch names a role from the role table, or `general-purpose` with a skill and brief
- [ ] Every brief opens with `Mode:` or `Persona:` (or the workflow path)
- [ ] No dispatch targets a `Skill(...)` row
- [ ] Multi-row matches were clarified, not guessed
- [ ] Role table row count is 18 and equals the files in `agents/` minus `README.md`
