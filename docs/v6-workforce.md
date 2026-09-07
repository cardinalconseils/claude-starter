# CKS v6 Workforce — Role Specification

The contract for `agents/*.md` in v6. Eighteen roles replace 173 task agents. Roles differ by
**tool grant and model**, never by prompt alone (`docs/wiki/extending.md`, "least agency").
Domain knowledge lives in skills the role loads; sequential procedures live in
`skills/<domain>/workflows/`; anything that must dispatch agents is a `SKILL-ORCHESTRATOR.md`
loaded top-level via `Skill()` (`.claude/rules/commands.md`, Orchestrator Exception).

## Invariants

- `subagent_type: cks:<basename>`; `name: <basename>`; list-form `tools:`; `model:`; `color:`; `skills:` listing every skill dir the body relies on (verify each `skills/<name>/SKILL.md` exists).
- **No role carries `Agent` except `chief-of-staff`.** Sub-agents cannot dispatch sub-agents.
- "Bash ro" = `Bash` granted with the read-only clause from `agents/chief-of-staff.md` (no redirects, `sed -i`, `tee`, heredocs, `mkdir`) stated in the body.
- Decide / review / report roles have no `Write` and no `Edit`. A role that writes names its write scope in the body and stays inside it.
- `AskUserQuestion` only on `sonnet`/`opus` roles (lower tiers narrate the question instead of calling the tool).
- Gated actions (send email, calendar invite with attendees, post to a channel, send an invoice, move money, deploy to production, delete files/routes, change a Routine) are never executed by a role on its own: draft, return, let the chief of staff route `GATED:`.
- MCP grants use the existing forms: `"mcp__claude_ai_<Server>__*"` for claude.ai connectors, `mcp__plugin_github_github__<tool>` for GitHub, `mcp__plugin_sentry_sentry__<tool>` for Sentry. Grant the narrowest set that does the job; wildcards only where every tool on that server is in scope.
- Body = system prompt: instructions to the role, not documentation. WHY comments only. No model names in files. No `[TOKENS]`/`[PLACEHOLDER]`.

## Roster

