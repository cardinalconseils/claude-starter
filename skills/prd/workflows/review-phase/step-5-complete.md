# Step 5: Completion Banner & Context Reset

<context>
Phase: Review (Phase 4)
Requires: Iteration decision made ([4d])
Produces: Completion banner + compaction suggestion
</context>

## AskUserQuestion Gate

Before displaying the completion banner, verify the interactive review gate:

```
If PHASE_MODE is `interactive` and AskUserQuestion was not called at least once during this phase, STOP — you skipped interactive checkpoints. Do not mark the phase complete. Return to step-4d (iteration decision) and call AskUserQuestion before proceeding.
```

## Completion Banner

Display the appropriate banner from `_shared.md` based on the [4d] decision (releasing vs. iterating).

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "phase.review.completed" "{NN}-{name}" "Review phase completed"`

## Context Reset & Next Steps

Display a clear message explaining what was saved and exactly what to do next:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Review Complete!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 Your feedback is saved:
   ✅ Review notes + retrospective
   ✅ Items to fix (if any)
   ✅ Your decision: {Release / Fix code / Redesign / Re-gather requirements}

 What to do now:
   1. Run /compact       (frees up memory for the next step)
   2. Run {exact_next_command}

 {exact_next_command} is derived from the [4d] decision above:
   Release         → /cks:release {NN}
   Iterate Sprint  → /cks:sprint {NN}
   Iterate Design  → /cks:design {NN}
   Re-discover     → /cks:discover {NN}

 Your progress is saved. Nothing is lost.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Do NOT chain to the next workflow via Skill().** Stop here.
