# Phase 01 — Dispatch-First Architecture
# Discovery Context

**Status:** Discovery complete  
**Date:** 2026-05-09

---

## Element 1 — Problem Statement

The main Claude Code session is doing all the work inline (reading files, writing code, reviewing, testing). This burns the context window fast, hitting the 55% safeguard mid-task. Non-dev users (marketers, analysts, devops) have no role-appropriate entry point. Business decisions (prod deploys, pricing changes, external comms) have no formal gate — agents can act on them without human approval.

---

## Element 2 — Users

- **Vibe coder** — describes features in plain language, expects agents to build them
- **Vibe marketer** — needs marketing agents (copy, SEO, brand) without dev noise
- **Vibe analyst** — needs research/observability agents without lifecycle overhead
- **Vibe devops** — needs infra/shipping agents without product lifecycle context
- **Power user / senior dev** — already knows the lifecycle, benefits from dispatch-first rule enforcement

---

## Element 3 — Scope

**In scope:**
1. `.claude/rules/dispatch-first.md` — behavioral rule: main session is orchestrator only
2. `skills/guardrails/catalogs/business-decisions.md` — catalog of gates requiring human approval
3. Update `skills/guardrails/SKILL.md` — always generate `business-decisions.md` at bootstrap
4. `--role` flag on `/cks:sprint`, `/cks:new`, `/cks:autonomous` — routes to role-appropriate agent team

**Out of scope:**
- New standalone vibe-* commands (use `--role` flag instead)
- New agents (reuse existing role-appropriate skills)
- Persona rewrite

---

## Element 4 — API Surface (Plugin Surface)

- NEW: `.claude/rules/dispatch-first.md` (global, no glob scope — always loads)
- NEW: `skills/guardrails/catalogs/business-decisions.md`
- EDIT: `skills/guardrails/SKILL.md` — add business-decisions to always-generate list
- EDIT: `commands/sprint.md`, `commands/new.md`, `commands/autonomous.md` — add `--role` flag
- EDIT: `commands/help.md`, `commands/README.md` — update if command signatures change

---

## Element 5 — Acceptance Criteria

1. **Dispatch-first rule loads** — opening a fresh session shows dispatch-first.md in loaded rules
2. **Inline Edit/Write triggers warning** — if main session attempts Edit/Write directly, the rule fires a visible violation message
3. **Worktree required for code changes** — any code-writing agent dispatched without `isolation: worktree` is flagged
4. **Business gate blocks** — when agent attempts a gated action (prod deploy, pricing change, external comm, destructive data op, chatbot behavior change, AI client-facing behavior change, file/workflow removal), execution pauses and AskUserQuestion fires before proceeding
5. **Gate resumes correctly** — after human approves, the agent continues from the exact point it was blocked
6. **`--role` flag routes correctly** — `/cks:sprint --role=marketer` dispatches marketing skill set (ai-marketing, brand-marketing, online-marketing, product-marketing); `--role=analyst` dispatches research/observability skills; `--role=devops` dispatches cicd/security/shipping skills
7. **Vibe flag appears in `/cks:help`** — `--role` documented in relevant commands

---

## Element 6 — Constraints & Negative Cases

**MUST NOT:**
- Dispatch-first rule must not block the orchestrator from reading a handful of files for orientation (initial Read of CLAUDE.md, PRD-STATE.md is allowed)
- Business gate must not fire for dev-only actions (writing tests, editing source files in a branch)
- `--role=marketer` must not load dev-only agents (prd-executor, prd-verifier)
- Rule must not conflict with existing `agents.md`, `commands.md`, `hooks.md`
- Worktree isolation must not be required for read-only agent dispatches (Explore agent, research agents)

---

## Element 7 — Business Decision Catalog (full list)

Gates that ALWAYS require human approval regardless of autonomous mode:
1. **Production deploy** — any deploy to a live/prod environment
2. **Pricing / billing changes** — subscription tiers, prices, billing logic
3. **External communications** — emails, social posts, announcements to real users or the public
4. **Destructive data operations** — deleting/migrating customer data, dropping tables in prod
5. **Chatbot behavior changes** — modifying AI behavior facing end users (tone, guardrails, persona)
6. **AI client-facing behavior** — any agent logic change that affects what clients/customers experience
7. **File or workflow removal** — deleting files or automation workflows (always ask first)

---

## Element 8 — Test Plan

- **Unit:** Rule file presence check in a fresh session (manually verify rules list)
- **Integration:** Bootstrap with `--no-security` flag still emits `business-decisions.md` (because it's in the always-generate list)
- **E2E (role routing):** `/cks:sprint --role=marketer "draft launch tweet"` → dispatches marketing agent team → pauses on "external communication" gate → user approves → resumes
- **E2E (dispatch-first):** Main session attempts inline Edit → violation message fires → user redirected to dispatch

---

## Element 9 — UAT Scenarios

1. **Happy path:** Vibe coder runs `/cks:sprint --role=coder "add login page"` → orchestrator dispatches prd-executor in worktree → no inline writes in main session → feature merged
2. **Business gate:** Agent attempts prod deploy → blocked → human approves → deploy proceeds
3. **Edge case:** Orchestrator tries to write a file inline → dispatch-first rule fires warning → user reminded to dispatch

---

## Element 10 — Definition of Done

- [ ] `.claude/rules/dispatch-first.md` created and loads in fresh session
- [ ] `skills/guardrails/catalogs/business-decisions.md` created
- [ ] `skills/guardrails/SKILL.md` updated (always-generate business-decisions)
- [ ] `--role` flag implemented in `commands/sprint.md`, `commands/new.md`, `commands/autonomous.md`
- [ ] `commands/help.md` updated
- [ ] Rule loads in fresh session (manually verified)
- [ ] Business gate blocks and resumes correctly (E2E test)
- [ ] `--role` flag routes to correct skill set (verified in sprint)
- [ ] PR merged to main with version bump

---

## Element 11 — N/A

Single-project repo. No PROJECT-MANIFEST.md.
