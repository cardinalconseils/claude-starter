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
  /cks:new [brief]           Create feature entry → enters Phase 1
  /cks:discover [phase]      Phase 1: Discovery — gather 11 Elements
  /cks:design [phase]        Phase 2: Design — UX flows, API contract, screen gen
  /cks:sprint [phase]        Phase 3: Sprint — plan → build → review → QA → UAT → merge
  /cks:review [phase]        Phase 4: Review & retro — feedback → iteration decision
  /cks:release [phase]       Phase 5: Release — Dev → Staging → RC → Production
  /cks:rpi                   R-P-I sub-cycle status — gates, artifacts, next action

QUICK ACTIONS (/cks:go):
  /cks:go                    Build → commit → push → PR (the daily driver)
  /cks:go commit [msg]       Stage + smart commit (no push)
  /cks:go pr [title]         Commit + push + open PR
  /cks:go dev                Start dev server (auto-detects project)
  /cks:go build              Run build (auto-detects project)

SESSION RITUALS:
  /cks:sprint-start           Load full context + validate guardrails (session open)
  /cks:sprint-close           Adherence audit + capture learnings (session close)
  /cks:standup               Morning resume — recap DEVLOG + suggest next action
  /cks:eod                   End of day — log progress to DEVLOG.md

VISUAL:
  /cks:board                 Launch Kanban dashboard in browser (multi-project, live sessions)

UTILITY:
  /cks:review-rules [--full] Audit codebase against .claude/rules/ guardrails
  /cks:context "topic"       Research a library/API → saves to .context/
  /cks:research "topic"      Deep multi-hop research → saves to .research/
  /cks:doctor                Project health diagnostic (env, TODOs, tests, git)
  /cks:migrate               Upgrade project state files to match plugin version
  /cks:changelog [--since]   Auto-generate CHANGELOG.md from git history
  /cks:retro [--auto]        Retrospective — extract learnings + propose conventions
  /cks:status                Unified dashboard: git, build, PRD phase, code health

AUTOMATION:
  /cks:next                  Auto-detect state → run next step → stop
  /cks:autonomous            Run all remaining phases + ship (no interruption)
  /cks:model [set|reset]     View or change model strategy (opus/sonnet/haiku per agent)

DESIGN:
  /cks:design-system [URL]   Generate DESIGN.md — plain-text design system for AI agents

QUALITY:
  /cks:simplify [file|all]   Simplify code for clarity — preserves behavior, reduces complexity
  /cks:launch-check [stage]  Pre-launch readiness — runs shipping checklist by maturity stage

OBSERVABILITY:
  /cks:observe               Sweep: detect all configured log sources
  /cks:observe --logs        Query: pull live logs, filter for errors
  /cks:observe --errors      Triage: Sentry error feed — issues, stack traces, regressions
  /cks:observe --traces      Analyze: LangSmith traces — latency, cost, errors

MODULES:
  /cks:bootstrap             Adapt .claude/ to project, generate CLAUDE.md
  /cks:adopt                 Mid-development? Adopt CKS into existing codebase
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
  /cks:review                Code review a PR or file
  /cks:browse                Browser automation
  /cks:seo-audit             Full SEO audit
  /cks:security              Security audit (OWASP, secrets, deps)
  /cks:ciso                  Personal CISO — threat intelligence, supply chain, RLS, secrets, GitHub Actions hardening
  /cks:sandbox               Generate Leash Cedar policy — sandbox Claude Code with minimal-privilege rules
  /cks:investigate [area]    Scan for issues → file to GitHub → debug queue
  /cks:db [investigate|fix|debug|erd] Database — schema audit, RLS fix, debug, ERD
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

PROFILES (set during /cks:bootstrap):
  app                        Versioned, full release ceremony (default)
  website                    No versioning, deploy-on-push
  library                    Strict versioning, publish to registry
  api                        Versioned, endpoint-focused release
  Edit .prd/prd-config.json to change profile or phase modes

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

THE ESCALATION LADDER:
  /cks:go commit             Save my work                    (5 seconds)
  /cks:go                    Build + commit + push + PR      (15 seconds)
  /cks:release               Full ceremony with deploy       (full ceremony)

FULL FLOW (from zero):
  /cks:ideate                Brainstorm first (optional, also works standalone)
  /kickstart                 Ideate? → Idea → design → scaffold
  /cks:go dev                Start dev server
  /cks:new "brief"           Create feature → discover → design → sprint → review → release
    ├── /cks:sprint-start    Load context (every session)
    ├── /cks:go dev          Dev server while coding
    ├── /cks:go commit       Save checkpoints
    ├── /cks:go pr           Quick PR for review
    ├── /cks:sprint-close    Audit + learnings (every session)
    └── /cks:release         Full ceremony → retro → CLAUDE.md update

COLLABORATION:
  /cks:peers                 Session dashboard — what is every session doing?
  /cks:peers setup           Install and configure claude-peers-mcp

AGENTS:
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
  launch-readiness           Pre-launch shipping checklist by maturity stage
  retrospective              Post-ship learning analyst
  db-investigator            Schema + RLS + migration + advisor audit
  db-fixer                   Proposes and applies RLS/schema fixes
  db-debugger                Traces RLS failures, slow queries, DB errors
  db-erd                     Generates Mermaid ERD from live schema
  debugger                   Diagnoses app errors + CKS plugin issues
  tdd-runner                 RED/GREEN/REFACTOR cycle specialist
  session-journalist         End-of-day DEVLOG composer
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
```
