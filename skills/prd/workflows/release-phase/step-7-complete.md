# Step 7: Completion Report & Context Reset

<context>
Phase: Release (Phase 5)
Requires: State updated (Step 6)
Produces: Completion banner + context reset
</context>

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
