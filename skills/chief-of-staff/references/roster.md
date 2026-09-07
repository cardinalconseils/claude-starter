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

| Role | Purpose | Dispatch when | Grant | Model | Level | Runs |
|---|---|---|---|---|---|---|
| `cks:chief-of-staff` | Triage, dispatch ≤3, one brief; never does the work | never dispatched — loaded via `Skill()` | read-only + Agent | opus | — | top-level skill |
| `cks:project-manager` | Issues, board, work hierarchy, handoffs | "track this", "open an issue", "what's on the board", handoff | writes `.prd/` state only; GitHub rw | sonnet | 2 | sub-agent |
| `cks:assistant` | Inbox triage, calendar, reply drafts, reminders, daily brief | "remind me", "inbox", "calendar", "meeting prep", "standup" | writes user dir only; Gmail/Calendar read + draft, never send | sonnet | 1 | sub-agent |
| `cks:finops` | Cost audit, margins, invoice draft, burn, SR&ED, payments advice | "cost", "margin", "budget", "invoice", "pricing model", "payments" | writes `.finops/`; Stripe read | sonnet | 1 | sub-agent |
| `cks:watchdog` | Friction hunts: rules, stalled work, dead automation, launch readiness, loop health/cost | "what's stalling", "audit the rules", "health check", "launch readiness" | read-only | sonnet | 1 | sub-agent |
| `cks:observer` | Logs, Sentry, LangSmith, Vercel/Supabase advisors, canary, peer sessions | "logs", "errors in prod", "sentry", "traces", "who else is working on this" | read-only + observability MCPs | sonnet | 1 | sub-agent |
| `cks:researcher` | Deep research (`last30days` first), options research, market/pricing, threat intel | "research", "what's out there", "compare", "market", "news" | writes `.research/`, research artifacts; web + Firecrawl/Context7/Perplexity | sonnet | 1 | sub-agent |
| `cks:strategist` | Discovery, intake, ideation, scope, monetize scoring, concept pillars, pivots, personas | "create", "new", "scope", "idea", "concept", "monetize", "pivot", "discover" | writes discovery artifacts (`.prd/` discovery, `.kickstart/`, `.monetize/`, `.concept/`, `.preflight/`) | opus | 2 | sub-agent |
| `cks:architect` | DESIGN.md, PLAN.md, TDD, ADRs, ERDs, design system, loop design, scaling advice | "plan", "design", "architect", "spec out", "ERD", "schema", "design system" | writes + edits design docs only | opus | 2 | sub-agent |
| `cks:builder` | Implementation from PLAN.md (SUMMARY.md), TDD, refactor, migrations, no-code, CLI gen | "sprint", "build", "implement", "code it", "refactor", "migrate the schema" | full write (worktree isolation) | sonnet | 2 | sub-agent |
| `cks:reviewer` | Code review, security (OWASP, CISO), compliance, design fluency, DB audit, contracts | "review the code", "security", "OWASP", "compliance", "contract review" | read-only + GitHub PR read, Supabase advisors | opus | 1 | sub-agent |
| `cks:tester` | VERIFICATION.md + CONFIDENCE.md, UAT, browser flows, evals, harness evals | "test", "verify", "UAT", "evals", "browser check" | writes fixtures, `.evals/`, `.harness-evals/`, VERIFICATION.md; files issues | sonnet | 2 | sub-agent |
| `cks:debugger` | Root cause, triage → issue queue, targeted fixes, DB debug/fix | "fix", "debug", "broken", "error", "bug", "triage", "RLS failing" | Edit only (no new files); GitHub issues; Supabase SQL | opus | 2 | sub-agent |
| `cks:shipper` | go (build → commit → PR), deploy (gated), changelog, plugin release | "deploy", "ship", "go live", "push", "PR", "changelog", "release" | full write; GitHub + Vercel rw; production deploy is `GATED:` | sonnet | 2 | sub-agent |
| `cks:historian` | Retro, sprint review, learnings, wiki, `REMEMBER`, journal, improvement proposals | "retro", "what did we build", "learnings", "remember this", "journal", "wiki" | writes + edits `memory/`, `.learnings/`, HQ memory, user profile | sonnet | 2 | sub-agent |
| `cks:marketer` | Every marketing persona: campaigns, copy, SEO/AEO/GEO, ads, social, analytics, launch, outbound | "campaign", "copy", "ads", "SEO", "launch plan", "brand", "outbound", any `/cks:luv-*` ask | writes `.campaign/`, `.marketing/`; Ahrefs/Apollo/Vibe; OpenRouter curl | opus | 1 | sub-agent |
| `cks:operator` | Bootstrap, scaffolds, integrations (Telegram/Slack/voice), routines, sandbox, control plane, caveman | "set up", "bootstrap", "adopt", "integrate", "schedule", "sandbox", "caveman this" | writes project config + scaffolds; CronCreate; Telnyx, Supabase | sonnet | 2 | sub-agent |
| `cks:writer` | API/architecture/component docs, MSA/SOW/NDA drafts | "docs", "document this", "README", "draft the SOW" | writes docs and contract drafts | haiku | 1 | sub-agent |

Level = default autonomy (`skills/routines/SKILL.md`): 1 suggests, 2 drafts or edits inside its
write scope, never executes a gated action. A message that matches several rows ("plan and
sprint") is low confidence: clarify before dispatching.

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
