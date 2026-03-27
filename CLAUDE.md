# CKS — Claude Code Starter Kit

> This is the starter template repository for the CKS plugin. CLAUDE.md is overwritten by `/cks:bootstrap` when applied to a real project.

## What This Project Is

A Claude Code plugin providing a 5-phase feature lifecycle — from idea to production. Discover, design, sprint, review, and release with structured workflows, AI agents, and quality gates.

## Stack

- **Claude Code** — Skills, agents, commands, hooks
- **Git + GitHub** — PR workflows via `/cks:go`
- **Railway** — Deployment via `/cks:deploy`

## Architecture

### Workflow Pattern: Chunked Orchestrators

Workflows follow a **chunked architecture** — a thin orchestrator file routes through sub-step files:

```
workflow-phase.md              (~60-80 lines, orchestrator)
  → Read step-0-progress.md   (display banner)
  → Read step-1-target.md     (determine phase)
  → Read step-N-*.md          (each sub-step <100 lines)
```

Each sub-step follows a standard format: context block, inputs, instructions, success condition, on-failure. The orchestrator uses `Read + inline execute` — not `Skill()` or `Agent()` — to keep local variables in scope.

### Secrets Lifecycle

Secrets (API keys, tokens, credentials) are tracked across the PRD lifecycle:
- **Discovery** — identified from tech stack, written to `{NN}-SECRETS.md`
- **Planning** — injected as pre-conditions into PLAN.md
- **Sprint** — blocking retrieval tasks before implementation
- Manifest format: `SEC-{NN}-{seq}` with status tracking (pending/resolved/deferred)

## Key Workflows

### 5-Phase Feature Lifecycle
```
/cks:new "feature"  → Phase 1: /cks:discover → Phase 2: /cks:design
→ Phase 3: /cks:sprint → Phase 4: /cks:review → Phase 5: /cks:release
```

### Quick Actions
```
/cks:go              → build + commit + push + PR
/cks:next            → auto-advance to next phase
/cks:autonomous      → run all 5 phases without stopping
```

## Commands Available

- `/cks:new` — Create a new feature and start the lifecycle
- `/cks:discover` — Phase 1: Discovery (10 Elements)
- `/cks:design` — Phase 2: Design (screens + specs)
- `/cks:sprint` — Phase 3: Sprint (plan → build → review → QA → merge)
- `/cks:review` — Phase 4: Review & Retrospective
- `/cks:release` — Phase 5: Release Management
- `/cks:go` — Quick actions (commit, PR, dev, build)
- `/cks:next` — Auto-advance to next phase
- `/cks:fix` — Auto-detect and fix build errors
- `/cks:tdd` — Standalone TDD workflow
- `/cks:security` — Security audit
- `/cks:context` — Research a library/API
- `/cks:research` — Deep multi-hop research
- `/cks:monetize` — Business model evaluation
- `/cks:bootstrap` — Adapt .claude/ to this project
- `/cks:virginize` — Strip files to starter-ready templates

## Agents Available

- **prd-discoverer** — Phase 1: Interactive requirements discovery (10 Elements)
- **prd-designer** — Phase 2: UX flows, screen generation, component specs
- **prd-planner** — Phase 3: Sprint planning + TDD strategy
- **prd-executor** — Phase 3: Implementation (team lead, dispatches workers)
- **prd-verifier** — Phase 3: QA validation
- **reviewer** — Code review
- **deployer** — Railway deployments + environment promotion
- **security-auditor** — OWASP Top 10, secrets detection, dependency audit
- **doc-generator** — API docs, architecture docs

## File Structure

```
skills/prd/workflows/
  discover-phase.md            ← Orchestrator (61 lines)
  discover-phase/              ← Sub-steps (10 files, each <100 lines)
  sprint-phase.md              ← Monolithic (to be chunked in future)
  secrets/                     ← Secrets lifecycle hooks
    hook-discover.md           ← Identify secrets from tech stack
    hook-plan.md               ← Inject pre-conditions into PLAN.md
    hook-sprint.md             ← Blocking retrieval tasks
```

## Always Follow These Rules

- Use `AskUserQuestion` for all user interactions during discovery — never infer silently
- Follow the chunked sub-step pattern for new workflows
- Keep sub-step files under 100 lines
- Persist state to `PRD-STATE.md` after every step
- Never commit secrets or .env values

## Environment Variables

| Variable | Purpose |
|----------|---------|
| `PERPLEXITY_API_KEY` | Enhanced research quality (optional — falls back to WebSearch) |

## Do Not

- Modify production database without explicit confirmation
- Commit secrets or env var values
- Deploy without passing health check
- Write monolithic workflow files over 150 lines — chunk them
