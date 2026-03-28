# Step 6: Update State

<context>
Phase: Discover (Phase 1)
Requires: Validation passed (step-5)
Produces: Updated PRD-STATE.md and PRD-ROADMAP.md
</context>

## Inputs

- Read: `.prd/PRD-STATE.md`
- Read: `.prd/PRD-ROADMAP.md`
- Read: `.prd/phases/{NN}-{name}/{NN}-SECRETS.md` (for secrets count)

## Instructions

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.6.started" "{NN}-{name}" "Step 6: Update state"`

**Update PRD-STATE.md:**
```yaml
active_phase: {NN}
phase_name: {name}
phase_status: discovered
last_action: "Discovery complete — 10/10 elements gathered"
last_action_date: {today}
next_action: "Run /cks:design to create UI designs"
suggested_command: "/cks:design {NN}"
```

If `{NN}-SECRETS.md` exists, also add to the session history:
```
| {today} | {NN} | Discovery + secrets identified | {N} secrets ({R} resolved, {P} pending) |
```

**Update PRD-ROADMAP.md:**
- Set the phase status to "Discovered"

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "state.transition" "{NN}-{name}" "State: discovering → discovered" '{"from_status":"discovering","to_status":"discovered"}'`

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.6.completed" "{NN}-{name}" "Step 6: State updated"`

## Success Condition

- PRD-STATE.md `phase_status` is `discovered`
- PRD-ROADMAP.md shows phase as "Discovered"

## On Failure

- If STATE.md write fails: report error, suggest manual update
