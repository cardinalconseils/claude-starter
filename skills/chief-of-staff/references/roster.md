# Roster — who to dispatch, and where each agent lands in v6

The chief of staff resolves every ACT item against this file. It replaces the old
instruction to glob `.claude/agents/*.md` and read descriptions at run time: the lookup
is here, generated from `agents/*.md` (`subagent_type` + `description`). When an agent
is added or removed, this table is regenerated with it.

Two tables. The first maps **intent words** to the agent to dispatch today and the v6
role that absorbs it. The second lists **every current agent** with its v6 role, so a
dispatch written today already names the role it will become.

Roles (18): chief-of-staff, project-manager, assistant, finops, watchdog, observer,
researcher, strategist, architect, builder, reviewer, tester, debugger, shipper,
historian, marketer, operator, writer. Agents marked **→ skill (SKILL-ORCHESTRATOR)**
are orchestrators that need `Agent` themselves; they cannot be dispatched from anywhere
and are loaded top-level by their own command (`Skill(skill="cks:<domain>")`) — never
route work to them.

## Role-first verb table

| Intent words | Dispatch today | v6 role |
|---|---|---|
| "status", "what's happening", "where are we", "progress" | none — read `.prd/PRD-STATE.md`, answer (Converse) | chief-of-staff |
| "track this", "open an issue", "board", "what's on the board" | `cks:project-manager` | project-manager |
| "remind me", "inbox", "calendar", "meeting prep", "follow up with" | `cks:reminder`, `cks:standup-reader` | assistant |
| "cost", "margin", "burn", "budget", "invoice", "pricing model" | `cks:cost-analyzer`, `cks:payment-advisor`, `cks:token-optimizer` | finops |
| "what's stalling", "audit the rules", "friction", "launch readiness", "health check" | `cks:watchdog`, `cks:rules-auditor`, `cks:launch-readiness`, `cks:health-checker` | watchdog |
| "logs", "errors in prod", "sentry", "traces", "who else is working on this" | `cks:sentry-observer`, `cks:log-reader`, `cks:langsmith-observer`, `cks:peer-coordinator` | observer |
| "research", "what's out there", "compare", "market", "threats", "news" | `cks:deep-researcher`, `cks:prd-researcher`, `cks:monetize-researcher`, `cks:cccs-intel-monitor` | researcher |
| "create", "start", "new", "build a", "i want to make", "scope", "idea", "concept", "monetize", "pivot" | `cks:prd-discoverer`, `cks:kickstart-intake`, `cks:kickstart-ideator`, `cks:monetize-evaluator`, `cks:pivot-analyzer` | strategist |
| "plan", "design", "architect", "spec out", "ERD", "schema", "design system" | `cks:prd-planner`, `cks:architecture-generator`, `cks:db-erd`, `cks:design-system-generator` | architect |
| "sprint", "build", "proceed", "implement", "execute", "code it", "refactor", "migrate the schema", "TDD" | `cks:prd-executor`, `cks:prd-refactorer`, `cks:db-migration`, `cks:tdd-runner` | builder |
| "review the code", "security", "OWASP", "compliance", "contract review", "design fluency" | `cks:reviewer`, `cks:security-auditor`, `cks:compliance-advisor`, `cks:design-fluency-reviewer` | reviewer |
| "test", "verify", "UAT", "evals", "run the suite", "browser check" | `cks:prd-verifier`, `cks:uat-runner`, `cks:evals-runner`, `cks:browser` | tester |
| "fix", "debug", "broken", "error", "bug", "triage the issues", "RLS failing" | `cks:debugger`, `cks:investigator`, `cks:db-debugger`, `cks:db-fixer` | debugger |
| "deploy", "release", "ship", "go live", "push to prod", "go", "push", "PR", "commit and push", "changelog" | `cks:deployer`, `cks:go-runner`, `cks:ship-runner`, `cks:changelog-generator` | shipper |
| "review", "retro", "what did we build", "learnings", "remember this", "journal", "wiki" | `cks:sprint-reviewer`, `cks:retrospective`, `cks:learnings-curator`, `cks:memory-agent`, `cks:wiki` | historian |
| "campaign", "copy", "ads", "SEO", "launch plan", "content calendar", "brand", "outbound" | `cks:campaign-orchestrator`, `cks:copywriter`, `cks:online-marketer`, `cks:product-marketer`, `cks:social-content` | marketer |
| "set up", "bootstrap", "adopt", "integrate", "telegram", "slack", "voice", "schedule", "sandbox", "control plane" | `cks:bootstrap-scanner`, `cks:telegram-integrator`, `cks:slack-integrator`, `cks:voice-setup`, `cks:scheduler`, `cks:sandbox-agent` | operator |
| "docs", "document this", "write the guide", "README", "hand-off manual", "caveman this" | `cks:doc-generator`, `cks:caveman-speaker` | writer |
| "full lifecycle", "run everything", "autonomous", "run the pipeline" | not dispatchable — `/cks:sprint` loads `Skill(skill="cks:attractor")` top-level | → skill |

