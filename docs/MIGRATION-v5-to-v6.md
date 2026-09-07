# CKS v5 → v6 Migration Guide

## Overview

CKS v6 replaces the **176 v5 task agents** with **18 roles**. A role is a tool grant plus a
model plus a system prompt; roles differ by what they may reach and write, never by prompt
alone. Every command, skill workflow and pipeline node now dispatches a role with a `Mode:` or
`Persona:` line at the top of the brief, and everything that used to fan out from an agent
runs as an orchestrator skill loaded top-level.

### What changed

- **176 agents → 18 roles.** `agents/` holds exactly eighteen files (`chief-of-staff`,
  `project-manager`, `assistant`, `finops`, `watchdog`, `observer`, `researcher`, `strategist`,
  `architect`, `builder`, `reviewer`, `tester`, `debugger`, `shipper`, `historian`, `marketer`,
  `operator`, `writer`). Contract: `docs/v6-workforce.md`. Catalogue: `docs/wiki/agents.md`.
- **Sub-agents cannot dispatch.** No role carries the `Agent` tool except `chief-of-staff`, and
  it is loaded as a skill, not dispatched. Every v5 orchestrator agent (attractor-runner,
  prd-orchestrator, kickstart-orchestrator, loop-*, concept-orchestrator, factory-runner,
  autoresearch-runner, sleep-runner, campaign-orchestrator) is now a
  `skills/<domain>/SKILL-ORCHESTRATOR.md` that its command loads with
  `Skill(skill="cks:<domain>")` (`.claude/rules/commands.md`, Orchestrator Exception).
- **Namespace.** Every role is `cks:<basename>`. The bare (`prd-executor`) and Luv
  (`luv:cmo`) spellings are gone; `scripts/migrate-v5-to-v6.sh` rewrites all three.
- **Procedures moved into skills.** Every v5 agent body that held a procedure was ported to
  `skills/<domain>/workflows/<verb>.md`; the role body points at it. The old bodies sit in
  `legacy/agents/` for one release.
- **Model-name caveat: none.** No role file, skill or doc names a model; tiers are
  `opus` / `sonnet` / `haiku` in frontmatter and `/cks:model` overrides them per role.

### Why

- One dispatch vocabulary instead of 176 names to remember or misroute
- Grants are the security boundary — 18 reviewed tool lists instead of 176 drifting ones
- Sub-agent dispatch never worked; making orchestration a top-level skill makes it honest
- Every role gets a win/loss record (`.prd/logs/agents/<role>.jsonl`) and golden briefs
  (`.evals/golden/roles/<role>/`), which 176 one-off agents never could

---

## Old `subagent_type` → new target

Generated from `scripts/agent-map.tsv`. Each row applies to all three v5 spellings —
`cks:<name>`, `<name>`, and (for the Luv bench) `luv:<name-without-luv->`. The **hint** is the
first line of the new brief; it tells the role which workflow or persona to load.

