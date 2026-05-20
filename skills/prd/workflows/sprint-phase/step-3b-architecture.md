# Sub-step [3b]: Design & Architecture

<context>
Phase: Sprint (Phase 3)
Requires: PLAN.md with secrets pre-conditions ([3a+])
Produces: {NN}-TDD.md (Technical Design Document)
Agent: prd-planner (technical design mode)
</context>

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.3b.started" "{NN}-{name}" "Sprint: design & architecture started"`

## Instructions

Read the PLAN.md and produce a Technical Design Document. Determine complexity:

```
AskUserQuestion({
  questions: [{
    question: "What level of technical design does this sprint need?",
    header: "Design & Architecture",
    multiSelect: false,
    options: [
      { label: "Standard", description: "Data model + API design + test strategy (recommended for most features)" },
      { label: "Comprehensive", description: "Standard + data flow + architecture review + security + NFRs" },
      { label: "Full", description: "All 11 sections (for complex/critical features)" },
      { label: "Minimal", description: "Test strategy only (for simple bug fixes or tweaks)" }
    ]
  }]
})
```

> **Expertise:** Read the `authentication` skill for auth pattern decisions. Read `api-design` for API conventions. Read `database-design` for schema decisions.

Based on selection, produce the relevant TDD sections and write to `.prd/phases/{NN}-{name}/{NN}-TDD.md`.

## Post-TDD: Architecture Artifacts

After writing the TDD, dispatch the architecture-generator agent in Sprint Update mode:

```
Agent(subagent_type="cks:architecture-generator", prompt="Mode: Sprint Update. Phase: {NN}-{name}. TDD path: .prd/phases/{NN}-{name}/{NN}-TDD.md. 1) Update ARCHITECTURE.md (create from template if missing, otherwise append Recent Changes entry). 2) Scan TDD for significant decisions — create .decisions/ADR-NNN.md if found. Report what was written.")
```

This runs silently — it does not block the sprint. If the agent creates an ADR, include it in the step summary.

```
  [3b] Design & Architecture  ✅ TDD: {level} ({N} sections) | ARCHITECTURE.md updated | ADR: {none/ADR-NNN}
```

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.3b.completed" "{NN}-{name}" "Sprint: design & architecture complete"`