A message can match several rows ("plan and sprint"). That is low confidence: clarify
before dispatching.

## Every current agent → v6 role

| subagent_type | Purpose | v6 role |
|---|---|---|
| `cks:aeo-geo-specialist` | AEO and GEO specialist for AI search visibility | marketer |
| `cks:agentic-os-builder` | Scaffolds the three-layer Agentic OS (architecture + memory + observability) inside any project. | operator |
| `cks:agile-eagle` | PRE-FLIGHT specialist — maps dependencies, risks, done criteria, gotchas, phase order, and instrumentation… | architect |
| `cks:ahe-evolution-agent` | AHE Evolution Agent — reads telemetry, governance, and harness-eval signals to propose targeted golden case… | tester |
| `cks:ai-marketer` | AI marketing specialist — AI citations, AEO/GEO optimization, llms.txt, prompt-matched content strategy, en… | marketer |
| `cks:analytics-tracker` | Analytics tracking specialist — sets up GA4 event taxonomy, GTM configuration, and ad pixel checklist; audi… | marketer |
| `cks:architecture-generator` | Generates or refreshes project-level ARCHITECTURE.md and ADRs from sprint TDDs and existing decisions. | architect |
| `cks:assess-runner` | Attractor assessment runner — drives the CKS assessment pipeline (health, code review, security, debug tria… | → skill (SKILL-ORCHESTRATOR) |
| `cks:attractor-runner` | Attractor pipeline runner — drives the CKS sprint lifecycle as a DOT graph, dispatching agents per node, se… | → skill (SKILL-ORCHESTRATOR) |
| `cks:autoresearch-runner` | Autonomous keep/discard loop — edits a target file, measures a metric each iteration, keeps improvements an… | → skill (SKILL-ORCHESTRATOR) |
| `cks:bootstrap-generator` | Bootstrap Phase 2 — generates CLAUDE.md, .prd/, .claude/rules/, .context/, MCP config, and deploy config fr… | operator |
| `cks:bootstrap-scanner` | Bootstrap Phase 1 — scans codebase, detects stack, runs guided intake with pre-filled answers from scan res… | operator |
| `cks:brand-marketer` | Brand marketing specialist — domain authority benchmarking, backlink gap analysis, citation building, brand… | marketer |
| `cks:browser` | Browser specialist — UAT mode: tests sprint features, opens GitHub issues. | tester |
| `cks:campaign-orchestrator` | Campaign orchestrator — runs intake Q&A, selects and chains marketing specialists, optionally loads Apollo… | marketer (chaining half → skill) |
| `cks:canary-monitor` | Post-deploy browser verification agent — opens URL, checks console errors, reports pass/fail | observer |
| `cks:caveman-speaker` | Rewrites prose into caveman speak — drops articles, filler, hedging — preserves 100% technical accuracy. | writer |
| `cks:cccs-intel-monitor` | CCCS threat intelligence monitor — fetches Canadian Centre for Cyber Security alerts and advisories, diffs… | researcher |
| `cks:changelog-generator` | Auto-generates CHANGELOG.md entries from git history with conventional commit categorization | shipper |
| `cks:chief-of-staff` | Chief of staff — triages inbound work, decides what deserves attention, dispatches specialist agents, and e… | chief-of-staff |
| `cks:ciso` | Personal CISO agent for PMC — audits repos and infra for supply chain attacks, secrets exposure, RLS gaps,… | reviewer |
| `cks:code-simplifier` | Simplifies code for clarity and maintainability while preserving exact behavior. | builder |
| `cks:compliance-advisor` | Compliance surface advisor — scans CONTEXT.md for GDPR, PCI, HIPAA, SOC 2 triggers at Phase 1; validates re… | reviewer |
| `cks:concept-orchestrator` | CKS concept feasibility orchestrator — detects plugin vs project mode, classifies concept, runs brainstormi… | → skill (SKILL-ORCHESTRATOR) |
| `cks:concept-pillar-worker` | Scores one feasibility pillar (business-value / tech-fit / data-impact) with file-level evidence. | strategist |
| `cks:control-plane-agent` | CKS v6 control plane management — health status, backup, restore, sync-queue drain, and reset. | operator |
| `cks:coordination-agent` | Multi-session awareness — show active agent sessions, claimed resources, and conflicts in the control plane… | observer |
| `cks:copywriter` | Copywriting specialist — writes hero copy, email sequences, ad copy, and landing pages using proven framewo… | marketer |
| `cks:cost-analyzer` | Cost analysis agent — builds unit economics models, calculates margins, and produces cost breakdown from ra… | finops |
| `cks:cost-researcher` | Cost research agent — researches real-world pricing for AI/ML inference, infrastructure, third-party servic… | researcher |
| `cks:db-debugger` | Database debugger — traces Supabase errors, RLS failures, slow queries, and edge function DB issues. | debugger |
| `cks:db-erd` | Database ERD generator — creates Mermaid entity-relationship diagrams from live Supabase schema. | architect |
| `cks:db-fixer` | Database fixer — proposes and applies fixes for RLS gaps, schema issues, and advisor warnings. | debugger |
| `cks:db-investigator` | Database investigator — audits Supabase schema, RLS policies, migrations, and security advisors. | reviewer |
| `cks:db-migration` | Database migration agent — generates schema changes, validates migrations, tests rollbacks. | builder |
| `cks:debugger-worker` | Lightweight parallel fix worker — diagnoses a single GitHub issue, applies the fix, runs verification, clos… | debugger |
| `cks:debugger` | Diagnoses app runtime errors, GitHub issues, and CKS plugin issues — traces code paths, reads logs, identif… | debugger |
| `cks:deep-researcher` | Autonomous multi-hop research specialist. | researcher |
| `cks:deployer` | Phase 5: Release Management agent — manages environment promotion (Dev → Staging → RC → Production), valida… | shipper |
| `cks:design-fluency-reviewer` | Visual-slop linter and design-fluency reviewer — runs npx impeccable detect on UI output, maps findings to… | reviewer |
| `cks:design-system-generator` | Generates a full DESIGN.html — interactive HTML design system with rendered components, brand-adapted nav,… | architect |
| `cks:doc-generator` | Generates project documentation from codebase analysis — API docs, architecture, component docs, onboarding… | writer |
| `cks:ecosystem-learner` | Ecosystem bulletin ingestion agent — classifies news articles by priority rubric, gates HIGH on human confi… | researcher |
| `cks:ecosystem-watcher` | Scheduled ecosystem monitoring agent — weekly scan of tech news sources, title-level diff against seen_titl… | researcher |
| `cks:evals-runner` | LLM output quality evaluation agent — runs smoke, standard, or comprehensive eval suites against memory, AP… | tester |
| `cks:expert-builder` | Builder expert — pragmatic architecture, implementation, deployment. | builder |
| `cks:expert-debugger` | Debugger expert — systematic root cause analysis, testing strategy, performance. | debugger |
| `cks:expert-product` | Product expert — user-centered features, UX, prioritization, metrics. | strategist |
| `cks:expert-specialist` | Specialist expert dispatcher — loads named specialist skill for deep-dive domain guidance across 22 experts. | → skill (experts, loaded by the role named in the brief) |
| `cks:factory-runner` | AFK software factory runner — reads labeled GitHub Issues, orchestrates the full CKS pipeline per issue, op… | → skill (SKILL-ORCHESTRATOR) |
| `cks:feature-cataloger` | Feature discovery for cks:adopt — scans codebase routes, directories, and git history to propose feature cl… | strategist |
| `cks:gatekeeper` | Skill lifecycle gatekeeper — reviews candidate skills in quarantine, runs format/conflict/scope checks, alw… | historian |
| `cks:github-project-setup-agent` | Runs the GitHub Project Kanban setup wizard — detects repo identity, creates a 6-column project, writes own… | operator |
| `cks:go-runner` | Quick action runner — commit, PR, dev, build, start across all languages. | shipper (fan-out half → skill) |
| `cks:grill-me-interviewer` | Relentless plan/design interrogator — one question at a time, recommends an answer per question, explores c… | strategist |
| `cks:harness-eval-runner` | Runs hook fixture evals against CKS harness handlers — feeds G2 AHE Evolution Agent validation signal | tester |
| `cks:health-checker` | Project health diagnostic — env vars, TODOs, tests, PRD state, git hygiene, dependency audit | watchdog |
| `cks:heartbeat-agent` | CKS v6 heartbeat engine — registers agents in the heartbeats table, creates CronCreate schedules, reports h… | operator |
| `cks:hermes-readiness` | Hermes Mode readiness agent — checks and initializes the chief-of-staff channel brain, user memory isolatio… | operator |
| `cks:honcho-integrator` | Wires the optional self-hosted Honcho memory layer into CKS — scaffolds the local docker instance, register… | operator |
| `cks:improvement-agent` | Analyzes session patterns, gotchas, RAID log, and learnings to generate improvement proposals for rules, pe… | historian |
| `cks:investigator` | Scans broadly for issues across a project or targeted area, files each finding to GitHub, and returns a pri… | debugger |
| `cks:kickstart-brand` | Kickstart Phase 4 — brand identity extraction. | marketer |
| `cks:kickstart-designer` | Kickstart Phase 5 — design artifact generation. | architect |
| `cks:kickstart-feature-scope` | Kickstart Phase 3.5 — feature discovery and MVP scoping. | strategist |
| `cks:kickstart-handoff` | Kickstart Phase 6 — project scaffolding and .claude/ personalization. | operator |
| `cks:kickstart-ideator` | Kickstart Phase 0 — idea brainstorming and refinement. | strategist |
| `cks:kickstart-intake` | Kickstart Phase 1+1b — guided intake Q&A and project composition. | strategist |
| `cks:kickstart-orchestrator` | Kickstart lifecycle orchestrator — sequences ideation, intake, research, monetize, brand, design, and hando… | → skill (SKILL-ORCHESTRATOR) |
| `cks:kickstart-validate` | Idea validation artifact generator — reads .kickstart/ideation.md refined pitch and produces 5 files in .ki… | strategist |
| `cks:langsmith-observer` | Analyzes LangSmith traces — surfaces errors, latency outliers, and token cost anomalies in LLM apps | observer |
| `cks:launch-readiness` | Pre-launch readiness checker — runs the full shipping checklist and reports blocking issues by maturity sta… | watchdog |
| `cks:launch-strategist` | Launch strategist — builds 8-week pre/launch/post campaign plan adapted to maturity stage (Prototype/Pilot/… | marketer |
| `cks:learnings-curator` | Daily pass over a source repository — finds material added since the last run, converts it into validated l… | historian |
| `cks:log-reader` | Queries application logs from auto-detected platforms — Vercel, Railway, Cloudflare, GCP, Docker, local files | observer |
| `cks:loop-cost-monitor` | Reads health.jsonl run count, applies static $-per-run estimate. | → skill (SKILL-ORCHESTRATOR) |
| `cks:loop-designer` | Interviews user on six-part loop composition, produces .loops/{slug}/LOOP-DESIGN.md with stop condition, au… | → skill (SKILL-ORCHESTRATOR) |
| `cks:loop-health-checker` | Reads health.jsonl run history, flags anomalies (consecutive failures, error rate spike, missing entries). | → skill (SKILL-ORCHESTRATOR) |
| `cks:loop-orchestrator` | Routes /cks:loop sub-commands to the correct agent: design→loop-designer, run→loop-runner, health→loop-heal… | → skill (SKILL-ORCHESTRATOR) |
| `cks:loop-runner` | Executes one iteration of a loop. | → skill (SKILL-ORCHESTRATOR) |
| `cks:loop-triage-curator` | Reads loop output files, scores findings by severity (high/medium/low), writes dated triage report to .tria… | → skill (SKILL-ORCHESTRATOR) |
| `cks:luv-ads-copywriter` | Writes high-converting short-form ad copy for Google, Meta, and LinkedIn — headlines, CTAs, email subject l… | marketer |
| `cks:luv-agent-browser` | Handles browser automation and web interaction — navigates websites, fills forms, extracts structured data,… | tester |
| `cks:luv-ai-tooling-engineer` | Owns AI model stack, prompt engineering, LLM integrations, agent orchestration, and LLM cost management for… | builder |
| `cks:luv-alan-sharpe` | Writes direct response B2B short-form copy in Alan Sharpe's voice — industrial-strength headlines, professi… | marketer |
| `cks:luv-api-designer` | Designs and maintains API contracts — OpenAPI 3.x specs, GraphQL schemas, versioning strategy, backward com… | architect |
| `cks:luv-backend-dev` | Implements FastAPI routes, MongoDB services, authentication flows, WebSockets, background jobs, and pytest… | builder |
| `cks:luv-brand-strategist` | Brand positioning, mission/vision, community development, key messages, and value proposition — April Dunfo… | marketer |
| `cks:luv-ceo` | Luv Marketing CEO — sets vision, approves strategy, delegates all execution to specialized agents across ma… | → skill (SKILL-ORCHESTRATOR) |
| `cks:luv-cicd` | Owns GitHub Actions workflows, automated deployment pipelines for Vercel/Railway/Supabase, release manageme… | shipper |
| `cks:luv-cmo` | Luv Marketing CMO — orchestrates all marketing execution, coordinates specialists, owns campaign positionin… | → skill (SKILL-ORCHESTRATOR) |
| `cks:luv-cto` | Luv Marketing CTO — owns technical roadmap, AI tooling, architecture decisions, and engineering team coordi… | → skill (SKILL-ORCHESTRATOR) |
| `cks:luv-data-engineer` | Owns data infrastructure, analytics pipelines, tracking implementation, GA4/GTM/CAPI, Looker Studio dashboa… | builder |
| `cks:luv-data-scientist` | Provides quantitative foundation for marketing decisions — campaign analytics, A/B test design, attribution… | marketer |
| `cks:luv-database-auth-engineer` | Owns database architecture and authentication infrastructure — Supabase, MongoDB, Firestore schemas, RLS, m… | architect |
| `cks:luv-debugger` | Diagnoses and resolves bugs, errors, and performance bottlenecks — root cause analysis, reproducible test c… | debugger |
| `cks:luv-designer` | UI/UX designer for PWA, website, and mobile app — wireframes, Figma mockups, design system, WCAG 2.1 AA acc… | architect |
| `cks:luv-devops` | Owns deployment platforms, database infrastructure, secrets management, monitoring, scaling, backups, and s… | shipper |
| `cks:luv-fin-ops` | Manages financial operations, budgeting, cloud and LLM cost optimization, client invoicing, burn rate repor… | finops |
| `cks:luv-frontend-dev` | Builds and maintains PWA and main website — React 19, TypeScript, Tailwind, Service Workers, offline capabi… | builder |
| `cks:luv-full-stack-dev` | Builds full-stack features from database to UI — third-party integrations, admin dashboards, webhooks, even… | builder |
| `cks:luv-growth-revenue-strategist` | Drives GTM design, revenue modeling, pipeline management, CAC/LTV analysis, and conversion rate optimizatio… | marketer |
| `cks:luv-landing-page-dev` | Builds and optimizes landing pages — CRO analysis, A/B testing, page speed, form optimization, GTM/GA4/pixe… | builder |
| `cks:luv-legal` | Provides legal counsel for the agency under Canadian law — contracts, IP, PIPEDA/Quebec Law 25 privacy comp… | reviewer |
| `cks:luv-linkedin-ads-specialist` | Owns LinkedIn Ads strategy, campaign setup, and optimization for B2B clients — audience targeting, Lead Gen… | marketer |
| `cks:luv-long-form-copywriter` | Writes long-form content that educates and converts — blog posts, whitepapers, email sequences, case studie… | marketer |
| `cks:luv-meta-ads-specialist` | Owns full Meta Business Suite strategy across Facebook, Instagram, Messenger, and WhatsApp — CAPI, pixel, r… | marketer |
| `cks:luv-mobile-app-dev` | Builds cross-platform iOS and Android apps in React Native — push notifications, native device features, Ap… | builder |
| `cks:luv-mythos` | Chief Cybersecurity Officer — owns end-to-end security strategy, governance, risk, compliance (SOC 2, ISO 2… | reviewer |
| `cks:luv-n8n-automation` | Designs and builds marketing workflow automations in n8n — lead nurturing, CRM integrations, social schedul… | operator |
| `cks:luv-paid-media-manager` | Owns and optimizes paid advertising campaigns across Meta, Google, and LinkedIn — budget allocation, bid st… | marketer |
| `cks:luv-photo-creator` | Directs and generates commercial photography using OpenAI gpt-image-1 — product photography, campaign image… | marketer |
| `cks:luv-qa-engineer` | Owns quality control across all technical and AI-generated outputs — reviews automation workflows, landing… | tester |
| `cks:luv-seo-geo-aeo` | Owns discoverability across traditional search, generative AI engines, and answer engines — SEO audits, GEO… | marketer |
| `cks:luv-strategist` | Provides competitive intelligence, market analysis, positioning frameworks, and go-to-market strategy — aud… | marketer |
| `cks:luv-tech-lead` | Oversees full development lifecycle — architecture decisions, sprint planning, team coordination, technical… | architect |
| `cks:luv-uat-engineer` | Owns user acceptance testing and Playwright E2E test suites — validates funnels, tracking, forms, mobile re… | tester |
| `cks:luv-video-creator` | Directs and generates AI video content using Kling API — ad creatives, social clips, product demos, and bra… | marketer |
| `cks:luv-video-producer` | Produces video content for marketing channels — product demos, explainers, testimonials, ad creatives, and… | marketer |
| `cks:memory-agent` | View, search, and manage control plane memory — project KB (facts/decisions/gotchas) and session continuity | historian |
| `cks:migrator` | Detects CKS version gaps and migrates project state files to match current plugin version. | operator |
| `cks:monetize-discoverer` | Monetization discovery agent — scans codebase, gathers business context via interactive questions, produces… | strategist |
| `cks:monetize-evaluator` | Monetization evaluation agent — evidence-based tier evaluation of models against context, research, cost, a… | strategist |
| `cks:monetize-reporter` | Monetization report agent — combines all artifacts into an honest, evidence-based business case with assump… | strategist |
| `cks:monetize-researcher` | Market research agent — queries Perplexity API or WebSearch for competitor pricing, market sizing, conversi… | researcher |
| `cks:monetize-roadmap` | Monetization roadmap agent — creates PRD-ready phase briefs from evaluation results and updates project roa… | strategist |
| `cks:no-code-specialist` | No-code/low-code automation specialist — builds, debugs, migrates, and optimizes workflows across n8n, Make… | operator |
| `cks:observability-agent` | Show session cost breakdown, tool-call metrics, and development time analytics from CKS v6 control plane ob… | observer |
| `cks:online-marketer` | Online marketing specialist — keyword gap discovery, funnel architecture, content calendar, email sequences… | marketer |
| `cks:payment-advisor` | Stripe payment advisor — designs idempotent Stripe payment flows, selects the right Stripe product (Checkou… | finops |
| `cks:peer-coordinator` | Session awareness dashboard — shows what all repo sessions are doing, detects conflicts, sends directives t… | observer |
| `cks:persona-interviewer` | Guided interview agent — populates agent-persona skill cards (persona-card, behavior-rules, knowledge-index… | historian |
| `cks:personas-agent` | CKS v6 control plane persona manager — list roster, add new persona files, or edit existing ones via guided… | historian |
| `cks:pivot-analyzer` | Strategic pivot analyst — ingests a research conversation or transcript, extracts the broken assumption and… | strategist |
| `cks:prd-designer` | UX/UI design agent — generates screens via Stitch MCP, creates component specs, manages design iteration an… | architect |
| `cks:prd-discoverer` | Phase 1: Discovery agent — gathers all 11 Elements using AskUserQuestion, researches codebase, produces str… | strategist |
| `cks:prd-executor-worker` | Lightweight implementation worker — executes a single task group from a sprint plan. | builder |
| `cks:prd-executor` | Implementation team lead — reads the sprint plan, splits work into task groups, dispatches parallel executo… | builder |
| `cks:prd-orchestrator` | Full-lifecycle orchestrator — drives the 5-phase cycle (discover → design → sprint → review → release) with… | → skill (SKILL-ORCHESTRATOR) |
| `cks:prd-planner` | Planning agent — takes discovery CONTEXT.md and produces PRD-{NNN}.html and PLAN.html, plus roadmap updates | architect |
| `cks:prd-refactorer` | Refactoring coordinator — phases work into impact analysis, parallel execution workers, and verification. | builder |
| `cks:prd-researcher` | Research agent — investigates codebase architecture, technology options, and implementation approaches to i… | researcher |
| `cks:prd-verifier` | Verification team lead — dispatches parallel test workers for unit/integration/E2E, consolidates results in… | tester |
| `cks:printing-press-runner` | Wraps cli-printing-press to generate a typed Go CLI + MCP server + Claude skill for any external API. | builder |
| `cks:product-marketer` | Product marketing specialist — positioning, ICP, competitive narrative, GTM strategy, messaging hierarchy b… | marketer |
| `cks:project-manager` | Turns dispatched work into GitHub Issues so every task is visible on the kanban board with an owner, a desc… | project-manager |
| `cks:reminder` | Saves due-dated reminders under per-user memory and registers the recurring proactive wake on the first rem… | assistant |
| `cks:remotion-specialist` | Remotion video specialist — builds and debugs programmatic videos in React | marketer |
| `cks:retrospective` | Post-ship learning analyst — analyzes completed work to extract conventions, patterns, gotchas, and velocit… | historian |
| `cks:reviewer` | Phase 3 [3d]: Code Review agent — reviews changes for correctness, conventions, security, and design spec a… | reviewer |
| `cks:rules-auditor` | Adherence audit — scans codebase against .claude/rules/ and reports per-rule compliance with grades | watchdog |
| `cks:sandbox-agent` | Leash sandbox setup agent — analyzes project stack and secrets, generates a minimal-privilege Cedar policy… | operator |
| `cks:scale-advisor` | Scaling advisor — reads current architecture + maturity stage, identifies position on the 7-rung scaling la… | architect |
| `cks:scheduler` | Recurring agent setup — interviews user, selects a template (analytics, sentiment, assets, or custom), writ… | operator |
| `cks:security-auditor` | Security scanning agent — OWASP Top 10 checks, secrets detection, dependency audit, auth review, config audit. | reviewer |
| `cks:sentry-observer` | Triages Sentry errors — lists unresolved issues, drills into stack traces, surfaces regressions by release | observer |
| `cks:seo-strategist` | SEO strategist for rank-and-rent local lead generation sites | marketer |
| `cks:session-journalist` | End-of-day journalist — gathers git activity, PRD state, and session learnings to compose a dated DEVLOG en… | historian |
| `cks:session-loader` | Session context loader — reads project state, guardrails, learnings, git context, and displays session brief | chief-of-staff |
| `cks:ship-runner` | Plugin release agent — cleans project docs from working tree, bumps version, commits, pushes, opens PR. | shipper |
| `cks:slack-integrator` | Slack setup wizard — creates .slack/config.json, generates n8n blueprint for slash commands and bot notific… | operator |
| `cks:sleep-runner` | SkillOpt-Sleep orchestrator — harvests session telemetry, replays tasks offline, gates improvements, and st… | → skill (SKILL-ORCHESTRATOR) |
| `cks:social-content` | Social content specialist — builds 30-day content calendar with platform-specific posts (Twitter/X, LinkedI… | marketer |
| `cks:sprint-reviewer` | Phase 4: Sprint Review coordinator — builds sprint summary from artifacts, collects user feedback, runs ret… | historian |
| `cks:standup-reader` | Morning standup — reads DEVLOG, cross-references project state, suggests where to pick up | assistant |
| `cks:tdd-runner` | Test-driven development specialist — runs RED/GREEN/REFACTOR cycles. | builder |
| `cks:telegram-integrator` | Sets up a per-project Telegram agent — this project's own bot, isolated config dir, chief-of-staff channel… | operator |
| `cks:token-optimizer` | Token optimization auditor — analyzes context budget, enabled plugins, MCP servers, compaction strategy, an… | finops |
| `cks:triage-runner` | Triage agent — fetches PRs, branches, and GitHub issues, classifies each by status, presents ACTION REQUIRE… | project-manager |
| `cks:uat-runner` | End-of-feature UAT orchestrator — reads PREFLIGHT.md acceptance criteria and CONTEXT.md DoD, generates UAT… | tester |
| `cks:user-profiler` | Guided interview agent — populates ~/.cks/user-profile.md with the user's personal profile, communication s… | historian |
| `cks:voice-setup` | Voice agent scaffolding — provisions Telnyx AI Assistant, Call Control App, and phone number via Telnyx MCP… | operator |
| `cks:watchdog` | Finds friction nobody reported — rules nothing enforces, assets never used, work that silently stalled, and… | watchdog |
| `cks:wiki` | Read and write wiki pages in the project memory layer (memory/wiki/) | historian |
| `cks:work-hierarchy-manager` | Sole writer for .prd/work-hierarchy.md — creates, moves, closes, activates, and lists Feature/Phase/Task nodes | project-manager |

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll glob the agents dir and pick by description" | The lookup is this file. Globbing at run time is what produced misrouted dispatches. |
| "The orchestrator agent is the closest match, dispatch it" | Orchestrators marked → skill cannot dispatch from a sub-agent. Route to the leaf agent or tell the founder to run the command. |
| "No exact match, so general-purpose with no brief" | Step 2 of the dispatch order: a domain skill run by `general-purpose` with an explicit brief. Never a bare dispatch. |
| "The v6 role column is future-proofing, ignore it" | Name the role in the brief today. When the role file lands, the brief still reads correctly. |

## Verification

- [ ] Every ACT dispatch names an agent from the second table, or `general-purpose` with a skill and brief
- [ ] No dispatch targets a row marked → skill
- [ ] Multi-row matches were clarified, not guessed
- [ ] Row count equals the number of files in `agents/` minus `README.md`
