# Sub-step [5b]: Staging Deploy + Feedback

<context>
Phase: Release (Phase 5)
Requires: Dev validated ([5a])
Produces: Staging feedback positive
</context>

**Quality Gate: Staging → RC**

## Instructions

1. Deploy to staging environment
2. Notify limited external testers (if applicable)
3. Monitor:
   - Error rates
   - Performance metrics
   - User feedback

```
AskUserQuestion({
  questions: [{
    question: "Staging deployment live. Collect feedback and validate:",
    header: "Staging → RC Gate",
    multiSelect: false,
    options: [
      { label: "Feedback positive — promote to RC", description: "Error rate acceptable, metrics trending right" },
      { label: "Issues found — fix first", description: "Go back to Sprint for fixes" },
      { label: "Design issues — revisit design", description: "Go back to Phase 2" },
      { label: "Skip staging", description: "Move directly to RC (small change or hotfix)" }
    ]
  }]
})
```

If routing back → update STATE.md, exit release.

```
  [5b] Staging Deploy         ✅ Feedback positive
```