| Role | Model | Write | Edit | Bash | Other grants | Skills (verify dirs) | Seed body | Absorbs |
|---|---|---|---|---|---|---|---|---|
| chief-of-staff | opus | – | – | ro | Agent, AskUserQuestion | chief-of-staff, decision-memo, operating-model | done in 5.2.0 | concierge |
| project-manager | sonnet | `.prd/` state only (`PRD-STATE.md`, `work-hierarchy.md`, `HANDOFF.md`, `.prd/handoffs/`) | – | rw (git read, gh) | AskUserQuestion, `"mcp__plugin_github_github__*"` | github-issues, prd, core-behaviors, caveman | project-manager | work-hierarchy-manager, github-project-setup-agent, session-journalist (handoff/DEVLOG), reminder (issue-backed) |
| assistant | sonnet | `$CKS_HQ/users/<slug>/` else `~/.cks/user/<slug>/` (drafts, reminders, notes) | – | ro | AskUserQuestion; Gmail read+draft only: `mcp__claude_ai_Gmail__search_threads`, `get_thread`, `get_message`, `list_drafts`, `get_draft`, `create_draft`, `update_draft`, `list_labels`, `label_thread`; Calendar: `mcp__claude_ai_Google_Calendar__list_calendars`, `list_events`, `search_events`, `get_event`, `suggest_time`, `create_event`, `update_event`. Never `send_message`, `reply`, `forward`, `respond_to_event`. `"mcp__Brain_1__*"` (unverified server name; Brain 1 tools take precedence when present) | executive-assistant (new), user-memory, conversation-state, core-behaviors, caveman | reminder + standup-reader | reminder, standup-reader |
| finops | sonnet | `.finops/`, `$(cks_finops_dir)` | – | ro | AskUserQuestion, WebFetch, `"mcp__claude_ai_Stripe__*"` (unverified name), `mcp__plugin_github_github__list_commits` | finops (new), payments, pricing-strategy, revops, analytics-tracking, core-behaviors, caveman | luv-fin-ops + cost-analyzer + payment-advisor | cost-analyzer, cost-researcher (cost side), token-optimizer (analysis), loop-cost-monitor, payment-advisor, luv-fin-ops |
| watchdog | sonnet | – | – | ro | – | core-behaviors, caveman, launch-strategy | watchdog | health-checker, rules-auditor, launch-readiness, loop-health-checker (report side), loop-cost-monitor (report side), gatekeeper (skill lifecycle review); adds an "agency KPIs" hunt |
| observer | sonnet | – | – | ro | WebFetch, `mcp__plugin_sentry_sentry__authenticate`, `mcp__plugin_sentry_sentry__complete_authentication`, `mcp__claude_ai_Vercel__get_runtime_logs`, `mcp__claude_ai_Vercel__get_deployment_build_logs`, `mcp__claude_ai_Supabase__list_projects`, `mcp__claude_ai_Supabase__get_advisors`, `mcp__claude_ai_Supabase__list_tables`, `mcp__cloudflare__workers_analytics_search` | observability, canary, control-plane (sub-skills as today), core-behaviors, caveman | sentry-observer | langsmith-observer, log-reader, observability-agent, canary-monitor, coordination-agent, peer-coordinator, control-plane-agent (read side) |
| researcher | sonnet | `.research/`, `.monetize/research.md`, `.kickstart/artifacts/research*` | – | rw (runs `last30days`) | WebSearch, WebFetch, `"mcp__claude_ai_Firecrawl__*"`, `"mcp__claude_ai_Context7__*"`, `"mcp__claude_ai_Perplexity__*"` | deep-research, ecosystem-watch, core-behaviors, caveman | deep-researcher | prd-researcher, monetize-researcher, cost-researcher (market side), ecosystem-learner, cccs-intel-monitor |
| strategist | opus | `.prd/` discovery artifacts, `.kickstart/`, `.monetize/`, `.concept/`, `.preflight/`, persona files | – | ro | AskUserQuestion, WebSearch, WebFetch | prd, kickstart, monetize, concept-evaluation, strategic-frameworks, kpi-architect, market-mapping, strategic-options, compliance, core-behaviors, caveman, karpathy-guidelines | monetize-evaluator + prd-discoverer + kickstart-intake | prd-discoverer, kickstart-ideator/-intake/-feature-scope/-validate/-brand, concept-orchestrator (scoring only), concept-pillar-worker, monetize-discoverer/-evaluator/-reporter/-roadmap, pivot-analyzer, persona-interviewer, personas-agent, user-profiler (interview), grill-me-interviewer, expert-product, expert-specialist, agile-eagle, compliance-advisor, feature-cataloger, luv-ceo (strategy), luv-legal |
| architect | opus | design docs: `PLAN.md`, `DESIGN.md`, `ARCHITECTURE.md`, `.decisions/`, design-system files, ERDs | same scope | ro | AskUserQuestion, `mcp__claude_ai_Supabase__list_tables`, `mcp__claude_ai_Supabase__search_docs` | prd, architecture, database-design, design-system, design-fluency, agent-build-sequence, ai-agent-projects, payments, core-behaviors, caveman, karpathy-guidelines | prd-planner | prd-designer, architecture-generator, kickstart-designer, design-system-generator, db-erd, expert-builder, scale-advisor, payment-advisor (advice), luv-api-designer, luv-tech-lead, luv-designer |
| builder | sonnet | yes | yes | rw | AskUserQuestion, TodoWrite, `"mcp__claude_ai_Supabase__*"` | prd, tdd, code-excellence, database-design, no-code, cli-printing-press, core-behaviors, caveman, karpathy-guidelines | prd-executor (strip worker dispatch) | prd-executor-worker, tdd-runner, prd-refactorer, code-simplifier, db-migration, no-code-specialist, remotion-specialist, printing-press-runner, luv-frontend-dev/-backend-dev/-full-stack-dev/-mobile-app-dev/-landing-page-dev/-database-auth-engineer/-ai-tooling-engineer/-n8n-automation |
| reviewer | opus | – | – | ro | AskUserQuestion, `mcp__plugin_github_github__pull_request_read`, `mcp__plugin_github_github__list_pull_requests`, `mcp__claude_ai_Supabase__list_tables`, `mcp__claude_ai_Supabase__get_advisors` | code-excellence, security-hardening, design-fluency, database-design, compliance, contracts (new), ciso, core-behaviors, caveman | reviewer + security-auditor + compliance-advisor | security-auditor, ciso, design-fluency-reviewer, db-investigator, luv-qa-engineer, luv-mythos |
| tester | sonnet | fixtures, `.evals/`, `.harness-evals/`, `VERIFICATION.md`, `CONFIDENCE.md` | – | rw | `mcp__plugin_github_github__issue_write`, browser tools as `agents/browser.md` grants them | uat, evals, harness-evals, tdd, core-behaviors, caveman | prd-verifier (trim to the verification loop) | uat-runner, browser, evals-runner, harness-eval-runner, luv-uat-engineer, luv-agent-browser |
| debugger | opus | **no** | yes | rw | AskUserQuestion, `mcp__plugin_github_github__issue_write`, `mcp__plugin_github_github__issue_read`, `mcp__plugin_github_github__list_issues`, `mcp__claude_ai_Supabase__execute_sql`, `mcp__claude_ai_Supabase__list_tables`, `mcp__plugin_sentry_sentry__authenticate`, `mcp__plugin_sentry_sentry__complete_authentication` | debug, failure-taxonomy, github-issues, database-recovery, core-behaviors, caveman | debugger | debugger-worker, investigator, triage-runner, db-debugger, db-fixer, expert-debugger, luv-debugger |
| shipper | sonnet | yes | `CHANGELOG.md`, config files | rw | AskUserQuestion, `"mcp__plugin_github_github__*"`, `"mcp__claude_ai_Vercel__*"` | shipping-checklist, environment-management, github-issues, migrations, core-behaviors, caveman | deployer + go-runner | go-runner, ship-runner, changelog-generator, luv-devops, luv-cicd |
| historian | sonnet | `memory/`, `.learnings/`, `.cks/control-plane/memory/`, `$CKS_HQ/memory/`, user profile | same scope | ro | – | learnings, retrospective, user-memory, honcho-memory, sleep-cycle, core-behaviors, caveman | learnings-curator | wiki, memory-agent, improvement-agent, retrospective, sleep-runner (proposal side), ahe-evolution-agent, honcho-integrator, user-profiler (profile write), session-journalist (journal) |
| marketer | opus | `.campaign/`, `.marketing/` | – | ro plus the OpenRouter `curl` form `luv-model-routing` documents | AskUserQuestion, WebSearch, WebFetch, `"mcp__claude_ai_aHref__*"`, `"mcp__claude_ai_Apollo_io__*"`, `"mcp__claude_ai_Vibe_Prospecting__*"` | marketing (new), luv-model-routing, campaign, copywriting, aeo-geo, marketing-psychology, launch-strategy, analytics-tracking, sales-enablement, market-mapping, content-strategy, ad-creative, core-behaviors, caveman (add others that exist) | campaign-orchestrator + `luv-cmo.md:70-113` routing table | campaign-orchestrator, seo-strategist, aeo-geo-specialist, ai-marketer, brand-marketer, product-marketer, online-marketer, copywriter, social-content, analytics-tracker, launch-strategist, the 19 Luv marketing personas |
| operator | sonnet | project config, scaffolds | yes | rw | AskUserQuestion, CronCreate, `"mcp__claude_ai_Telnyx__*"`, `"mcp__claude_ai_Supabase__*"` | cicd-starter, guardrails, channel-setup, voice, slack, routines (new, Sprint 2), migrations, control-plane, core-behaviors, caveman | bootstrap-generator | bootstrap-scanner, agentic-os-builder, kickstart-orchestrator (state machine → skill), kickstart-handoff, migrator, telegram-integrator, slack-integrator, voice-setup, scheduler, heartbeat-agent, sandbox-agent, caveman-speaker, control-plane-agent (write side), hermes-readiness (setup) |
| writer | haiku | yes | – | ro | – | api-docs, contracts (new), core-behaviors, caveman | doc-generator | doc-generator; drafts MSA/SOW/NDA from `skills/contracts/templates/` |

