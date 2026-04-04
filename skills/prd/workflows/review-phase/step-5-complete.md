# Step 5: Completion Banner & Context Reset

<context>
Phase: Review (Phase 4)
Requires: Iteration decision made ([4d])
Produces: Completion banner + compaction suggestion
</context>

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
   2. Run /cks:next      (picks up where you left off)

 Your progress is saved. Nothing is lost.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Do NOT chain to the next workflow via Skill().** Stop here.
