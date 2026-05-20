# Sub-step [4d]: Iteration Decision

<context>
Phase: Review (Phase 4)
Requires: Backlog refinement ([4c])
Produces: STATE.md updated with routing decision
</context>

**THIS IS THE CRITICAL ROUTING STEP.**

## Iteration Guard

Before routing, check `iteration_count` in STATE.md.
If `iteration_count >= 3`, show this INSTEAD of the normal decision:

```
AskUserQuestion({
  questions: [{
    question: "This feature has been revised {N} times. What should we do?",
    header: "Phase {NN}: {name} — Multiple Revisions",
    multiSelect: false,
    options: [
      { label: "Ship it now", description: "We've invested enough. Release it and address remaining issues in a future update." },
      { label: "One final round of fixes", description: "Last chance — one more round, then we ship no matter what." },
      { label: "Pause and move on", description: "Park this feature. Move to the next one. We can come back later." }
    ]
  }]
})
```

If "Pause and move on" → set `phase_status: shelved` in STATE.md, move to next roadmap feature.
If "One final round of fixes" → proceed but log override in STATE.md: `iteration_limit_override: true`.

## Recommendation Engine

Before asking the user, load full context:
1. Read `.prd/PRD-PROJECT.md` — product maturity stage, business goals
2. Read `.prd/PRD-ROADMAP.md` — which roadmap features depend on this one completing
3. Read `.prd/PROJECT-MANIFEST.md` if it exists — sub-project build order dependencies
4. Read this phase's `CONTEXT.md` Section 5 (constraints/deps) and Section 9 (success metrics)
5. Read `VERIFICATION.md` — AC pass/fail results
6. Read `BACKLOG.md` — blocking vs. enhancement items from [4c]
7. Read `iteration_count` from STATE.md

Compute the recommendation (check in priority order):
1. Any downstream feature in ROADMAP.md is blocked by this AND a blocking AC fails → **recommend "Fix code issues"** — unblocking the roadmap takes priority
2. ALL ACs pass AND no blocking BACKLOG items → **recommend "Release to users"**
3. Any blocking AC fails (feature-internal) → **recommend "Fix code issues"**
4. [4a] feedback mentions look/feel/flow/UX AND no downstream features currently blocked → **recommend "Rethink the design"**
5. `iteration_count >= 2` AND no critical failures AND maturity = Prototype → **recommend "Release to users"** (sunk-cost + maturity gate)
6. Scope mismatch between what was built and the roadmap business goal → **recommend "Go back to requirements"**

Display this block BEFORE the AskUserQuestion call:

```
· · · · · · · · · · · · · · · · · · · · · · · ·
🎯 AI RECOMMENDATION
· · · · · · · · · · · · · · · · · · · · · · · ·
Best next move: {recommended option name}
Why: {one sentence grounded in specific evidence}
     Examples:
       "All 5 ACs passed, no blocking issues, and Feature 03 depends on this shipping"
       "AC-2 fails and Feature 04 is blocked until this resolves"
       "Two iterations in at Prototype maturity — good enough to ship and learn from"
· · · · · · · · · · · · · · · · · · · · · · · ·
```

In the AskUserQuestion call that follows, append `(Recommended)` to the label of the recommended option.

## Iteration Decision

Based on all feedback, retro, and backlog decisions, ask the user what happens next.
**Use plain language with clear consequences for each choice:**

```
AskUserQuestion({
  questions: [{
    question: "What happens next with this feature?",
    header: "Phase {NN}: {name} — Next Step",
    multiSelect: false,
    options: [
      { label: "Release to users", description: "Feature is ready. We'll deploy it through staging → production." },
      { label: "Fix code issues", description: "Go back to coding to fix bugs or add missing pieces. Then we'll review again. (Days of work)" },
      { label: "Rethink the design", description: "The look, flow, or approach needs to change. We'll redesign, then re-build. (More significant rework)" },
      { label: "Go back to requirements", description: "What we're building needs to fundamentally change. We'll re-gather requirements from scratch. (Major reset)" }
    ]
  }]
})
```

## Route Based on Decision

**→ Release:**
First, merge the open sprint PR so main has the code before release:
```bash
# Find and merge the open PR for this phase
gh pr list --state open --json number,title | grep -i "{phase name}"
gh pr merge {PR_NUMBER} --squash --auto
```
If no open PR exists (already merged or direct commit), skip this step.

Then update STATE.md:
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
