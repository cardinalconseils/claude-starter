# PRD-001: RPI Methodology Skill

**Status:** Planned
**Created:** 2026-04-04
**Phase:** 01-rpi-methodology
**Author:** prd-planner

---

## Problem Statement

Research findings get lost between phases. There is no explicit Research-Plan-Implement (R-P-I) sub-cycle sequencing within each lifecycle phase, quality gates between R, P, and I stages are missing, and iteration loops do not refresh research before re-planning.

The 5-phase lifecycle (discover, design, sprint, review, release) works at the macro level but lacks rigor at the micro level within each phase. Agents skip directly from problem to implementation without a structured planning step, and quality varies because nothing enforces "research done before planning" or "plan validated before implementing."

## Who Has This Problem

- **Plugin users** -- lose research context when moving between phases; iteration loops feel like starting from scratch
- **prd-orchestrator agent** -- has no formal R-P-I sub-cycle to follow within each phase dispatch; relies on implicit sequencing
- **Agent authors** -- lack a documented methodology for wiring R-P-I into new agents or skills

## Solution

Add an RPI methodology skill to CKS that defines a Research-Plan-Implement sub-cycle with explicit quality gates. This is delivered as three new files (skill, workflow, command) plus agent wiring updates. No new agents, no state machine changes, no modifications to the 5-phase lifecycle.

## Deliverables

| # | Deliverable | File | Description |
|---|-------------|------|-------------|
| 1 | RPI Skill | `skills/rpi/SKILL.md` | Methodology definition: sub-stage definitions, artifact contracts (what each stage produces/consumes), gate criteria (R->P and P->I) |
| 2 | RPI Workflow | `skills/rpi/workflows/rpi-subcycle.md` | Step-by-step sub-cycle logic: gate check procedures, iteration refresh protocol, concrete gate check examples |
| 3 | RPI Command | `commands/rpi.md` | `/cks:rpi` thin dispatcher: shows sub-cycle status for current phase, dispatches orchestrator with RPI context |
| 4 | Agent Wiring | `agents/prd-orchestrator.md` | Add `rpi` to `skills:` frontmatter list |
| 5 | Help Update | `commands/help.md` | Add `/cks:rpi` to the command listing |
| 6 | README Update | `commands/README.md` | Update command count to reflect new command |

## Scope

### In Scope

- `skills/rpi/SKILL.md` -- new skill defining the RPI methodology, artifact contracts, gate definitions
- `skills/rpi/workflows/rpi-subcycle.md` -- workflow detailing R-P-I sub-cycle steps, gate checks, iteration refresh logic
- `commands/rpi.md` -- new `/cks:rpi` command (thin dispatcher showing sub-cycle status)
- Agent wiring updates -- update `agents/prd-orchestrator.md` to reference the `rpi` skill
- Quality gate definitions -- formal gate criteria between R->P and P->I stages
- Documentation updates -- `commands/help.md` and `commands/README.md`

### Out of Scope

- **No new agents** -- RPI is a skill/methodology, not a new agent role
- **No 5-phase lifecycle changes** -- the 5 phases remain unchanged; RPI operates within phases
- **No state machine changes** -- existing state transitions in `PRD-STATE.md` are not modified; RPI status is derived from artifact presence
- **No hook changes** -- gate enforcement is at the workflow/agent instruction level, not hook-level automation

## Acceptance Criteria

- [ ] AC-01: Running `/cks:rpi` displays the current phase's R-P-I sub-stage (Research, Plan, or Implement) and what artifacts exist vs. are pending
- [ ] AC-02: The status output identifies which gate (R->P or P->I) has been passed or is blocking
- [ ] AC-03: The R->P gate blocks planning if required research artifacts are missing (no research notes, no codebase scan results)
- [ ] AC-04: The P->I gate blocks implementation if required planning artifacts are missing (no plan document, no acceptance criteria confirmed)
- [ ] AC-05: Gate violations produce a clear message identifying what is missing and how to satisfy the gate
- [ ] AC-06: `agents/prd-orchestrator.md` references the `rpi` skill in its `skills:` frontmatter
- [ ] AC-07: The orchestrator follows R-P-I sequencing when dispatching sub-phase work
- [ ] AC-08: When an iteration loop returns to a phase, the Research sub-stage re-runs or explicitly refreshes before Plan executes
- [ ] AC-09: `skills/rpi/SKILL.md` exists, is under 250 lines, and documents sub-stage definitions, artifact contracts, and gate criteria
- [ ] AC-10: `skills/rpi/workflows/rpi-subcycle.md` contains at least one concrete example of a gate check with pass/fail criteria

## Constraints

- `skills/rpi/SKILL.md` must stay under 250 lines (skill rules)
- `commands/rpi.md` must stay under 60 lines (command rules)
- Command must be a thin dispatcher using at most `Read`, `Agent`, `AskUserQuestion`
- No new agents may be created
- All existing commands, agents, and state transitions must continue to work unchanged
- RPI sub-stage status is derived from artifact presence in `.prd/phases/`, not new state fields

## Negative Cases

- Running `/cks:rpi` when no `.prd/` directory exists -> message directing user to run `/cks:new` first
- Running `/cks:rpi` when no phase is active -> message indicating no active phase, suggesting `/cks:next`
- Gate check when artifacts are partially present -> list specifically which artifacts are missing

## Success Metrics

| Metric | Target |
|--------|--------|
| Research artifact survival across iterations | 100% refreshed, not discarded |
| Gate enforcement rate | 100% of Plan attempts blocked when Research incomplete |
| Methodology adoption | `rpi` skill referenced in orchestrator, available via `/cks:rpi` |
| Documentation completeness | SKILL.md + workflow + command all present and valid |

## Implementation Phase

This PRD is implemented in a single phase (Phase 01). All deliverables are markdown files within the existing CKS plugin architecture. Estimated scope: **Small** -- 3 new files, 3 file updates, no code.
