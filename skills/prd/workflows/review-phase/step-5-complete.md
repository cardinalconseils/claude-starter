# Step 5: Completion Banner & Context Reset

<context>
Phase: Review (Phase 4)
Requires: Iteration decision made ([4d])
Produces: Completion banner + compaction suggestion
</context>

## Completion Banner

Display the appropriate banner from `_shared.md` based on the [4d] decision (releasing vs. iterating).

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "phase.review.completed" "{NN}-{name}" "Review phase completed"`

## Context Reset & Compaction

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Review complete. Artifacts saved to disk.
Run /compact before the next phase.

  ✅ REVIEW.md       — feedback + retrospective
  ✅ BACKLOG.md      — iteration items (if any)
  ✅ PRD-STATE.md    — phase tracking + iteration decision
  ✅ Working Notes   — session context (auto-captured)

  /compact
  /cks:next

Nothing is lost.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Do NOT chain to the next workflow via Skill().** Stop here.
