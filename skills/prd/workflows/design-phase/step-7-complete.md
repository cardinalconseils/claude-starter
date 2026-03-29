# Step 7: Completion Banner & Context Reset

<context>
Phase: Design (Phase 2)
Requires: State updated (Step 6)
Produces: Completion banner + compaction suggestion
</context>

## Completion Banner

```
  [2] Design      ✅ done
      Output: .prd/phases/{NN}-{name}/{NN}-DESIGN.md
      Diagrams: {N} flowcharts, user flows, sequence diagrams
      Screens: {N} generated, {N} approved
      Components: {N} specified
      Design tokens: defined
      Next: /cks:sprint {NN}
```

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "phase.design.completed" "{NN}-{name}" "Design phase completed"`

## Context Reset & Compaction

All state is persisted to disk. Suggest compaction before sprint:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Design complete. Specs saved to {NN}-DESIGN.md and design/ directory.
Run /compact before sprint to maximize implementation context.

  ✅ DESIGN.md       — design summary
  ✅ design/         — screens, flows, diagrams, component specs
  ✅ PRD-STATE.md    — phase tracking
  ✅ Working Notes   — session context (auto-captured)

  /compact
  /cks:next

Nothing is lost.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Do NOT chain to the next workflow via Skill().** Stop here.