| v5 `subagent_type` (any spelling) | v6 target | Hint | Example |
|---|---|---|---|
| `cks:aeo-geo-specialist` / `aeo-geo-specialist` | `cks:marketer` | Persona: seo-geo-aeo | `Agent(subagent_type="cks:marketer", prompt="Persona: seo-geo-aeo. …")` |
| `cks:agentic-os-builder` / `agentic-os-builder` | `cks:operator` | Mode: agentic-os init | `Agent(subagent_type="cks:operator", prompt="Mode: agentic-os init. …")` |
| `cks:agile-eagle` / `agile-eagle` | `cks:strategist` |  | `Agent(subagent_type="cks:strategist", prompt="…")` |
| `cks:ahe-evolution-agent` / `ahe-evolution-agent` | `cks:historian` |  | `Agent(subagent_type="cks:historian", prompt="…")` |
| `cks:ai-marketer` / `ai-marketer` | `cks:marketer` |  | `Agent(subagent_type="cks:marketer", prompt="…")` |
| `cks:analytics-tracker` / `analytics-tracker` | `cks:marketer` | Mode: analytics | `Agent(subagent_type="cks:marketer", prompt="Mode: analytics. …")` |
| `cks:architecture-generator` / `architecture-generator` | `cks:architect` |  | `Agent(subagent_type="cks:architect", prompt="…")` |
| `cks:assess-runner` / `assess-runner` | `Skill(skill="cks:attractor")` |  | `Skill(skill="cks:attractor")` — run the command that loads it |
| `cks:attractor-runner` / `attractor-runner` | `Skill(skill="cks:attractor")` |  | `Skill(skill="cks:attractor")` — run the command that loads it |
| `cks:autoresearch-runner` / `autoresearch-runner` | `Skill(skill="cks:autoresearch")` |  | `Skill(skill="cks:autoresearch")` — run the command that loads it |
| `cks:bootstrap-generator` / `bootstrap-generator` | `cks:operator` | Mode: bootstrap (HQ MODE for /cks:hq) | `Agent(subagent_type="cks:operator", prompt="Mode: bootstrap (HQ MODE for /cks:hq). …")` |
| `cks:bootstrap-scanner` / `bootstrap-scanner` | `cks:operator` | Mode: scan | `Agent(subagent_type="cks:operator", prompt="Mode: scan. …")` |
| `cks:brand-marketer` / `brand-marketer` | `cks:marketer` | Persona: brand-strategist | `Agent(subagent_type="cks:marketer", prompt="Persona: brand-strategist. …")` |
| `cks:browser` / `browser` | `cks:tester` | Mode: browser flows | `Agent(subagent_type="cks:tester", prompt="Mode: browser flows. …")` |
| `cks:campaign-orchestrator` / `campaign-orchestrator` | `cks:marketer` | workflows/campaign.md | `Agent(subagent_type="cks:marketer", prompt="workflows/campaign.md. …")` |
| `cks:canary-monitor` / `canary-monitor` | `cks:observer` | Mode: canary | `Agent(subagent_type="cks:observer", prompt="Mode: canary. …")` |
| `cks:caveman-speaker` / `caveman-speaker` | `cks:operator` |  | `Agent(subagent_type="cks:operator", prompt="…")` |
| `cks:cccs-intel-monitor` / `cccs-intel-monitor` | `cks:researcher` |  | `Agent(subagent_type="cks:researcher", prompt="…")` |
| `cks:changelog-generator` / `changelog-generator` | `cks:shipper` | Mode: changelog | `Agent(subagent_type="cks:shipper", prompt="Mode: changelog. …")` |
| `cks:chief-of-staff` / `chief-of-staff` | `cks:chief-of-staff` | unchanged (v6 role) | `Agent(subagent_type="cks:chief-of-staff", prompt="…")` |
| `cks:ciso` / `ciso` | `cks:reviewer` | Mode: security, cross-repo | `Agent(subagent_type="cks:reviewer", prompt="Mode: security, cross-repo. …")` |
| `cks:code-simplifier` / `code-simplifier` | `cks:builder` | Mode: simplify | `Agent(subagent_type="cks:builder", prompt="Mode: simplify. …")` |
| `cks:compliance-advisor` / `compliance-advisor` | `cks:reviewer` | Mode: compliance (references/canada.md) | `Agent(subagent_type="cks:reviewer", prompt="Mode: compliance (references/canada.md). …")` |
| `cks:concept-orchestrator` / `concept-orchestrator` | `Skill(skill="cks:concept-evaluation")` |  | `Skill(skill="cks:concept-evaluation")` — run the command that loads it |
| `cks:concept-pillar-worker` / `concept-pillar-worker` | `cks:strategist` | Mode: concept pillar (one per dispatch) | `Agent(subagent_type="cks:strategist", prompt="Mode: concept pillar (one per dispatch). …")` |
| `cks:control-plane-agent` / `control-plane-agent` | `cks:operator` | Mode: control plane | `Agent(subagent_type="cks:operator", prompt="Mode: control plane. …")` |
| `cks:coordination-agent` / `coordination-agent` | `cks:observer` |  | `Agent(subagent_type="cks:observer", prompt="…")` |
| `cks:copywriter` / `copywriter` | `cks:marketer` | Persona: long-form-copywriter or ads-copywriter | `Agent(subagent_type="cks:marketer", prompt="Persona: long-form-copywriter or ads-copywriter. …")` |
| `cks:cost-analyzer` / `cost-analyzer` | `cks:finops` | workflows/cost-audit.md | `Agent(subagent_type="cks:finops", prompt="workflows/cost-audit.md. …")` |
| `cks:cost-researcher` / `cost-researcher` | `cks:researcher` | Mode: infra pricing | `Agent(subagent_type="cks:researcher", prompt="Mode: infra pricing. …")` |
| `cks:db-debugger` / `db-debugger` | `cks:debugger` | Mode: db diagnose | `Agent(subagent_type="cks:debugger", prompt="Mode: db diagnose. …")` |
| `cks:db-erd` / `db-erd` | `cks:architect` | Mode: ERD | `Agent(subagent_type="cks:architect", prompt="Mode: ERD. …")` |
| `cks:db-fixer` / `db-fixer` | `cks:debugger` | Mode: db-fix | `Agent(subagent_type="cks:debugger", prompt="Mode: db-fix. …")` |
| `cks:db-investigator` / `db-investigator` | `cks:reviewer` | Mode: db audit (workflows/supabase-audit.md) | `Agent(subagent_type="cks:reviewer", prompt="Mode: db audit (workflows/supabase-audit.md). …")` |
| `cks:db-migration` / `db-migration` | `cks:builder` | Mode: migration | `Agent(subagent_type="cks:builder", prompt="Mode: migration. …")` |
| `cks:debugger` / `debugger` | `cks:debugger` | unchanged (v6 role) | `Agent(subagent_type="cks:debugger", prompt="…")` |
| `cks:debugger-worker` / `debugger-worker` | `cks:debugger` | Mode: fix, one file-scope group | `Agent(subagent_type="cks:debugger", prompt="Mode: fix, one file-scope group. …")` |
| `cks:deep-researcher` / `deep-researcher` | `cks:researcher` | multi-hop; last30days first | `Agent(subagent_type="cks:researcher", prompt="multi-hop; last30days first. …")` |
| `cks:deployer` / `deployer` | `cks:shipper` | Mode: deploy (gated) | `Agent(subagent_type="cks:shipper", prompt="Mode: deploy (gated). …")` |
| `cks:design-fluency-reviewer` / `design-fluency-reviewer` | `cks:reviewer` | Mode: design fluency | `Agent(subagent_type="cks:reviewer", prompt="Mode: design fluency. …")` |
| `cks:design-system-generator` / `design-system-generator` | `cks:architect` |  | `Agent(subagent_type="cks:architect", prompt="…")` |
| `cks:doc-generator` / `doc-generator` | `cks:writer` | workflows/generate.md | `Agent(subagent_type="cks:writer", prompt="workflows/generate.md. …")` |
| `cks:ecosystem-learner` / `ecosystem-learner` | `cks:researcher` |  | `Agent(subagent_type="cks:researcher", prompt="…")` |
| `cks:ecosystem-watcher` / `ecosystem-watcher` | `cks:researcher` |  | `Agent(subagent_type="cks:researcher", prompt="…")` |
| `cks:evals-runner` / `evals-runner` | `cks:tester` | Mode: evals --tier | `Agent(subagent_type="cks:tester", prompt="Mode: evals --tier. …")` |
| `cks:expert-builder` / `expert-builder` | `cks:builder` |  | `Agent(subagent_type="cks:builder", prompt="…")` |
| `cks:expert-debugger` / `expert-debugger` | `cks:debugger` | Mode: root cause | `Agent(subagent_type="cks:debugger", prompt="Mode: root cause. …")` |
| `cks:expert-product` / `expert-product` | `cks:strategist` |  | `Agent(subagent_type="cks:strategist", prompt="…")` |
| `cks:expert-specialist` / `expert-specialist` | `cks:strategist` |  | `Agent(subagent_type="cks:strategist", prompt="…")` |
| `cks:factory-runner` / `factory-runner` | `Skill(skill="cks:github-issues")` |  | `Skill(skill="cks:github-issues")` — run the command that loads it |
| `cks:feature-cataloger` / `feature-cataloger` | `cks:strategist` | Mode: catalog features | `Agent(subagent_type="cks:strategist", prompt="Mode: catalog features. …")` |
| `cks:gatekeeper` / `gatekeeper` | `cks:watchdog` |  | `Agent(subagent_type="cks:watchdog", prompt="…")` |
| `cks:github-project-setup-agent` / `github-project-setup-agent` | `cks:operator` | Mode: board setup | `Agent(subagent_type="cks:operator", prompt="Mode: board setup. …")` |
| `cks:go-runner` / `go-runner` | `cks:shipper` | workflows/go.md | `Agent(subagent_type="cks:shipper", prompt="workflows/go.md. …")` |
| `cks:grill-me-interviewer` / `grill-me-interviewer` | `cks:strategist` | Mode: grill | `Agent(subagent_type="cks:strategist", prompt="Mode: grill. …")` |
| `cks:harness-eval-runner` / `harness-eval-runner` | `cks:tester` | Mode: harness evals | `Agent(subagent_type="cks:tester", prompt="Mode: harness evals. …")` |
| `cks:health-checker` / `health-checker` | `cks:watchdog` | Hunt: health | `Agent(subagent_type="cks:watchdog", prompt="Hunt: health. …")` |
| `cks:heartbeat-agent` / `heartbeat-agent` | `cks:operator` | → skills/routines | `Agent(subagent_type="cks:operator", prompt="-> skills/routines. …")` |
| `cks:hermes-readiness` / `hermes-readiness` | `cks:operator` | Mode: hermes readiness | `Agent(subagent_type="cks:operator", prompt="Mode: hermes readiness. …")` |
| `cks:honcho-integrator` / `honcho-integrator` | `cks:historian` |  | `Agent(subagent_type="cks:historian", prompt="…")` |
| `cks:improvement-agent` / `improvement-agent` | `cks:historian` | Mode: improvement proposals | `Agent(subagent_type="cks:historian", prompt="Mode: improvement proposals. …")` |
| `cks:investigator` / `investigator` | `cks:debugger` | Mode: triage scan → issue queue | `Agent(subagent_type="cks:debugger", prompt="Mode: triage scan -> issue queue. …")` |
| `cks:kickstart-brand` / `kickstart-brand` | `cks:strategist` | Mode: brand brief | `Agent(subagent_type="cks:strategist", prompt="Mode: brand brief. …")` |
| `cks:kickstart-designer` / `kickstart-designer` | `cks:architect` | Mode: design system | `Agent(subagent_type="cks:architect", prompt="Mode: design system. …")` |
| `cks:kickstart-feature-scope` / `kickstart-feature-scope` | `cks:strategist` | Mode: feature scope | `Agent(subagent_type="cks:strategist", prompt="Mode: feature scope. …")` |
| `cks:kickstart-handoff` / `kickstart-handoff` | `cks:operator` | Mode: scaffold handoff | `Agent(subagent_type="cks:operator", prompt="Mode: scaffold handoff. …")` |
| `cks:kickstart-ideator` / `kickstart-ideator` | `cks:strategist` | Mode: ideate | `Agent(subagent_type="cks:strategist", prompt="Mode: ideate. …")` |
| `cks:kickstart-intake` / `kickstart-intake` | `cks:strategist` | Mode: intake | `Agent(subagent_type="cks:strategist", prompt="Mode: intake. …")` |
| `cks:kickstart-orchestrator` / `kickstart-orchestrator` | `Skill(skill="cks:kickstart")` |  | `Skill(skill="cks:kickstart")` — run the command that loads it |
| `cks:kickstart-validate` / `kickstart-validate` | `cks:strategist` | Mode: validate | `Agent(subagent_type="cks:strategist", prompt="Mode: validate. …")` |
| `cks:langsmith-observer` / `langsmith-observer` | `cks:observer` | Mode: langsmith | `Agent(subagent_type="cks:observer", prompt="Mode: langsmith. …")` |
| `cks:launch-readiness` / `launch-readiness` | `cks:watchdog` | Hunt: launch readiness | `Agent(subagent_type="cks:watchdog", prompt="Hunt: launch readiness. …")` |
| `cks:launch-strategist` / `launch-strategist` | `cks:marketer` | Mode: launch | `Agent(subagent_type="cks:marketer", prompt="Mode: launch. …")` |
| `cks:learnings-curator` / `learnings-curator` | `cks:historian` | Mode: curate (PR) | `Agent(subagent_type="cks:historian", prompt="Mode: curate (PR). …")` |
| `cks:log-reader` / `log-reader` | `cks:observer` | Mode: logs | `Agent(subagent_type="cks:observer", prompt="Mode: logs. …")` |
| `cks:loop-cost-monitor` / `loop-cost-monitor` | `Skill(skill="cks:loop")` |  | `Skill(skill="cks:loop")` — run the command that loads it |
| `cks:loop-designer` / `loop-designer` | `Skill(skill="cks:loop")` |  | `Skill(skill="cks:loop")` — run the command that loads it |
| `cks:loop-health-checker` / `loop-health-checker` | `Skill(skill="cks:loop")` |  | `Skill(skill="cks:loop")` — run the command that loads it |
| `cks:loop-orchestrator` / `loop-orchestrator` | `Skill(skill="cks:loop")` |  | `Skill(skill="cks:loop")` — run the command that loads it |
| `cks:loop-runner` / `loop-runner` | `Skill(skill="cks:loop")` |  | `Skill(skill="cks:loop")` — run the command that loads it |
| `cks:loop-triage-curator` / `loop-triage-curator` | `Skill(skill="cks:loop")` |  | `Skill(skill="cks:loop")` — run the command that loads it |
| `cks:luv-ads-copywriter` / `luv-ads-copywriter` / `luv:ads-copywriter` | `cks:marketer` | Persona: ads-copywriter | `Agent(subagent_type="cks:marketer", prompt="Persona: ads-copywriter. …")` |
| `cks:luv-agent-browser` / `luv-agent-browser` / `luv:agent-browser` | `cks:tester` |  | `Agent(subagent_type="cks:tester", prompt="…")` |
| `cks:luv-ai-tooling-engineer` / `luv-ai-tooling-engineer` / `luv:ai-tooling-engineer` | `cks:builder` |  | `Agent(subagent_type="cks:builder", prompt="…")` |
| `cks:luv-alan-sharpe` / `luv-alan-sharpe` / `luv:alan-sharpe` | `cks:marketer` | Persona: alan-sharpe | `Agent(subagent_type="cks:marketer", prompt="Persona: alan-sharpe. …")` |
| `cks:luv-api-designer` / `luv-api-designer` / `luv:api-designer` | `cks:architect` |  | `Agent(subagent_type="cks:architect", prompt="…")` |
| `cks:luv-backend-dev` / `luv-backend-dev` / `luv:backend-dev` | `cks:builder` |  | `Agent(subagent_type="cks:builder", prompt="…")` |
| `cks:luv-brand-strategist` / `luv-brand-strategist` / `luv:brand-strategist` | `cks:marketer` | Persona: brand-strategist | `Agent(subagent_type="cks:marketer", prompt="Persona: brand-strategist. …")` |
| `cks:luv-ceo` / `luv-ceo` / `luv:ceo` | `cks:marketer` | Persona: marketing-director | `Agent(subagent_type="cks:marketer", prompt="Persona: marketing-director. …")` |
| `cks:luv-cicd` / `luv-cicd` / `luv:cicd` | `cks:shipper` |  | `Agent(subagent_type="cks:shipper", prompt="…")` |
| `cks:luv-cmo` / `luv-cmo` / `luv:cmo` | `cks:marketer` | Persona: campaign-lead | `Agent(subagent_type="cks:marketer", prompt="Persona: campaign-lead. …")` |
| `cks:luv-cto` / `luv-cto` / `luv:cto` | `cks:builder` |  | `Agent(subagent_type="cks:builder", prompt="…")` |
| `cks:luv-data-engineer` / `luv-data-engineer` / `luv:data-engineer` | `cks:builder` |  | `Agent(subagent_type="cks:builder", prompt="…")` |
| `cks:luv-data-scientist` / `luv-data-scientist` / `luv:data-scientist` | `cks:marketer` | Persona: data-scientist | `Agent(subagent_type="cks:marketer", prompt="Persona: data-scientist. …")` |
| `cks:luv-database-auth-engineer` / `luv-database-auth-engineer` / `luv:database-auth-engineer` | `cks:builder` |  | `Agent(subagent_type="cks:builder", prompt="…")` |
| `cks:luv-debugger` / `luv-debugger` / `luv:debugger` | `cks:debugger` |  | `Agent(subagent_type="cks:debugger", prompt="…")` |
| `cks:luv-designer` / `luv-designer` / `luv:designer` | `cks:architect` | Persona: designer | `Agent(subagent_type="cks:architect", prompt="Persona: designer. …")` |
| `cks:luv-devops` / `luv-devops` / `luv:devops` | `cks:shipper` |  | `Agent(subagent_type="cks:shipper", prompt="…")` |
| `cks:luv-fin-ops` / `luv-fin-ops` / `luv:fin-ops` | `cks:finops` | finops | `Agent(subagent_type="cks:finops", prompt="finops. …")` |
| `cks:luv-frontend-dev` / `luv-frontend-dev` / `luv:frontend-dev` | `cks:builder` |  | `Agent(subagent_type="cks:builder", prompt="…")` |
| `cks:luv-full-stack-dev` / `luv-full-stack-dev` / `luv:full-stack-dev` | `cks:builder` |  | `Agent(subagent_type="cks:builder", prompt="…")` |
| `cks:luv-growth-revenue-strategist` / `luv-growth-revenue-strategist` / `luv:growth-revenue-strategist` | `cks:marketer` | Persona: growth-revenue-strategist | `Agent(subagent_type="cks:marketer", prompt="Persona: growth-revenue-strategist. …")` |
| `cks:luv-landing-page-dev` / `luv-landing-page-dev` / `luv:landing-page-dev` | `cks:builder` |  | `Agent(subagent_type="cks:builder", prompt="…")` |
| `cks:luv-legal` / `luv-legal` / `luv:legal` | `cks:reviewer` | Persona: claims-compliance | `Agent(subagent_type="cks:reviewer", prompt="Persona: claims-compliance. …")` |
| `cks:luv-linkedin-ads-specialist` / `luv-linkedin-ads-specialist` / `luv:linkedin-ads-specialist` | `cks:marketer` | Persona: linkedin-ads-specialist | `Agent(subagent_type="cks:marketer", prompt="Persona: linkedin-ads-specialist. …")` |
| `cks:luv-long-form-copywriter` / `luv-long-form-copywriter` / `luv:long-form-copywriter` | `cks:marketer` | Persona: long-form-copywriter | `Agent(subagent_type="cks:marketer", prompt="Persona: long-form-copywriter. …")` |
| `cks:luv-meta-ads-specialist` / `luv-meta-ads-specialist` / `luv:meta-ads-specialist` | `cks:marketer` | Persona: meta-ads-specialist | `Agent(subagent_type="cks:marketer", prompt="Persona: meta-ads-specialist. …")` |
| `cks:luv-mobile-app-dev` / `luv-mobile-app-dev` / `luv:mobile-app-dev` | `cks:builder` |  | `Agent(subagent_type="cks:builder", prompt="…")` |
| `cks:luv-mythos` / `luv-mythos` / `luv:mythos` | `cks:reviewer` | Persona: brand-security | `Agent(subagent_type="cks:reviewer", prompt="Persona: brand-security. …")` |
| `cks:luv-n8n-automation` / `luv-n8n-automation` / `luv:n8n-automation` | `cks:operator` |  | `Agent(subagent_type="cks:operator", prompt="…")` |
| `cks:luv-paid-media-manager` / `luv-paid-media-manager` / `luv:paid-media-manager` | `cks:marketer` | Persona: paid-media-manager | `Agent(subagent_type="cks:marketer", prompt="Persona: paid-media-manager. …")` |
| `cks:luv-photo-creator` / `luv-photo-creator` / `luv:photo-creator` | `cks:marketer` | Persona: photo-creator | `Agent(subagent_type="cks:marketer", prompt="Persona: photo-creator. …")` |
| `cks:luv-qa-engineer` / `luv-qa-engineer` / `luv:qa-engineer` | `cks:tester` |  | `Agent(subagent_type="cks:tester", prompt="…")` |
| `cks:luv-seo-geo-aeo` / `luv-seo-geo-aeo` / `luv:seo-geo-aeo` | `cks:marketer` | Persona: seo-geo-aeo | `Agent(subagent_type="cks:marketer", prompt="Persona: seo-geo-aeo. …")` |
| `cks:luv-strategist` / `luv-strategist` / `luv:strategist` | `cks:marketer` | Persona: strategist | `Agent(subagent_type="cks:marketer", prompt="Persona: strategist. …")` |
| `cks:luv-tech-lead` / `luv-tech-lead` / `luv:tech-lead` | `cks:architect` |  | `Agent(subagent_type="cks:architect", prompt="…")` |
| `cks:luv-uat-engineer` / `luv-uat-engineer` / `luv:uat-engineer` | `cks:tester` |  | `Agent(subagent_type="cks:tester", prompt="…")` |
| `cks:luv-video-creator` / `luv-video-creator` / `luv:video-creator` | `cks:marketer` | Persona: video-creator | `Agent(subagent_type="cks:marketer", prompt="Persona: video-creator. …")` |
| `cks:luv-video-producer` / `luv-video-producer` / `luv:video-producer` | `cks:marketer` | Persona: video-producer | `Agent(subagent_type="cks:marketer", prompt="Persona: video-producer. …")` |
| `cks:memory-agent` / `memory-agent` | `cks:historian` | Mode: persist REMEMBER | `Agent(subagent_type="cks:historian", prompt="Mode: persist REMEMBER. …")` |
| `cks:migrator` / `migrator` | `cks:operator` | Mode: migrate | `Agent(subagent_type="cks:operator", prompt="Mode: migrate. …")` |
| `cks:monetize-discoverer` / `monetize-discoverer` | `cks:strategist` | Mode: monetize discover | `Agent(subagent_type="cks:strategist", prompt="Mode: monetize discover. …")` |
| `cks:monetize-evaluator` / `monetize-evaluator` | `cks:strategist` | Mode: monetize evaluate | `Agent(subagent_type="cks:strategist", prompt="Mode: monetize evaluate. …")` |
| `cks:monetize-reporter` / `monetize-reporter` | `cks:strategist` | Mode: monetize report | `Agent(subagent_type="cks:strategist", prompt="Mode: monetize report. …")` |
| `cks:monetize-researcher` / `monetize-researcher` | `cks:researcher` | Mode: market/pricing research | `Agent(subagent_type="cks:researcher", prompt="Mode: market/pricing research. …")` |
| `cks:monetize-roadmap` / `monetize-roadmap` | `cks:strategist` | Mode: monetize roadmap | `Agent(subagent_type="cks:strategist", prompt="Mode: monetize roadmap. …")` |
| `cks:no-code-specialist` / `no-code-specialist` | `cks:builder` |  | `Agent(subagent_type="cks:builder", prompt="…")` |
| `cks:observability-agent` / `observability-agent` | `cks:observer` | Mode: cost/latency | `Agent(subagent_type="cks:observer", prompt="Mode: cost/latency. …")` |
| `cks:online-marketer` / `online-marketer` | `cks:marketer` |  | `Agent(subagent_type="cks:marketer", prompt="…")` |
| `cks:payment-advisor` / `payment-advisor` | `cks:finops` | Mode: payments advice | `Agent(subagent_type="cks:finops", prompt="Mode: payments advice. …")` |
| `cks:peer-coordinator` / `peer-coordinator` | `cks:observer` |  | `Agent(subagent_type="cks:observer", prompt="…")` |
| `cks:persona-interviewer` / `persona-interviewer` | `cks:strategist` |  | `Agent(subagent_type="cks:strategist", prompt="…")` |
| `cks:personas-agent` / `personas-agent` | `cks:strategist` |  | `Agent(subagent_type="cks:strategist", prompt="…")` |
| `cks:pivot-analyzer` / `pivot-analyzer` | `cks:strategist` | Mode: pivot | `Agent(subagent_type="cks:strategist", prompt="Mode: pivot. …")` |
| `cks:prd-designer` / `prd-designer` | `cks:architect` | Mode: design (DESIGN.md) | `Agent(subagent_type="cks:architect", prompt="Mode: design (DESIGN.md). …")` |
| `cks:prd-discoverer` / `prd-discoverer` | `cks:strategist` | Mode: discover (skills/prd/workflows/discover-phase) | `Agent(subagent_type="cks:strategist", prompt="Mode: discover (skills/prd/workflows/discover-phase). …")` |
| `cks:prd-executor` / `prd-executor` | `cks:builder` | Mode: sprint from PLAN.md; writes SUMMARY.md | `Agent(subagent_type="cks:builder", prompt="Mode: sprint from PLAN.md; writes SUMMARY.md. …")` |
| `cks:prd-executor-worker` / `prd-executor-worker` | `cks:builder` | one task group per dispatch | `Agent(subagent_type="cks:builder", prompt="one task group per dispatch. …")` |
| `cks:prd-orchestrator` / `prd-orchestrator` | `Skill(skill="cks:attractor")` |  | `Skill(skill="cks:attractor")` — run the command that loads it |
| `cks:prd-planner` / `prd-planner` | `cks:architect` | Mode: plan (PLAN.md) | `Agent(subagent_type="cks:architect", prompt="Mode: plan (PLAN.md). …")` |
| `cks:prd-refactorer` / `prd-refactorer` | `cks:builder` | Mode: refactor | `Agent(subagent_type="cks:builder", prompt="Mode: refactor. …")` |
| `cks:prd-researcher` / `prd-researcher` | `cks:researcher` | Mode: codebase + options research | `Agent(subagent_type="cks:researcher", prompt="Mode: codebase + options research. …")` |
| `cks:prd-verifier` / `prd-verifier` | `cks:tester` | Mode: verify; writes VERIFICATION.md + CONFIDENCE.md | `Agent(subagent_type="cks:tester", prompt="Mode: verify; writes VERIFICATION.md + CONFIDENCE.md. …")` |
| `cks:printing-press-runner` / `printing-press-runner` | `cks:builder` |  | `Agent(subagent_type="cks:builder", prompt="…")` |
| `cks:product-marketer` / `product-marketer` | `cks:marketer` | Persona: strategist | `Agent(subagent_type="cks:marketer", prompt="Persona: strategist. …")` |
| `cks:project-manager` / `project-manager` | `cks:project-manager` | unchanged (v6 role) | `Agent(subagent_type="cks:project-manager", prompt="…")` |
| `cks:reminder` / `reminder` | `cks:assistant` | Mode: reminders | `Agent(subagent_type="cks:assistant", prompt="Mode: reminders. …")` |
| `cks:remotion-specialist` / `remotion-specialist` | `cks:builder` |  | `Agent(subagent_type="cks:builder", prompt="…")` |
| `cks:retrospective` / `retrospective` | `cks:historian` | Mode: retro | `Agent(subagent_type="cks:historian", prompt="Mode: retro. …")` |
| `cks:reviewer` / `reviewer` | `cks:reviewer` | unchanged (v6 role) | `Agent(subagent_type="cks:reviewer", prompt="…")` |
| `cks:rules-auditor` / `rules-auditor` | `cks:watchdog` | Hunt: rules | `Agent(subagent_type="cks:watchdog", prompt="Hunt: rules. …")` |
| `cks:sandbox-agent` / `sandbox-agent` | `cks:operator` | Mode: sandbox policy | `Agent(subagent_type="cks:operator", prompt="Mode: sandbox policy. …")` |
| `cks:scale-advisor` / `scale-advisor` | `cks:architect` |  | `Agent(subagent_type="cks:architect", prompt="…")` |
| `cks:scheduler` / `scheduler` | `cks:operator` | → skills/routines (register via chief of staff) | `Agent(subagent_type="cks:operator", prompt="-> skills/routines (register via chief of staff). …")` |
| `cks:security-auditor` / `security-auditor` | `cks:reviewer` | Mode: security (OWASP) | `Agent(subagent_type="cks:reviewer", prompt="Mode: security (OWASP). …")` |
| `cks:sentry-observer` / `sentry-observer` | `cks:observer` | Mode: sentry | `Agent(subagent_type="cks:observer", prompt="Mode: sentry. …")` |
| `cks:seo-strategist` / `seo-strategist` | `cks:marketer` | Persona: seo-geo-aeo | `Agent(subagent_type="cks:marketer", prompt="Persona: seo-geo-aeo. …")` |
| `cks:session-journalist` / `session-journalist` | `cks:historian` | Mode: handoff/DEVLOG | `Agent(subagent_type="cks:historian", prompt="Mode: handoff/DEVLOG. …")` |
| `cks:session-loader` / `session-loader` | `Skill(skill="cks:chief-of-staff")` |  | `Skill(skill="cks:chief-of-staff")` — run the command that loads it |
| `cks:ship-runner` / `ship-runner` | `cks:shipper` | Mode: ship | `Agent(subagent_type="cks:shipper", prompt="Mode: ship. …")` |
| `cks:slack-integrator` / `slack-integrator` | `cks:operator` | Mode: slack setup | `Agent(subagent_type="cks:operator", prompt="Mode: slack setup. …")` |
| `cks:sleep-runner` / `sleep-runner` | `Skill(skill="cks:sleep-cycle")` | proposal review via historian | `Skill(skill="cks:sleep-cycle")` — run the command that loads it |
| `cks:social-content` / `social-content` | `cks:marketer` | Mode: social | `Agent(subagent_type="cks:marketer", prompt="Mode: social. …")` |
| `cks:sprint-reviewer` / `sprint-reviewer` | `cks:historian` |  | `Agent(subagent_type="cks:historian", prompt="…")` |
| `cks:standup-reader` / `standup-reader` | `cks:assistant` | Mode: daily brief | `Agent(subagent_type="cks:assistant", prompt="Mode: daily brief. …")` |
| `cks:tdd-runner` / `tdd-runner` | `cks:builder` | Mode: TDD | `Agent(subagent_type="cks:builder", prompt="Mode: TDD. …")` |
| `cks:telegram-integrator` / `telegram-integrator` | `cks:operator` | Mode: telegram setup | `Agent(subagent_type="cks:operator", prompt="Mode: telegram setup. …")` |
| `cks:token-optimizer` / `token-optimizer` | `cks:finops` | workflows/cost-audit.md | `Agent(subagent_type="cks:finops", prompt="workflows/cost-audit.md. …")` |
| `cks:triage-runner` / `triage-runner` | `cks:debugger` | Mode: triage | `Agent(subagent_type="cks:debugger", prompt="Mode: triage. …")` |
| `cks:uat-runner` / `uat-runner` | `cks:tester` | Mode: UAT | `Agent(subagent_type="cks:tester", prompt="Mode: UAT. …")` |
| `cks:user-profiler` / `user-profiler` | `cks:historian` |  | `Agent(subagent_type="cks:historian", prompt="…")` |
| `cks:voice-setup` / `voice-setup` | `cks:operator` | Mode: voice setup | `Agent(subagent_type="cks:operator", prompt="Mode: voice setup. …")` |
| `cks:watchdog` / `watchdog` | `cks:watchdog` | unchanged (v6 role) | `Agent(subagent_type="cks:watchdog", prompt="…")` |
| `cks:wiki` / `wiki` | `cks:historian` | Mode: wiki (OKF) | `Agent(subagent_type="cks:historian", prompt="Mode: wiki (OKF). …")` |
| `cks:work-hierarchy-manager` / `work-hierarchy-manager` | `cks:project-manager` | sole writer of .prd/work-hierarchy.md | `Agent(subagent_type="cks:project-manager", prompt="sole writer of .prd/work-hierarchy.md. …")` |

