# Sub-step [3e]: QA Validation

<context>
Phase: Sprint (Phase 3)
Requires: Code review passed ([3d])
Produces: {NN}-VERIFICATION.md
Agent: prd-verifier (team lead)
</context>

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.3e.started" "{NN}-{name}" "Sprint: QA validation started"`

## Instructions

The verifier autonomously decides solo vs. team based on test layers present. Pass file paths, not content.

```
Agent(
  subagent_type="prd-verifier",
  prompt="
    Project root: {project_root}
    Phase: {phase_number} — {phase_name}

    Read these files (lazy — load only what you need):
    - .prd/phases/{NN}-{name}/{NN}-PLAN.md — acceptance criteria
    - .prd/phases/{NN}-{name}/{NN}-SUMMARY.md — what was implemented
    - PRD document: docs/prds/PRD-{NNN}-{name}.md — broader criteria

    Run all test layers, verify all acceptance criteria.
    Write results to: .prd/phases/{NN}-{name}/{NN}-VERIFICATION.md

    If API feature: check for Newman collection at
    .prd/phases/{NN}-{name}/testing/newman/api-contract.postman_collection.json
    If found, include API contract tests as a verification track (npx newman run).

    You decide: solo (1 test type) or team (2+ test types in parallel).
    Use model='sonnet' for test workers if dispatching a team.
  "
)
```

## Handle QA Results

Process results:
- **All pass** → proceed to [3f]
- **Some fail** →
```
AskUserQuestion({
  questions: [{
    question: "QA found {N} failures. How to proceed?",
    header: "QA Validation Results",
    multiSelect: false,
    options: [
      { label: "Fix and re-test", description: "Go back to implementation, fix failures" },
      { label: "Accept partial", description: "Proceed with known failures documented" },
      { label: "Re-scope", description: "Remove failing criteria from this sprint" }
    ]
  }]
})
```

If "Fix and re-test" → re-run [3c] for fixes, then re-run [3e].

```
  [3e] QA Validation          ✅ {X}/{Y} criteria passed {team ? "— parallel QA team" : ""}
```

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.3e.completed" "{NN}-{name}" "Sprint: QA validation complete"`
