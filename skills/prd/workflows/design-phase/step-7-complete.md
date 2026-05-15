# Step 7: Completion Banner & Context Reset

<context>
Phase: Design (Phase 2)
Requires: State updated (Step 6)
Produces: Completion banner + compaction suggestion
</context>

## AskUserQuestion Gate

Before outputting the completion banner, verify the interactive design gate:

```
If {aq_count} < 3:
  STOP. Do not complete the design phase.
  The design phase requires at least 3 AskUserQuestion calls to ensure the user
  has been consulted on design decisions. Only {aq_count} question(s) were asked.
  Return to step-3-dispatch and ask at least one more design question before completing.
  Candidates: UX flow approval, screen iteration feedback, API contract review,
              component spec confirmation, or [2f] Design Review sign-off.

If {aq_count} >= 3:
  Proceed with the completion banner below.
```

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