## Commands whose invocation changed

| Command | v5 | v6 |
|---|---|---|
| `/cks:sprint`, `/cks:sprint-run`, `/cks:assess` | `Agent(cks:attractor-runner)` / `cks:assess-runner` | `Skill(skill="cks:attractor")` |
| `/cks:kickstart` | `Agent(cks:kickstart-orchestrator)` | `Skill(skill="cks:kickstart")` |
| `/cks:loop`, `/cks:loop-migrate` | `Agent(cks:loop-orchestrator)` | `Skill(skill="cks:loop")` |
| `/cks:monetize` | `Agent(cks:monetize-*)` chain | `Skill(skill="cks:monetize")` |
| `/cks:campaign` | `Agent(cks:campaign-orchestrator)` | `Skill(skill="cks:campaign")` |
| `/cks:concept` | `Agent(cks:concept-orchestrator)` | `Skill(skill="cks:concept-evaluation")` |
| `/cks:sleep` | `Agent(cks:sleep-runner)` | `Skill(skill="cks:sleep-cycle")` |
| `/cks:factory` | `Agent(cks:factory-runner)` | `Skill(skill="cks:github-issues")` |
| `/cks:autoresearch` | `Agent(cks:autoresearch-runner)` | `Skill(skill="cks:autoresearch")` |
| `/cks:chief`, `/cks:sprint-start`, `/cks:standup` (context half) | `Agent(cks:chief-of-staff)` / `cks:session-loader` | `Skill(skill="cks:chief-of-staff")` |
| `/cks:luv`, `/cks:marketing*`, `/cks:creative`, `/cks:market`, `/cks:copy` | `luv:ceo` → `luv:cmo` → persona agents | `Agent(cks:marketer, "Persona: <name>")` |
| `/cks:remind`, `/cks:standup` | `cks:reminder`, `cks:standup-reader` | `Agent(cks:assistant, "Mode: reminders" / "Mode: daily brief")` |
| `/cks:cost`, `/cks:payments`, `/cks:monetize-cost-analysis` | `cks:cost-analyzer`, `cks:payment-advisor` | `Agent(cks:finops, …)` (+ `cks:researcher` for pricing) |
| `/cks:schedule` | `cks:scheduler` | `cks:strategist` interview → chief of staff registers a Routine (`skills/routines`) |
| `/cks:expert builder\|product\|debugger\|specialist` | `cks:expert-{type}` | `cks:architect` / `cks:strategist` / `cks:debugger` / `cks:strategist` with `Persona: experts/…` |

