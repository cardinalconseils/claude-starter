# Sub-step [4d]: Iteration Decision

<context>
Phase: Review (Phase 4)
Requires: Backlog refinement ([4c])
Produces: STATE.md updated with routing decision
</context>

**THIS IS THE CRITICAL ROUTING STEP.**

## Iteration Guard

Before routing to any iteration, check `iteration_count` in STATE.md.
If `iteration_count >= 3`, do NOT offer iteration options. Instead:

```
AskUserQuestion({
  questions: [{
    question: "This feature has iterated {N} times. Continuing may indicate a deeper issue. How to proceed?",
    header: "Iteration Limit Reached (max: 3)",
    multiSelect: false,
    options: [
      { label: "Release as-is", description: "Ship current state — address remaining issues as a new feature" },
      { label: "Force one more iteration", description: "Override limit — I understand the risk" },
      { label: "Shelve feature", description: "Move to backlog and start a different feature" }
    ]
  }]
})
```

If "Shelve feature" → set `phase_status: shelved` in STATE.md, move to next roadmap feature.
If "Force one more iteration" → proceed but log override in STATE.md: `iteration_limit_override: true`.

## Iteration Decision

Based on all feedback, retro, and backlog decisions:

```
AskUserQuestion({
  questions: [{
    question: "How should we proceed with Phase {NN}: {name}?",
    header: "Iteration Decision",
    multiSelect: false,
    options: [
      { label: "Release", description: "Feature is ready — proceed to Phase 5 (Release Management)" },
      { label: "Iterate: Design", description: "UX/UI changes needed — go back to Phase 2 (Design)" },
      { label: "Iterate: Sprint", description: "Code changes needed — go back to Phase 3 (Sprint) with updated backlog" },
      { label: "Re-discover", description: "Requirements fundamentally changed — go back to Phase 1 (Discovery)" }
    ]
  }]
})
```

## Route Based on Decision

**→ Release:**
Update STATE.md:
```yaml
phase_status: reviewed
next_action: "Run /cks:release for environment promotion"
```

**→ Iterate: Design:**
**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "state.iteration" "{NN}-{name}" "Iteration: back to design" '{"from_phase":"review","to_phase":"design","reason":"{feedback summary}"}'`
Update STATE.md:
```yaml
phase_status: iterating_design
iteration_count: {N+1}
iteration_reason: "{feedback summary}"
next_action: "Run /cks:design {NN} to iterate on designs"
```
Write iteration backlog to `.prd/phases/{NN}-{name}/{NN}-BACKLOG.md`.

**→ Iterate: Sprint:**
**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "state.iteration" "{NN}-{name}" "Iteration: back to sprint" '{"from_phase":"review","to_phase":"sprint","reason":"{feedback summary}"}'`
Update STATE.md:
```yaml
phase_status: iterating_sprint
iteration_count: {N+1}
iteration_reason: "{feedback summary}"
next_action: "Run /cks:sprint {NN} to implement fixes"
```
Write iteration backlog to `.prd/phases/{NN}-{name}/{NN}-BACKLOG.md`.

**→ Re-discover:**
**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "state.iteration" "{NN}-{name}" "Iteration: back to discover" '{"from_phase":"review","to_phase":"discover","reason":"{feedback summary}"}'`
Update STATE.md:
```yaml
phase_status: iterating_discover
iteration_count: {N+1}
iteration_reason: "{feedback summary}"
next_action: "Run /cks:discover {NN} to re-gather requirements"
```

```
  [4d] Iteration Decision     ✅ {decision}
```
