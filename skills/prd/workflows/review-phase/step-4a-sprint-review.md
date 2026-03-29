# Sub-step [4a]: Sprint Review

<context>
Phase: Review (Phase 4)
Requires: Phase context loaded (Step 1)
Produces: {NN}-REVIEW.md with feedback
</context>

## Instructions

**Demo + Feedback Collection**

**Decision: Single review vs. Agent Team**

Check sprint complexity from SUMMARY.md:
- **≤ 10 files changed, single layer** → single inline review (below)
- **> 10 files or multiple layers (frontend + backend + infra)** → use Agent Team for parallel assessment

### Agent Team Sprint Review (complex sprint)

When the sprint touched multiple layers, use a team to assess quality from different angles simultaneously:

```
Create an agent team to review Phase {NN}: {phase_name} sprint output.

Team lead synthesizes assessments into a comprehensive review for the user.

Spawn 3 teammates (use Sonnet):
- Teammate "feature-check": Verify what was built matches CONTEXT.md acceptance criteria
  and DESIGN.md approved screens. Take screenshots if frontend feature.
  Report: {X}/{Y} criteria met, with evidence for each.

- Teammate "quality-check": Review VERIFICATION.md test results, check test coverage,
  identify untested edge cases from CONTEXT.md constraints (Section 5).
  Report: test health, coverage gaps, risk areas.

- Teammate "metrics-check": Assess success metrics baseline from CONTEXT.md Section 9.
  Check if KPIs are measurable with current implementation.
  Report: which metrics are trackable, which need instrumentation.

Team lead:
- Consolidate all three assessments
- Present unified review to user via AskUserQuestion
```

After the team assessment, continue with user feedback collection below.

### Review Presentation (default or after team assessment)

1. Present what was built (from SUMMARY.md):
   - Key files changed
   - Features implemented
   - Screenshots (if frontend — use Chrome DevTools MCP)

2. Present verification results (from VERIFICATION.md):
   - Acceptance criteria: {X}/{Y} passed
   - QA results: unit/integration/E2E status
   - UAT results

3. Present success metrics baseline (from CONTEXT.md):
   - Expected KPIs
   - Current measurable state (if deployed to dev/staging)

4. Collect feedback:

```
AskUserQuestion({
  questions: [{
    question: "Sprint review complete. What's your overall assessment?",
    header: "Sprint Review",
    multiSelect: true,
    options: [
      { label: "Feature works as expected", description: "Core functionality is correct" },
      { label: "UX/UI needs improvement", description: "Layout, styling, or interaction issues" },
      { label: "Logic bugs found", description: "Feature has functional issues" },
      { label: "Performance concerns", description: "Feature is slow or resource-heavy" },
      { label: "Missing functionality", description: "Acceptance criteria gaps" },
      { label: "Scope needs adjustment", description: "Requirements need revisiting" },
      { label: "Ready for release", description: "No issues — ship it" }
    ]
  }]
})
```

Write feedback to `.prd/phases/{NN}-{name}/{NN}-REVIEW.md`.

```
  [4a] Sprint Review          ✅ Feedback collected
```