**New commands:** `/cks:finops [audit|margin|invoice|burn|sred]`,
`/cks:assistant [inbox|calendar|draft|prep]`, `/cks:routine new|list|status|pause|resume|run-now`,
`/cks:hq init|status`.

**Removed:** `/cks:concierge` — its intake loop is `/cks:chief` (the chief-of-staff skill).

## The `legacy/` holdout

`legacy/agents/` holds the 168 v5 agent files that did not become roles. Claude Code only
discovers `agents/`, so nothing there is loaded, scanned by `scripts/agent-graph.sh`,
`scripts/test-integrity.sh` or `scripts/smoke-test.sh`, or dispatchable. It exists for one
release so anyone who copied an agent into `~/.claude/agents/` can diff it against the role
that absorbed it. **It is removed in 6.1.** `bash scripts/agent-graph.sh --legacy` reports any
legacy type still referenced from live paths.

## Migrating a target project

Projects that copied CKS dispatch sites into their own `.claude/commands/`,
`.claude/agents/`, `CLAUDE.md` or `.prd/**/*.md` need the old types rewritten. From the
project root:

```bash
bash "$CLAUDE_PLUGIN_ROOT/scripts/migrate-v5-to-v6.sh"          # dry run — lists every rewrite
bash "$CLAUDE_PLUGIN_ROOT/scripts/migrate-v5-to-v6.sh" --apply  # rewrite in place
```

