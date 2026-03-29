# Step 7: Completion Banner & Context Reset

<context>
Phase: Discover (Phase 1)
Requires: State updated (step-6)
Produces: Completion banner displayed, session guidance
</context>

## Instructions

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.7.started" "{NN}-{name}" "Step 7: Completion banner"`

Display the completion banner:

```
  [1] Discover    ✅ done
      Output: .prd/phases/{NN}-{name}/{NN}-CONTEXT.md
      Elements: 11/11 complete
        ✅ Problem Statement    ✅ User Stories (N)
        ✅ Scope                ✅ API Surface ({N} endpoints | N/A)
        ✅ Acceptance Criteria  ✅ Constraints
        ✅ Test Plan            ✅ UAT Scenarios (N)
        ✅ Definition of Done   ✅ Success Metrics (N)
        ✅ Cross-Project Deps (N/A if single)
      Secrets: {N} identified ({R} resolved, {P} pending)
      Next: /cks:design {NN}
```

Then suggest context reset:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Discovery complete. All 11 elements saved to {NN}-CONTEXT.md.
Run /compact before design to free context for the next phase.

  ✅ CONTEXT.md      — all 11 discovery elements
  ✅ SECRETS.md      — secrets manifest
  ✅ PRD-STATE.md    — phase tracking
  ✅ Working Notes   — session context (auto-captured)

  /compact
  /cks:next

Nothing is lost.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.7.completed" "{NN}-{name}" "Step 7: Completion banner displayed"`

**Do NOT chain to the next workflow via Skill().** Stop here.

## Success Condition

- Completion banner displayed with accurate counts
- User informed of next steps

## On Failure

- N/A — this step is display-only
