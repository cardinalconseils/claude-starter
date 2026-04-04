---
name: rpi
description: >
  Research-Plan-Implement sub-cycle methodology for the CKS feature lifecycle. Defines the R-P-I
  sequence within each phase, quality gates between stages, artifact contracts, and iteration-aware
  refresh. Use when: checking R-P-I status, enforcing research-before-planning gates, validating
  plan-before-implementation gates, refreshing stale research on iteration loops, or when the user
  says "rpi", "research plan implement", "quality gates", "artifact handoff", "what stage am I in",
  "why is planning blocked", or any variation of R-P-I sub-cycle management.
allowed-tools: Read, Glob, Grep
---

# RPI — Research-Plan-Implement Sub-Cycle

Every feature phase in CKS follows a disciplined R-P-I sub-cycle:
**Research → Plan → Implement**, with quality gates between each transition.

## The Sub-Cycle

```
Research ──[R→P gate]──→ Plan ──[P→I gate]──→ Implement
    ↑                                              │
    └──────── iteration refresh ◄──────────────────┘
```

RPI operates **within** the 5-phase lifecycle. It is not a replacement for Discover/Design/Sprint/Review/Release — it is the micro-discipline inside each phase that ensures research informs planning and planning informs implementation.

## Sub-Stage Definitions

### Research (R)

**Purpose:** Gather knowledge before making decisions.
**Who:** `prd-researcher`, `deep-researcher`, context-research skill
**Artifacts produced:**
- `.context/{slug}.md` — technology briefs (API patterns, gotchas, code examples)
- `.research/{slug}/report.md` — deep research reports (strategic findings, competitive analysis)
- `.prd/phases/{NN}-{name}/{NN}-RESEARCH.md` — feature-specific technical investigation

**When complete:** At least one of the above exists for the technologies/domains relevant to the feature.

### Plan (P)

**Purpose:** Define what to build and how, informed by research.
**Who:** `prd-discoverer` (requirements), `prd-planner` (execution plan)
**Artifacts produced:**
- `.prd/phases/{NN}-{name}/{NN}-CONTEXT.md` — discovery output (11 Elements)
- `.prd/phases/{NN}-{name}/{NN}-PLAN.md` — execution plan with tasks and acceptance criteria
- `docs/prds/PRD-{NNN}-{name}.md` — PRD document

**When complete:** PLAN.md exists with tasks, acceptance criteria, and file scopes.

### Implement (I)

**Purpose:** Build what the plan specifies, using research findings.
**Who:** `prd-executor`, `prd-executor-worker`, `prd-verifier`
**Artifacts produced:**
- `.prd/phases/{NN}-{name}/{NN}-SUMMARY.md` — implementation summary
- `.prd/phases/{NN}-{name}/{NN}-VERIFICATION.md` — test results and acceptance checks
- Source code changes per PLAN.md task list

**When complete:** VERIFICATION.md exists with PASS verdict.

## Quality Gates

### R→P Gate (Research → Plan)

**Blocks planning if research is insufficient.**

Check: Does at least ONE research artifact exist for the feature?
- `{NN}-RESEARCH.md` in the phase directory, OR
- `.context/*.md` briefs for technologies referenced in the feature, OR
- `.research/*/report.md` for the feature's domain

**Pass:** At least one research artifact exists. Proceed to Plan.
**Fail:** No research artifacts found. Message:
```
R→P gate blocked: No research artifacts found for phase {NN}.
Run /cks:context "{technology}" or /cks:research "{topic}" first.
```

**Skip condition:** If the feature brief explicitly states no external technologies or integrations are involved, the gate may be marked `SKIP:trivial` with justification.

### P→I Gate (Plan → Implement)

**Blocks implementation if plan is incomplete.**

Check: Does the plan exist and contain acceptance criteria?
- `{NN}-PLAN.md` exists in the phase directory
- PLAN.md contains at least one `### Task` section
- PLAN.md contains an `## Acceptance Criteria` section with at least one item

**Pass:** Plan exists with tasks and acceptance criteria. Proceed to Implement.
**Fail:** Plan incomplete. Message:
```
P→I gate blocked: {specific missing item}.
Run /cks:sprint to generate the execution plan.
```

## Iteration Refresh Protocol

When `iteration_count > 0` in PRD-STATE.md (feature returning from Phase 4 Review):

1. **Research re-runs:** All `.context/` briefs for the feature are refreshed (not skipped)
2. **Deep research checked:** If `.research/` reports exist and the iteration feedback references technology issues, flag them for manual refresh
3. **Plan re-evaluates:** The planner reads refreshed research before producing an iteration plan
4. **Gate re-checks:** Both gates re-evaluate with fresh artifacts

## Status Derivation

RPI status is derived from filesystem artifacts — no new state fields needed:

```
Phase directory: .prd/phases/{NN}-{name}/

Research:  EXISTS({NN}-RESEARCH.md) OR EXISTS(.context/*.md relevant) → done
Plan:      EXISTS({NN}-PLAN.md) with tasks                           → done
Implement: EXISTS({NN}-VERIFICATION.md) with PASS                    → done
```

| Artifacts Present | Current Sub-Stage |
|-------------------|-------------------|
| None | Research (start here) |
| Research only | Plan (R→P gate: passed) |
| Research + Plan | Implement (P→I gate: passed) |
| Research + Plan + Verification(PASS) | Complete |

## Workflow

For step-by-step gate check procedures, iteration refresh logic, and status display format:

Read: `${SKILL_ROOT}/workflows/rpi-subcycle.md`