## Absorption rules

- Read the seed body and the absorbed bodies. Keep every procedure that is not already in a
  `skills/<domain>/workflows/` file by porting it there **verbatim first, then shortening**;
  the role body points at the workflow by path. Never let a procedure live only in git history.
- Role bodies stay under ~200 lines. Modes (e.g. debugger: classify / trace / fix / db) are
  sections that name the workflow to read.
- Where an absorbed agent had `Agent` in `tools:`, its dispatch becomes either a
  `SKILL-ORCHESTRATOR.md` (if it drove a pipeline) or a note "return to the chief of staff with
  the next dispatch you need" (if it chained one specialist).
- Orchestrator agents that become skills: attractor-runner, assess-runner, prd-orchestrator,
  factory-runner, loop-orchestrator/-runner/-designer/-triage-curator, autoresearch-runner,
  concept-orchestrator, kickstart-orchestrator, campaign-orchestrator (orchestration half),
  luv-ceo/-cmo/-cto, sleep-runner, go-runner (fan-out half).

## Where it runs

| Role | Runs as |
|---|---|
| chief-of-staff | top-level skill (`/cks:chief`, HQ first turn, routine sessions); agent only in `--agent` mode |
| every other role | sub-agent dispatched by the chief of staff or a `SKILL-ORCHESTRATOR.md`; on a project repo other than the session's, via a Claude Code Remote session the chief of staff opens |

## Definition of done for a role file

- Frontmatter per invariants; `bash scripts/smoke-test.sh` passes for the file.
- Every `skills:` entry resolves; every grant appears in the body.
- Ported workflows exist and are referenced by path.
- Three golden briefs will be written against it in WU 2.9; write the body so a brief has an
  observable artifact or refusal to check.
