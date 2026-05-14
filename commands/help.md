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
  /cks:ideate [idea]         Phase 0: Ideation — brainstorm and refine a project idea
  /cks:kickstart             Ideate? → Q&A → research → design → scaffold project
  /cks:new [brief] [--role=R]    Create feature entry → enters Phase 1
  /cks:discover [phase]          Phase 1: Discovery — gather 11 Elements
  /cks:design [phase]            Phase 2: Design — UX flows, API contract, screen gen
  /cks:sprint [phase] [--role=R] Phase 3: Sprint — plan → build → review → QA → UAT → merge
  /cks:review [phase]        Phase 4: Review & retro — feedback → iteration decision
  /cks:release [phase]       Phase 5: Release — Dev → Staging → RC → Production
  /cks:rpi                   R-P-I sub-cycle status — gates, artifacts, next action

HIERARCHY:
  /cks:work new|move|close|activate|list   Manage Feature → Phase → Task tree

SESSION RITUALS:
  /cks:standup               Morning resume — recap DEVLOG + load session context + suggest next action
  /cks:handoff               Save session state to .prd/HANDOFF.md for next session
  /cks:eod                   End of day — log progress to DEVLOG.md

UTILITY:
  /cks:review-rules [--full] Audit codebase against .claude/rules/ guardrails
  /cks:context "topic"       Research a library/API → saves to .context/
  /cks:research "topic"      Deep multi-hop research → saves to .research/
  /cks:doctor                Project health diagnostic (env, TODOs, tests, git)
  /cks:version               Show installed CKS plugin version, project version, and migration status
  /cks:migrate               Upgrade project state files to match plugin version
  /cks:changelog [--since]   Auto-generate CHANGELOG.md from git history
  /cks:retro [--auto]        Retrospective — extract learnings + propose conventions
  /cks:status                Unified dashboard: git, build, PRD phase, code health

AUTOMATION:
  /cks:next                  Auto-detect state → run next step → stop
  /cks:autonomous [--role=R] Run all remaining phases + ship (no interruption)
  /cks:factory               AFK software factory — drain GitHub Issue backlog autonomously
  /cks:model [set|reset]     View or change model strategy (opus/sonnet/haiku per agent)
  /cks:persona [--scaffold <path>]   Configure agent persona — role, reasoning, domain knowledge

DESIGN:
  /cks:design-system [URL]   Generate DESIGN.md — plain-text design system for AI agents

QUALITY:
  /cks:simplify [file|all]   Simplify code for clarity — preserves behavior, reduces complexity
  /cks:caveman [target] [level]  Caveman mode — compress prose, cut ~65% tokens (lite|full|ultra|wenyan)
  /cks:launch-check [stage]  Pre-launch readiness — runs shipping checklist by maturity stage

OBSERVABILITY:
  /cks:observe               Sweep: detect all configured log sources
  /cks:observe --logs        Query: pull live logs, filter for errors
  /cks:observe --errors      Triage: Sentry error feed — issues, stack traces, regressions
  /cks:observe --traces      Analyze: LangSmith traces — latency, cost, errors

MODULES:
  /cks:bootstrap             Adapt .claude/ to project, generate CLAUDE.md
  /cks:adopt                 Mid-development? Adopt CKS into existing codebase
  /cks:market [discipline] [domain]  Marketing team — product, brand, online, AI (Ahrefs + DataForSEO)
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
  /cks:review                Code review a PR or file [legacy — use /cks:sprint]
  /cks:browse                Browser automation
  /cks:seo-audit             Full SEO audit
  /cks:security              Security audit (OWASP, secrets, deps)
  /cks:ciso                  Personal CISO — threat intelligence, supply chain, RLS, secrets, GitHub Actions hardening
  /cks:sandbox               Generate Leash Cedar policy — sandbox Claude Code with minimal-privilege rules
  /cks:investigate [area]    Scan for issues → file to GitHub → debug queue
  /cks:db [investigate|fix|debug|erd] Database — schema audit, RLS fix, debug, ERD
  /cks:payments [design|review|idempotency|webhooks|subscriptions|pci] Payment systems guidance
  /cks:debug [error|--issue N|--cks] Debug errors, GitHub issues, or CKS plugin issues
  /cks:fix [error]           Quick fix — debug + auto-apply
  /cks:decide                Stop asking — diagnose and act
  /cks:evaluate              Build Process Evaluator feature
  /cks:remotion              Remotion video dev — build, debug, optimize React videos
  /cks:refactor              Safe refactoring with impact analysis
  /cks:map-codebase          Codebase structure analysis
  /cks:docs                  Generate API/architecture/component docs
  /cks:optimize              Performance optimization suggestions
  /cks:progress              Feature progress dashboard
  /cks:logs                  View CKS activity logs
  /cks:virginize             Strip project-specific content for starter repo

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
    └── /cks:eod             Log progress at end of day

COLLABORATION:
  /cks:peers                 Session dashboard — what is every session doing?
  /cks:peers setup           Install and configure claude-peers-mcp

AGENTS:
  factory-runner             AFK factory pipeline — reads issue queue, dispatches prd-orchestrator per issue
  peer-coordinator           Cross-session coordination via claude-peers-mcp
  prd-orchestrator           Drives full lifecycle
  prd-discoverer             Interactive requirements gathering
  prd-planner                Writes PRDs and execution plans
  prd-executor               Implements code changes
  prd-verifier               Checks acceptance criteria
  prd-researcher             Investigates codebase and technology
  prd-refactorer             Safe refactoring with analysis
  design-system-generator    DESIGN.md generator for AI design tools
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
  DESIGN.md                  Plain-text design system for AI agents (Stitch, v0, Lovable)
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
