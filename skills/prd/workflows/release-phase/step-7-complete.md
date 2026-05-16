# Step 7: Completion Report & Context Reset

<context>
Phase: Release (Phase 5)
Requires: State updated (Step 6)
Produces: Completion banner + context reset
</context>

## AskUserQuestion Gate

Before displaying the completion report, verify the interactive release gate:

```
If PHASE_MODE is `interactive` and AskUserQuestion was not called at least once during this phase, STOP — you skipped interactive checkpoints. Do not mark the phase complete. Return to the deploy confirmation step and call AskUserQuestion before proceeding.
```

## Completion Report

Display the completion banner from `_shared.md`.

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "phase.release.completed" "{NN}-{name}" "Release phase completed"`

## CD Integration

For continuous deployment monitoring, suggest:
```
Tip: Run /ralph-loop:ralph-loop "monitor production {url} for errors"
```

## Context Reset

```
━━━ Context Reset ━━━
Release complete. Clear context before next work:

  /clear
  /cks:next    ← if more features remain
  /cks:status  ← to check overall progress

State is on disk — nothing is lost.
━━━━━━━━━━━━━━━━━━━━━
```
