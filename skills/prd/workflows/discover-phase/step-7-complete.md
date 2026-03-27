# Step 7: Completion Banner & Context Reset

<context>
Phase: Discover (Phase 1)
Requires: State updated (step-6)
Produces: Completion banner displayed, session guidance
</context>

## Instructions

Display the completion banner:

```
  [1] Discover    ✅ done
      Output: .prd/phases/{NN}-{name}/{NN}-CONTEXT.md
      Elements: 10/10 complete
        ✅ Problem Statement    ✅ User Stories (N)
        ✅ Scope                ✅ API Surface ({N} endpoints | N/A)
        ✅ Acceptance Criteria  ✅ Constraints
        ✅ Test Plan            ✅ UAT Scenarios (N)
        ✅ Definition of Done   ✅ Success Metrics (N)
      Secrets: {N} identified ({R} resolved, {P} pending)
      Next: /cks:design {NN}
```

Then suggest context reset:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Discovery complete. All 10 elements saved to {NN}-CONTEXT.md.
Run /compact before design to free context for the next phase.

  ✅ CONTEXT.md      — all 10 discovery elements
  ✅ SECRETS.md      — secrets manifest
  ✅ PRD-STATE.md    — phase tracking
  ✅ Working Notes   — session context (auto-captured)

  /compact
  /cks:next

Nothing is lost.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Do NOT chain to the next workflow via Skill().** Stop here.

## Success Condition

- Completion banner displayed with accurate counts
- User informed of next steps

## On Failure

- N/A — this step is display-only
