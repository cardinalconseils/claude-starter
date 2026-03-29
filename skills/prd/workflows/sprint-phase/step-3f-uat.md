# Sub-step [3f]: UAT (User Acceptance Testing)

<context>
Phase: Sprint (Phase 3)
Requires: QA validation passed ([3e])
Produces: UAT results + stakeholder approval
</context>

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.3f.started" "{NN}-{name}" "Sprint: UAT started"`

## Instructions

Use browser testing if frontend feature. First check if the browse skill is available:

```
IF browse skill exists (commands/browse.md or browse skill installed):
  Skill(skill="browse", args="Navigate to {app_url}. Execute UAT scenarios from discovery:
  - {UAT scenario 1}
  - {UAT scenario 2}
  Take screenshots. Report PASS/FAIL per scenario.")
ELSE:
  Skip automated browser testing. Present manual UAT checklist:
  "Browser automation not available. Please manually verify these scenarios:
   - {UAT scenario 1}
   - {UAT scenario 2}
  Then confirm results below."
```

Present results:
```
AskUserQuestion({
  questions: [{
    question: "UAT results: {N}/{M} scenarios passed. Approve?",
    header: "User Acceptance Testing",
    multiSelect: false,
    options: [
      { label: "Approve — proceed to merge", description: "Feature delivers expected value" },
      { label: "Reject — fix issues", description: "Go back to implementation" },
      { label: "Reject — design issues", description: "Go back to Phase 2 (Design)" },
      { label: "Partial approve", description: "Accept with documented limitations" }
    ]
  }]
})
```

If "Reject — fix issues" → back to [3c].
If "Reject — design issues" → exit Sprint, route to Phase 2 (update STATE.md accordingly).

```
  [3f] UAT                    ✅ {N}/{M} scenarios passed — stakeholder approved
```

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.3f.completed" "{NN}-{name}" "Sprint: UAT complete"`
