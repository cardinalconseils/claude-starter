# Sub-step [4c]: Backlog Refinement

<context>
Phase: Review (Phase 4)
Requires: Sprint review ([4a]) + Retrospective ([4b])
Produces: {NN}-BACKLOG.md (if items identified)
</context>

## Instructions

Based on feedback from [4a] and retro from [4b], identify action items:

1. Parse feedback for actionable items
2. Categorize each item:
   - **Design debt** — UX/UI fixes needed
   - **Bug** — logic/functional issues
   - **Enhancement** — missing or improved functionality
   - **Tech debt** — architecture/performance improvements
   - **Process improvement** — workflow changes

3. Present refined backlog:

```
AskUserQuestion({
  questions: [{
    question: "Backlog refined. {N} items identified. Prioritize:",
    header: "Backlog Refinement",
    multiSelect: false,
    options: [
      { label: "Fix all before release", description: "{N} items — iterate first" },
      { label: "Fix critical only", description: "{N} critical items — defer the rest" },
      { label: "Defer all", description: "Ship as-is — address in next feature cycle" },
      { label: "Review item by item", description: "Let me decide on each one" }
    ]
  }]
})
```

If "Review item by item" → present each item with accept/defer/remove options.

Write refined backlog to `.prd/phases/{NN}-{name}/{NN}-BACKLOG.md`.

```
  [4c] Backlog Refinement     ✅ {N} items: {N} fix, {N} defer
```
