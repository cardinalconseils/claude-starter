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

3. **Show the items FIRST** before asking what to do. Display them in a clear list:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 ITEMS FOUND — {N} total
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 {for each item:}
 [{priority}] {plain description}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Where priority labels are: `Must fix` (bugs, broken things) or `Nice to have` (improvements, polish).

4. Then ask what to do:

```
AskUserQuestion({
  questions: [{
    question: "We found {N} items to address. How should we handle them?",
    header: "What To Fix Before Shipping",
    multiSelect: false,
    options: [
      { label: "Fix everything first", description: "We'll iterate and fix all {N} items before releasing." },
      { label: "Fix must-fix items only", description: "We'll fix the {X} critical items now. The {Y} nice-to-haves go in a future update." },
      { label: "Ship now, fix later", description: "Release the feature as-is. Add these improvements in a future version." },
      { label: "Let me decide on each one", description: "Show me each item so I can pick which to fix now." }
    ]
  }]
})
```

If "Let me decide on each one" → present each item individually:
```
AskUserQuestion({
  questions: [{
    question: "{item description}",
    header: "Item {N}/{total}",
    multiSelect: false,
    options: [
      { label: "Fix now", description: "Include in next round of fixes" },
      { label: "Fix later", description: "Save for a future update" },
      { label: "Skip", description: "Not important enough to track" }
    ]
  }]
})
```

Write refined backlog to `.prd/phases/{NN}-{name}/{NN}-BACKLOG.md`.

```
  [4c] Backlog Refinement     ✅ {N} items: {N} fix, {N} defer
```
