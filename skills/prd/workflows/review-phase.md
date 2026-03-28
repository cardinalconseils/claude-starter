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
 PRD ► Phase {NN}: {name} ► REVIEW {iteration_count > 0 ? "— after Iteration #"+iteration_count : ""}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 [1] Discover    ✅ done
 [2] Design      ✅ done
 [3] Sprint      ✅ done (PR #{number}) {iteration_count > 0 ? "— Iteration #"+iteration_count : ""}
 [4] Review      ▶ current
     [4a] Sprint Review          ○ pending
     [4b] Retrospective          ○ pending
     [4c] Backlog Refinement     ○ pending
     [4d] Iteration Decision     ○ pending
 [5] Release     ○ pending

 {if iteration_count > 0:}
 Iteration History:
   Sprint (initial)     ✅ → Review → Iterate
   {for each iteration 1..iteration_count:}
   Iteration #{N}       ✅ → Review {N == iteration_count ? "▶ current" : "→ Iterate"}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "phase.review.started" "{NN}-{name}" "Review phase started"`

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

**Decision: Single review vs. Agent Team**

Check sprint complexity from SUMMARY.md:
- **≤ 10 files changed, single layer** → single inline review (below)
- **> 10 files or multiple layers (frontend + backend + infra)** → use Agent Team for parallel assessment

#### Agent Team Sprint Review (complex sprint)

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

#### Review Presentation (default or after team assessment)

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

**Always interactive.** The retro asks 3 contextual questions seeded from sprint data, then optionally feeds the learning system.

#### Step 1: Gather Context for Question Generation

**Prerequisite:** `{NN}-REVIEW.md` must exist from [4a]. If missing, log a warning and proceed with reduced context.

Parse these sources to build contextual options:

| Source | What to extract |
|--------|----------------|
| `{NN}-REVIEW.md` (from [4a]) | Sprint review feedback, quality-check issues, feature-check results |
| `{NN}-SUMMARY.md` | Files changed, features implemented, scope changes |
| `{NN}-VERIFICATION.md` | Pass/fail counts, specific failures |
| `{NN}-DESIGN.md` | Compare component list against SUMMARY.md — if >= 80% match, design was "closely followed" |
| Git history | Commit patterns (feat/fix ratio), hotspot files (changed > 3 times), velocity |

Build two lists:
- `wins[]` — things that went well (high pass rate, clean areas, design followed, scope handled)
- `issues[]` — things flagged (quality-check findings, verification failures, hotspots, high fix ratio)

#### Step 2: Question 1 — Wins (contextual)

Generate options dynamically from `wins[]`. Each option should reference specific sprint data.

```
AskUserQuestion({
  questions: [{
    question: "What went well during this sprint?",
    header: "Retro — Wins",
    multiSelect: true,
    options: [
      // Dynamic options generated from wins[] — examples:
      { label: "{feature} works as designed", description: "{X}/{Y} acceptance criteria met" },
      { label: "Design specs were accurate", description: "Implementation matched {design artifact}" },
      { label: "Quality review caught real issues", description: "{N} issues identified in [4a]" },
      { label: "Good velocity", description: "Sprint completed in {N} commits across {N} files" },
      // Always include:
      { label: "Other", description: "I'll elaborate" }
    ]
  }]
})
```

**Option generation rules (Q1):**
- If verification pass rate >= 80%: include "Strong verification results — {X}/{Y} criteria passed"
- If feat:fix commit ratio > 2:1: include "Clean implementation — few bug fixes needed"
- If >= 80% of DESIGN.md components appear in SUMMARY.md: include "Design specs were accurate"
- If scope changed mid-sprint and was handled: include "Scope change handled well — {what changed}"
- Cap at 6 options total (4-5 contextual + Other). "Other" counts toward the cap.

If user selects "Other", follow up:
```
AskUserQuestion({
  questions: [{
    question: "What else went well?",
    header: "Retro — Wins"
  }]
})
```

#### Step 3: Question 2 — Frustrations (contextual, seeded from [4a])

Issues from the Sprint Review appear as pre-populated options — the user does not need to recall them.

```
AskUserQuestion({
  questions: [{
    question: "What slowed us down or should improve?",
    header: "Retro — Improvements",
    multiSelect: true,
    options: [
      // Dynamic options generated from issues[] — examples:
      { label: "{quality-check issue}", description: "Flagged during sprint review" },
      { label: "{verification failure}", description: "Failed: {criterion}" },
      { label: "{hotspot file} needed repeated changes", description: "Changed {N} times — potential design issue" },
      // Include generic fallbacks only if < 3 contextual issues found:
      { label: "Requirements were unclear", description: "Had to re-discover mid-sprint" },
      { label: "Scope was too large", description: "Too much for one sprint" },
      // Always include:
      { label: "Other", description: "I'll elaborate" }
    ]
  }]
})
```

**Option generation rules (Q2):**
- Every quality-check issue from [4a] becomes an option (e.g., "No rate limiting on AI endpoints")
- Every verification failure becomes an option
- Files changed > 3 times become hotspot options
- If fix:feat ratio > 1:1: include "Too many bugs during implementation"
- If < 3 contextual issues, add generic fallbacks: "Requirements were unclear", "Scope was too large"
- Cap at 7 options total (up to 5 contextual + 1 generic + Other). "Other" counts toward the cap.

If user selects "Other", follow up with free-text question.

#### Step 4: Question 3 — What to Change Next Time

Options are derived from Q2 answers — each frustration maps to an actionable improvement.

```
AskUserQuestion({
  questions: [{
    question: "What should we do differently next time?",
    header: "Retro — Next Time",
    multiSelect: true,
    options: [
      // Dynamic options mapped from Q2 answers:
      { label: "More thorough design phase", description: "Catch structural issues earlier" },
      { label: "Add security hardening earlier", description: "Address before sprint, not after" },
      { label: "Write tests first", description: "TDD to prevent regression" },
      { label: "Smaller scope per sprint", description: "Split into multiple phases" },
      { label: "Better context research", description: "Research dependencies before coding" },
      // Always include:
      { label: "Other", description: "I'll elaborate" }
    ]
  }]
})
```

**Option generation rules (Q3 — derived from Q2):**
- If Q2 included a verification failure → "Write tests first — TDD to prevent regression"
- If Q2 included a hotspot file → "More thorough design phase — catch structural issues earlier"
- If Q2 included "Requirements were unclear" → "Better context research — research dependencies before coding"
- If Q2 included security/rate-limiting issue → "Add security hardening earlier — address before sprint, not after"
- If Q2 included scope issue → "Smaller scope per sprint — split into multiple phases"
- If Q2 included "Too many bugs" → "Write tests first" (if not already added)
- If < 3 contextual options, add generic: "More thorough planning", "Smaller commits, more incremental"
- Cap at 6 options total. "Other" counts toward the cap.

If user selects "Other", follow up with free-text question.

#### Step 5: Save to REVIEW.md

Append to `{NN}-REVIEW.md` (already created by [4a]):

```markdown

### Retrospective

**Wins:**
- {selected option label}: {description}
- {user's free-text if "Other" selected}

**Frustrations:**
- {selected option label}: {description}
- {user's free-text if "Other" selected}

**Next Time:**
- {selected option label}: {description}
- {user's free-text if "Other" selected}
```

#### Step 6: Feed the Learning System

After saving to REVIEW.md, call the retro skill in auto mode to extract learnings into `.learnings/`:

```
Skill(skill="retro", args="--auto")
```

The auto-retro workflow reads REVIEW.md (containing both [4a] feedback and [4b] retro answers) and enriches its session-log, conventions, gotchas, and metrics analysis with the user's input.

If the retro skill is not available (not installed in this project), skip this step silently — the user's retro answers are already persisted in REVIEW.md.

#### Step 7: Update Banner

```
  [4b] Retrospective          ✅ {N} retro items reflected on
```

Where N = count of wins + frustrations + next-time items selected by the user.

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
**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "state.iteration" "{NN}-{name}" "Iteration: back to design" '{"from_phase":"review","to_phase":"design","reason":"{feedback summary}"}'`
Update STATE.md:
```yaml
phase_status: iterating_design
iteration_count: {N+1}
iteration_reason: "{feedback summary}"
next_action: "Run /cks:design {NN} to iterate on designs"
```
Write iteration backlog to `.prd/phases/{NN}-{name}/{NN}-BACKLOG.md`.

**→ Iterate: Sprint:**
**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "state.iteration" "{NN}-{name}" "Iteration: back to sprint" '{"from_phase":"review","to_phase":"sprint","reason":"{feedback summary}"}'`
Update STATE.md:
```yaml
phase_status: iterating_sprint
iteration_count: {N+1}
iteration_reason: "{feedback summary}"
next_action: "Run /cks:sprint {NN} to implement fixes"
```
Write iteration backlog to `.prd/phases/{NN}-{name}/{NN}-BACKLOG.md`.

**→ Re-discover:**
**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "state.iteration" "{NN}-{name}" "Iteration: back to discover" '{"from_phase":"review","to_phase":"discover","reason":"{feedback summary}"}'`
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
      Retrospective: {N} retro items
      Backlog: {N} items (all resolved or deferred)
      Decision: RELEASE
      Next: /cks:release {NN}
```

**If iterating:**
```
  [4] Review      ✅ done — iterating
      Sprint Review: feedback collected
      Retrospective: {N} retro items
      Backlog: {N} items to address
      Decision: ITERATE → Phase {X} ({phase_name})
      Iteration: #{iteration_count}
      Next: /cks:{command} {NN}
```

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "phase.review.completed" "{NN}-{name}" "Review phase completed"`

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
