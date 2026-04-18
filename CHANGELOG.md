# Changelog

All notable changes to the CKS (Claude Code Starter Kit) plugin are documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---


## [4.8.1] - 2026-04-18

### Added
- Add ultrareview + auto-mode skills, wire assess into adopt and migrate

## [4.8.0] - 2026-04-18

### Added
- `skills/github-issues/SKILL.md` — Dark Factory issue filing: auto-file GitHub issues at lifecycle events (verification failure, retro, backlog punts) with no user prompting; file then notify
- GitHub Issues gate in `agents/deployer.md` — checks open `cks:blocking` issues before any deploy; gives user proceed-or-stop choice
- GitHub Issues soft warning in `commands/new.md` — shows open issue count before starting a new feature (non-blocking)
- Auto-filing in `agents/prd-verifier.md` — files blocking issues to GitHub after FAIL/PARTIAL verification; includes dedup check
- Auto-filing in `agents/sprint-reviewer.md` — files bugs as `cks:blocking`, improvements as `cks:enhancement`, punted scope as `cks:backlog`
- Label taxonomy: `cks:auto-filed`, `cks:blocking`, `cks:backlog`, `cks:enhancement` with idempotent `gh label create` setup
- `skills/ultrareview/SKILL.md` — deep multi-pass code review skill for security, architecture, and quality
- `skills/auto-mode/SKILL.md` — autonomous sprint execution mode for uninterrupted full-phase runs

### Fixed
- `agents/prd-verifier.md` — added missing MCP tool declarations (`mcp__plugin_github_github__issue_write`, `mcp__plugin_github_github__list_issues`) required for GitHub integration
- `scripts/bump-version.sh` — reads version from source file (plugin.json, package.json) instead of git tags; supports `--bump-type patch|minor|major` argument

### Changed
- `agents/go-runner.md` — version bump step now asks user to choose bump type with recommended default based on commit analysis








## [4.7.0] - 2026-04-16

