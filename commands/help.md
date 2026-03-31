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

UTILITY:
  /cks:review-rules [--full] Audit codebase against .claude/rules/ guardrails
  /cks:context "topic"       Research a library/API → saves to .context/
  /cks:research "topic"      Deep multi-hop research → saves to .research/
  /cks:doctor                Project health diagnostic (env, TODOs, tests, git)
  /cks:changelog [--since]   Auto-generate CHANGELOG.md from git history
  /cks:retro [--auto]        Retrospective — extract learnings + propose conventions
  /cks:status                Unified dashboard: git, build, PRD phase, code health

AUTOMATION:
  /cks:next                  Auto-detect state → run next step → stop
  /cks:autonomous            Run all remaining phases + ship (no interruption)

MODULES:
  /cks:bootstrap             Adapt .claude/ to project, generate CLAUDE.md
  /cks:monetize              Business model evaluation (12 revenue models)
  /cks:deploy                Deploy to Railway
  /cks:test [flags]          Run test suite
  /cks:review                Code review a PR or file
  /cks:browse                Browser automation
  /cks:seo-audit             Full SEO audit
  /cks:debug [error|--cks]   Debug app errors or CKS plugin issues
  /cks:decide                Stop asking — diagnose and act
  /cks:refactor              Safe refactoring with impact analysis
  /cks:map-codebase          Codebase structure analysis
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

AGENTS:
  prd-orchestrator           Drives full lifecycle
  prd-discoverer             Interactive requirements gathering
  prd-planner                Writes PRDs and execution plans
  prd-executor               Implements code changes
  prd-verifier               Checks acceptance criteria
  prd-researcher             Investigates codebase and technology
  prd-refactorer             Safe refactoring with analysis
  deep-researcher            Multi-hop recursive research
  retrospective              Post-ship learning analyst
  debugger                   Diagnoses app errors + CKS plugin issues
  tdd-runner                 RED/GREEN/REFACTOR cycle specialist
  session-journalist         End-of-day DEVLOG composer
  security-auditor           OWASP, secrets, dependency audit
  doc-generator              API, architecture, component docs
  kickstart-ideator          Idea brainstorming and refinement
  bootstrap-scanner          Codebase scan + guided intake
  bootstrap-generator        CLAUDE.md, rules, PRD generation

FILES:
  CLAUDE.md                  Project constitution (150 lines max, updated at sprint-close)
  .claude/rules/             Glob-scoped guardrails (security, testing, database, docs, language)
  .prd/                      Planning state + phase artifacts
  .prd/prd-config.json       Profile, versioning, phase autonomy settings
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