The script reads `scripts/agent-map.tsv`, rewrites `subagent_type="…"` in all three spellings
to the role, and prints `MANUAL` for sites whose target is an orchestrator skill — those must
become `Skill(skill="cks:<domain>")` in a top-level command by hand. It never touches
`legacy/`, `CHANGELOG.md`, or this guide.

`scripts/auto-migrate.sh` (SessionStart) stamps `.prd/.cks-version` to 6.0.0 on the first
session and prints a one-line pointer here; it writes no other files.

## Key differences v5 → v6

| Aspect | v5 | v6 |
|---|---|---|
| **Workers** | 176 task agents | 18 roles (grant + model) |
| **Dispatch** | `Agent(subagent_type="<agent>")`, three spellings | `Agent(subagent_type="cks:<role>", prompt="Mode: …")` |
| **Orchestration** | Agents with `Agent` in `tools:` (dead dispatches) | `SKILL-ORCHESTRATOR.md` loaded via `Skill()` top-level |
| **Chief of staff** | agent + concierge | top-level skill; `--agent` mode only for the file |
| **Marketing** | Luv org chart (CEO → CMO → 19 persona agents) | `cks:marketer` + `skills/marketing/personas/` |
| **Scheduling** | `cks:scheduler`, `heartbeat-agent`, CronCreate | `skills/routines/` + `/cks:routine`, registered by the chief of staff |
| **Where it runs** | in-session only | in-session, or a Claude Code Remote session on the target repo |
| **Legacy** | — | `legacy/agents/` for one release, removed in 6.1 |

## Questions?

- **Role contract:** `docs/v6-workforce.md`
- **Per-role catalogue:** `docs/wiki/agents.md`
- **Dispatch lookup for the brain:** `skills/chief-of-staff/references/roster.md`
- **Single mapping source:** `scripts/agent-map.tsv` (consumed by `scripts/remap-dispatch.sh`
  in this repo and `scripts/migrate-v5-to-v6.sh` in target projects)