### Added
- Add /cks:sandbox — Leash Cedar policy generator for agent sandboxing
- Dynamic model strategy — cost-aware opus/sonnet/haiku per task type (#88)

### Fixed
- Kickstart + bootstrap interactive agents — opus + tool call enforcement (#89)
- Add next-step suggestions to all lifecycle commands

### Documentation
- Add WORKFLOW.md and peers to README

## [4.7.0] - 2026-04-15

### Added
- `/cks:sandbox` command — generates a Leash Cedar policy (`.leash/policy.cedar`) for the current project, sandboxing Claude Code with minimal-privilege file, process, and network rules
- `agents/sandbox-agent.md` — analyzes stack, detects .env files and external API hosts, writes project-specific Cedar rules
- `skills/agent-safety/SKILL.md` — Cedar schema knowledge, entity types, action semantics, and stack-aware policy templates (Next.js, Python, Go)
- Dynamic model strategy — cost-aware opus/sonnet/haiku per task type (#88)

### Fixed
- Kickstart + bootstrap interactive agents — opus + tool call enforcement (#89)
- Add next-step suggestions to all lifecycle commands

### Documentation
- Add WORKFLOW.md and peers to README

## [4.6.1] - 2026-04-07

### Maintenance
- Bump to v4.6.0

## [4.6.0] - 2026-04-07

### Added
- Peers v2: session awareness dashboard with auto-announce lifecycle hooks
- Auto-summary via `peer-announce.sh` — fires on SessionStart, SubagentStop, Stop
- Covers ALL session types: kickstart, ideation, design, sprint, review, research, debug
- Conflict detection — flags when two sessions work on the same feature
- Directive protocol (stop, redirect, priority) replaces manual messaging
- Strict repo isolation — peers only see same-repo sessions

### Removed
- Manual `/cks:peers send` and `/cks:peers check` — no better than switching tabs
- Parallel sprint workflow — task distribution belongs to Agent Teams, not peers
- Task-based message protocol — replaced by directive protocol

## [4.5.0] - 2026-04-06

### Added
- Peer coordination via claude-peers-mcp — `/cks:peers` command, `peer-coordinator` agent, `peers` skill
- Failure recipe for peer messaging with single-session fallback
- Session-start hook shows active peer count when broker is running

## [4.4.0] - 2026-04-05

### Added
- ClawCode-inspired failure taxonomy, event schema, anti-monolith refactor

## [4.3.1] - 2026-04-05

### Changed
- Merge pull request #73 from cardinalconseils/feat/board-logs-sync

## [4.3.0] - 2026-04-04

### Added
- Board logs panel + fix session needs_input state

### Fixed
- Discovery agent skipping acceptance criteria — model upgrade + step restructure

## [4.2.1] - 2026-04-04

### Changed
- Merge pull request #70 from cardinalconseils/feat/board-enhancement

## [4.2.0] - 2026-04-04

### Added
- CKS Board — multi-project Kanban command center
- Kickstart handoff — brand, design artifacts, and scaffold wiring
- RPI methodology — Research-Plan-Implement sub-cycle as first-class plugin skill (`skills/rpi/`), `/cks:rpi` command, quality gates (R→P, P→I), iteration-aware refresh
- Research artifacts wired into RPI handoff chain (discoverer, planner, designer, sprint dispatch)
- Remotion video development skill, agent, and command
- Integrity checks, migrations, tools layer, and agent hardening

### Fixed
- Close the feedback loop — show what was built, wire learnings into agents
- Rewrite review/sprint-close UX for vibe coders — plain language, clear consequences
- Comprehensive codebase audit — broken dispatches, missing kickstart steps, hook bugs
- Gitignore plugin dev state, add multi-platform deploy detection

## [4.1.1] - 2026-03-31

### Changed
- Merge pull request #60 from cardinalconseils/feat/ideation-phase-0
  - feat(ideation): add Phase 0 ideator — skill, agent, command, rules, hook

## [4.0.1] - 2026-03-31

### Changed
- Merge pull request #56 from cardinalconseils/chore/cleanup-plugin-distribution
  - chore: strip development artifacts — plugin distribution cleanup

## [3.3.1] - 2026-03-31

### Changed
- Merge pull request #55 from cardinalconseils/chore/cleanup-deprecated-and-bootstrap
  - chore: delete deprecated commands, add guardrails, fill CLAUDE.md

## [3.4.0] - 2026-03-30

### Changed
- Merge pull request #46 from cardinalconseils/feat/v4-architecture-refactor
  - feat: v4.0 architecture refactor — kickstart as reference implementation

## [4.1.0] - 2026-03-30

### Added
- 2 new bootstrap agents: `bootstrap-scanner` (scan + intake), `bootstrap-generator` (file generation)
- `skills: monetize` field to 5 monetize agents (researcher, cost-researcher, cost-analyzer, evaluator, reporter)
- `model: sonnet` to `monetize-reporter` agent

### Changed
- `/cks:bootstrap` rewritten as thin agent orchestrator (123 → ~45 lines)
- `/cks:monetize` rewritten as thin agent orchestrator (37 → ~70 lines)
- 6 monetize sub-commands rewritten as single-agent dispatchers
- `skills/cicd-starter/SKILL.md` updated with agent phase map
- `skills/monetize/SKILL.md` orchestration logic removed (now in command)

### Architecture
- Bootstrap and monetize now follow the v4.0 reference pattern:
  Command → Agent(skills: loaded) → Hook(logs)

## [3.4.0] - 2026-03-30

### Documentation
- Add kickstart architecture refactor design spec
  - Establishes the reference pattern for migrating CKS from the current
  - anti-pattern (command loads SKILL.md into main context) to the correct
  - Claude Code architecture (command dispatches agents with skills: field).
  - Covers: 4 new agents, thin command orchestrator, SubagentStop hook,
  - SKILL.md refactored from process script to expertise reference.

## [4.0.0] - 2026-03-30

### Breaking Changes
- Kickstart command rewritten as thin agent orchestrator — no longer loads SKILL.md into main context
- Kickstart SKILL.md refactored from 490-line process script to ~175-line expertise reference
- New architecture pattern: Command → Agent(skills: loaded) → Hook(logs)

### Added
- 4 new kickstart agents: `kickstart-intake`, `kickstart-brand`, `kickstart-designer`, `kickstart-handoff`
- `skills:` frontmatter field on agents — loads skill content at subagent startup
- SubagentStop hook for kickstart phase completion logging
- `skills:` field added to `deep-researcher` and `monetize-discoverer` agents

### Changed
- `/cks:kickstart` command: dispatches agents instead of loading workflows into main context
- Feature Roadmap generation folded into kickstart-designer agent output

### Architecture
- Establishes the reference pattern for migrating all 52 commands:
  - BEFORE: Command → reads SKILL.md into context → follows instructions → dispatches agent
  - AFTER: Command → dispatches Agent (skills: loaded) → agent works with expertise → hook logs

## [3.5.0] - 2026-03-30

### Added
- `allowed-tools` frontmatter to 11/14 skills — framework-enforced tool restrictions
- `model: sonnet` to 8 lightweight skills — reduces token cost for simple operations
- `## Customization` section to all 14 skills — guides users on what to adapt
- Progressive disclosure: extracted reference files for debug, context-research, language-rules, api-docs
- `hooks/README.md` — hook event documentation and customization guide
- `docs/ARCHITECTURE.md` — 4-layer architecture overview for users
- "Review & Customize" sections in `skills/README.md` and `agents/README.md`

### Fixed
- `aeo-geo-specialist` and `seo-strategist` agents: added missing `tools`/`color` frontmatter
- `debugger` agent: removed Write/Edit tools — enforces read-only diagnosis
- `doc-generator` agent: removed Edit tool

### Security
- `debug` skill + `debugger` agent now enforce read-only via `allowed-tools`

## [3.4.0] - 2026-03-30

### Added
- Inline sprint review + lightweight release — complete lifecycle in one session (#45)
  - Sprint step-5 now collects the user's verdict (ship/iterate/full review) inline
  - instead of deferring to a separate /cks:review session. New step-6 handles
  - lightweight release (merge PR, bump version, tag, changelog) when user ships.
  - This eliminates the 3-command, 3-session completion problem:
  -   Before: /cks:sprint → /compact → /cks:review → /compact → /cks:release

## [3.5.0] - 2026-03-30

### Added
- `allowed-tools` frontmatter to 11/14 skills — framework-enforced tool restrictions per the Claude Code open standard
- `model: sonnet` to 8 lightweight skills — reduces token cost for simple operations
- `## Customization` section to all 14 skills — guides users on what to review and adapt
- Progressive disclosure: extracted reference files for debug, context-research, language-rules, api-docs
- `hooks/README.md` — hook event documentation and customization guide
- `docs/ARCHITECTURE.md` — 4-layer architecture overview (hooks, skills, agents, commands) with user review guide
- "Review & Customize" section in `skills/README.md` and `agents/README.md`

### Fixed
- `aeo-geo-specialist` and `seo-strategist` agents: added missing `tools`/`color` frontmatter (were non-functional)
- `deep-researcher`, `retrospective`, `prd-designer` agents: added missing `color`
- `debugger` agent: removed Write/Edit tools — enforces read-only diagnosis per skill philosophy
- `doc-generator` agent: removed Edit tool — docs are generated fresh, not edited in place

### Changed
- `kickstart` SKILL.md split from 696 → ~479 lines via progressive disclosure (validation rules, phase banners, auto-chain extracted to reference/workflow files)

### Security
- `debug` skill + `debugger` agent now enforce read-only via `allowed-tools` — no Write/Edit until user explicitly approves a fix





















## [3.4.0] - 2026-03-30

### Added
- Inline sprint review + lightweight release — complete lifecycle in one session (#45)
  - Sprint step-5 now collects the user's verdict (ship/iterate/full review) inline
  - instead of deferring to a separate /cks:review session. New step-6 handles
  - lightweight release (merge PR, bump version, tag, changelog) when user ships.
  - This eliminates the 3-command, 3-session completion problem:
  -   Before: /cks:sprint → /compact → /cks:review → /compact → /cks:release

## [3.3.1] - 2026-03-29

### Fixed
- Review phase — mandatory structured summary before feedback (#44)
  - The review phase was asking users for their assessment without first
  - showing a clear summary of what was built. Now step [4a] mandates a
  - structured sprint summary block showing: what was requested, what was
  - built, files changed, acceptance criteria pass/fail, test results, and
  - design vs implementation comparison — all before collecting feedback.

## [3.2.65] - 2026-03-29

### Fixed
- Review phase — mandatory structured summary before feedback (#44)
  - The review phase was asking users for their assessment without first
  - showing a clear summary of what was built. Now step [4a] mandates a
  - structured sprint summary block showing: what was requested, what was
  - built, files changed, acceptance criteria pass/fail, test results, and
  - design vs implementation comparison — all before collecting feedback.

## [3.2.62] - 2026-03-29

### Fixed
- Audit autonomous workflow — align with audited phases (#42)
  - Fixed autonomous.md to match the audited lifecycle:
  - - 9 → 11 discovery elements
  - - Added secrets hooks (hook-discover, hook-plan, hook-sprint)
  - - Added Stitch MCP + diagrams to Design agent prompt
  - - Added missing sprint sub-steps: [3a+] Secrets, [3b+] Gate,

## [3.3.0] - 2026-03-29

### Changed
- **Chunked architecture across all 5 phases** — Every phase workflow is now a thin orchestrator (~55-90 lines) referencing modular sub-step files, replacing monolithic 500-900 line files ([#35](https://github.com/cardinalconseils/claude-starter/pull/35), [#36](https://github.com/cardinalconseils/claude-starter/pull/36), [#37](https://github.com/cardinalconseils/claude-starter/pull/37))
  - Discover: 9 sub-step files
  - Design: 10 sub-step files
  - Sprint: 17 sub-step files
  - Review: 8 sub-step files
  - Release: 9 sub-step files

### Added
- **Newman API contract testing** — Postman CLI integration at Sprint [3a] collection generation, Sprint [3e] QA validation, and Release [5c] RC validation ([#34](https://github.com/cardinalconseils/claude-starter/pull/34))
- **Diagram generation** — Stitch MCP prompt templates for flowcharts, state diagrams, sequence diagrams in Design phase ([#35](https://github.com/cardinalconseils/claude-starter/pull/35))
- **Chrome DevTools MCP** — Browser preview documentation for Design [2d] iteration ([#35](https://github.com/cardinalconseils/claude-starter/pull/35))
- **[3c+] De-Sloppify sub-step** — Cleanup agent between Implementation and Code Review to remove debug artifacts, dead code, console.log ([#36](https://github.com/cardinalconseils/claude-starter/pull/36))
- **Chunked architecture diagrams** in `docs/WORKFLOW.md` for all 5 phases ([#35](https://github.com/cardinalconseils/claude-starter/pull/35), [#36](https://github.com/cardinalconseils/claude-starter/pull/36), [#37](https://github.com/cardinalconseils/claude-starter/pull/37))

### Fixed
- **Bootstrap phase** — 7 fixes for connections, secrets, and artifacts ([#31](https://github.com/cardinalconseils/claude-starter/pull/31))
- **Discover phase** — Normalized element count to 11 across all references ([#32](https://github.com/cardinalconseils/claude-starter/pull/32))
- **Design phase** — Stitch SDK→MCP rename, sub-step alignment, phantom `frontend-design` skill removed ([#33](https://github.com/cardinalconseils/claude-starter/pull/33))
- **Path normalization** — Fixed 15 hardcoded `.claude/skills/` references to `${CLAUDE_PLUGIN_ROOT}/skills/` across 7 agent and workflow files ([#38](https://github.com/cardinalconseils/claude-starter/pull/38))
- **Phantom references removed** — `claude-md-management:revise-claude-md` skill (never existed) removed from release and ship workflows ([#39](https://github.com/cardinalconseils/claude-starter/pull/39))
- **Phantom `agent-browser/SKILL.md`** reference removed from browse command ([#40](https://github.com/cardinalconseils/claude-starter/pull/40))
- **Sprint quick reference** — Updated from 7 to all 11 sub-steps in `commands/sprint.md` ([#36](https://github.com/cardinalconseils/claude-starter/pull/36))
- **prd-planner.md** — Fixed 2 broken `${CLAUDE_PLUGIN_ROOT}` path references ([#36](https://github.com/cardinalconseils/claude-starter/pull/36))

## [3.2.46] - 2026-03-28

### Changed
- Merge pull request #27 from cardinalconseils/feat/guardrails-layer
  - feat: add guardrails layer with scoped rules, session rituals, and project scaffolding

## [3.2.44] - 2026-03-28

### Added
- **Guardrails layer** — Scoped rules, session rituals, and project scaffolding for enforcing conventions ([#27](https://github.com/cardinalconseils/claude-starter/pull/27))
- **Project profiles** — Profile-aware versioning, phase autonomy modes, and per-project configuration ([#26](https://github.com/cardinalconseils/claude-starter/pull/26))
  - Bootstrap and adopt commands prompt for project profile
  - Pre-commit hook respects versioning profile
  - All five phase orchestrators read autonomy mode from config
- **`/cks:eod` and `/cks:standup` commands** — Daily dev rhythm with DEVLOG summaries and next-action suggestions ([#25](https://github.com/cardinalconseils/claude-starter/pull/25))
- **Changelog update notification** — Session-start hook shows changelog link after plugin updates ([#24](https://github.com/cardinalconseils/claude-starter/pull/24))
- **Auto-stage changelog** — CHANGELOG.md and all bumped files are auto-staged on commit ([#23](https://github.com/cardinalconseils/claude-starter/pull/23))

### Fixed
- Handle jq false-as-falsy in bump-version.sh config reading

### Changed
- Design specs moved from `docs/superpowers/` to `.prd/specs/`
- Bump-version.sh made profile-aware with multi-source support

## [3.2.23] - 2026-03-28

### Added
- **Structured lifecycle logging** — JSONL event logging across all CKS phases with `scripts/cks-log.sh` utility ([#22](https://github.com/cardinalconseils/claude-starter/pull/22))
- **`/cks:logs` command** — Query lifecycle logs with `--feature`, `--phase`, `--severity`, `--since`, `--metrics`, `--summary` filters
- **Event catalog reference** — `skills/prd/references/logging-events.md` for workflow authors
- **Session correlation** — Session ID file written by session-start hook for log correlation
- **Logging design spec** — `docs/superpowers/specs/2026-03-27-lifecycle-logging-design.md` ([#21](https://github.com/cardinalconseils/claude-starter/pull/21))
- **Project composition phase** — New "Compose" phase (1b) in kickstart for multi-sub-project discovery alignment ([#20](https://github.com/cardinalconseils/claude-starter/pull/20))
  - `PROJECT-MANIFEST.md` with dependency graph, build order, cross-project contracts
  - Per-sub-project design artifacts in kickstart
  - 11th discovery element: Cross-Project Dependencies
  - Multi-feature handoff from manifest

## [3.2.16] - 2026-03-27

### Added
- **Auto version bump** — Git hook and Claude Code guard auto-bump version on every commit ([#19](https://github.com/cardinalconseils/claude-starter/pull/19))
- **Contextual retrospective** — Review phase [4b] retrospective is now interactive with codebase-aware insights ([#18](https://github.com/cardinalconseils/claude-starter/pull/18))
- **API contract sub-steps** — Kickstart design phase generates API contracts with sub-step tracking ([#17](https://github.com/cardinalconseils/claude-starter/pull/17))
- **Cost analysis agents** — Dedicated agents for monetization cost analysis phase ([#16](https://github.com/cardinalconseils/claude-starter/pull/16))
- **`/cks:adopt` command** — Onboarding flow for existing codebases, replaces migrate/upgrade ([#15](https://github.com/cardinalconseils/claude-starter/pull/15))

## [3.2.0] - 2026-03-27

### Added
- **No-code specialist agent** — Builds, debugs, and optimizes workflows across n8n, Make.com, Workato, Zapier ([#13](https://github.com/cardinalconseils/claude-starter/pull/13))
- **Secrets lifecycle management** — Chunked discover phase architecture with secrets sub-step ([#12](https://github.com/cardinalconseils/claude-starter/pull/12))

### Changed
- Reset .prd/ state and CLAUDE.md to starter template

## [3.1.0] - 2026-03-27

### Added
- **Multi-agent delegation** — Token optimization for PRD lifecycle with parallel agent dispatch ([#11](https://github.com/cardinalconseils/claude-starter/pull/11))

## [3.0.8] - 2026-03-27

### Added
- **Brand phase** — Brand guidelines intake in kickstart with auto-chain to feature lifecycle ([#10](https://github.com/cardinalconseils/claude-starter/pull/10))
- **Schema.sql generation** — Kickstart design phase generates database DDL
- **Optional Perplexity** — Research phase falls back to WebSearch when Perplexity API unavailable

## [3.0.5] - 2026-03-27

### Added
- **Sprint iteration tracking** — Numbered iteration cycles with scoped re-planning ([#9](https://github.com/cardinalconseils/claude-starter/pull/9))

## [3.0.2] - 2026-03-27

### Added
- **API-first cascade** — API contracts cascade across the full lifecycle + documentation pipeline ([#8](https://github.com/cardinalconseils/claude-starter/pull/8))
- **Version tracking** — Automated version sync across README.md and WORKFLOW.md ([#7](https://github.com/cardinalconseils/claude-starter/pull/7))

---

[3.2.44]: https://github.com/cardinalconseils/claude-starter/compare/v3.2.23...v3.2.44
[3.2.23]: https://github.com/cardinalconseils/claude-starter/compare/v3.2.16...v3.2.23
[3.2.16]: https://github.com/cardinalconseils/claude-starter/compare/v3.2.0...v3.2.16
[3.2.0]: https://github.com/cardinalconseils/claude-starter/compare/v3.1.0...v3.2.0
[3.1.0]: https://github.com/cardinalconseils/claude-starter/compare/v3.0.8...v3.1.0
[3.0.8]: https://github.com/cardinalconseils/claude-starter/compare/v3.0.5...v3.0.8
[3.0.5]: https://github.com/cardinalconseils/claude-starter/compare/v3.0.2...v3.0.5
[3.0.2]: https://github.com/cardinalconseils/claude-starter/releases/tag/v3.0.2
