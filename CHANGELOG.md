# Changelog

All notable changes to the CKS (Claude Code Starter Kit) plugin are documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---







## [5.1.186] - 2026-07-01

### Added
- /cks:brainstorm — context-aware open-ended brainstorming (#457)

### Fixed
- Add RELEASE.md artifact — close progress dashboard gap for released phases (#456)

## [5.1.185] - 2026-06-21

### Added
- /cks:brainstorm — context-aware open-ended brainstorming

### Fixed
- Add RELEASE.md artifact — close progress dashboard gap for released phases (#456)

## [5.1.184] - 2026-06-21

### Fixed
- Add RELEASE.md artifact — close progress dashboard gap for released phases (#456)

## [5.1.183] - 2026-06-21

### Documentation
- V5.1.181 — OKF compliance changelog + README header (#454)

## [5.1.182] - 2026-06-21

### Added
- `.claude/rules/context-fork.md` — new rule: `context-guard.sh` hard-blocks at 75% context with `/fork` instruction; replaces graduated warnings at 48/55%
- `.claude/rules/deterministic-automation.md` — new rule: classifies every automation step as deterministic (tool-first) or indeterministic (agent judgment); includes Make.com account rule and operation table

### Changed
- `skills/prd/workflows/progress.md` — progress dashboard now detects `*-RELEASE.md` on disk for `[✓]` status instead of reading `phase_status` field
- `skills/prd/workflows/release-phase/step-6-state.md` — Release phase must write `{NN}-RELEASE.md` terminal artifact before updating STATE.md; path and minimal template documented
- `agents/sprint-reviewer.md` — `*-REVIEW.md` write path now requires `{NN}-` prefix so progress dashboard glob scan resolves correctly

### Fixed
- OKF compliance — frontmatter on 3 files, ext taxonomy, wiki edit mode (#397)
- `hooks/handlers/context-guard.sh` — updated to hard-block (`exit 1`) at 75% context and instruct `/fork`; old graduated 48%/55% warnings removed

### Removed
- `.prd/G6-SUMMARY.md` — process artifact accidentally committed in v5.1.151; `.prd/` is gitignored and phase summaries do not ship with the plugin

## [5.1.181] - 2026-06-21

### Fixed
- OKF compliance: added required YAML frontmatter (`type`, `name`, `description`) to `memory/correction_log.md`, `memory/gatekeeper/review_log.md`, and `memory/wiki/README.md` — these violated the `memory-format.md` rule since v5.1.156

### Changed
- `memory-format.md` type taxonomy extended — `report` added for `memory/output/`, `log` for `memory/gatekeeper/`; derivation rule now covers all `memory/` subdirectories, not only `memory/wiki/`
- `agents/wiki.md` — new `edit` mode preserves OKF frontmatter on page updates (prior write-only approach risked stripping frontmatter); OKF validation gate added to `write` and `edit` modes (blocks missing `type`/`name`/`description` with `▶ ACTION REQUIRED`)

## [5.1.179] - 2026-06-20

### Added
- feat(bootstrap): FastAPI+SPA paired detection — Step 2b in bootstrap-scanner.md detects FastAPI ≥ 0.138.0 + SPA sibling dirs, surfaces app.frontend() wiring suggestion
- feat(bootstrap): --dismiss flag — /cks:bootstrap --dismiss fastapi-frontend suppresses suggestion persistently via .bootstrap/DISMISSED-DETECTION.md
- feat(kickstart): FastAPI+SPA one-binary stack option — stack-selection.md Step 4 now includes FastAPI+SPA option that records stack_choice in .kickstart/state.md










## [5.1.179] - 2026-06-20

### Added
- `/cks:loop` — loop lifecycle manager command (design / run / health / triage / cost / migrate / status sub-commands)
- `/cks:loop-migrate` — validate `.loops/**/*.jsonl` schema_version:1 compliance; report non-compliant entries
- `agents/loop-designer` — six-part loop composition interview → produces `LOOP-DESIGN.md` with mandatory stop condition and Level 1 autonomy default
- `agents/loop-runner` — executes one iteration; writes `health.jsonl` with `schema_version:1`; Sentry capture on error; LangSmith trace per run
- `agents/loop-health-checker` — dispatches `cks:sentry-observer` + `cks:langsmith-observer` every health run
- `agents/loop-triage-curator` — scores findings, writes `.triage/{slug}/{date}.md` as primary user-facing output
- `agents/loop-cost-monitor` — haiku model; always shows "estimate, not measured — Layer 2 not shipped" banner
- `agents/loop-orchestrator` — routes all seven sub-commands to specialist agents
- `skills/loop/SKILL.md` — domain expertise: six-part composition, autonomy ladder, stop condition rules, triage-inbox-first UX, observability wiring
- `docs/schemas/loop-events-v1.md` — `.loops/**/*.jsonl` schema lock (`schema_version` int required on every line)

## [5.1.178] - 2026-06-20

### Added
- Human-controlled phase gates v5.1.176 (#368)

## [5.1.177] - 2026-06-18

### Added
- Human-controlled phase gates v5.1.176

## [5.1.176] - 2026-06-18

### Added
- Human-controlled lifecycle phase gates: every phase (pre-flight, discover, design, sprint) now requires explicit AskUserQuestion confirmation before dispatch — agent recommends based on artifact status, human decides
- New rule `.claude/rules/phase-gates.md` — mandates per-phase human gates in all orchestrators, declares artifact writing (SUMMARY.md, VERIFICATION.md) non-negotiable
- Phase status banner shown before gates so human sees all phases at a glance before being asked

### Changed
- `agents/prd-orchestrator.md` — replaced silent `if no artifact → dispatch` conditionals with Step 1.5 Phase Selection Gates (sequential AskUserQuestion per phase)
- `commands/sprint.md` — expanded pre-flight gate into 3-gate lifecycle check (Pre-Flight, Discover, Design) before attractor dispatch

### Fixed
- Correct attractor skill reference and remove deprecated /cks:release (#367)

## [5.1.175] - 2026-06-18

### Added
- Loop lifecycle enforcement v5.1.174 (#366)

## [5.1.174] - 2026-06-18

### Changed
- **Loop lifecycle enforcement** — `/cks:loop design` now requires a CKS lifecycle phase to exist
  before entering the six-part composition interview. If none exists, surfaces a DECISION REQUIRED
  block: start full lifecycle (recommended) or override to design directly.
- **`loop-designer` prerequisite check** — agent halts with ACTION REQUIRED if CONTEXT.md or
  DESIGN.md are missing; pre-fills interview answers from CONTEXT.md when they exist so the
  six-part interview only asks what's truly missing.
- **Design phase step [2e]** — `design-phase.md` now scans CONTEXT.md for loop signals and
  dispatches `loop-designer` automatically at Phase 2, making LOOP-DESIGN.md a design artifact
  (alongside api-contract.md) rather than a planning interrupt.
- **`loops.md` rule clarified** — Phase 2 is the primary dispatch point; step-3a is fallback
  only; adds CONTEXT.md existence check before step-3a can dispatch loop-designer.
- **step-3a de-duplication** — planning step checks for an existing LOOP-DESIGN.md before
  re-dispatching loop-designer; passes the path to prd-planner if it already exists.

## [5.1.173] - 2026-06-17

### Added
- CCCS threat intel session banner + gitignore agent dirs

## [5.1.172] - 2026-06-17

### Added
- CCCS threat intel: session-start hook surfaces open `cccs-threat` GitHub Issues created by remote Claude Desktop routine
- `.agents/` and `scripts/cccs-session-check.sh` gitignored — personal infra, not part of the plugin
- `scripts/cccs-session-check.sh` guard is no-op for users without the script (`[ -x ]` check in hook)

## [5.1.171] - 2026-06-17

### Added
- Fix session continuity — control-plane auto-init + /cks:save-context (#352)
- CCCS threat intel monitor + Telegram alerting + ciso integration (#351)
- /cks:loop — loop lifecycle runtime (Phase 01) (#350)
- Setup-philosophy — deterministic rails vs non-deterministic calls (#348)

### Documentation
- Fix README command/agent counts (133 commands, 173 agents)

### Maintenance
- Release v5.1.169 — docs + version alignment post-loop+cccs merge
- Release v5.1.165 (#349)

## [5.1.170] - 2026-06-17

### Added
- Fix session continuity — control-plane auto-init + /cks:save-context

### Documentation
- V5.1.167 — CCCS threat intel monitor + Telegram alerting

## [5.1.169] - 2026-06-17

### Added
- CCCS threat intel monitor + Telegram alerting + ciso integration (#351)
- /cks:loop — loop lifecycle runtime (Phase 01) (#350)
- Setup-philosophy — deterministic rails vs non-deterministic calls (#348)

### Documentation
- commands/README.md count 131 → 132; add /cks:cccs-intel to security table
- docs/WORKFLOW.md, docs/wiki/README.md, README.md — version headers aligned to current release

## [5.1.167] - 2026-06-17

### Added
- `/cks:loop` — loop lifecycle runtime: 1 command (loop + loop-migrate), 6 agents (designer/runner/health-checker/triage-curator/cost-monitor/orchestrator), 1 skill (loop), 1 schema doc (loop-events-v1). Triage-inbox-first UX; autonomy Level 1 default; schema_version:1 enforced on every health.jsonl entry.
- `/cks:cccs-intel` — CCCS threat intel monitor with Telegram alerting: daily fetch from cyber.gc.ca, dedup via seen_threat_ids, ciso agent Step 8 integration




## [5.1.169] - 2026-06-17

### Documentation
- V5.1.167 — CCCS threat intel monitor + Telegram alerting

## [5.1.168] - 2026-06-17

### Added
- Add CCCS threat intel monitor with Telegram alerting + ciso integration
- /cks:loop — loop lifecycle runtime (Phase 01)
- Setup-philosophy — deterministic rails vs non-deterministic calls (#348)

### Fixed
- Auto-detect TELEGRAM_BOT_TOKEN + TELEGRAM_CHAT_ID from env during setup

### Maintenance
- Release v5.1.165 (#349)

## [5.1.167] - 2026-06-17

### Added
- **`/cks:cccs-intel`** — new command + `cks:cccs-intel-monitor` agent: daily scheduled fetch of Canadian Centre for Cyber Security alerts, advisories, and bulletins; diffs against seen threats; delivers new findings to Telegram via Bot API
- **`cks:ciso` Step 8** — every CISO audit now appends a live CCCS threat intel brief filtered for PMC stack keywords (node, npm, github, supabase, stripe, railway, vercel, anthropic, mcp, next.js, react); non-blocking if CLI unavailable
- Auto-detects `TELEGRAM_BOT_TOKEN` + `TELEGRAM_CHAT_ID` from env during setup — no manual wizard entry required when both vars are set


## [5.1.167] - 2026-06-20

### Added
- /cks:loop — loop lifecycle runtime (Phase 01)
- Setup-philosophy — deterministic rails vs non-deterministic calls (#348)

### Maintenance
- Release v5.1.165 (#349)

## [5.1.166] - 2026-06-17

### Maintenance
- Release v5.1.165 — ships setup-philosophy rule, concept-evaluation Rule 8 enforcement, loop-runtime decision docs

## [5.1.165] - 2026-06-17

### Added
- Add setup-philosophy rule + enforcement trigger in concept-evaluation

## [5.1.164] - 2026-06-17

### Added
- feat(rules): new `.claude/rules/setup-philosophy.md` — formalizes the deterministic-rail-vs-non-deterministic-call principle across the 7 CKS layers; includes bucket table, two failure modes (rule-as-prose drift / judgment-as-script brittleness), setup order, copy-paste skeletons, enforcement trigger section, Common Rationalizations, and Verification checklist
- feat(rules): `concept-evaluation.md` Rule 8 — Technology Fit pillar must apply the bucket test from `setup-philosophy.md`; wrong-bucket components scored down and flagged as finding

### Documentation
- docs(loop): `memory/wiki/decisions/loop-runtime-go.md` — V1 interview results, pivot to triage inbox + push notification UX (operator console deprioritized)
- docs(loop): correct sprint-run entry point — dispatched via attractor orchestrator, not /cks:new

## [5.1.163] - 2026-06-17

### Documentation
- V1 interview results — pivot operator console → triage inbox

## [5.1.162] - 2026-06-17

### Maintenance
- Release v5.1.161

## [5.1.161] - 2026-06-17

### Added
- feat(rules): new `.claude/rules/loops.md` — deterministic gate for loop architecture signals; dispatches `cks:architecture-generator` Mode 3 on loop-pattern match before PLAN.md

### Changed
- chore(rules): `.claude/rules/scheduling.md` updated — loops supersede schedules; loop signals (cron expression blocks, multi-stage retry, fan-out/fan-in) route to loops.md first
- docs(memory): `memory/index.md` updated with loop-runtime-go decision entry
- docs(memory): new `memory/wiki/decisions/loop-runtime-go.md` — decision record for loop runtime architecture

## [5.1.160] - 2026-06-16

### Added
- feat(autoresearch): scheduler + retrospective + sprint-review integrations (#343) — `--schedule=<cron>` flag + CronCreate in autoresearch-runner; retrospective autoresearch-aware (surfaces keep rate, best delta, gotchas); sprint-reviewer SUGGESTION block at [4d] iterate path
- feat(premortem): Gary Klein pre-mortem integration — Probe 5 in ideation stress-test (deterministic, no skip) + post-Go gate in concept-orchestrator (AskUserQuestion before branch creation)
- feat(rules): new `.claude/rules/premortem.md` — mandatory post-Go pre-mortem gate with Klein framing rules and common rationalization table
- feat(concept): concept-orchestrator Step 10 — offers Klein pre-mortem on every Go verdict ≥ 4.0; user may Skip but gate cannot be silently omitted
- feat(ideation): ideate.md Probe 5 — Klein prospective hindsight fires last in every stress-test; past-tense framing enforced; vague causes pushed back
- feat(strategic): pre-mortem workflow Concept Mode variant — past-tense Klein framing + independent generation instruction for concept gate use
- feat(memory): klein-premortem-desktop-instruction.md — copy-paste Claude Desktop project instruction for Gary Klein pre-mortem facilitation

## [5.1.159] - 2026-06-15

### Added
- Add /cks:sleep — SkillOpt-Sleep nightly skill training loop

## [5.1.158] - 2026-06-15

### Added
- OKF format adoption + self-improvement feedback loop (#345)
- /cks:print-cli — cli-printing-press integration (#344)
- Cks:autoresearch — autonomous keep/discard optimization loop (#341)

## [5.1.157] - 2026-06-15

### Added
- Adopt OKF format + surface learnings in session-loader

## [5.1.156] - 2026-06-15

### Added
- OKF memory format: `memory/log.md` (OKF reserved chronological log)
- New rule `.claude/rules/memory-format.md` — type taxonomy (`learning`, `decision`, `article`, `fact`, `index`, `log`), required frontmatter fields, self-improvement loop spec

### Changed
- `memory/index.md`, `memory/wiki/index.md` — OKF-compliant frontmatter (`type: index`)
- `memory/wiki/learnings/phase-08-*.md` — OKF frontmatter added (`type: learning`)
- `agents/wiki.md` — injects OKF frontmatter on every new page write; derives `type` from subdirectory
- `agents/session-loader.md` — Step 3 now scans `memory/wiki/learnings/` and surfaces 3 most recent `type:learning` entries in session brief, closing the self-improvement feedback loop

## [5.1.155] - 2026-06-14

### Added
- Cks:autoresearch — autonomous keep/discard optimization loop (#341)
- Add cks:autoresearch — autonomous keep/discard optimization loop

## [5.1.154] - 2026-06-08

### Added
- V5.1.151 — CodeGraph integration, Agentic OS refresh, Lovable marketing skills (#339)
- Add AHE Evolution Agent — telemetry-driven golden case proposals (#338)

### Changed
- Release v5.1.152 (#340)

### Documentation
- Update command/agent counts + add harness-eval and evolve to table


## [5.1.153] - 2026-06-08

### Added
- V5.1.151 — CodeGraph integration, Agentic OS refresh, Lovable marketing skills (#339)
- Add AHE Evolution Agent — telemetry-driven golden case proposals (#338)

### Changed
- Release v5.1.152 (#340)

## [5.1.152] - 2026-06-08

### Added
- AHE Evolution Agent (`cks:ahe-evolution-agent`) — reads session traces + governance log to propose telemetry-driven golden case mutations for hook handler validation
- Agentic OS dashboard refresh — `agentic-os-refresh.sh` and updated `agentic-os-builder` agent with board/HANDOFF.md support
- Lovable marketing skills — 4 new skills added to `lovable-skills/`: `market-mapping`, `competitor-alternatives`, `ad-creative`, `signup-flow-cro`

## [5.1.151] - 2026-06-08

### Added
- CodeGraph integration — `/cks:codegraph` command + `skills/codegraph/SKILL.md` for opt-in codebase knowledge graph MCP (~47% fewer tokens on exploration)
- Agentic OS refresh — updated agentic-os-builder agent, DESIGN.md, README.md, and `scripts/agentic-os-refresh.sh`
- Lovable marketing skills — 19 domain skill files under `lovable-skills/marketing/` (copywriting, paid-ads, SEO, CRO, brand, email, and more)
- Board UI — new `board/index.html` replaces decommissioned `dashboard/index.html`

### Changed
- `/cks:bootstrap` and `/cks:adopt` completion output now suggests `/cks:codegraph install` as a post-setup optimization
- AHE Evolution Agent — telemetry-driven golden case proposals (from g2 branch)

## [5.1.150] - 2026-06-08

### Added
- Add harness eval framework for hook behavior validation (#337)

## [5.1.149] - 2026-06-08

### Added
- HITL governance log — persist HIGH-risk approvals to .cks/governance.json (#336)

## [5.1.148] - 2026-06-08

### Added
- G3 Deep Telemetry Layer 1 — per-tool-call session traces (v5.1.145) (#334)

### Maintenance
- Fix CHANGELOG entry for strategic-frameworks v5.1.145

## [5.1.147] - 2026-06-08

### Added
- Unified SPA with Board/Metrics/Luv/Settings navigation

## [5.1.146] - 2026-06-08

### Added
- **G3 Deep Telemetry Layer 1** — new `PostToolUse` hook `post-tool-trace.sh` records per-tool-call traces to `.prd/logs/sessions/{session_id}.jsonl`
- `args_digest` field uses SHA256 of sorted `tool_input` JSON (first 8 hex chars) — secrets-safe by design, never logs raw values
- `.claude/rules/telemetry.md` schema contract defines Layer 1 fields (`tool`, `args_digest`, `outcome`, `timestamp`, `session_id`) and reserves Layer 2 (cost/latency) and Layer 3 (decision traces) fields for future use
- Session trace files gitignored — per-dev artifacts only; `lifecycle.jsonl` unchanged for existing consumers
- Prerequisite for G2 AHE Evolution Agent (reads session traces to propose rule mutations)

## [5.1.145] - 2026-06-08

### Added
- `skills/strategic-frameworks/` — 7 PM strategy frameworks imported from phuryn/pm-skills (MIT): Lean Canvas, Opportunity Solution Tree, Pre-Mortem, North Star Metric, PESTLE Analysis, Ansoff Matrix, Porter’s Five Forces
- Each framework split into deterministic YAML/DOT structure file + non-deterministic MD facilitation workflow
- `output-schemas.yaml` — deterministic contract mapping each framework’s output to CONTEXT.md sections and PRD-STATE.md Working Notes
- `agents/kickstart-ideator.md` and `agents/prd-discoverer.md` updated to load `strategic-frameworks` skill
- `LICENSE-NOTICES.md` — MIT attribution for phuryn/pm-skills derived files

## [5.1.144] - 2026-06-08

### Added
- Evidence Bundle Contract + Luv profile editor board UI — v5.1.143 (#333)

## [5.1.143] - 2026-06-08

### Documentation
- Fix CHANGELOG entry for evidence-bundle verification (G1)

## [5.1.142] - 2026-06-08

### Added
- Add Evidence Bundle front-matter contract (G1)

## [5.1.141] - 2026-06-08

### Added
- **Evidence Bundle Contract (G1)** — VERIFICATION.md now requires a YAML front-matter block with required fields agents cannot skip: `scope_changed`, `uncovered` (must be explicit — empty = full coverage claimed), `confidence.overall` (computed from CONFIDENCE.md, not estimated), and `confidence.per_criterion` (one entry per AC with `why` root cause on every FAIL)
- **Sprint review vibe coder UX** — Phase 4 [4a] sprint summary now produces exactly two outputs: a `❓ DECISION REQUIRED` block (release / fix / scope down with evidence-derived recommendation) and a task list split into "Must fix" (FAIL verdicts) and "Should cover" (uncovered items), each with one actionable instruction
- Evidence bundle is the first governance prerequisite (G1) for the AHE Evolution Agent (G2) — enables programmatic gap analysis across sprints

## [5.1.140] - 2026-06-08

### Added
- **Luv model routing profiles** — `skills/luv-model-routing/` with quality, budget, and speed profiles
  - `quality`: Claude Opus 4.7 for strategy/analysis, Claude Sonnet 4.6 for copy and long-form, Claude Haiku 4.5 for fast iterations
  - `budget`: Claude Sonnet 4.6 for strategy, GPT-4o-mini for copy and long-form, Gemini Flash 2.0 for fast iterations
  - `speed`: Gemini 2.5 Flash for strategy/analysis, GPT-4o-mini for all text tasks
  - Image (`gpt-image-1`) and video (`kling-v1-5`) remain direct-API across all profiles
- **Profile resolution**: `$LUV_PROFILE` env → `.luv/active-profile` → `~/.cks/profiles/luv/active` → default `quality` (Hermes-tier aware)
- **`/cks:luv-profile` command** — view or switch the active Luv model routing profile
- **`OPENROUTER_API_KEY`** added to `CLAUDE.md` env vars table and `.env.local` label
- **Luv text agents wired for OpenRouter** — ads-copywriter, alan-sharpe, long-form-copywriter, brand-strategist now declare `Bash` tool and load `luv-model-routing` skill for programmatic routing

## [5.1.139] - 2026-06-08

### Added
- Optional self-hosted Honcho memory layer (augment, local-only)
- Per-project Telegram agent via /cks:telegram + onboarding offer

### Documentation
- Document OPENAI_API_KEY and KLING_API_KEY labels in CLAUDE.md env vars table (#331)

## [5.1.138] - 2026-06-08

### Maintenance
- Bump version after luv creative suite release (#330)
- Update docs: command count 120→123, agent count 89→161, skill count 110→142, rules count 18→22
- Update wiki What's New to reflect v5.1.137 creative suite and v5.1.134 arch-pattern-auto-invocation

## [5.1.137] - 2026-06-08

### Added
- **`luv-alan-sharpe` agent** — Alan Sharpe B2B direct response copywriter persona; Pencil framework (Problem→Evidence→Need→Claim→Invitation→Logic), industrial/professional services voice
- **`luv-brand-strategist` agent** — April Dunford positioning methodology (5-component Obviously Awesome framework) + Seth Godin brand philosophy (smallest viable audience, purple cow, generosity strategy); produces positioning statements, mission/vision, key messages, value proposition canvas, community strategy
- **`luv-photo-creator` agent** — Peter Belanger commercial photography aesthetic; generates images via OpenAI `gpt-image-1`; 6 named lighting presets; structured prompt template
- **`luv-video-creator` agent** — Kling API (kling-v1-5) text-to-video and image-to-video; platform specs (TikTok/LinkedIn/Instagram/YouTube/X); 8-element prompt structure; 3-variant deliverable standard
- **`positioning` skill** — April Dunford 5-component framework + Seth Godin brand philosophy; positioning stress-tests; community development phases; key messages YAML template; value proposition canvas
- **`photo-direction` skill** — Peter Belanger aesthetic; lighting configuration table; background palette; OpenAI gpt-image-1 API parameters; prompt construction template
- **`video-ai-direction` skill** — Kling API workflow; platform specs; motion language reference; the 5-second rule for ad creative
- **`/cks:creative` command** — direct creative suite dispatcher bypassing CMO hierarchy
- Upgraded **`luv-ads-copywriter`** to Joel Klettke VoC persona — Listen→Map→Write, Schwartz 5 awareness levels
- Upgraded **`luv-long-form-copywriter`** to TBWA\Media Arts Lab persona — Disrupt→Vision→Proof→Call, human truth first
- Updated **`luv-cmo`** team roster and 11-step campaign workflow with all new creative specialists
- Updated **`/cks:luv`** org chart to reflect full creative suite

## [5.1.136] - 2026-06-08

### Maintenance
- Merge main into feat/kickstart-idea-validation (v5.1.134)

## [5.1.135] - 2026-06-08

### Maintenance
- Remove project-usage artifacts from plugin repo

## [5.1.134] - 2026-06-08

### Maintenance
- Remove project-usage artifacts from plugin repo (`.concept/`, `.learnings/`, `.prd/` working files, `.agents/ecosystem-watch/` state files)

## [5.1.133] - 2026-06-07

### Added
- Idea validation artifacts at end of Phase 0 ideation
- Secrets-scan PreToolUse guard — deterministic credential backstop
- V5.1.125 — arch pattern auto-invocation + executive summary infographic (#318)
- /cks:remind command + reminder agent with one-shot wake registration
- Scheduled push of blockers/reminders (Hermes Mode P5)
- Resumable per-user threads (Hermes Mode P3)
- Architecture pattern auto-invocation — full lifecycle distributed pattern detection (v5.1.123)
- Wire inbound channel events through the concierge (Hermes Mode P1.5)
- Deterministic user-memory isolation guard (Hermes Mode security)
- Add multi-user durable memory (Hermes Mode P2)
- Add conversational Converse branch (Hermes Mode P1)
- McKinsey Strategy OS — 7 new consulting skills (v5.1.121)

### Fixed
- Restore pipeline — attractor_mode, skill namespace, artifact contract (#313)

### Documentation
- VPS deployment runbook for P4 (Telegram, always-on)
- Clarify CKS plugin is preserved (and extended) in Hermes Mode
- Add Hermes Mode design — CKS as always-on conversational agent

### Maintenance
- Release v5.1.131 — code-excellence skill for reviewer and code-simplifier (#323)
- Release v5.1.130
- Fix CHANGELOG duplicate Added block in v5.1.128
- V5.1.128 — impeccable/design-fluency wired into /cks:design lifecycle
- V5.1.126 — wire prompt-caching skill to lifecycle agents (#319)
- Remove superpowers artifacts + block superpowers:* skill usage

## [5.1.132] - 2026-06-07

### Added
- Secrets-scan PreToolUse guard — deterministic credential backstop
- V5.1.125 — arch pattern auto-invocation + executive summary infographic (#318)
- /cks:remind command + reminder agent with one-shot wake registration
- Scheduled push of blockers/reminders (Hermes Mode P5)
- Resumable per-user threads (Hermes Mode P3)
- Architecture pattern auto-invocation — full lifecycle distributed pattern detection (v5.1.123)
- Wire inbound channel events through the concierge (Hermes Mode P1.5)
- Deterministic user-memory isolation guard (Hermes Mode security)
- Add multi-user durable memory (Hermes Mode P2)
- Add conversational Converse branch (Hermes Mode P1)
- McKinsey Strategy OS — 7 new consulting skills (v5.1.121)

### Fixed
- Restore pipeline — attractor_mode, skill namespace, artifact contract (#313)

### Documentation
- VPS deployment runbook for P4 (Telegram, always-on)
- Clarify CKS plugin is preserved (and extended) in Hermes Mode
- Add Hermes Mode design — CKS as always-on conversational agent

### Maintenance
- Release v5.1.131 — code-excellence skill for reviewer and code-simplifier (#323)
- Release v5.1.130
- Fix CHANGELOG duplicate Added block in v5.1.128
- V5.1.128 — impeccable/design-fluency wired into /cks:design lifecycle
- V5.1.126 — wire prompt-caching skill to lifecycle agents (#319)
- Remove superpowers artifacts + block superpowers:* skill usage

## [5.1.131] - 2026-06-07

### Added
- `skills/code-excellence/SKILL.md` — unified "what good code looks like" skill covering naming & cognitive load, function/module boundaries, error handling strategy, testability as a design property, and idiom conformance
- `reviewer` and `code-simplifier` agents now load `code-excellence` skill

## [5.1.130] - 2026-06-07

### Added
- Secrets-scan PreToolUse guard — deterministic credential backstop
- V5.1.125 — arch pattern auto-invocation + executive summary infographic (#318)
- /cks:remind command + reminder agent with one-shot wake registration
- Scheduled push of blockers/reminders (Hermes Mode P5)
- Resumable per-user threads (Hermes Mode P3)
- Architecture pattern auto-invocation — full lifecycle distributed pattern detection (v5.1.123)
- Wire inbound channel events through the concierge (Hermes Mode P1.5)
- Deterministic user-memory isolation guard (Hermes Mode security)
- Add multi-user durable memory (Hermes Mode P2)
- Add conversational Converse branch (Hermes Mode P1)
- McKinsey Strategy OS — 7 new consulting skills (v5.1.121)

### Fixed
- Restore pipeline — attractor_mode, skill namespace, artifact contract (#313)

### Documentation
- VPS deployment runbook for P4 (Telegram, always-on)
- Clarify CKS plugin is preserved (and extended) in Hermes Mode
- Add Hermes Mode design — CKS as always-on conversational agent

### Maintenance
- Fix CHANGELOG duplicate Added block in v5.1.128
- V5.1.128 — impeccable/design-fluency wired into /cks:design lifecycle
- V5.1.126 — wire prompt-caching skill to lifecycle agents (#319)
- Remove superpowers artifacts + block superpowers:* skill usage

## [5.1.129] - 2026-06-07

### Added
- Secrets-scan PreToolUse guard — deterministic credential backstop
- V5.1.125 — arch pattern auto-invocation + executive summary infographic (#318)
- /cks:remind command + reminder agent with one-shot wake registration
- Scheduled push of blockers/reminders (Hermes Mode P5)
- Resumable per-user threads (Hermes Mode P3)
- Architecture pattern auto-invocation — full lifecycle distributed pattern detection (v5.1.123)
- Wire inbound channel events through the concierge (Hermes Mode P1.5)
- Deterministic user-memory isolation guard (Hermes Mode security)
- Add multi-user durable memory (Hermes Mode P2)
- Add conversational Converse branch (Hermes Mode P1)
- McKinsey Strategy OS — 7 new consulting skills (v5.1.121)

### Fixed
- Restore pipeline — attractor_mode, skill namespace, artifact contract (#313)

### Documentation
- VPS deployment runbook for P4 (Telegram, always-on)
- Clarify CKS plugin is preserved (and extended) in Hermes Mode
- Add Hermes Mode design — CKS as always-on conversational agent

### Maintenance
- V5.1.128 — impeccable/design-fluency wired into /cks:design lifecycle
- V5.1.126 — wire prompt-caching skill to lifecycle agents (#319)
- Remove superpowers artifacts + block superpowers:* skill usage

## [5.1.128] - 2026-06-07

### Added
- `agents/prd-designer.md` [2d]: runs `npx impeccable detect` on each generated screen HTML before the per-screen review question — maps findings to design verbs from the loaded `design-fluency` skill
- `commands/design.md`: dispatches `cks:design-fluency-reviewer` as a batch final pass across all screens after prd-designer returns, before ExitPlanMode

## [5.1.127] - 2026-06-07

### Added
- Executive summary infographic — one-page SVG for GitHub README
- Resumable per-user threads (Hermes Mode P3)
- Architecture pattern auto-invocation — full lifecycle distributed pattern detection (v5.1.123)
- Wire inbound channel events through the concierge (Hermes Mode P1.5)
- Deterministic user-memory isolation guard (Hermes Mode security)
- Add multi-user durable memory (Hermes Mode P2)
- Add conversational Converse branch (Hermes Mode P1)
- McKinsey Strategy OS — 7 new consulting skills (v5.1.121)

### Fixed
- Restore pipeline — attractor_mode, skill namespace, artifact contract (#313)

### Documentation
- Clarify CKS plugin is preserved (and extended) in Hermes Mode
- Add Hermes Mode design — CKS as always-on conversational agent

### Maintenance
- V5.1.126 — wire prompt-caching skill to lifecycle agents
- V5.1.125 — arch pattern auto-invocation + executive summary infographic
- Remove superpowers artifacts + block superpowers:* skill usage

## [5.1.126] - 2026-06-07

### Added
- Wire `prompt-caching` skill to 5 high-cost agents: `prd-orchestrator`, `prd-planner`, `prd-executor`, `evals-runner`, `bootstrap-generator` — activates MARK-ORDER-VERIFY guidance for all lifecycle-critical runs (skill was orphaned since creation)

## [5.1.125] - 2026-06-07

### Added
- **Architecture Pattern Auto-Invocation (Phase 08)** — deterministic keyword-triggered pattern detection at planning, sprint, and review gates; dispatches `cks:architecture-generator` before bad code ships
  - `skills/architecture/references/distributed-patterns.md` — 12-pattern catalog (DLQ, Saga, Circuit Breaker, State Machine, Service Mesh, CQRS, Event Sourcing, Outbox, Idempotency, Retry/Backoff, Bulkhead, Fan-out/Fan-in)
  - `.claude/rules/arch-patterns.md` — trigger rule with 3 lifecycle gates (planning, sprint, review)
- **Executive Summary Infographic** — dark-theme 800×820px SVG embedded in README; narrative covers 5-phase lifecycle, three pillars (arch safety nets, lifecycle discipline, Hermes Mode), stats, and install CTA

### Fixed
- Restore pipeline — attractor_mode, skill namespace, artifact contract (#313)

### Documentation
- Clarify CKS plugin is preserved (and extended) in Hermes Mode
- Add Hermes Mode design — CKS as always-on conversational agent

## [5.1.124] - 2026-06-07

### Added
- Architecture pattern auto-invocation — full lifecycle distributed pattern detection
- Deterministic user-memory isolation guard (Hermes Mode security)
- Add multi-user durable memory (Hermes Mode P2)
- Add conversational Converse branch (Hermes Mode P1)
- McKinsey Strategy OS — 7 new consulting skills (v5.1.121)

### Fixed
- Restore pipeline — attractor_mode, skill namespace, artifact contract (#313)

### Documentation
- Clarify CKS plugin is preserved (and extended) in Hermes Mode
- Add Hermes Mode design — CKS as always-on conversational agent

## [5.1.123] - 2026-06-07

### Added
- `AGENTS.md` — Hermes Agent standing orders for multi-harness compatibility
- `skills/hermes-agent/` — Hermes integration skill: scaffolding, AGENTS.md generation, skill mapping
- `skills/experts/core/` — Three expert distillation skills: expert-builder, expert-debugger, expert-product
- `skills/ai-agent-projects/` — AI agent project patterns skill
- `skills/mcp-server-authoring/` — MCP server authoring guidance skill
- `skills/schema-markup/references/` — Schema markup reference library
- `scripts/smoke-test.sh` — Lightweight smoke test runner script
- `.agents/skills/` — Agent-local skills directory scaffold

### Maintenance
- Remove all superpowers:* skill and agent artifacts; block superpowers:* invocations via guardrail rule

## [5.1.122] - 2026-06-07

### Added
- Deterministic user-memory isolation guard (Hermes Mode security)
- Add multi-user durable memory (Hermes Mode P2)
- Add conversational Converse branch (Hermes Mode P1)
- McKinsey Strategy OS — 7 new consulting skills (v5.1.121)

### Documentation
- Clarify CKS plugin is preserved (and extended) in Hermes Mode
- Add Hermes Mode design — CKS as always-on conversational agent

## [5.1.121] - 2026-06-06

### Added
- Standalone plan interrogator — skill + agent + command (v5.1.117)

## [5.1.119] - 2026-06-06

### Added
- Standalone plan interrogator — skill + agent + command (v5.1.117)

## [5.1.118] - 2026-06-06

### Maintenance
- Release v5.1.116 — grill-me plan interrogator

## [5.1.117] — 2026-06-06

### Added
- `skills/grill-me/SKILL.md` — standalone plan interrogator skill: recommend before asking, explore codebase before asking, one question at a time, walk decision tree in dependency order
- `agents/grill-me-interviewer.md` — Opus agent that loads grill-me skill and drives the relentless interview loop with per-question recommendations and codebase exploration
- `commands/grill.md` — thin dispatcher for `/cks:grill [plan-file]`; phase-unbound, works any time a user has a plan to stress-test


























## [5.1.116] - 2026-06-06

### Added
- Port gstack freeze + canary into CKS (v5.1.115) (#299)

### Maintenance
- Ecosystem-watch run 2026-06-01 — 17 new bulletins, 2 pending review
- Ecosystem-watch run 2026-05-25 — 29 new bulletins, 5 pending review

## [5.1.115] - 2026-06-06

### Added
- V4→v5 attractor migration remediation + audit (v5.1.114) (#298)

## [5.1.114] - 2026-05-24

### Maintenance
- Release v5.1.113 — skill lifecycle gate + artifact cleanup

## [5.1.113] - 2026-05-24

### Added
- `/cks:gate` command + `cks:gatekeeper` agent — human-gated skill lifecycle: quarantine → review → validated (live) or archived (restorable) (#297)
  - Candidates submitted as `CANDIDATE.md` in `skills/quarantine/` (inert to auto-discovery)
  - Gatekeeper runs 3 checks (format / conflict / scope) then always fires `AskUserQuestion` — no auto-promote path
  - Approve: renames to `SKILL.md` in `skills/validated/` (activates auto-discovery)
  - Reject: archives as `CANDIDATE.md` in `skills/archived/` (restorable)
  - Append-only audit trail in `memory/gatekeeper/review_log.md`
  - `memory/correction_log.md` scaffold for future self-learning improvements
- Command count: 111 → 112

### Maintenance
- Untrack `.prd/` session artifacts from git (were gitignored but still tracked) — keeps plugin repo clean

## [5.1.112] - 2026-05-24

### Added
- Add /cks:scale — 7-rung scaling advisor with maturity guardrails

## [5.1.111] - 2026-05-22

### Added
- Add vibe-coder human sign-off to UAT — GIF per AC + AskUserQuestion verdict (v5.1.110) (#295)

### Maintenance
- Release v5.1.108 — post-sprint cleanup + phase 06 complete (#294)

## [5.1.110] - 2026-05-22

### Maintenance
- Release v5.1.108 — post-sprint cleanup + phase 06 complete (#294)

## [5.1.109] - 2026-05-22

### Maintenance
- Session artifacts + version bump v5.1.107

## [5.1.108] - 2026-05-22

### Maintenance
- Remove stale eval golden cases, attractor run artifacts, and impeccable concept file (post-sprint cleanup)
- Mark phase 06 released — llms-txt-for-agents (#293)

## [5.1.106] - 2026-05-22

### Added
- Add scope:agent to cks:doc-generator — emit llms.txt for coding agents (v5.1.103) (#293)

## [5.1.105] - 2026-05-22

### Added
- /cks:ship command — clean project docs, bump, PR (v5.1.103) (#292)

## [5.1.104] - 2026-05-22

### Added
- /cks:ship command — clean project docs, bump, PR (v5.1.103)

## [5.1.103] - 2026-05-22

### Added
- `/cks:ship` command + `ship-runner` agent — clean project docs, bump version, commit, push, open PR
- `.gitignore` coverage for remaining `.prd/` project-state files (HANDOFF.md, PRD-STATE.md, work-hierarchy.md, prd-config.json, session-*.md)

## [5.1.102] - 2026-05-22

### Added
- Design-fluency skill + visual-slop linter via impeccable (v5.1.101) (#290)
- Cks:uat — eval AC matrix quality + debug loop (v5.1.102) (#289)

## [5.1.101] - 2026-05-22

### Added
- Add code-comments rule + pre-commit scan to verification (v5.1.100) (#288)

## [5.1.100] - 2026-05-22

### Fixed
- Integrity checker false failures + stale help.md entry (v5.1.98)

## [5.1.99] - 2026-05-22

### Added
- /cks:concept — concept feasibility evaluator with brainstorm-first pipeline (v5.1.97) (#286)

### Fixed
- Sprint pipeline — move attractor orchestration from sub-agent to skill (v5.1.94) (#285)

## [5.1.98] - 2026-05-22

### Maintenance
- Release v5.1.97

## [5.1.97] - 2026-05-22

### Added
- /cks:concept — concept feasibility evaluator with brainstorm-first pipeline

## [5.1.96] - 2026-05-22

### Fixed
- Sprint pipeline — move attractor orchestration from sub-agent to skill (v5.1.94)

## [5.1.95] - 2026-05-22

### Added
- Generate-evaluate-repair loop — wire eval failures to auto-fixer (v5.1.93)

## [5.1.93] - 2026-05-22

### Added
- `skills/evals/workflows/generate-evaluate-repair.md` — loop algorithm: classify failure (code/prompt/golden), dispatch fixer, re-run failing cases, cap at 2 iterations, escalate with structured block
- `agents/evals-runner.md` — `--auto-repair` flag: when set, classifies failure type and dispatches cks:debugger (code) or cks:prd-executor-worker (prompt) instead of asking user; default behavior unchanged
- `agents/prd-executor.md` — step 5c eval gate: scans PLAN.md for AI/LLM trigger patterns; if found, runs smoke evals with --auto-repair before writing SUMMARY.md; blocks build if smoke fails after repair loop exhausted
- `agents/debugger.md` — eval-repair mode: new row in mode detection table; reads failing case input.yaml + assertion + actual output, traces root cause, dispatches worker to apply fix

## [5.1.92] - 2026-05-22

### Added
- Eval system runtime layer — judge prompt, golden cases, lifecycle rules (v5.1.90) (#283)

## [5.1.90] - 2026-05-22

### Added
- Eval system runtime layer: `.evals/judge-prompt.md` global LLM-as-judge template + feature-level rubric for `prd-discoverer`
- 5 seed golden cases for `prd-discoverer` (ctrl-001 smoke, edge-001/002 standard, boundary-001/002 standard) with deterministic YAML assertions + LLM-judge path
- `.evals/baseline.json` regression anchor (seeded empty, populated after first comprehensive run)
- `.claude/rules/evals.md` — lifecycle gate rules: smoke at build [3c], standard at review [4a], comprehensive at release [5c]
- `docs/EVALS.md` — eval system concept overview and entry point reference

## [5.1.89] - 2026-05-22

### Fixed
- `agents/debugger.md` subagent_type `debugger` → `cks:debugger` — all dispatch was broken (#273)
- Wave labels: explicit `gh label create` before `--add-label` (#274)
- `debug/SKILL.md` mode table missing issue-driven / multi-issue / wave modes (#275)
- `failure-classify.yaml` + 8 stub recovery recipes in `skills/debug/recipes/` (#276)
- Label taxonomy reconciled across investigator + github-issues skill (#277)
- Parser fallback: missing/empty `## Dependencies` defaults to wave 1, no crash (#278)
- Cross-filer dedup: prefix-match → keyword-based title matching (#279)
- `investigate.md` trimmed 65 → 60 lines; Project Sync block moved into agent (#280)

### Added
- Convergence loop, skill promotion, worktree-isolation guard (#271)

## [5.1.87] - 2026-05-20

### Maintenance
- CHANGELOG for v5.1.85 — dependency-aware issue schema (phase 06)

## [5.1.86] - 2026-05-20

### Changed
- Add VERIFICATION.md for phase 06 (all ACs pass; E2E gate deferred)

## [5.1.86] — 2026-05-20

### Added — Dependency-Aware Issue Schema (Phase 06)

- **Structured `## Dependencies` section** in every CKS-opened GitHub issue. Four fields: `depends-on`, `file-scope`, `root-cause`, `symptom-of`. Added to the canonical issue-body template in `skills/github-issues/SKILL.md` and the inline `[INV]` template in `agents/investigator.md`.
- **Wave-based parallel debug dispatch.** `cks:debug --all` (and `--issues`) now parses the `## Dependencies` section, topologically sorts issues into dependency waves, applies `cks:wave-N` labels, and dispatches parallel workers wave-by-wave — sequential waves, parallel within each wave. New Step 1.5 in `skills/debug/workflows/mode-multi-issue.md`.
- **Symptom deduplication.** Issues declaring `symptom-of: #N` are dropped from dispatch when `#N` is in the same run, since fixing the root cause resolves the symptom.
- **Cycle guard.** A dependency cycle is reported explicitly and halts dispatch (no auto-resolve), mirroring the existing merge-conflict policy.
- **`cks:wave-{N}` label family** documented in the label taxonomy (created on demand during the debug run, not pre-seeded).

### Changed (BREAKING — Pilot impact)

- Issue output format from `cks:investigate`, `cks:uat`, and `cks:test` now includes the `## Dependencies` section. This is a breaking change to agent issue output. Existing issues filed before this version lack the section — the wave parser treats a missing section as `depends-on: empty` → wave 1 (graceful fallback, no crash).

### Notes

- `agents/prd-verifier.md` and `agents/uat-runner.md` were intentionally not modified: prd-verifier uses the `github-issues` skill template, and uat-runner files issues via the investigator — both covered transitively.
- Static + algorithm-logic verification complete (all 7 acceptance criteria pass). Live 3-issue runtime verification is the deferred Pilot manual gate.


























## [5.1.88] - 2026-05-21

### Added
- Convergence-driven sprint QA loop in prd-orchestrator — bounded by `convergence.max_sprint_iterations` (default 3) and the verifier's 2-FAIL anti-loop, with a targeted fix-recipe handoff to the executor instead of a blind retry (#271)
- Self-accumulating skill promotion in retrospective — procedural learnings graduate to project-local skills (`.claude/skills/{topic}/SKILL.md`) via skill-creator, alongside declarative rule promotion (#271)
- Worktree-isolation advisory hook (PreToolUse on Edit/Write/MultiEdit) — warns when production code is edited outside a git worktree (#271)

### Documentation
- `docs/code-as-agent-harness-gap-analysis.md` mapping the "code as agent harness" survey to CKS (#271)
- Refresh README/CLAUDE/wiki counts (107 commands, 141 agents, 110 skills, 18 rules) (#271)











## [5.1.85] - 2026-05-20

### Added
- Dependency-aware issue schema + wave-based debug dispatch (phase 06)

## [5.1.84] - 2026-05-20

### Added
- Voice — provision via Telnyx MCP directly, no n8n (#269)

## [5.1.83] - 2026-05-20

### Added
- Voice — Telnyx phone + WebRTC widget as primary platform (#268)

## [5.1.82] - 2026-05-20

### Added
- CKS Conversational Orchestrator — concierge + Slack + voice (v5.1.80) (#267)

### Fixed
- Repair malformed PRD-STATE table rows (hook truncation artifact)

## [5.1.81] - 2026-05-20

### Added
- Update README/help (+3 commands: concierge, slack, voice), bump to v5.1.79
- Add concierge/slack/voice agents, commands, slack-notify hook (CKS conversational orchestrator)
- Add concierge, slack, voice skills (CKS conversational orchestrator)

## [5.1.79] - 2026-05-20

### Maintenance
- Release v5.1.78 — post-v6 state update + notes.txt gitignore

## [5.1.78] - 2026-05-20

### Maintenance
- Update PRD state history post v6 release + add notes.txt to .gitignore

## [5.1.77] - 2026-05-20

### Added
- CKS v6 Control Plane — Phases 3-6 (agent coordination, observability, self-improvement, hardening) v5.1.75 (#266)
- Add monetize-roadmap agent — fix missing phase capture (v5.1.71) (#265)

## [5.1.76] - 2026-05-20

### Maintenance
- Release v5.1.75 — CKS v6 Control Plane complete (Phases 3-6)

## [5.1.75] - 2026-05-20

### Added
- CKS v6 Control Plane complete — Phases 3–6 wired into session lifecycle hooks
- Phase 3: Agent coordination — registry (claim/release/clean), multi-session awareness, `/cks:agents`, Supabase `agent_sessions` table
- Phase 4: Observability — session duration tracking, tool-call counter, cost banner, `/cks:cost`, Supabase `observability_sessions` table
- Phase 5: Self-improvement loop — confidence-scored proposals, `/cks:improve` (analyze/list/apply/reject), Supabase `improvements` table
- Phase 6: Production hardening — health check, backup/restore, sync-queue drain, `/cks:control-plane` extended, Supabase `cp_health_log` table
- All phases wired into `session-start.sh` (start + banner) and `stop.sh` (cleanup + sync) hooks
- `control-plane-init.sh` scaffolds all Phase 3–6 directories on first run

## [5.1.71] - 2026-05-20

### Added
- CKS v6 Phase 2 — memory layer (v5.1.69) (#264)
- monetize-roadmap agent — fix missing phase capture

## [5.1.70] - 2026-05-20

### Added
- CKS v6 Phase 2 — memory layer (v5.1.69) (#264)

## [5.1.69] - 2026-05-20

### Added
- **v6 Phase 2 — Memory Layer**: per-agent `.md` memory files, project knowledge base (facts/decisions/gotchas), and dated session continuity snapshots
- `skills/control-plane/migrations/002_memory.sql` — `memory` table with natural unique key `(org_id, project_id, memory_type, agent_id, key)`, RLS policies, safe to re-run
- `scripts/memory-sync.sh` — deterministic file-to-Supabase sync: reads `supabase_url` from `config.yaml`; present → REST API upsert at session end; absent → zero network calls (dev mode)
- `scripts/stop-memory.sh` — writes dated session snapshot then calls memory-sync; called from Stop hook
- `commands/memory.md` + `agents/memory-agent.md` — `/cks:memory` command to view/search/manage KB and session snapshots
- Memory summary line in SessionStart banner (last session, KB fact/decision counts)
- `control-plane-init.sh` now scaffolds `memory/agents/`, `memory/project/`, `memory/sessions/` with template files

## [5.1.68] - 2026-05-20

### Fixed
- Marketplace.json root version drift + bump script jq fix (v5.1.67) (#263)

## [5.1.67] - 2026-05-20

### Added
- CKS v6 Phase 0 + Phase 1 — control plane personas, RAID log, heartbeat engine (v5.1.66)
- /cks:pivot + /cks:marketing* — pivot workflow and marketing agency commands (v5.1.53) (#259)
- 3 core experts + 22 specialists + /cks:expert command (v5.1.58) (#260)
- Remove /cks:parallel — tmux C.W.A.S. workspace command (#258)

## [5.1.66] - 2026-05-20

### Documentation
- Add /cks:heartbeat to command index and help (95 commands total)

## [5.1.65] - 2026-05-20

### Added
- Extend session-start hook with Phase 1 heartbeat agent count

## [5.1.64] - 2026-05-20

### Added
- Add cks:heartbeat-agent + /cks:heartbeat command

## [5.1.63] - 2026-05-20

### Added
- Add Phase 1 migration + db-query-patterns reference

## [5.1.62] - 2026-05-20

### Fixed
- Rewrite generate-persona-manifest as Python + bash wrapper

## [5.1.61] - 2026-05-20

### Added
- Add /cks:personas, /cks:control-plane commands + personas-agent

## [5.1.60] - 2026-05-20

### Added
- Add generate-persona-manifest.sh + domain: field to persona files

## [5.1.59] - 2026-05-20

### Added
- Add RAID log template with grep-compatible append-only format

## [5.1.58] - 2026-05-20

### Added
- Add 10 default professional persona files for CKS v6 control plane
- Add team persona manifest.yaml (Tier 1 — 10 personas, session start)

## [5.1.57] - 2026-05-20

### Added
- Add team persona manifest.yaml (Tier 1 — 10 personas, session start)

## [5.1.56] - 2026-05-20

### Added
- Add control-plane-init.sh scaffold script

## [5.1.55] - 2026-05-20

### Added
- Add control plane activation gate to session-start hook

## [5.1.54] - 2026-05-20

### Added
- Add config.yaml template for control plane activation gate

## [5.1.53] - 2026-05-20

### Added
- Scaffold skills/control-plane/ directory structure for v6 Phase 0
## [5.1.53] - 2026-05-20

### Added
- Add /cks:pivot — strategic pivot command + analyzer agent


## [5.1.52] - 2026-05-20

### Maintenance
- Ignore .worktrees/ directory

## [5.1.51] - 2026-05-20

### Added
- Remove /cks:parallel — tmux C.W.A.S. workspace command

## [5.1.50] - 2026-05-20

### Added
- Luv Marketing agency — 34 agents, 23 skills, /cks:luv command with full orchestration

## [5.1.49] - 2026-05-20

### Added
- Compliance surface detection — skill, agent, command, lifecycle gates (v5.1.48) (#256)
- Add prompt-caching skill — MARK-ORDER-VERIFY, economics, silent invalidators (v5.1.47) (#255)

## [5.1.48] - 2026-05-20

### Added
- Compliance surface detection — skill, agent, command, lifecycle gates for GDPR/PCI/HIPAA/SOC 2 (#256)

## [5.1.47] - 2026-05-20

### Added
- Prompt-caching skill — MARK-ORDER-VERIFY, cost economics, silent invalidators, pre-warming, provider portability (#255)
- P1 marketing execution layer — copywriting, launch strategy, social content, analytics tracking (#254)

## [5.1.46] - 2026-05-20

### Added
- Design tool integration + Recommended: propagation (v5.1.44/5.1.45) (#253)

## [5.1.45] - 2026-05-20

### Fixed
- Propagate mandatory Recommended: line to all DECISION REQUIRED blocks

## [5.1.44] - 2026-05-20

### Added
- Design tool integration — Claude.ai/design and Google Stitch as first-class design system sources
  - `kickstart-brand`: Brand phase now offers "use a design tool" option with ACTION REQUIRED block guiding user to Claude.ai/design or Stitch, then imports via URL
  - `design-system-generator`: Recognizes Claude.ai/design and Google Stitch URL patterns; extracts CSS custom properties and component HTML specific to each tool's output; stamps import source in DESIGN.html header
  - `prd-designer`: Stitch MCP screen prompts now inject design tokens (primary/accent hex, font family, border-radius, background) parsed from DESIGN.html; warns when no DESIGN.html present rather than silently using generic styles
  - `commands/design-system`: Quick reference lists Claude.ai/design and Stitch as named first-class URL sources

## [5.1.43] - 2026-05-20

### Documentation
- Expand CHANGELOG entries for v5.1.40–5.1.41

## [5.1.42] - 2026-05-20

### Added
- /cks:adopt reconciliation — delta catalog, dedup phases, dedup roadmap (v5.1.41) (#251)
- Context-aware AI recommendation at every decision point (#250)

## [5.1.41] - 2026-05-20

### Added
- `/cks:adopt` reconciliation — delta catalog and dedup: `--delta` flag skips features already present in PRD-ROADMAP.md; duplicate phases and duplicate roadmap entries are automatically merged rather than appended

### Changed
- Context-aware AI recommendation at every decision point — Recommendation Engine reads PRD-PROJECT.md (maturity, business goals), PRD-ROADMAP.md (downstream deps), VERIFICATION.md, and BACKLOG.md before declaring the best next move; roadmap blocking weighs highest in priority order
- Mandatory `Recommended:` field in all `DECISION REQUIRED` blocks (human-intervention.md rule) — grounded in observable evidence, never a generic default
- `(Recommended)` label marker on `AskUserQuestion` lifecycle options so users see the AI's pick at a glance
- Review completion banner now shows exact next command (`/cks:release NN`, `/cks:sprint NN`, etc.) instead of generic `/cks:next`
- Auto-propagated recommendations to parallel-launcher, work-hierarchy-manager, and sprint planning DECISION REQUIRED blocks

## [5.1.39] - 2026-05-20

### Added
- Adopt reconciliation — delta catalog, dedup phases, dedup roadmap

## [5.1.38] - 2026-05-20

### Added
- Architecture design & communication — ARCHITECTURE.md + ADRs (#249)
- HTML Artifacts mini-site — DESIGN.html, PRD.html, PLAN.html with shared nav (v5.1.35) (#248)

## [5.1.37] - 2026-05-19

### Added
- Architecture design & communication — ARCHITECTURE.md + ADRs

## [5.1.35] — 2026-05-19

### Added
- `skills/prd/references/html-shell.md` — shared nav shell template for CKS HTML artifact mini-site (Design, Brand, PRD, Plan, ERD, Features tabs)

### Changed
- `skills/design-system/SKILL.md` — updated to produce `DESIGN.html` (interactive, browser-viewable) instead of `DESIGN.md`; added rendered swatch, type specimen, and component HTML structure requirements
- `agents/design-system-generator.md` — generates `DESIGN.html` with nav shell, brand color extraction, and rendered components; preserves existing `DESIGN.md` as read-only input source
- `agents/prd-planner.md` — produces `PRD-{NNN}.html` and `{NN}-PLAN.html` with mini-site nav shell and structured HTML layouts
- `agents/prd-designer.md` — reads `DESIGN.html` first for design tokens, falls back to `DESIGN.md`
- `agents/bootstrap-generator.md` — added `Agent` + `AskUserQuestion` tools; generates `DESIGN.html` after CLAUDE.md if brand signals exist
- `agents/kickstart-brand.md` — dispatches design-system-generator for `DESIGN.html` instead of `DESIGN.md`
- `commands/design-system.md` — re-run detection and dispatch updated to `DESIGN.html`
- `skills/kickstart/workflows/brand.md` — Step 5 updated to generate `DESIGN.html`

---

## [5.1.36] - 2026-05-19

### Added
- HTML Artifacts mini-site — DESIGN.html, PRD.html, PLAN.html with shared nav (v5.1.35)

## [5.1.35] — 2026-05-19

### Added
- `skills/prd/references/html-shell.md` — shared nav shell template for CKS HTML artifact mini-site (Design, Brand, PRD, Plan, ERD, Features tabs)

### Changed
- `skills/design-system/SKILL.md` — updated to produce `DESIGN.html` (interactive, browser-viewable) instead of `DESIGN.md`; added rendered swatch, type specimen, and component HTML structure requirements
- `agents/design-system-generator.md` — generates `DESIGN.html` with nav shell, brand color extraction, and rendered components; preserves existing `DESIGN.md` as read-only input source
- `agents/prd-planner.md` — produces `PRD-{NNN}.html` and `{NN}-PLAN.html` with mini-site nav shell and structured HTML layouts
- `agents/prd-designer.md` — reads `DESIGN.html` first for design tokens, falls back to `DESIGN.md`
- `agents/bootstrap-generator.md` — added `Agent` + `AskUserQuestion` tools; generates `DESIGN.html` after CLAUDE.md if brand signals exist
- `agents/kickstart-brand.md` — dispatches design-system-generator for `DESIGN.html` instead of `DESIGN.md`
- `commands/design-system.md` — re-run detection and dispatch updated to `DESIGN.html`
- `skills/kickstart/workflows/brand.md` — Step 5 updated to generate `DESIGN.html`

---

## [5.1.35] - 2026-05-19

### Added
- Add accuracy-priming language to 8 agents and skills

## [5.1.34] - 2026-05-19

### Maintenance
- Release v5.1.33 — parallel path fixes + handoffs gitignored

## [5.1.33] - 2026-05-19

### Fixed
- `/cks:parallel` worker briefs now use correct relative paths (`src/`, `tasks/`) — workers no longer look for `../src/` which broke path resolution inside panes
- `parallel-launcher` agent now writes `BIGPICTURE.md` and `STATUS.md` as explicit steps (9a/9b) before remaining artifacts, ensuring shared context exists before workers start

### Added
- `BIGPICTURE.md` and `STATUS.md` templates added to `skills/parallel/SKILL.md` — launcher has a complete spec to follow

### Removed
- Deleted 12 stale `.prd/handoffs/` files — these are session-local artifacts, not plugin content
- Added `.prd/handoffs/` to `.gitignore` so future handoffs are never shipped with the plugin

## [5.1.32] - 2026-05-19

### Added
- `/cks:investigate` and `/cks:test` now read PREFLIGHT.md — scope investigation to §P (Position) and §F (Flag); surface §E (Establish) acceptance-criteria coverage gaps in the test runner
- Parallel skill (C.W.A.S.): BIGPICTURE.md shared context, STATUS.md live progress board, question/answer protocol between workers and Controller

### Changed
- `.gitignore` — ignore `.prd/handoffs/` (generated session artifacts)

## [5.1.31] - 2026-05-19

### Added
- `/cks:uat` command — end-of-feature UAT driven by PREFLIGHT.md acceptance criteria + CONTEXT.md DoD; browser-automated via Claude-in-Chrome; files GitHub issues for failures; writes dated `.uat/` report
- `cks:uat-runner` agent — orchestrates AC loading (PREFLIGHT §E → CONTEXT DoD → SUMMARY fallback), test matrix generation, browser dispatch, issue filing
- `skills/uat/SKILL.md` — UAT methodology: AC source priority, test matrix patterns by feature type, pass/fail criteria, preflight integration
- BrowserUAT pipeline node (`review-merge-loop.md §BrowserUAT`) now reads PREFLIGHT.md + CONTEXT.md acceptance criteria before dispatching browser agent

## [5.1.30] - 2026-05-19

### Added
- /cks:triage command + kickstart brand domain & business name check (v5.1.29)

## [5.1.29] - 2026-05-19

### Added
- `/cks:triage` command + `triage-runner` agent — triage PRs, stale branches, and GitHub issues with ACTION REQUIRED blocks per item
- Kickstart brand Phase 4: domain + business name availability check (Step 3.5) — checks `.com .io .co .ai .ca .app .dev .net`, USPTO/CIPO trademark search, web presence, social handles; results saved to `brand.md`
- `WebSearch` added to `kickstart-brand` agent tools for trademark/business name queries
- Instant Domain Search MCP wired into brand agent via `mcp__*` wildcard

## [5.1.28] - 2026-05-19

### Documentation
- Fix CHANGELOG v5.1.26 entry + add session handoff artifacts

## [5.1.27] - 2026-05-19

### Documentation
- Fix CHANGELOG v5.1.26 entry — correctly attribute skill description optimization to PR #243

## [5.1.26] - 2026-05-19

### Performance
- Trim 15 verbose skill descriptions from 60–108 words to ≤20 words each — saves ~4–5k tokens per session (PR #243)

## [5.1.25] - 2026-05-19

### Documentation
- Clean CHANGELOG — fix v5.1.23 entry text, remove on-branch noise

## [5.1.24] - 2026-05-18

### Added
- Add /cks:parallel — tmux C.W.A.S. parallel workspace generator (#241)
- Ecosystem-watch — living knowledge system for agent awareness (#240)

### Changed
- Release v5.1.23 — ecosystem-watch + sentry-sdk-setup skill (#242)

## [5.1.23] - 2026-05-18

### Maintenance
- Version bump following merge of PR #242 (ecosystem-watch + sentry-sdk-setup); no functional changes beyond v5.1.22

## [5.1.22] - 2026-05-18

### Added
- **`ecosystem-watch` skill** — living knowledge store for ecosystem changes; tracks SDK updates, deprecations, and breaking changes agents encounter across sessions
- **`ecosystem-learner` + `ecosystem-watcher` agents** — learner extracts ecosystem signals from code/errors; watcher synthesizes trends and surfaces upgrade paths
- **`/cks:learn` command** — triggers ecosystem learning pipeline to capture signals from the current session
- **`sentry-sdk-setup` skill** — router skill from getsentry/sentry-for-ai (Apache-2.0); detects platform and loads the correct Sentry SDK sub-skill for 19 platforms

### Maintenance
- Wire `ecosystem-watch` into `prd-planner`, `prd-executor`, `db-migration`, and session-start alert
- Session-start banner surfaces ecosystem alerts when ecosystem watch has pending signals

## [5.1.16] - 2026-05-17

### Added
- Add cks-stack skill — 26-layer production stack reference (#239)
- Propagate user profile to all agents via core-behaviors + session context (#237)

## [5.1.15] - 2026-05-17

### Added
- Add cks-stack skill — 26-layer production stack reference
- Propagate user profile to all agents via core-behaviors + session context (#237)

## [5.1.14] - 2026-05-17

### Added
- Pre-catalog detection in cks:new + bootstrap phase stub creation (v5.1.13)

## [5.1.13] - 2026-05-17

### Added
- **Pre-catalog detection in `cks:new`** — kebab-normalizes feature name and greps `PRD-ROADMAP.md` before assigning a new phase slot; reuses existing NN when exactly one match found (idempotent mkdir), emits `❓ DECISION REQUIRED` on ambiguous matches, falls back to next-available NN on zero matches
- **Bootstrap phase stub creation** — `cks:bootstrap` now runs `scripts/create-phase-stubs.sh` after the generator (Phase 2.5), creating stub `CONTEXT.md` files for each catalog entry; no-op when `.bootstrap/features-catalog.md` absent
- **Log events** — `feature.reused`, `feature.created`, `bootstrap.cataloged`, `bootstrap.stubs_created` emitted to `.prd/logs/lifecycle.jsonl` for traceability
- **`Bash` added to `cks:bootstrap` allowed-tools** — required for Phase 2.5 script invocation

## [5.1.12] - 2026-05-17

### Fixed
- **Handoff dual-write enforced** — `skills/handoff/SKILL.md` now mandates writing both a unique timestamped archive (`.prd/handoffs/HANDOFF-{ts}-{branch}.md`) and a pointer (`.prd/HANDOFF.md`); previously agents only saw the single-file instruction
- **Pointer auto-consumed on session resume** — `session-start.sh` deletes `.prd/HANDOFF.md` after displaying the ⚡ HANDOFF RESUME block; archive in `.prd/handoffs/` is preserved permanently
- **Standup + sprint-start fallback to archive** — both commands now check `.prd/handoffs/` when the pointer is absent (which it is after session-start consumes it)

## [5.1.11] - 2026-05-16

### Added
- User profile system: `/cks:me` command, `agents/user-profiler.md`, `skills/user-profile/` — personalizes CKS behavior per user
- Session start banner shows user profile status with `/cks:me` prompt when profile is absent
- `user-profile` skill wired into prd-discoverer, session-journalist, and sprint-reviewer agents

### Fixed
- Bulk-close 17 auto-filed issues across attractor pipeline, debugger dispatch-first, and kickstart agent wiring

## [5.1.10] - 2026-05-16

### Fixed
- Close attractor issues #195-#203 — update sprint.md Quick Reference to Attractor nodes

## [5.1.9] - 2026-05-16

### Fixed
- Close 17 auto-filed issues: attractor pipeline wiring (#195-#203), debugger dispatch-first violations (#141-#143, #145), kickstart agent paths and Skill() misuse (#188, #190, #191)
- Fix /cks:sprint to dispatch attractor-runner, not prd-planner (#195)
- Fix nodeToColumn map to cover all 10 pipeline nodes (#196)
- Add Attractor State table to PRD-STATE.md template (#197)
- Set attractor_mode: false as default in plugin.json (#200)
- Remove Python attractor package import from assess-runner (#201)
- Remove Edit from debugger tools; enforce dispatch-first isolation (#145)


## [5.1.9] - 2026-05-16

### Fixed
- Remove Edit from debugger tools — enforce dispatch-first isolation

## [5.1.8] - 2026-05-16

### Added
- Encode plan mode transitions in sprint.dot + attractor-runner
- Auto EnterPlanMode after discovery, ExitPlanMode after design
- Deterministic phase stubs from feature catalog (#232)

## [5.1.7] - 2026-05-16

### Added
- Auto EnterPlanMode after discovery, ExitPlanMode after design

## [5.1.6] - 2026-05-16

### Maintenance
- Release v5.1.5 (#230)

## [5.1.5] - 2026-05-15

### Fixed
- Enforce AskUserQuestion tool calls — no more plain text questions (#229)

## [5.1.4] - 2026-05-15

### Fixed
- Enforce AskUserQuestion tool across all phases and agents

## [5.1.3] - 2026-05-15

### Maintenance
- Fix duplicate PR ref in CHANGELOG and remove dead workflow reference (#228)

## [5.1.2] - 2026-05-15

### Added
- Kickstart Phase 3.5 — feature discovery + MVP scoping (#227) (#227)

## [5.1.1] - 2026-05-15

### Added
- Bootstrap Step 3b — version stamp, dirs, prd-config, lifecycle log (#226)

## [5.1.0] - 2026-05-15

### Added
- **Kickstart Phase 3.5 — Feature Scope** — new `agents/kickstart-feature-scope.md` (model: opus) slots between Monetize and Brand. Runs an interactive feature-elicitation interview with grill-me probing, calibrates MVP cut to maturity stage (Prototype → max 3 features, Production → full set), and produces three `.prd/` artifacts: `FEATURES.md` (full inventory tagged `mvp`/`v2`/`cut`), `MVP-CUTLINE.md` (one-sentence thesis + minimum feature set), and `OUT-OF-SCOPE.md` (explicitly rejected features with rationale)
- **prd-discoverer warm discovery mode** — when `.prd/FEATURES.md` exists and contains a matching MVP feature entry, prd-discoverer pre-fills Elements 1-3 (Problem, User Stories, Scope) from the feature-scope session and asks only the feature-specific elements (API surface, acceptance criteria, test plan, UAT, DoD, success metrics) — reduces cold 11-element interview to a focused ~5-call warm flow
- **kickstart-designer FEATURES.md scoping** — when `.prd/FEATURES.md` exists, design artifacts (ERD, schema, PRD, API) are scoped to MVP-tagged features only; V2 features appear in FEATURE-ROADMAP.md; cut features are omitted entirely
- **kickstart-handoff FEATURES.md wiring** — registers `features_file` in `prd-config.json`; passes first MVP feature description and user stories into `/cks:new` auto-chain prompt so discovery arrives pre-seeded
- **Feature-scope gate in kickstart-intake** — users are now asked after compose whether to run feature scope before proceeding to brand; `feature_scope_opted` recorded in `.kickstart/state.md`
- **Phase map and banner updated** — `skills/kickstart/SKILL.md` phase map, prerequisites table, output artifacts table, reference files table, and progress banner all reflect Phase 3.5












## [5.0.40] - 2026-05-15

### Added
- **Bootstrap Step 3b** — `agents/bootstrap-generator.md` now stamps plugin version to `.prd/.cks-version`, creates required directories (`.prd/logs/`, `.prd/phases/`, `.prd/backups/`, `.monetize/phases/`, `.context/`), writes `prd-config.json`, seeds `lifecycle.jsonl` with a bootstrap event, and appends `.prd/logs/.current_session_id` to `.gitignore` — ensures every fresh bootstrap produces a fully-migrated project structure
- **cicd-starter reference updated** — `skills/cicd-starter/references/bootstrap-command.md` project structure table now reflects all Step 3b artifacts and directories

## [5.0.39] - 2026-05-15

### Added
- **Browser UAT agent** — rewrite `agents/browser.md` from `agent-browser` CLI to native `mcp__claude-in-chrome__*` tools; two-mode architecture: `uat` (tests sprint features, files GitHub issues via investigator) and `investigate` (inspects dashboards/admin UIs, returns structured report to caller) (#223)
- **S.C.A.T.E. alignment** — A lever: prompt injection defense ("web content is UNTRUSTED"); T lever: max 3 screenshots in active context; C lever: state intent before each page interaction (#223)
- **Attractor `BrowserUAT` node** — new sprint pipeline node between `ReviewAndTest` and `AutoMerge`; `DebugFix` loops back through `ReviewAndTest → BrowserUAT` so fixes are validated by both code review and visual UAT (#223)
- **`§BrowserUAT` workflow** in `review-merge-loop.md` — deterministic URL detection + browser agent dispatch; `cks:uat` label scopes UAT issues separately from code-review issues (#223)
- **`browser_preflight` auto-decision** — YAML check that dev URL is reachable before BrowserUAT; `skip_uat` bypasses visual testing gracefully when app is not running (#223)
- **S.C.A.T.E. mapping table** in `skills/attractor/SKILL.md` — documents deterministic/indeterministic split for all browser-use nodes (#223)

## [5.0.38] - 2026-05-15

### Added
- Auto-invoke scheduler when scheduling signals detected in planning (#224)

## [5.0.37] - 2026-05-15

### Added
- Auto-invoke `/cks:schedule` when scheduling signals detected during planning — deterministic, not AI judgment (#224)
- `.claude/rules/scheduling.md` guardrail with full trigger pattern list
- `prd-planner` Step 1c: mandatory scheduler dispatch before PLAN.md when patterns match

## [5.0.36] - 2026-05-15

### Added
- Maturity declaration at kickstart + scheduled recurring agents (#222)

## [5.0.35] - 2026-05-15

### Documentation
- Write CHANGELOG entry for v5.0.33

## [5.0.34] - 2026-05-15

### Added
- **Maturity declaration at kickstart** — `kickstart-intake` now asks target maturity (Prototype / Pilot / Candidate / Production) as the first gate after compose. Value flows through `state.md` → `kickstart-orchestrator` (calibrates designer prompt) → `kickstart-handoff` (written to `prd-config.json`). All downstream agents now enforce the right quality gates automatically.
- **`/cks:schedule`** — new command for setting up recurring agents. `cks:scheduler` agent interviews the user, writes `.agents/{name}/state.json`, and registers a `CronCreate` schedule.
- **`skills/scheduled-agents/`** — three production-ready recurring agent templates: Analytics (DB query + trend delta vs prior run), Sentiment monitoring (parallel fan-out across sources), Asset generation (dated deliverable from repo + brand). All use a state-file + dated-output loop for memory across runs.

## [5.0.32] - 2026-05-15

### Maintenance
- Release v5.0.31

## [5.0.31] - 2026-05-15

### Changed
- Gitignore `docs/ATTRACTOR-REBUILD.md` — dev planning artifact, not plugin source (`docs/prds/` was already gitignored)

## [5.0.30] - 2026-05-15

### Added
- Enforce interactive design gates — AskUserQuestion counter (#218)
- Payment checklist yaml — grep-based checks before AI diagnosis (#215)
- Kickstart human gates — confirm direction before research and design spend (#219)
- Db.dot pipeline — deterministic inspect + AI diagnose + human gate (#216)
- Deterministic failure classification — regex patterns before AI diagnosis (#220)
- Node outcome file protocol — agents write JSON, runner reads file (#217)
- Deterministic gate scoring — add check_cmd to auto-decisions.yaml (#212)

### Changed
- Add attractor gate fixtures for PRD-002 (#213)

## [5.0.29] - 2026-05-15

### Added
- Enforce interactive design gates — AskUserQuestion counter

## [5.0.28] - 2026-05-15

### Added
- Deterministic gate scoring — add check_cmd to auto-decisions.yaml (#212)
- Node outcome file protocol — agents write JSON, runner reads file
- Kickstart human gates — confirm direction before research and design spend

### Changed
- Add attractor gate fixtures for PRD-002 (#213)

## [5.0.27] - 2026-05-15

### Added
- Deterministic gate scoring — add check_cmd to auto-decisions.yaml
- Deterministic failure classification — regex patterns before AI diagnosis

## [5.0.26] - 2026-05-15

### Added
- Auto PR→review→fix→merge loop + attractor-runner refactor (#211)
- Add orchestration skill — state machine, saga, circuit breaker patterns (#210)
- Add v5.0.0→v5.0.14 migration step to backfill 4 guardrail rules (#209)

## [5.0.25] - 2026-05-15

### Added
- Auto PR→review→fix→merge loop + attractor-runner refactor (#211): new sprint pipeline nodes CreatePR → ReviewAndTest → DebugFix (loop) → AutoMerge inserted between Release and Learnings; auto-opens GitHub Issues per blocking finding; parallel debugger workers fix and close them; auto-merges when clean
- `skills/attractor/` — new skill package: `SKILL.md` (format registry), `node-handlers.yaml` (YAML step handlers for worktree, create_pr, auto_merge, learnings, sprint_completion, startup), `auto-decisions.yaml` (pass/fail checklists for ReviewPlan + SprintReview auto-mode), `workflows/review-merge-loop.md` (agent instructions for ReviewAndTest + DebugFix)

### Changed
- `agents/attractor-runner.md` refactored from 679 → 201 lines: embedded pipeline graph removed (reads `sprint.dot` from disk), all YAML-executable mechanics extracted to `skills/attractor/` (lazy-loaded per node), only orchestration logic and the 5-step edge-selection algorithm remain inline

## [5.0.18] - 2026-05-15

### Added
- Add orchestration skill — state machine, saga, circuit breaker patterns

## [5.0.17] - 2026-05-15

### Added
- `skills/orchestration/` — new skill covering state machine design, control plane/orchestrator pattern, message queue (job table schema), saga pattern with compensating transactions, circuit breaker (CLOSED/OPEN/HALF_OPEN), idempotency keys, dead letter queue, fan-out/fan-in coordination, and health-aware routing. Includes `workflows/state-machine.md` (6-step FSM design process) and `workflows/saga.md` (5-step saga implementation guide).

## [5.0.16] - 2026-05-15

### Fixed
- Move `version-bump-guard` hook from `PreToolUse(Bash)` to `git commit`-specific hook for tighter scoping
- Remove noisy "uncommitted changes" message from stop hook (was firing on every session end)

### Changed
- Ignore `.claude/commands/` in `.gitignore` so local dev commands are not shipped with the plugin

## [5.0.14] - 2026-05-15

### Added
- Definition of done rule, anti-patterns skill, functional E2E in prd-verifier, Attractor SprintReview extended to 5 auto-criteria
- `guardrails` skill now generates 6 always-included rule files (human-intervention, output-voice, verification, engineering-discipline) instead of 2
- New guardrails catalogs for engineering-discipline, human-intervention, output-voice, and verification rules

## [5.0.13] - 2026-05-15

### Added
- Add caveman skill to all 77 agents — enforce default output voice

## [5.0.12] - 2026-05-15

### Added
- Add PMC Legibility Framework to ideation and sprint planning (#207)

## [5.0.11] - 2026-05-15

### Added
- Add /cks:resume command to execute handoff in new session (#206)

### Maintenance
- Remove stale phase 3 from PRD state + update session history

## [5.0.10] - 2026-05-15

### Added
- `/cks:resume` command — reads `.prd/HANDOFF.md` (or latest from `.prd/handoffs/`) in a new session and executes the next steps via `cks:prd-orchestrator`; shows handoff summary + DECISION REQUIRED block before acting; supports optional focus override via args
- Updated `help.md` (SESSION RITUALS + lifecycle tree) and README command count (69 → 70)







## [5.0.9] - 2026-05-15

### Fixed
- Unique handoff files per session + attractor sprint.dot resolution (#204-#205) (#205)
- Wire Attractor pipeline end-to-end (#194-#203) (#204)

## [5.0.8] - 2026-05-15

### Fixed
- Handoff command now writes unique per-session files (`HANDOFF-{date}-{time-EST}-{branch}.md`) in `.prd/handoffs/` so parallel sessions don't clobber each other; `.prd/HANDOFF.md` kept as latest pointer for sprint-start auto-detect
- Attractor runner no longer hard-stops when `pipelines/sprint.dot` is absent from user project roots; resolves via `${CLAUDE_PLUGIN_ROOT}/pipelines/sprint.dot` first, falls back to embedded graph

## [5.0.7] - 2026-05-15

### Fixed
- Correct skill/path references in kickstart early-lifecycle chain (#193)

## [5.0.6] - 2026-05-14

### Fixed
- Restore broken connections in kickstart early-lifecycle chain (#192)

## [5.0.5] - 2026-05-14

### Maintenance
- Virginize plugin state for v5.0.3 release (#185)

## [5.0.4] - 2026-05-14

### Fixed
- Add v4.7→v5.0 migration entry + stamp .cks-version to 5.0.2

## [5.0.3] - 2026-05-14

### Added
- Migrator agent runs migrate-v4-to-v5.sh when v4 detected

### Fixed
- Update command count to 80 + clean up sprint-start legacy stub

## [5.0.2] - 2026-05-14

### Fixed
- Update command count to 80 + clean up sprint-start legacy stub

## [5.0.1] - 2026-05-14

### Changed
- Merge pull request #184 from cardinalconseils/w8-v5-release

## [5.0.0] - 2026-05-14

### Breaking Changes
- `attractor_mode` now defaults to `true` — Attractor spine is the active execution path
- `sprint-runner` fully removed; all execution goes through `attractor-runner`
- `/cks:sprint-close` deleted; Release node handles session close automatically
- `/cks:go`, `/cks:release`, `/cks:review` marked legacy — use Attractor pipeline commands

### Added
- Full migration script: `scripts/migrate-v4-to-v5.sh` — detects v4 shape, patches config, renames refs, validates
- `/cks:setup-webhooks` — GitHub Project Kanban webhook onboarding (Wave 6)
- `/cks:wiki` — Read/write CKS wiki pages in `memory/wiki/` (Wave 5)
- Bidirectional Kanban automation — `tools/webhook-listener.js` with HMAC-SHA256 verification (Wave 6)
- `docs/AUTOMATION.md` — full bidirectional automation guide
- Attractor pipeline: Discover → Design → Build → Test → Review → Release nodes
- GitHub Project sync: `tools/github-project-sync.js` GraphQL wrapper
- Parallel-dispatch skill + worktree lifecycle management
- Prior-art queries from Kanban in Discover node; Learnings node writes sprint wiki pages

### Migration
- v4 projects: run `scripts/migrate-v4-to-v5.sh` from your project root
- `attractor_mode: false` in `.claude/settings.json` restores v4 behavior
- All 73 agents and 45 skills preserved — no behavioral changes




















## [4.15.22] - 2026-05-14

### Maintenance
- Finalize PRD-STATE and VERSION for wave7 PR

## [4.15.21] - 2026-05-14

### Maintenance
- Update PRD-STATE and VERSION after wave7 merge

## [4.15.20] - 2026-05-14

### Added
- Archive legacy commands + standup absorbs sprint-start

## [4.15.19] - 2026-05-14

### Maintenance
- Bump VERSION to 4.15.17 for wave6 board decommission

## [4.15.18] - 2026-05-14

### Added
- Decommission old Agentic OS board UI — remove board/public/, strip static serving from CKS Console
- /cks:setup-webhooks command — webhook automation onboarding
- Console server rename + POST /webhooks/github mount
- Webhook listener — HMAC-SHA256 verify, column→action map, reconciliation loop

### Documentation
- Add AUTOMATION.md — bidirectional Kanban automation guide

## [4.15.17] - 2026-05-14

### Added
- /cks:setup-webhooks command — webhook automation onboarding
- Console server rename + POST /webhooks/github mount
- Webhook listener — HMAC-SHA256 verify, column→action map, reconciliation loop

### Documentation
- Add AUTOMATION.md — bidirectional Kanban automation guide
## [4.15.17] - 2026-05-14

### Added
- Agentic OS data layer — /cks:wiki command, wiki agent, prior-art + Learnings node wiring

## [4.15.16] - 2026-05-14

### Added
- /cks:setup-webhooks command — webhook automation onboarding
- Console server rename + POST /webhooks/github mount
- Webhook listener — HMAC-SHA256 verify, column→action map, reconciliation loop

## [4.15.15] - 2026-05-14

### Maintenance
- Resolve merge conflicts — keep v4.15.13, fix migrator v4 detection
- Wave 5 (Sub-Phase 5): Agentic OS Data Layer — `/cks:wiki` command + `cks:wiki` agent for reading/writing `memory/wiki/` pages
- Attractor runner Discover node now queries `getPriorArt()` from GitHub Kanban and prepends prior-art context to the discoverer prompt
- Learnings node added to the Attractor pipeline (after Release, before End) — writes a structured sprint wiki page to `memory/wiki/sprints/` on every successful run

## [4.15.15] - 2026-05-14

### Added
- Wave 4 (Sub-Phase 4): Entry point wiring for `/cks:new`, `/cks:investigate`, `/cks:debug` — GitHub Project Phase item creation, issue sync, and Attractor context enrichment, all behind `isConfigured()` guard (no-op when unconfigured)
- New skill `skills/github-project-setup/SKILL.md` — onboarding wizard for GitHub Project Kanban setup

## [4.15.14] - 2026-05-14

### Added
- Release node wiring + GitHub Projects integration doc

## [4.15.13] - 2026-05-14

### Fixed
- Update sprint-runner → attractor-runner references in commands + wiki

## [4.15.12] - 2026-05-14

### Added
- Rename sprint-runner → attractor-runner; add enterNode + dispatchParallel

## [4.15.11] - 2026-05-14

### Added
- Add parallel-dispatch skill — task grouping, worktree lifecycle, merge strategy

## [4.15.10] - 2026-05-14

### Added
- Add attractor-feature issue template for Attractor pipeline
- Expand SprintReview into 5-edge box node with dispatchParallel Build
- GitHub GraphQL sync wrapper + PRD-STATE attractor schema + runner sync helpers

## [4.15.9] - 2026-05-14

### Added
- Expand SprintReview into 5-edge box node with dispatchParallel Build
- GitHub GraphQL sync wrapper + PRD-STATE attractor schema + runner sync helpers

## [4.15.8] - 2026-05-14

### Added
- GitHub GraphQL sync wrapper + PRD-STATE attractor schema + runner sync helpers

## [4.15.7] - 2026-05-14

### Added
- Create GitHub Projects v2 Kanban for CKS v5 migration tracking

## [4.15.6] - 2026-05-14

### Added
- Add migration doc, script stub, and attractor_mode flags to plugin.json

## [4.15.5] - 2026-05-14

### Added
- Add v4-layout detection logic for attractor migration

## [4.15.4] - 2026-05-14

### Maintenance
- Bump version to v4.15.2 and update PRD state (#173)

## [4.15.3] - 2026-05-13

### Added
- Phase-aware start hint in session banner (#172)

## [4.15.2] - 2026-05-13

### Fixed
- Reliable stamp write when multiple CKS plugin instances active (#171)

## [4.15.1] - 2026-05-13

### Added
- Automate context-continuity handoff for AFK development (#170)
- Add Stripe payments skill — idempotency, webhooks, subscriptions, PCI compliance (#167)
- Wire database-design and database-recovery skills to db agents

### Documentation
- Update agents/ and skills/ READMEs — add all missing entries, group by domain (#169)

## [4.15.0] - 2026-05-13

### Added
- **Context-continuity for AFK development** — at 55% context, `context-guard.sh` now auto-writes shell HANDOFF.md (no manual trigger needed); session-journalist agent emits `▶ ACTION REQUIRED /clear` after every `/cks:handoff`; `session-start.sh` detects fresh HANDOFF.md (< 2h) and shows `⚡ HANDOFF RESUME` next step in the session banner ([#170](https://github.com/cardinalconseils/claude-starter/pull/170))
- **Payments skill** — `skills/payments/SKILL.md` covering Stripe-only integration: idempotency keys, webhook signature verification, subscription lifecycle (trial → active → past-due → canceled), PCI compliance scope, and metered billing patterns ([#167](https://github.com/cardinalconseils/claude-starter/pull/167))
- **Caching skill** — `skills/caching/SKILL.md` with tiered cache strategy (CDN → reverse proxy → app → DB query), TTL discipline, cache invalidation patterns, and Redis/Memcached decision guide ([#165](https://github.com/cardinalconseils/claude-starter/pull/165))
- **Database-recovery skill** — `skills/database-recovery/SKILL.md` covering backup strategies, RTO/RPO targets, point-in-time recovery, and disaster-recovery runbooks ([#165](https://github.com/cardinalconseils/claude-starter/pull/165))
- **Skill-creator skill** — `skills/skill-creator/SKILL.md` synthesizing Anthropic official guidance and Matt Pocock best practices: 1024-char description limit, two-sentence trigger format, ≤100-line body target, when-to-split rules ([#163](https://github.com/cardinalconseils/claude-starter/pull/163))
- **System Architecture Tier as Discovery Element 12** — `prd-discoverer` now asks users to select target scale tier (Tier 1 ~$1 MRR single-VM / Tier 2 ~$1K MRR dedicated app+DB / Tier 3 ~$100K+ distributed); tier captured in CONTEXT.md Section 12 and used by prd-designer to generate tier-appropriate architecture diagrams ([#164](https://github.com/cardinalconseils/claude-starter/pull/164))
- **Grill-me principle in discovery and kickstart intake** — discovery agent and kickstart-intake now challenge surface-level answers with follow-up probes (Socratic drilling) instead of accepting the first response; prevents shallow requirements that cause mid-sprint rework ([#162](https://github.com/cardinalconseils/claude-starter/pull/162))

### Changed
- **Database-design skill extended** — added DB type selection guide, RLS patterns, and backup strategy pointer ([#165](https://github.com/cardinalconseils/claude-starter/pull/165))
- **DB agents wired to skills** — `db-debugger`, `db-fixer`, `db-investigator`, and `db-migration` agents now declare `database-design` and `database-recovery` in their `skills:` frontmatter so the skills load at agent startup ([#168](https://github.com/cardinalconseils/claude-starter/pull/168))
- **Payments skill Stripe-only** — scoped down from generic payment-processor guidance to Stripe-specific patterns only, removing ambiguity ([#167](https://github.com/cardinalconseils/claude-starter/pull/167))

### Fixed
- Architecture-tiers skill invocation paths corrected; missing banner entries in architecture-tiers skill added ([#166](https://github.com/cardinalconseils/claude-starter/pull/166))

### Documentation
- `agents/README.md` and `skills/README.md` fully updated — all entries present, grouped by domain, with missing entries backfilled ([#169](https://github.com/cardinalconseils/claude-starter/pull/169))








## [4.13.19] - 2026-05-13

### Added
- Add payments skill — idempotency, webhooks, subscriptions, PCI compliance
- Wire database-design and database-recovery skills to db agents

### Changed
- Make payments skill Stripe-only

### Documentation
- Update agents/ and skills/ READMEs — add all missing entries, group by domain (#169)

## [4.13.18] - 2026-05-13

### Added
- Wire database-design and database-recovery skills to db agents

## [4.13.17] - 2026-05-13

### Fixed
- Fix architecture-tiers invocation paths and missing banner entries (#166)

## [4.13.16] - 2026-05-13

### Added
- Add system architecture tier as discovery element 12 (#164)

## [4.13.15] - 2026-05-13

### Added
- Add `skills/prd/references/architecture-tiers.md` — MRR-based system scaling reference mapping Tier 1 (~$1 MRR, single VM), Tier 2 (~$1K MRR, dedicated app + DB), and Tier 3 (~$100K+ MRR, distributed + caching + queues) to concrete infrastructure topologies
- Add discovery Element [1l] System Architecture Tier — prd-discoverer now asks users to select their target scale tier during Phase 1, capturing it in CONTEXT.md Section 12
- Make design-phase architecture diagrams tier-aware — prd-designer reads CONTEXT.md Section 12 and generates topology matching the selected tier (single-node / two-node / distributed)

### Changed
- Update CONTEXT.md template from 11 to 12 elements, adding Section 12 System Architecture Tier
- Update SKILL.md command table to reflect 12-element discovery

## [4.13.14] - 2026-05-13

### Maintenance
- Update PRD-STATE with recent session activity

## [4.13.13] - 2026-05-13

### Added
- Add `skills/skill-creator/SKILL.md` — CKS-native skill creation guide synthesizing Anthropic official skill-creator and Matt Pocock write-a-skill best practices: 1024-char description limit, two-sentence trigger format, ≤100-line body target, when-to-split rules, and CKS architecture constraints

## [4.13.11] - 2026-05-13

### Added
- Add mandatory Next Step line at end of every handoff doc

## [4.13.10] - 2026-05-13

### Documentation
- Fix CHANGELOG — consolidate v4.13.8 entry, remove duplicate v4.14.0 label

## [4.13.9] - 2026-05-13

### Maintenance
- Release v4.14.0 — handoff command, caveman skill strengthened, context-guard tighter

## [4.13.8] — 2026-05-13

### Added
- `/cks:handoff` — new command that writes a structured session handoff document (`.handoff/YYYY-MM-DD-HH-MM.md`) with branch state, uncommitted changes, open decisions, and suggested next steps. Solves the cross-session context-loss problem. ([#158](https://github.com/cardinalconseils/claude-starter/pull/158))
- `skills/handoff/SKILL.md` — domain knowledge for handoff generation: captures current branch, diff summary, open decisions, blockers, and next-step recommendations in a standard Markdown format
- **Caveman skill strengthened** — `skills/caveman/SKILL.md` updated with Persistence section (active every response, no filler drift), short-synonym rules, common abbreviations (`DB/auth/config/req/res/fn/impl`), arrow causality (`→`), output pattern `[thing] [action] [reason]. [next step].`, and Not/Yes examples replacing verbose Before/After format ([#158](https://github.com/cardinalconseils/claude-starter/pull/158))
- **Context-guard tighter thresholds** — `hooks/handlers/context-guard.sh` now fires stop warning at 55% (was 52%) and advisory at 48% (was 45%), aligned with `/cks:handoff` trigger point ([#159](https://github.com/cardinalconseils/claude-starter/pull/159))








## [4.13.7] - 2026-05-13

### Added
- Strengthen skill with persistence, abbreviations, arrow causality, and Not/Yes examples

## [4.13.6] - 2026-05-13

### Added
- Add /cks:handoff command and skill for session context preservation

## [4.13.5] - 2026-05-13

### Maintenance
- Update CHANGELOG for v4.13.3

## [4.13.4] - 2026-05-13

### Fixed
- Auto-stamp on session start; fix repo URL fallback when plugin.json absent from cache

## [4.13.3] - 2026-05-13

### Fixed
- Auto-stamp version on session start; fix repo URL fallback when plugin.json absent from cache (144e138)
- Read VERSION file from cache root — plugin.json excluded from installed cache (e0e3662)

## [4.13.2] - 2026-05-13

### Documentation
- Add v4.13.0 release notes to wiki README

## [4.13.1] - 2026-05-13

### Maintenance
- Release v4.13.0 — engineering discipline guardrails

## [4.13.0] - 2026-05-13

### Maintenance
- Update CHANGELOG for v4.12.19

## [4.12.19] — 2026-05-13

### Documentation
- docs(wiki): add guardrail rules section to extending.md, list all active rules (2e7eca4)



## [4.12.18] - 2026-05-13

### Maintenance
- Close phase 02 in work-hierarchy, update PRD-STATE session log

## [4.12.17] - 2026-05-13

### Maintenance
- Update CHANGELOG for v4.12.16

## [4.12.16] - 2026-05-13

### Added
- Add engineering-discipline guardrails — simplicity, minimal impact, root cause (5543ca9)






## [4.12.15] - 2026-05-13

### Changed
- Merge pull request #157 from cardinalconseils/02-developer-experience-guardrails

## [4.12.14] - 2026-05-11

### Added
- Add /cks:bg command for Agent View background session launching

## [4.12.13] - 2026-05-11

### Maintenance
- Update PRD-STATE after merging PR #154

## [4.12.12] - 2026-05-11

### Added
- Add feature cataloging phase to cks:adopt (#154)
- Caveman default voice — always-on with auto-clarity overrides (#156)
- Caveman mode — compress agent output, cut ~65% tokens (#155)

## [4.12.11] - 2026-05-10

### Maintenance
- Mark phase 01 Work Hierarchy as released in PRD-STATE

## [4.12.10] - 2026-05-10

### Added
- Work hierarchy — Feature → Phase → Task model (Phase 01) (#153)

## [4.12.9] - 2026-05-10

### Added
- Work hierarchy — Feature → Phase → Task model

## [4.12.8] - 2026-05-10

### Added
- **Work Hierarchy** — Feature → Phase → Task model for organizing CKS work.
  - New `/cks:work` command (new | move | close | activate | list) — thin dispatcher.
  - New `work-hierarchy-manager` agent — sole writer of `.prd/work-hierarchy.md`.
  - SessionStart auto-wraps existing flat phases under an `F-LEGACY` Feature on first run (idempotent).
  - SessionStart banner shows `Work: F-XX / P-YY` when active pointers are set.
  - `PRD-STATE.md` schema extended with `Active Feature:` and `Active Phase (Hierarchy):`.
  - `/cks:new --type {feature|phase|task} --parent ID` flags (default `--type phase` preserves prior behavior).
  - `/cks:board`, `/cks:status`, `/cks:progress` extended with hierarchy roll-up sections.
  - Command count bumped to 74; `help.md` adds a `HIERARCHY:` section.

## [4.12.7] - 2026-05-10

### Fixed
- Use jq for JSON version writes to prevent duplicate keys (#151)
- Context continuity — breadcrumb enforcement + PRD-STATE format (#148)

### Maintenance
- Virginize PRD state — ignore runtime artifacts, reset PRD-STATE (#150)
- Update wiki README version on every bump (#147)

## [4.12.6] - 2026-05-10

### Fixed
- Context continuity: PRD-STATE.md format mismatch caused blank Next/Run fields on every session resume (#148)
- stop.sh: emit warning when Next Action breadcrumb is missing before session ends (#148)
- session-start.sh: show actionable fallback instead of blank fields when no breadcrumb is set (#148)
- prd-orchestrator: add mandatory Context Breadcrumb section requiring plain-English next-action updates (#148)

## [4.12.5] - 2026-05-10

### Changed
- Thin browse/debug/investigate commands + add browser & debugger-worker agents (#146)

## [4.12.4] - 2026-05-10

### Documentation
- Add mini wiki to docs/wiki/ (#140)

## [4.12.3] - 2026-05-10

### Added
- Dispatch-first architecture — orchestrator-only session, business gates, --role flag (v4.12.0)

### Changed
- Progressive disclosure for debugger agent (v4.12.1) (#139)

### Documentation
- Bump to v4.11.6, add CHANGELOG entry for git-hygiene rules (#137)

### Maintenance
- Bump version to 4.11.5 — git-hygiene rules release (#136)

## [4.12.2] - 2026-05-10

### Added
- Dispatch-first architecture — orchestrator-only session, business gates, --role flag (v4.12.0)

### Changed
- Progressive disclosure for debugger agent — slim agent body + 5 workflow files

### Documentation
- Bump to v4.11.6, add CHANGELOG entry for git-hygiene rules (#137)

### Maintenance
- Bump version to 4.11.5 — git-hygiene rules release (#136)

## [4.12.1] - 2026-05-10

### Changed
- `agents/debugger.md` — refactored from 316-line agent with 5 inline modes down to 97 lines using progressive disclosure; model now reads only the detected mode's workflow file at runtime, preventing context hallucination from all-modes-loaded-simultaneously

### Added
- `skills/debug/workflows/mode-app-error.md` — Mode 1 steps: parse error, trace call chain, identify root cause, strategic logging format
- `skills/debug/workflows/mode-app-exploratory.md` — Mode 2 steps: clarify via AskUserQuestion, map code path, find divergence
- `skills/debug/workflows/mode-cks-self.md` — Mode 3 steps: lifecycle logs, PRD state, CKS failure patterns table
- `skills/debug/workflows/mode-issue-driven.md` — Mode 4 steps: parse issue, validate classification, fix-and-close flow
- `skills/debug/workflows/mode-multi-issue.md` — Mode 5 steps: parallel worker dispatch, branch merge, PR ship

## [4.12.0] - 2026-05-09

### Added
- `.claude/rules/dispatch-first.md` — orchestrator/worker separation rule. Main session must dispatch agents for code-writing work; worktree isolation required for code-writing agents
- `skills/guardrails/catalogs/business-decisions.md` — always-generated catalog gating 7 high-impact actions (prod deploy, pricing, external comms, destructive data ops, chatbot/AI behavior, file/workflow removal) behind explicit human approval
- `--role=coder|marketer|analyst|devops` flag on `/cks:new`, `/cks:sprint`, `/cks:autonomous` — dispatched agents load only the role's skill set, keeping context focused for non-dev users

### Changed
- `skills/guardrails/SKILL.md` — `business-decisions.md` is now in the ALWAYS-generate list at bootstrap
- `commands/help.md`, `commands/README.md` — document `--role` flag and Roles reference

## [4.11.6] - 2026-05-09

### Added
- Add `.claude/rules/git-hygiene.md` — branch naming convention (`{issue-number}-short-description`), 30-day staleness policy, and deletion safety check (#136)

## [4.11.5] - 2026-05-09

### Fixed
- Correct version sync logic for stamp-ahead case in auto-bump hook (#135)

## [4.11.4] - 2026-05-09

### Fixed
- Resolve hook bad-substitution, token-optimize /cks:version, auto-suggest migrate on update (#134)

## [4.11.3] - 2026-05-09

### Added
- Add /cks:version command — show plugin and project version with migration status (#133)

## [4.11.2] - 2026-05-09

### Added
- Add 55% context window safeguard — UserPromptSubmit guard + PreCompact state hook (v4.11.1)

### Documentation
- Bump to v4.11.1, add CHANGELOG entry for context window safeguard

## [4.11.1] - 2026-05-08

### Added
- **Context window safeguard** — `UserPromptSubmit` hook warns at 45% ("wrap up soon") and 52% ("urgent — compact imminent") before the 55% auto-compact threshold fires
- **`PreCompact` state hook** — saves branch, uncommitted file count, and PRD phase into the compaction summary so sessions resume cleanly after auto-compact
- **55% threshold alignment** — `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` recommendation updated from 50 → 55 in `token-optimizer` agent to match the hook warning thresholds

### Changed
- `agents/token-optimizer.md` — recommended `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` updated to 55




















## [4.10.2] - 2026-05-08

### Added
- Zero-touch pipeline — dep refresh, E2E gate, worktree lifecycle, auto-release (v4.11.0) (#132)

## [4.10.1] - 2026-05-08

### Added
- Quality-gated /cks:go pipeline — parallel review+security, secret gate, CI workflow, auto-release (v4.10.0)

## [4.10.0] - 2026-05-08

### Added
- Add /cks:agentic-os — command, builder agent, skill, and templates (v4.9.47) (#129)

### Fixed
- Dashboard copy button works on file:// URLs — add execCommand fallback (v4.9.50)
- Rename skill agentic-os → agentic-os-builder to fix dispatch error (v4.9.49)

## [4.9.50] - 2026-05-06

### Fixed
- Dashboard copy button now works when opened as a `file://` URL — adds `execCommand('copy')` fallback for non-secure contexts where `navigator.clipboard` is unavailable; extracts a `flash(btn)` helper to remove duplicated visual feedback logic

## [4.9.49] - 2026-05-06

### Fixed
- Rename skill `agentic-os` → `agentic-os-builder` to eliminate naming collision with the `/cks:agentic-os` command; the shared name caused Claude to dispatch `Agent(subagent_type="cks:agentic-os")` instead of the correct `cks:agentic-os-builder`, producing "Agent type not found" errors
- Update `agents/agentic-os-builder.md` `skills:` frontmatter to reference `agentic-os-builder`
- Move `skills/agentic-os/` → `skills/agentic-os-builder/`

## [4.9.48] - 2026-05-06

### Added
- Add agentic-os command, builder agent, and skill — v4.9.47

## [4.9.47] - 2026-05-06

### Added
- Add `/cks:agentic-os` command — scaffolds the three-layer Agentic OS (architecture + memory + observability) inside any project
- Add `agentic-os-builder` agent — interviews user for domains/tasks, generates `.agentic-os/`, `memory/`, `dashboard/index.html`, and injects CLAUDE.md sections
- Add `agentic-os` skill — domain knowledge, rationalization guards, and 5 templates (domains, skill stub, memory index, dashboard HTML, CLAUDE.md injection)
- `init` subcommand: full scaffold with domain interview, memory layer (raw/wiki/output), and static HTML dashboard with copy-paste CLI buttons
- `status` subcommand: terminal dashboard showing active domains, memory file counts, and skill shortcuts
- `add-domain` subcommand: add a new domain to an existing Agentic OS without re-scaffolding

## [4.9.46] - 2026-05-03

### Added
- Add marketing team — 4 skills, 4 agents, /cks:market command

## [4.9.45] - 2026-05-03

### Added
- Add library-skills integration — auto-install FastAPI/Streamlit AI skills at bootstrap (#126)

### Maintenance
- Bump to 4.9.44 — document library-skills in CHANGELOG, README, WORKFLOW (#127)

## [4.9.44] - 2026-05-01

### Added
- Library-skills integration — auto-install FastAPI/Streamlit official AI skills at bootstrap (#126)

### Documentation
- Add `skills/library-skills/` to skills/README.md
- Bump skill count to 44 in README.md

---

## [4.9.43] - 2026-05-01

### Added
- Integrate AFK factory pipeline into core workflow automation (#125)
- Agent persona system — /cks:persona command + skill (#124)

### Maintenance
- Bump version to 4.9.31 — fix marketplace regression (#123)

## [4.9.42] - 2026-05-01

### Added
- Agent persona system — /cks:persona command + skill (#124)

### Maintenance
- Bump version to 4.9.31 — fix marketplace regression (#123)

## [4.9.41] - 2026-05-01

### Documentation
- Add /cks:persona to help and update command count to 70

## [4.9.40] - 2026-05-01

### Added
- Add /cks:persona command

## [4.9.39] - 2026-05-01

### Added
- Add persona-interviewer agent

## [4.9.38] - 2026-05-01

### Added
- Add agent-persona skill — interview workflow

## [4.9.37] - 2026-05-01

### Added
- Add agent-persona skill — knowledge-fit decision tree

## [4.9.36] - 2026-05-01

### Added
- Add agent-persona skill — SKILL.md entry point

## [4.9.35] - 2026-05-01

### Added
- Add agent-persona skill — knowledge-index template

## [4.9.34] - 2026-05-01

### Added
- Add agent-persona skill — behavior-rules template

## [4.9.33] - 2026-05-01

### Added
- Add agent-persona skill — persona-card template

## [4.9.32] - 2026-05-01

### Maintenance
- Bump version to 4.9.31 — fix marketplace regression

## [4.9.31] - 2026-05-01

### Added
- Add observability layer — /cks:observe, log-reader, sentry-observer, langsmith-observer (#121)

### Documentation
- Refresh documentation with accurate counts and missing commands (#122)

## [4.9.30] - 2026-05-01

### Documentation
- Refresh documentation with accurate counts and missing commands (#122)

## [4.9.29] - 2026-05-01

### Documentation
- Update ARCHITECTURE.md counts for observability layer

## [4.9.28] - 2026-05-01

### Documentation
- Add /cks:observe to commands README and help

## [4.9.27] - 2026-05-01

### Added
- Add observability skill to debugger and investigator agents

## [4.9.26] - 2026-05-01

### Added
- Add /cks:observe command — dispatches log-reader, sentry-observer, langsmith-observer

## [4.9.25] - 2026-05-01

### Added
- Add log-reader, sentry-observer, langsmith-observer agents

## [4.9.24] - 2026-05-01

### Added
- Add log-triage, sentry-triage, langsmith-triage workflows

## [4.9.23] - 2026-05-01

### Added
- Add observability skill — shared triage knowledge for live signals

## [4.9.22] - 2026-05-01

### Added
- Add human-intervention formatting rule — Action Required, Decision Required, Suggestion visual blocks (#120)

### Documentation
- Refresh README and ARCHITECTURE with accurate counts: 68 commands, 61 agents, 43 skills, 8 rules
- Add /cks:ciso, /cks:investigate, /cks:ideate, /cks:assess, /cks:evaluate, /cks:launch-check, /cks:board, /cks:model, /cks:explore, /cks:simplify, /cks:sandbox to Standalone Tools
- Add .claude/rules/ guardrails section to file structure trees

## [4.9.21] - 2026-05-01

### Documentation
- Add observability layer implementation plan

## [4.9.20] - 2026-05-01

### Added
- Add destructive-op guardrails — hook + rule + catalog (#119)

## [4.9.19] - 2026-05-01

### Documentation
- Fix spec — add Read to observer agents, clarify GCP auto-detect precedence

## [4.9.18] - 2026-05-01

### Documentation
- Add observability layer design spec

## [4.9.17] - 2026-05-01

### Added
- Add /cks:ciso — Personal CISO agent with PMC-specific threat intelligence (#118)

## [4.9.16] - 2026-05-01

### Maintenance
- Bump version to 4.9.15

## [4.9.15] - 2026-04-30

### Fixed
- Investigate output now recommends /cks:debug --issue N for fixes (#117)
- Bump-version now syncs plugin files and updates installed_plugins.json (#116)

## [4.9.14] - 2026-04-30

### Fixed
- Bump-version now syncs plugin files and updates installed_plugins.json

## [4.9.13] - 2026-04-30

### Fixed
- Prevent double version bump — pre-commit hook now skips if already bumped manually

## [4.9.12] - 2026-04-30

### Added
- Add /cks:investigate command — scan, file issues to GitHub, debug queue

### Maintenance
- Bump version to 4.9.10 (minor — /cks:investigate command)

## [4.9.11] - 2026-04-30

### Added
- Add /cks:investigate command — scan, file issues to GitHub, debug queue

## [4.9.10] - 2026-04-30

### Added
- Add /cks:investigate command — scan, file issues to GitHub, debug queue

## [4.9.9] - 2026-04-30

### Fixed
- Migrator always stamps .cks-version even when no migrations needed (#114)

## [4.9.8] - 2026-04-28

### Added
- Add /cks:db command — investigate, fix, debug, ERD for Supabase

## [4.9.7] - 2026-04-28

### Changed
- Merge pull request #112 from cardinalconseils/feat/rtk-integration

## [4.9.6] - 2026-04-28

### Added
- Add RTK token proxy integration to optimize + session banner

## [4.9.5] - 2026-04-28

### Added
- OpenRouter model selection skill with human-in-the-loop research (#111)

## [4.9.4] - 2026-04-28

### Added
- OpenRouter model selection skill with human-in-the-loop research (#111)

## [4.9.3] - 2026-04-27

### Maintenance
- Bump version to 4.9.0 (minor — new OpenRouter skill)

## [4.9.2] - 2026-04-27

### Maintenance
- Bump version to 4.9.0 (minor — new OpenRouter skill)

## [4.9.1] - 2026-04-27

### Added
- Add OpenRouter model selection skill with human-in-the-loop research

## [4.9.0] - 2026-04-27

### Added
- Add OpenRouter model selection skill with human-in-the-loop research

## [4.8.12] - 2026-04-25

### Added
- Optimize --apply now sets MAX_THINKING_TOKENS and CLAUDE_AUTOCOMPACT_PCT_OVERRIDE

## [4.8.11] - 2026-04-25

### Added
- `/cks:optimize --apply` now interactively applies `MAX_THINKING_TOKENS` and `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` — Step 2b prompts user before writing to `~/.claude/settings.json`

## [4.8.10] - 2026-04-20

### Fixed
- Resolve install.sh Windows path mismatch on Git Bash + native Python (#108)

## [4.8.9] - 2026-04-20

### Fixed
- Bump-version.sh updates local Claude Code marketplace cache (#107)

## [4.8.8] - 2026-04-20

### Fixed
- `bump-version.sh` now updates the local Claude Code marketplace cache (`~/.claude/plugins/marketplaces/`) so `claude plugin update` sees the new version immediately

## [4.8.7] - 2026-04-20

### Fixed
- `bump-version.sh` pushes version tags to remote after bump so `claude plugin update` can detect new versions (#106)

### Documentation
- Fix CHANGELOG and README for v4.8.5 optimize feature (#105)

## [4.8.6] - 2026-04-20

### Added
- Enhance /cks:optimize with interactive plugin management (#104)

## [4.8.5] - 2026-04-20

### Added
- `/cks:optimize` plugin management: audit `enabledPlugins` by category (output-styles / universal / project-specific), interactive apply mode to disable global plugins and generate project-level `.claude/settings.json` (#104)

## [4.8.3] - 2026-04-19

### Added
- Sprint-close shows peer sessions + uncovered next work

## [4.8.2] - 2026-04-19

### Added
- GitHub Issues Dark Factory gate + ultrareview + auto-mode skills (v4.8.0) (#99)

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
