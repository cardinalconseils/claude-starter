# Phase Transitions — Navigation Protocol

## The 5-Phase Cycle

```
Phase 1: Discover → Phase 2: Design → Phase 3: Sprint → Phase 4: Review → Phase 5: Release
                                          ↑                    |
                                          └────── iterate ─────┘
```

| Phase | Name | Entry Command | Exit Artifact | Directory Prefix |
|-------|------|--------------|---------------|-----------------|
| 1 | Discover | `/cks:discover` | `{NN}-CONTEXT.md` | `01-` |
| 2 | Design | `/cks:design` | `{NN}-DESIGN.md` | `02-` |
| 3 | Sprint | `/cks:sprint` | `{NN}-SUMMARY.md` + `{NN}-VERIFICATION.md` | `03-` |
| 4 | Review | `/cks:review` | `{NN}-REVIEW.md` | `04-` |
| 5 | Release | `/cks:release` | Deployed + tagged | `05-` |

`{NN}` = the feature's phase directory number (e.g., `03-backend-api`).

## Directory Structure

Each feature lives in `.prd/phases/{NN}-{feature-slug}/`:

```
.prd/phases/03-backend-api/
  03-CONTEXT.md          ← Phase 1 output
  03-DESIGN.md           ← Phase 2 output
  03-PLAN.md             ← Phase 3 planning output
  03-TDD.md              ← Phase 3 technical design
  03-SUMMARY.md          ← Phase 3 completion output
  03-VERIFICATION.md     ← Phase 3 QA output
  03-REVIEW.md           ← Phase 4 output
  CONFIDENCE.md          ← Quality gate tracking
  design/diagrams/       ← Mermaid sources + rendered SVGs
```

All artifact filenames are prefixed with the feature number (`{NN}-`).

## Phase Detection

Check which phase is complete by scanning for exit artifacts:

| To confirm phase is done | Check for |
|-------------------------|-----------|
| Discover complete | `{NN}-CONTEXT.md` exists |
| Design complete | `{NN}-DESIGN.md` exists |
| Sprint complete | `{NN}-SUMMARY.md` AND `{NN}-VERIFICATION.md` exist |
| Review complete | `{NN}-REVIEW.md` exists |
| Release complete | Git tag exists for feature |

## Forward Transition

To advance to the next phase:

1. Verify the current phase's exit artifact exists
2. Update `.prd/PRD-STATE.md` (see `tools/prd-state.md`):
   - `Active Phase` → next phase number
   - `Phase Name` → next phase name
   - `Phase Status` → `IN_PROGRESS`
   - `Last Action` → what completed
   - `Next Action` → first step of next phase
   - `Suggested Command` → next phase's entry command
3. Log the transition (see `tools/lifecycle-log.md`):
   - Event: `phase.{current}.completed`
   - Then: `phase.{next}.started`

## Iteration (Backward Transition)

Review (Phase 4) can route backward:

| Review Decision | Target | When |
|----------------|--------|------|
| Release | Phase 5 | All criteria met |
| Iterate Sprint | Phase 3 | Bugs or gaps to fix |
| Iterate Design | Phase 2 | UX/architecture rework needed |
| Re-discover | Phase 1 | Scope needs fundamental change |

When iterating backward:
1. Increment `Iteration Count` in PRD-STATE.md
2. Set `Iteration Reason` to why
3. Log event type `iteration.back` with metadata `{"from": 4, "to": 3, "reason": "..."}`
4. Update phase fields as normal

## Quality Gates (CONFIDENCE.md)

Each phase tracks quality via `CONFIDENCE.md`:

```markdown
| # | Gate | Applies | Status | Evidence | Timestamp |
|---|------|---------|--------|----------|-----------|
| 1 | Tests pass | Yes | PASS | 42/42 green | 2026-04-02 |
| 2 | No secrets | Yes | PASS | scan clean | 2026-04-02 |
```

Status values: `PASS`, `FAIL`, `SKIPPED`.

Merge guards read this file — a `FAIL` blocks the merge.

## Context Loading Strategy

Agents should lazy-load artifacts — read only what's needed for the current step:

| Agent Role | Read First | Read On Demand |
|-----------|-----------|----------------|
| Discoverer | CLAUDE.md, PROJECT.md | — |
| Designer | CONTEXT.md, PROJECT.md | CLAUDE.md |
| Planner | CONTEXT.md, DESIGN.md | CLAUDE.md, ROADMAP.md |
| Executor | PLAN.md, CLAUDE.md | TDD.md (workers load their own) |
| Reviewer | SUMMARY.md, VERIFICATION.md | CONTEXT.md (for scope check) |

Never read all artifacts at once — it wastes context window.
