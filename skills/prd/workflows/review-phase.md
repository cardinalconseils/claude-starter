# Workflow: Review Phase (Phase 4)

## Overview
Sprint review, retrospective, backlog refinement, and the critical **iteration decision** that routes back to the correct phase or forward to release. All user interactions MUST use `AskUserQuestion` with selectable options.

## Pre-Conditions
- Phase has completed Sprint (phase_status = "sprinted")
- PR exists from Sprint [3g]

## Steps

### Step 0: Progress Banner

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PRD ► Phase {NN}: {name} ► REVIEW
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 [1] Discover    ✅ done
 [2] Design      ✅ done
 [3] Sprint      ✅ done (PR #{number})
 [4] Review      ▶ current
     [4a] Sprint Review          ○ pending
     [4b] Retrospective          ○ pending
     [4c] Backlog Refinement     ○ pending
     [4d] Iteration Decision     ○ pending
 [5] Release     ○ pending

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 1: Determine Target Phase

Read `.prd/PRD-STATE.md` to find the active phase with status "sprinted".

Load:
- `.prd/phases/{NN}-{name}/{NN}-SUMMARY.md` — what was built
- `.prd/phases/{NN}-{name}/{NN}-VERIFICATION.md` — QA results
- `.prd/phases/{NN}-{name}/{NN}-DESIGN.md` — original design specs
- `.prd/phases/{NN}-{name}/{NN}-CONTEXT.md` — original requirements
- `docs/prds/PRD-{NNN}-{name}.md` — PRD with acceptance criteria

---

### Sub-step [4a]: Sprint Review

**Demo + Feedback Collection**

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

---

### Sub-step [4b]: Retrospective

Run the retrospective:

```
Skill(skill="retro", args="--auto")
```

If retro skill is not available, conduct inline:

```
AskUserQuestion({
  questions: [{
    question: "What went well during this sprint?",
    header: "Retrospective — What Went Well",
    multiSelect: true,
    options: [
      { label: "Discovery was thorough", description: "Requirements were clear" },
      { label: "Design specs were useful", description: "Implementation matched designs" },
      { label: "TDD helped", description: "Technical design prevented rework" },
      { label: "Tests caught issues early", description: "QA was effective" },
      { label: "Good velocity", description: "Sprint completed on time" },
      { label: "Other", description: "I'll elaborate" }
    ]
  }]
})

AskUserQuestion({
  questions: [{
    question: "What slowed us down or should change?",
    header: "Retrospective — Improvements",
    multiSelect: true,
    options: [
      { label: "Discovery was incomplete", description: "Requirements gaps during sprint" },
      { label: "Design didn't match needs", description: "Screens needed rework" },
      { label: "Technical design was wrong", description: "Architecture decisions needed revision" },
      { label: "Tests were insufficient", description: "Bugs found late" },
      { label: "Scope was too large", description: "Too much for one sprint" },
      { label: "Tooling issues", description: "Dev environment problems" },
      { label: "Other", description: "I'll elaborate" }
    ]
  }]
})
```

Append retrospective notes to `.prd/phases/{NN}-{name}/{NN}-REVIEW.md`.

```
  [4b] Retrospective          ✅ {N} learnings captured
```

---

### Sub-step [4c]: Backlog Refinement

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

---

### Sub-step [4d]: Iteration Decision

**THIS IS THE CRITICAL ROUTING STEP.**

Based on all feedback, retro, and backlog decisions:

```
AskUserQuestion({
  questions: [{
    question: "How should we proceed with Phase {NN}: {name}?",
    header: "Iteration Decision",
    multiSelect: false,
    options: [
      { label: "Release", description: "Feature is ready — proceed to Phase 5 (Release Management)" },
      { label: "Iterate: Design", description: "UX/UI changes needed — go back to Phase 2 (Design)" },
      { label: "Iterate: Sprint", description: "Code changes needed — go back to Phase 3 (Sprint) with updated backlog" },
      { label: "Re-discover", description: "Requirements fundamentally changed — go back to Phase 1 (Discovery)" }
    ]
  }]
})
```

**Route based on decision:**

**→ Release:**
Update STATE.md:
```yaml
phase_status: reviewed
next_action: "Run /cks:release for environment promotion"
```

**→ Iterate: Design:**
Update STATE.md:
```yaml
phase_status: iterating_design
iteration_count: {N+1}
iteration_reason: "{feedback summary}"
next_action: "Run /cks:design {NN} to iterate on designs"
```
Write iteration backlog to `.prd/phases/{NN}-{name}/{NN}-BACKLOG.md`.

**→ Iterate: Sprint:**
Update STATE.md:
```yaml
phase_status: iterating_sprint
iteration_count: {N+1}
iteration_reason: "{feedback summary}"
next_action: "Run /cks:sprint {NN} to implement fixes"
```
Write iteration backlog to `.prd/phases/{NN}-{name}/{NN}-BACKLOG.md`.

**→ Re-discover:**
Update STATE.md:
```yaml
phase_status: iterating_discover
iteration_count: {N+1}
iteration_reason: "{feedback summary}"
next_action: "Run /cks:discover {NN} to re-gather requirements"
```

```
  [4d] Iteration Decision     ✅ {decision}
```

---

### Step 2: Completion Banner

**If releasing:**
```
  [4] Review      ✅ done — proceeding to Release
      Sprint Review: feedback collected
      Retrospective: {N} learnings
      Backlog: {N} items (all resolved or deferred)
      Decision: RELEASE
      Next: /cks:release {NN}
```

**If iterating:**
```
  [4] Review      ✅ done — iterating
      Sprint Review: feedback collected
      Retrospective: {N} learnings
      Backlog: {N} items to address
      Decision: ITERATE → Phase {X} ({phase_name})
      Iteration: #{iteration_count}
      Next: /cks:{command} {NN}
```

### Step 3: Context Reset & Compaction

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Review complete. Artifacts saved to disk.
Run /compact before the next phase.

  ✅ REVIEW.md       — feedback + retrospective
  ✅ BACKLOG.md      — iteration items (if any)
  ✅ PRD-STATE.md    — phase tracking + iteration decision
  ✅ Working Notes   — session context (auto-captured)

  /compact
  /cks:next

Nothing is lost.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Do NOT chain to the next workflow via Skill().** Stop here.

## Post-Conditions
- `.prd/phases/{NN}-{name}/{NN}-REVIEW.md` exists (feedback + retro)
- `.prd/phases/{NN}-{name}/{NN}-BACKLOG.md` exists (if items identified)
- PRD-STATE.md updated with iteration decision
- PRD-ROADMAP.md updated
- `.learnings/` updated (if retro skill available)
