# Discovery: Secrets Lifecycle Management

**Phase:** 01
**Date:** 2026-03-27
**Status:** Complete
**Elements:** 10/10 gathered

---

## 1. Problem Statement & Value Proposition

**Problem:** Secrets (API keys, tokens, credentials) are untracked in the CKS PRD lifecycle. They surface mid-sprint as blockers, stalling implementation and wasting context window tokens. Additionally, new developers joining a project have no documentation of which secrets to obtain.

**Who has it:** Developers using CKS to build projects with external services (Stripe, Supabase, Firebase, etc.), and project leads onboarding new team members.

**Cost of not solving:** Broken sprint flow, wasted AI context when execution stalls on missing credentials, ad-hoc secret handling that risks exposure, and onboarding friction.

**Value delivered:** Smooth sprint execution where every required credential is accounted for before coding begins, with explicit "go fetch this" tasks. New developers can read SECRETS.md to know exactly what credentials they need.

---

## 2. User Stories

| ID | Story | Priority |
|----|-------|----------|
| US-01-01 | As a developer running /cks:discover, I want secrets identified from my tech stack so that I know what credentials I'll need before coding starts. | Must Have |
| US-01-02 | As a developer running /cks:sprint, I want unresolved secrets shown as pre-conditions in PLAN.md so that I can prioritize retrieval. | Must Have |
| US-01-03 | As a developer starting implementation, I want an explicit task asking me to go retrieve each secret (with provider, dashboard path, and required scope) so that I'm not blocked mid-coding. | Must Have |
| US-01-04 | As a project lead, I want a secrets manifest (SECRETS.md) tracking pending/resolved/deferred status so that I can see which credentials are still missing. | Should Have |

---

## 3. Scope (In / Out)

**In scope:**
- Secrets identification during discovery (parse tech stack, cross-reference known-secrets table, create SECRETS.md)
- Pre-conditions injection into PLAN.md during sprint planning
- Blocking retrieval tasks via AskUserQuestion before sprint implementation
- Status tracking in SECRETS.md manifest (pending/resolved/deferred)

**Out of scope:**
- .env file generation or validation — different feature
- Secret rotation or expiry tracking — future enhancement
- Vault integration (1Password, Infisical, etc.) — future enhancement
- Chunking sprint-phase.md — separate refactoring feature (Phase 02)

---

## 4. API Surface Map

N/A — this feature has no API component. It modifies CKS workflow markdown files and uses AskUserQuestion for user interactions.

---

## 5. Acceptance Criteria

### US-01-01: Developer discovers secrets early
- [ ] AC-01: When /cks:discover runs and CONTEXT.md mentions technologies in the known-secrets table, those secrets are identified and written to {NN}-SECRETS.md
- [ ] AC-02: Each secret entry includes: ID (SEC-{NN}-{seq}), name, provider, how to get it, scope needed, and status

### US-01-02: Planner flags blocking secrets
- [ ] AC-03: After planner produces PLAN.md, unresolved secrets are injected as a "Pre-Conditions: Unresolved Secrets" section
- [ ] AC-04: Each pending secret is mapped to the PLAN.md tasks it blocks

### US-01-03: Sprint prompts for retrieval
- [ ] AC-05: Before executor dispatch, AskUserQuestion presents each pending secret with provider name, dashboard path, and required scope — contextual to the specific tech stack and phase
- [ ] AC-06: "Skip — use mock values" option is always available (deferred secrets block release, not sprint)
- [ ] AC-07: Before prompting, .env.local is re-checked to auto-resolve secrets added since discovery
- [ ] AC-08: SECRETS.md is updated with current status after each user interaction

### US-01-04: Manifest tracks status
- [ ] AC-09: SECRETS.md uses the manifest format with SEC-{NN}-{seq} IDs and pending/resolved/deferred statuses
- [ ] AC-10: Environment mapping table connects secrets to .env keys and source files

---

## 6. Constraints & Negative Cases

**Business rules that must NOT be violated:**
- Never store actual secret values in SECRETS.md — names and status only
- Known-secrets table must be extensible by users

**Behaviors that must fail gracefully:**
- Never block indefinitely — skip/defer option must always be available
- If no secrets detected (e.g., pure frontend project) → SECRETS.md created with empty table and note "No external secrets identified"
- If SECRETS.md is malformed → report parsing error, don't crash
- If .env.local doesn't exist → skip re-check, proceed to prompt

---

## 7. Test Plan

### Unit Tests
| ID | What to Test | Input | Expected Output |
|----|-------------|-------|-----------------|
| UT-01 | Known-secrets table lookup | "Stripe" in tech stack | Returns STRIPE_SECRET_KEY, STRIPE_PUBLISHABLE_KEY, STRIPE_WEBHOOK_SECRET |
| UT-02 | Known-secrets table — unknown tech | "FooBarLib" in tech stack | Returns empty list |
| UT-03 | Manifest parsing — normal | Valid SECRETS.md with 3 entries | Counts: 1 resolved, 1 pending, 1 deferred |
| UT-04 | Manifest parsing — empty table | SECRETS.md with no entries | Counts: 0/0/0, message "No secrets" |
| UT-05 | Manifest parsing — malformed | Corrupted SECRETS.md | Error message, no crash |

