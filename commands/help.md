---
description: Show all available CKS commands and usage guide
allowed-tools:
  - Read
---

# /cks:help — Available Commands

Display the following help text:

```
CKS — Claude Code Starter Kit
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

LIFECYCLE (idea → shipped):
  /cks:concept [description] Evaluate a concept — brainstorm first, score 3 pillars, Go/Defer/Reject
  /cks:ideate [idea]         Phase 0: Ideation — brainstorm and refine a project idea
  /cks:kickstart             Ideate? → Q&A → research → design → scaffold project
  /cks:new [brief] [--role=R]    Create feature entry → enters Phase 1
  /cks:discover [phase]          Phase 1: Discovery — gather 11 Elements
  /cks:design [phase]            Phase 2: Design — UX flows, API contract, screen gen
  /cks:sprint [args] [--role=R]  Enter Attractor pipeline — Discover → Plan → Implement → Verify → Review → Release → Learnings
  /cks:review [phase]        Phase 4: Review & retro — feedback → iteration decision
  /cks:release [phase]       Phase 5: Release — Dev → Staging → RC → Production
  /cks:rpi                   R-P-I sub-cycle status — gates, artifacts, next action

HIERARCHY:
  /cks:work new|move|close|activate|list   Manage Feature → Phase → Task tree

SESSION RITUALS:
  /cks:standup               Morning resume — recap DEVLOG + load session context + suggest next action
  /cks:handoff               Save session state to .prd/HANDOFF.md for next session
  /cks:resume                New session — read handoff and execute next steps
  /cks:eod                   End of day — log progress to DEVLOG.md

UTILITY:
  /cks:review-rules [--full] Audit codebase against .claude/rules/ guardrails
  /cks:context "topic"       Research a library/API → saves to .context/
  /cks:gate [skill-name]     Skill lifecycle gate — review quarantined candidates, approve → validated/ or reject → archived/
  /cks:research "topic"      Deep multi-hop research → saves to .research/
  /cks:doctor                Project health diagnostic (env, TODOs, tests, git)
  /cks:version               Show installed CKS plugin version, project version, and migration status
  /cks:migrate               Upgrade project state files to match plugin version
  /cks:changelog [--since]   Auto-generate CHANGELOG.md from git history
  /cks:retro [--auto]        Retrospective — extract learnings + propose conventions
  /cks:pivot [transcript]    Strategic pivot — ingest research, extract new direction, update CONTEXT.md
  /cks:status                Unified dashboard: git, build, PRD phase, code health
  /cks:assess                Full codebase assessment — health, review, security, debug triage
  /cks:explore "repo-url"    Investigate a GitHub repo for CKS-adoptable concepts
  /cks:learn <url>           Ingest news/article as ecosystem bulletin
  /cks:cks-wiki [cmd]        Read/write wiki pages in project memory layer
  /cks:triage [--prs|--branches|--issues]  Triage PRs, branches, issues — ACTION REQUIRED per item

AUTOMATION:
  /cks:next                  Auto-detect state → run next step → stop
  /cks:sprint-run            Run CKS sprint lifecycle via Attractor pipeline engine
  /cks:sprint-auto           Autonomous full-session sprint — peers-aware, AI decides at every gate
  /cks:autonomous [--role=R] Run all remaining phases + ship (no interruption)
  /cks:factory               AFK software factory — drain GitHub Issue backlog autonomously
  /cks:bg <command>          Launch any CKS command as a background session
  /cks:schedule [type]       Set up a recurring agent — analytics, sentiment, or asset generation
  /cks:setup-webhooks        Configure GitHub Project Kanban webhook + attractor_mode (v5 onboarding)
  /cks:model [set|reset]     View or change model strategy (opus/sonnet/haiku per agent)
  /cks:persona [--scaffold <path>]   Configure agent persona — role, reasoning, domain knowledge

DESIGN:
  /cks:design-system [URL]   Generate DESIGN.html — interactive HTML design system with rendered swatches and nav

QUALITY:
  /cks:simplify [file|all]   Simplify code for clarity — preserves behavior, reduces complexity
  /cks:caveman [target] [level]  Caveman mode — compress prose, cut ~65% tokens (lite|full|ultra|wenyan)
  /cks:evals [--type] [--tier]  Run LLM output quality evals — memory, API, tool-use, regression, safety
  /cks:harness-eval [--hook=<name>] [--tier]  Run hook fixture evals — validate handler exit codes + output patterns
  /cks:evolve                AHE Evolution Agent — reads harness signals, proposes golden cases for hook validation
  /cks:launch-check [stage]  Pre-launch readiness — runs shipping checklist by maturity stage
  /cks:ship [--dry-run]      Plugin release — clean project docs, bump version, commit, push, open PR

OBSERVABILITY:
  /cks:observe               Sweep: detect all configured log sources
  /cks:observe --logs        Query: pull live logs, filter for errors
  /cks:observe --errors      Triage: Sentry error feed — issues, stack traces, regressions
  /cks:observe --traces      Analyze: LangSmith traces — latency, cost, errors

CONTROL PLANE (v6):
  /cks:control-plane init    Scaffold .cks/control-plane/ — config, personas, RAID log
  /cks:personas              View and manage team roster (list / --add / --edit)
  /cks:heartbeat init <id>   Register heartbeat agent in DB + create CronCreate schedule
  /cks:heartbeat status      Show all agents: last beat, status, cycles missed
  /cks:memory [--facts|--decisions|--gotchas|--sessions|--sync]  View and manage project memory KB + session continuity
  /cks:cost [--sessions|--trends|--session <ID>]  Session cost breakdown — dev hours, tool calls, observability metrics
  /cks:agents [--claim|--release|--clean]  Active sessions, claimed resources, conflict detection
  /cks:board-export          Export board state as a committed markdown summary
  /cks:improve [--analyze|--list|--apply <id>|--reject <id>]  Self-improvement loop — scan patterns, propose and apply rule/persona/workflow improvements

MODULES:
  /cks:bootstrap             Adapt .claude/ to project, generate CLAUDE.md
  /cks:adopt                 Mid-development? Adopt CKS into existing codebase
  /cks:preflight [brief]    PRE-FLIGHT — map dependencies, risks, phase order before any build
  /cks:market [discipline] [domain]  Marketing team — product, brand, online, social, AI, launch (Ahrefs + DataForSEO)
  /cks:copy [hero|email|ad|landing|all]      Copywriter — framework-driven copy for any format
  /cks:analytics [setup|audit|report]         Analytics — GA4 events, GTM, pixel checklist
  /cks:agentic-os [init|status|add-domain]  Scaffold Agentic OS — domains + memory + dashboard
  /cks:monetize              Business model evaluation (12 revenue models)
  /cks:monetize-discover     Monetize: discover business context
  /cks:monetize-research     Monetize: research models and benchmarks
  /cks:monetize-evaluate     Monetize: evaluate strategy fit
  /cks:monetize-report       Monetize: generate final report
  /cks:monetize-cost-analysis Monetize: infrastructure cost analysis
  /cks:monetize-roadmap      Monetize: revenue-prioritized roadmap
  /cks:deploy                Deploy to configured environment
  /cks:test [flags]          Run test suite
  /cks:tdd                   RED/GREEN/REFACTOR cycle
  /cks:grill [plan-file]     Grill-me plan interrogator — relentless stress-test with recommended answers
  /cks:review                Code review a PR or file [legacy — use /cks:sprint]
  /cks:uat                   End-of-feature UAT — PREFLIGHT AC + CONTEXT DoD → browser tests → GitHub issues
  /cks:browse                Browser automation
  /cks:seo-audit             Full SEO audit
  /cks:security              Security audit (OWASP, secrets, deps)
  /cks:ciso                  Personal CISO — threat intelligence, supply chain, RLS, secrets, GitHub Actions hardening
  /cks:compliance            Compliance scan — detect GDPR, PCI, HIPAA, SOC 2 obligations
  /cks:scale                 Scale advisor — scaling ladder + next rung recommendation
  /cks:sandbox               Generate Leash Cedar policy — sandbox Claude Code with minimal-privilege rules
  /cks:investigate [area]    Scan for issues → file to GitHub → debug queue
  /cks:db [investigate|fix|debug|erd] Database — schema audit, RLS fix, debug, ERD
  /cks:payments [design|review|idempotency|webhooks|subscriptions|pci] Payment systems guidance
  /cks:debug [error|--issue N|--cks] Debug errors, GitHub issues, or CKS plugin issues
  /cks:expert [builder|product|debugger|specialist <name>] "question"   Invoke an expert persona
  /cks:fix [error]           Quick fix — debug + auto-apply
  /cks:decide                Stop asking — diagnose and act
  /cks:evaluate              Build Process Evaluator feature
  /cks:remotion              Remotion video dev — build, debug, optimize React videos
  /cks:refactor              Safe refactoring with impact analysis
  /cks:map-codebase          Codebase structure analysis
  /cks:codegraph [install|init|index|status|upgrade|uninstall]    CodeGraph MCP — opt-in knowledge graph, ~47% fewer tokens on exploration
  /cks:architecture          Refresh ARCHITECTURE.md — topology diagram, component table, ADR index
  /cks:docs                  Generate API/architecture/component docs
  /cks:optimize              Performance optimization suggestions
  /cks:progress              Feature progress dashboard
  /cks:logs                  View CKS activity logs
  /cks:freeze                Restrict file edits to a specific directory (freeze boundary)
  /cks:unfreeze              Remove the active freeze boundary
  /cks:canary [url]          Post-deploy browser verification — console errors, page failures
  /cks:virginize             Strip project-specific content for starter repo

MARKETING AGENCY (Luv Marketing — fully agentic org chart):
  /cks:luv [task]              CEO entry — delegates to CMO or CTO for any marketing/engineering task
  /cks:marketing [brief]       Any marketing task — CMO routes to right specialist (campaign, copy, brand, IA, page)
  /cks:campaign [type] [brief] Campaign orchestrator — outbound, launch, ABM, content/paid campaigns
  /cks:marketing-build [brief] Build a site, page, or app — CEO coordinates CMO + CTO
  /cks:marketing-analytics [brief]  Performance analysis, A/B tests, attribution, dashboards, tracking setup
  /cks:marketing-dev [brief]   Technical marketing engineering — tracking, automation, integrations, infra

CONVERSATIONAL & INTEGRATIONS:
  /cks:concierge [intent]    Talk to your project — natural language → right CKS workflow
  /cks:hermes [status|init|smoke]  Hermes Mode readiness — always-on channel brain checks
  /cks:remind <when> to <what>  Set/list reminders — proactive brain pushes them when due
  /cks:telegram [setup|service]  Per-project Telegram agent — own bot, isolated config, always-on
  /cks:honcho [setup|validate]   Self-hosted Honcho memory — theory-of-mind layer over file memory
  /cks:slack [setup|notify]  Slack integration — webhook notifications + slash command setup
  /cks:voice [setup|status]  Voice agent setup — Telnyx AI Assistant + Cloudflare Worker, no n8n

HOOKS (automatic):
  SessionStart               Shows PRD status when opening Claude Code
  Stop                       Reminds about uncommitted changes

ROLES (--role flag on /cks:new, /cks:sprint, /cks:autonomous):
  coder     prd, incremental-implementation, testing, debug, simplification (default)
  marketer  ai-marketing, brand-marketing, online-marketing, product-marketing
  analyst   repo-exploration, deep-research, observability, monitoring
  devops    cicd-starter, shipping-checklist, environment-management, security, ciso

PROFILES (set during /cks:bootstrap):
  app                        Versioned, full release ceremony (default)
  website                    No versioning, deploy-on-push
  library                    Strict versioning, publish to registry
  api                        Versioned, endpoint-focused release
  Edit .prd/prd-config.json to change profile or phase modes

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

FULL FLOW (from zero):
  /cks:ideate                Brainstorm first (optional, also works standalone)
  /kickstart                 Ideate? → Idea → design → scaffold
  /cks:new "brief"           Create feature → attractor pipeline handles the rest
    ├── /cks:standup         Load context + recap DEVLOG (every session)
    ├── /cks:sprint          Enter Attractor pipeline (plan → build → review → release)
    ├── /cks:handoff         Save state mid-session or before /compact
    ├── /cks:resume          New session — read handoff and execute (pair with /cks:handoff)
    └── /cks:eod             Log progress at end of day

COLLABORATION:
  /cks:peers                 Session dashboard — what is every session doing?
  /cks:peers setup           Install and configure claude-peers-mcp

AGENTS:
  factory-runner             AFK factory pipeline — reads issue queue, dispatches prd-orchestrator per issue
  peer-coordinator           Cross-session coordination via claude-peers-mcp
  coordination-agent         Multi-session registry — active sessions, claimed resources, conflicts
  prd-orchestrator           Drives full lifecycle
  prd-discoverer             Interactive requirements gathering
  prd-planner                Writes PRDs and execution plans
  prd-executor               Implements code changes
  prd-verifier               Checks acceptance criteria
  prd-researcher             Investigates codebase and technology
  prd-refactorer             Safe refactoring with analysis
  design-system-generator    DESIGN.html generator — interactive design system with rendered components
  deep-researcher            Multi-hop recursive research
  code-simplifier            Simplifies code while preserving behavior
  caveman-speaker            Compresses prose into caveman speak — preserves technical accuracy
  launch-readiness           Pre-launch shipping checklist by maturity stage
  retrospective              Post-ship learning analyst
  db-investigator            Schema + RLS + migration + advisor audit
  db-fixer                   Proposes and applies RLS/schema fixes
  db-debugger                Traces RLS failures, slow queries, DB errors
  db-erd                     Generates Mermaid ERD from live schema
  debugger                   Diagnoses app errors + CKS plugin issues
  tdd-runner                 RED/GREEN/REFACTOR cycle specialist
  session-journalist         End-of-day DEVLOG composer
  payment-advisor            Payment flow design, idempotency, webhooks, PCI compliance
  security-auditor           OWASP, secrets, dependency audit
  ciso                       Personal CISO — PMC-specific threat intel, supply chain, RLS, secrets, GitHub Actions
  sandbox-agent              Leash Cedar policy generator — minimal-privilege sandbox for Claude Code
  doc-generator              API, architecture, component docs
  remotion-specialist        Remotion video development specialist
  kickstart-ideator          Idea brainstorming and refinement
  bootstrap-scanner          Codebase scan + guided intake
  bootstrap-generator        CLAUDE.md, rules, PRD generation
  migrator                   Version-aware project state migration

FILES:
  CLAUDE.md                  Project constitution (150 lines max, updated at sprint-close)
  .claude/rules/             Glob-scoped guardrails (security, testing, database, docs, language)
  .prd/                      Planning state + phase artifacts
  .prd/prd-config.json       Profile, versioning, phase autonomy settings
  DESIGN.html                Interactive design system — rendered swatches, type specimens, mini-site nav
  .prd/specs/                Design specs (brainstorming output)
  .prd/DEVLOG.md             Rolling development journal (newest first)
  .context/                  Persistent research briefs
  .context/config.md         Research source priority + preferences
  .research/                 Deep research reports
  .learnings/                Retrospective insights + adherence reports
  CHANGELOG.md               Auto-generated changelog

CD TIP:
  After shipping, use ralph-loop for continuous deployment:
  /ralph-loop:ralph-loop "monitor PR #{number} and deploy when merged"

LEGACY COMMANDS (v4 — superseded in v5):
  /cks:go                    Replaced by attractor-runner Build node + /cks:sprint dispatch
  /cks:release               Replaced by attractor-runner Release node
  /cks:review                Replaced by attractor-runner SprintReview node
  /cks:board                 Board UI decommissioned in Wave 6; board data now in CKS Console
  /cks:sprint-start          Replaced by /cks:standup (now handles both recap and context loading)
  (sprint-close deleted)     Replaced by attractor-runner auto-close at Release node
```
