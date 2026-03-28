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
  /cks:kickstart             Idea → Q&A → research → design → scaffold project
  /cks:new [brief]           Initialize feature + run full autonomous cycle
  /cks:discuss [phase]       Interactive discovery (auto-researches technologies)
  /cks:plan [phase]          Write PRD + execution plan
  /cks:execute [phase]       Implement the next planned phase
  /cks:verify [phase]        Verify acceptance criteria
  /cks:ship [phase|all]      Doctor → PR → changelog → CLAUDE.md → review → deploy → retro

QUICK ACTIONS (/cks:go):
  /cks:go                    Build → commit → push → PR (the daily driver)
  /cks:go commit [msg]       Stage + smart commit (no push)
  /cks:go pr [title]         Commit + push + open PR
  /cks:go dev                Start dev server (auto-detects project)
  /cks:go build              Run build (auto-detects project)

UTILITY:
  /cks:eod                   End of day — log progress to DEVLOG.md
  /cks:standup               Morning resume — recap + suggest next action
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
  /cks:migrate               Guided migration from GSD plugin to CKS
  /cks:monetize              Business model evaluation (12 revenue models)
  /cks:deploy                Deploy to Railway
  /cks:test [flags]          Run test suite
  /cks:review                Code review a PR or file
  /cks:browse                Browser automation
  /cks:seo-audit             Full SEO audit
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
  /cks:ship                  Full ceremony with deploy       (full ceremony)

FULL FLOW (from zero):
  /kickstart                 Idea → design → scaffold
  /cks:go dev                Start dev server
  /cks:new "brief"           Define → plan → execute → verify → ship
    ├── /cks:go dev          Dev server while coding
    ├── /cks:go commit       Save checkpoints
    ├── /cks:go pr           Quick PR for review
    └── /cks:ship            Full ceremony → retro → CLAUDE.md update

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

FILES:
  .prd/                      Planning state + phase artifacts
  .prd/prd-config.json       Profile, versioning, phase autonomy settings
  .prd/specs/                Design specs (brainstorming output)
  .context/                  Persistent research briefs
  .context/config.md         Research source priority + preferences
  .research/                 Deep research reports
  .prd/DEVLOG.md             Rolling development journal (newest first)
  .learnings/                Retrospective insights
  CHANGELOG.md               Auto-generated changelog
  CLAUDE.md                  Project instructions (auto-updated on ship)

CD TIP:
  After shipping, use ralph-loop for continuous deployment:
  /ralph-loop:ralph-loop "monitor PR #{number} and deploy when merged"
```
