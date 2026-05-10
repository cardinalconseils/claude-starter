# The 5-Phase Lifecycle

Every feature in CKS follows the same path. Start with `/cks:new "feature name"`, then advance through phases with `/cks:next` or by running each phase command directly.

```
/cks:new "feature"
  Phase 1: /cks:discover
  Phase 2: /cks:design
  Phase 3: /cks:sprint
  Phase 4: /cks:review   ──→ iterate? ──→ back to Phase 1, 2, or 3
  Phase 5: /cks:release
```

## Phase 1 — Discovery

**Command:** `/cks:discover`
**Agent:** `prd-discoverer`
**Purpose:** Understand what you're building before writing any code.

The discoverer gathers 11 Elements through conversation:

1. Problem statement — what problem does this solve and for whom?
2. User stories — who does what, and why?
3. Scope — what's in and what's explicitly out?
4. API surface — what endpoints or integrations are needed?
5. Acceptance criteria — how do we know it's done?
6. Constraints — technical, time, or resource limits
7. Test plan — what will be tested and how?
8. UAT scenarios — what does the user verify before sign-off?
9. Definition of Done — the complete checklist for "shippable"
10. KPIs — how will success be measured post-launch?
11. Cross-project dependencies — what other features or systems does this touch?

**Artifacts produced:** `CONTEXT.md`, `SECRETS.md` (if secrets are needed)

**Triggers next phase:** Discovery is marked complete when all 11 Elements are captured and validated.

---

## Phase 2 — Design

**Command:** `/cks:design`
**Agent:** `prd-designer`
**Purpose:** Define how the feature looks, flows, and integrates before implementation.

The designer produces:

- UX flows — screen transitions and user paths
- API contract — endpoints, request/response shapes, error codes
- Screen generation — uses Stitch MCP to generate actual UI screens
- Component specs — what components are needed and how they connect

**Artifacts produced:** `DESIGN.md`, screen files, API contract document

**Triggers next phase:** Design is complete when flows are approved and the API contract is finalized.

---

## Phase 3 — Sprint

**Command:** `/cks:sprint`
**Agents:** `prd-planner`, `prd-executor`, `prd-executor-worker`, `reviewer`, `prd-verifier`
**Purpose:** Build, review, and validate the feature.

Sprint runs in sub-steps:

| Sub-step | What Happens |
|----------|-------------|
| 3a — Planning | Break design into task groups, write `PLAN.md`, inject secrets as pre-conditions |
| 3b — Pre-conditions | Resolve any required secrets or environment variables |
| 3c — Implementation | Execute task groups; executor may dispatch parallel workers for large plans |
| 3d — Code review | Reviewer checks code quality, security, and adherence to rules |
| 3e — QA validation | Verifier checks acceptance criteria one by one |
| 3f — UAT | User confirms scenarios from Discovery |
| 3g — Merge | Branch merged, PR closed |

The executor decides how to split work:
- 1-2 task groups: executes inline
- 3-5 independent groups: parallel subagents
- 6+ groups or large context: agent teams with git worktree isolation

**Artifacts produced:** `PLAN.md`, implementation branch, PR

**Triggers next phase:** Sprint completes when UAT passes and the PR is merged.

---

## Phase 4 — Review

**Command:** `/cks:review`
**Agent:** `sprint-reviewer`
**Purpose:** Capture feedback and decide whether to ship or iterate.

The reviewer:

1. Runs the app (or verifies it runs)
2. Collects user feedback
3. Runs a retrospective — what worked, what didn't
4. Makes an iteration decision

**Iteration routing:**

| Feedback | Route |
|----------|-------|
| UX issues | Back to Phase 2 (Design) |
| Logic bugs | Back to Phase 3 (Sprint) |
| Scope changed | Back to Phase 1 (Discovery) |
| Ready to ship | Forward to Phase 5 (Release) |

Maximum 3 iteration loops before the reviewer escalates and asks for a decision.

**Artifacts produced:** `RETRO.md`, updated backlog, iteration decision

---

## Phase 5 — Release

**Command:** `/cks:release`
**Agent:** `deployer`
**Purpose:** Promote the feature through environments to production with quality gates at each step.

| Stage | Gate |
|-------|------|
| Dev | Tests passing, no open blocking issues |
| Staging | Smoke tests, performance check, security scan |
| RC (Release Candidate) | Final UAT sign-off, rollback plan confirmed |
| Production | All gates passed, monitoring confirmed active |

Deferred secrets from Discovery block production promotion until resolved.

**Artifacts produced:** Deployment record, environment promotion log

---

## Automation: `/cks:autonomous`

Runs all 5 phases without stopping. Use when requirements are clear and you want the entire lifecycle executed hands-off. Add `--role=coder|marketer|analyst|devops` to scope the skill set to your role.

## Session Context

At the start of every work session, run `/cks:sprint-start` — it loads your current phase, PRD state, git status, and the last session's learnings. At the end, run `/cks:sprint-close` to capture what was done and flag anything for the next session.

## Secrets Lifecycle

Secrets (API keys, credentials) are tracked across the entire lifecycle:

| Phase | What Happens |
|-------|-------------|
| Discovery | Tech stack analyzed → required secrets identified → `SECRETS.md` created |
| Planning | Unresolved secrets added as blocking pre-conditions in `PLAN.md` |
| Sprint | User is prompted to retrieve each secret before coding proceeds |
| Release | Deferred secrets block production deployment |