### Integration Tests
| ID | What to Test | Components | Expected Behavior |
|----|-------------|------------|-------------------|
| IT-01 | Discovery → secrets hook | discover-phase orchestrator + hook-discover.md | SECRETS.md created with entries matching tech stack |
| IT-02 | Planning → secrets pre-conditions | sprint [3a] + hook-plan.md | PLAN.md contains "Pre-Conditions: Unresolved Secrets" section |
| IT-03 | Sprint → secrets gate | sprint [3b+] + hook-sprint.md | AskUserQuestion presented with pending secrets |

### End-to-End Test Scenarios
| ID | User Journey | Steps | Expected Outcome |
|----|-------------|-------|-----------------|
| E2E-01 | Full lifecycle | /cks:discover (with Stripe+Supabase) → /cks:sprint → resolve secrets → implement | SECRETS.md tracks lifecycle: pending → resolved, no mid-sprint blockers |

---

## 8. UAT Scenarios

### Scenario 1: Happy Path — Secrets Found and Resolved
```
Given a project with Stripe and Supabase in the tech stack
When /cks:discover runs and completes step-4b (secrets hook)
Then SECRETS.md is created with ~5 secrets (STRIPE_SECRET_KEY, SUPABASE_URL, etc.)
When /cks:sprint runs and reaches [3b+] (secrets gate)
Then AskUserQuestion prompts: "Go to Stripe Dashboard > Developers > API Keys"
When I add secrets to .env.local and select "I've added them"
Then SECRETS.md is updated: all secrets resolved
```

### Scenario 2: Error Recovery — Skip and Defer
```
Given pending secrets at sprint time
When I select "Skip — use mock values for now"
Then secrets are marked as "deferred" in SECRETS.md
When /cks:release runs later
Then deferred secrets are flagged in release preflight as blocking production
When I resolve the deferred secrets and re-run release
Then preflight passes
```

### Scenario 3: Edge Case — No Secrets Needed
```
Given a pure frontend project with no external API dependencies
When /cks:discover runs and completes step-4b (secrets hook)
Then SECRETS.md is created with empty secrets table
And a note reads "No external secrets identified for this feature"
When /cks:sprint runs
Then secrets gate is skipped (no pending secrets)
```

---

## 9. Definition of Done

- [x] All workflow files created (secrets hooks + chunked discover sub-steps)
- [x] Chunked architecture verified (orchestrator <80 lines, sub-steps <100 lines)
- [x] Secrets hooks integrated at 3 lifecycle points (discovery, planning, sprint)
- [x] Documentation updated (CLAUDE.md, README.md, skills/README.md)
- [x] PR created and merged (#12)
- [ ] Tested with real project run (this test session)
- [ ] Product owner approval

---

## 10. Success Metrics / KPIs

| Metric | Target | Measurement Method | Baseline |
|--------|--------|--------------------|----------|
| Mid-sprint secret blockers | Zero | Developer reports during /cks:sprint | Currently ad-hoc discovery |
| Secrets identified at discovery | 100% for supported technologies | Compare SECRETS.md vs actual .env needs | No tracking today |
| Retrieval task completion rate | >80% resolved before sprint | Count resolved vs deferred in SECRETS.md | No tracking today |

---

## Technical Context

### Files created (already implemented)
- `skills/prd/workflows/secrets/_manifest-format.md` — Schema reference
- `skills/prd/workflows/secrets/hook-discover.md` — Discovery hook (89 lines)
- `skills/prd/workflows/secrets/hook-plan.md` — Planning hook (62 lines)
- `skills/prd/workflows/secrets/hook-sprint.md` — Sprint hook (80 lines)
- `skills/prd/workflows/secrets/check-secrets.md` — Status utility (49 lines)
- `skills/prd/workflows/discover-phase/` — 10 sub-step files + _shared.md
- `skills/prd/workflows/discover-phase.md` — Thin orchestrator (61 lines)

### Files modified
- `skills/prd/workflows/sprint-phase.md` — Added [3a+] and [3b+] hook invocations
- `skills/prd/templates/context.md` — Added External Secrets section
- `skills/prd/templates/state.md` — Added Secrets Tracking fields
- `agents/prd-discoverer.md` — Added hard gate for user confirmation

### Data model changes
New artifact: `{NN}-SECRETS.md` in phase directories, using `SEC-{NN}-{seq}` ID scheme.

### Dependencies
None — uses existing AskUserQuestion, Read, Write tools.

### External Secrets

No external secrets required for this feature (CKS is workflow tooling).

## Codebase Research Notes

- Existing pattern for artifacts: `{NN}-CONTEXT.md`, `{NN}-PLAN.md`, `{NN}-SUMMARY.md` — SECRETS.md follows this convention
- `next.md` (139 lines, pure Skill() router) is the model for the orchestrator pattern
- `prd-executor.md` dispatches workers — similar team-lead delegation pattern

## Open Questions

- [ ] Should the known-secrets table be moved to a separate reference file as it grows?

## Assumptions

- Technologies in the known-secrets table cover ~80% of common stacks
- Users will add custom secrets via the "Add custom secret" option when needed

## Discovery Method

Interactive session — all 10 elements confirmed by user via AskUserQuestion
