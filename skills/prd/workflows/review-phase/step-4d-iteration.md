# Sub-step [4d]: Iteration Decision

<context>
Phase: Review (Phase 4)
Requires: Backlog refinement ([4c])
Produces: STATE.md updated with routing decision
</context>

**THIS IS THE CRITICAL ROUTING STEP.**

## Iteration Guard

Before routing, check `iteration_count` in STATE.md.
If `iteration_count >= 3`, show this INSTEAD of the normal decision:

```
AskUserQuestion({
  questions: [{
    question: "This feature has been revised {N} times. What should we do?",
    header: "Phase {NN}: {name} — Multiple Revisions",
    multiSelect: false,
    options: [
      { label: "Ship it now", description: "We've invested enough. Release it and address remaining issues in a future update." },
      { label: "One final round of fixes", description: "Last chance — one more round, then we ship no matter what." },
      { label: "Pause and move on", description: "Park this feature. Move to the next one. We can come back later." }
    ]
  }]
})
```

If "Pause and move on" → set `phase_status: shelved` in STATE.md, move to next roadmap feature.
If "One final round of fixes" → proceed but log override in STATE.md: `iteration_limit_override: true`.

## Iteration Decision

Based on all feedback, retro, and backlog decisions, ask the user what happens next.
**Use plain language with clear consequences for each choice:**

```
AskUserQuestion({
  questions: [{
    question: "What happens next with this feature?",
    header: "Phase {NN}: {name} — Next Step",
    multiSelect: false,
    options: [
      { label: "Release to users", description: "Feature is ready. We'll deploy it through staging → production." },
      { label: "Fix code issues", description: "Go back to coding to fix bugs or add missing pieces. Then we'll review again. (Days of work)" },
      { label: "Rethink the design", description: "The look, flow, or approach needs to change. We'll redesign, then re-build. (More significant rework)" },
      { label: "Go back to requirements", description: "What we're building needs to fundamentally change. We'll re-gather requirements from scratch. (Major reset)" }
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
