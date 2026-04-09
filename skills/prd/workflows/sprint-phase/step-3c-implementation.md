# Sub-step [3c]: Implementation

<context>
Phase: Sprint (Phase 3)
Requires: TDD + secrets gate passed ([3b+])
Produces: Source code changes + {NN}-SUMMARY.md
Agent: prd-executor (team lead)
</context>

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.3c.started" "{NN}-{name}" "Sprint: implementation started"`

## Instructions

> **Expertise:** Read the `incremental-implementation` skill — build in thin vertical slices, test each before expanding.

The executor is a **team lead** that autonomously decides whether to implement solo or dispatch parallel workers. Pass it file paths, not content.

### First Sprint — Full Implementation

```
Agent(
  subagent_type="cks:prd-executor",
  model="{resolved_model_execute}",
  prompt="
    Project root: {project_root}
    Phase: {phase_number} — {phase_name}

    Read these files (lazy — load only what you need per step):
    - .prd/phases/{NN}-{name}/{NN}-PLAN.md — your task list
    - .prd/phases/{NN}-{name}/{NN}-TDD.md — technical design
    - .prd/phases/{NN}-{name}/{NN}-DESIGN.md — UI specs (for frontend tasks)
    - .prd/phases/{NN}-{name}/design/component-specs.md — component specs
    - CLAUDE.md — project conventions
    - Domain context: {list .context/*.md filenames matching PLAN.md domains:}

    Implement all tasks from the plan.
    Write summary to: .prd/phases/{NN}-{name}/{NN}-SUMMARY.md

    You decide: solo (≤ 2 task groups) or team (3+ independent groups).
    Use model='{resolved_model_bulk}' for workers if dispatching a team.
  "
)
```

```
  [3c] Implementation         ✅ {N} files changed {team ? "— team ("+N+" workers)" : ""}
```

### Iteration Sprint — Targeted Fixes

```
Agent(
  subagent_type="cks:prd-executor",
  model="{resolved_model_execute}",
  prompt="
    Project root: {project_root}
    Phase: {phase_number} — {phase_name}
    ITERATION MODE: Iteration #{iteration}

    Read these files (lazy — load only what you need):
    - .prd/phases/{NN}-{name}/{NN}-PLAN-iter{iteration}.md — iteration tasks
    - .prd/phases/{NN}-{name}/{NN}-SUMMARY.md — previous implementation
    - .prd/phases/{NN}-{name}/{NN}-REVIEW.md — feedback context
    - .prd/phases/{NN}-{name}/{NN}-TDD.md — technical design
    - .prd/phases/{NN}-{name}/{NN}-DESIGN.md — design specs
    - CLAUDE.md — conventions

    Fix/improve ONLY what the iteration plan specifies.
    Write summary to: .prd/phases/{NN}-{name}/{NN}-SUMMARY-iter{iteration}.md
  "
)
```

```
  [3c] Implementation         ✅ Iteration #{iteration} — {N} files changed, {N} backlog items addressed
```

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.3c.completed" "{NN}-{name}" "Sprint: implementation complete"`
