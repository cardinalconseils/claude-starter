# Step 5: Sprint Review & Verdict

<context>
Phase: Sprint (Phase 3)
Requires: State updated (Step 4)
Produces: Sprint summary, user verdict, REVIEW.md, routing to step-6 or stop
</context>

## Sprint Completion Banner

Display the summary of what was accomplished:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PRD ► Phase {NN}: {name} ► SPRINT COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 [3a] Sprint Planning        ✅ {N} tasks
 [3b] Design & Architecture  ✅ TDD: {level}
 [3c] Implementation         ✅ {N} files changed
 [3c+] De-Sloppify           ✅ cleaned
 [3d] Code Review            ✅ {status}
 [3e] QA Validation          ✅ {X}/{Y} criteria
 [3f] UAT                    ✅ {N}/{M} scenarios
 [3g] Merge to Main          ✅ PR #{number}
 [3h] Documentation Check    ✅ {status}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

For iteration sprints, use this banner instead:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PRD ► Phase {NN}: {name} ► ITERATION #{iteration} COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 Iteration reason: {iteration_reason}
 Backlog: {N}/{M} items resolved

 [3a]-[3h] All sub-steps    ✅ PR #{number}

 Iteration History:
   Sprint (initial)     ✅ → Iterate
   {for each past iteration:}
   Iteration #{N}       ✅ → {Iterate | current}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "phase.sprint.completed" "{NN}-{name}" "Sprint phase completed"`

## Inline Review — The Verdict

Instead of deferring to a separate /cks:review session, collect the verdict now while context is fresh.

### Build Quick Summary

Read these files and build a 5-line summary:
- `.prd/phases/{NN}-{name}/{NN}-SUMMARY.md` — what was built
- `.prd/phases/{NN}-{name}/{NN}-VERIFICATION.md` — test results
- `.prd/phases/{NN}-{name}/{NN}-CONTEXT.md` — original acceptance criteria

Display:
```
 🎯 Goal: {1 sentence from CONTEXT.md}
 🔨 Built: {key features, 1-2 lines from SUMMARY.md}
 ✅ Tests: {pass/total} acceptance criteria verified
 📁 Files: {N} files changed
 🔗 PR: #{number} — {url}
```

### Ask for Verdict

```
AskUserQuestion({
  questions: [{
    question: "Sprint is done. What's the call?",
    header: "Phase {NN}: {name} — Verdict",
    multiSelect: false,
    options: [
      { label: "Ship it", description: "Merge PR, bump version, tag release — feature done" },
      { label: "Iterate: code changes needed", description: "Back to sprint with updated backlog" },
      { label: "Iterate: design changes needed", description: "Back to design phase" },
      { label: "Full review", description: "Run /cks:review for deeper retrospective + agent review" }
    ]
  }]
})
```

### Iteration Guard

If `iteration_count >= 3`, replace the question with:

```
AskUserQuestion({
  questions: [{
    question: "This feature has iterated {N} times. How to proceed?",
    header: "Iteration Limit Reached (max: 3)",
    multiSelect: false,
    options: [
      { label: "Ship as-is", description: "Release current state — address remaining issues as a new feature" },
      { label: "Force one more iteration", description: "Override limit — I understand the risk" },
      { label: "Shelve feature", description: "Move to backlog and start a different feature" }
    ]
  }]
})
```

If "Shelve feature" → set `phase_status: shelved` in STATE.md, stop.
If "Force one more iteration" → log override: `iteration_limit_override: true`.

## Route Based on Verdict

### → Ship it
Write REVIEW.md with summary + verdict, then **continue to Step 6** (step-6-ship.md).

Update STATE.md:
```yaml
phase_status: reviewed
last_action: "Sprint review — verdict: ship"
last_action_date: {today}
```

### → Iterate: code changes
Write REVIEW.md with summary + verdict.

Update STATE.md:
```yaml
phase_status: iterating_sprint
iteration_count: {N+1}
iteration_reason: "{user feedback}"
next_action: "Run /cks:sprint {NN} to implement fixes"
```

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "state.iteration" "{NN}-{name}" "Iteration: back to sprint"`

Show:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Iteration #{N+1} queued. Run:
   /compact
   /cks:sprint {NN}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Stop here.** Do NOT continue to step 6.

### → Iterate: design changes
Write REVIEW.md with summary + verdict.

Update STATE.md:
```yaml
phase_status: iterating_design
iteration_count: {N+1}
iteration_reason: "{user feedback}"
next_action: "Run /cks:design {NN} to iterate on designs"
```

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "state.iteration" "{NN}-{name}" "Iteration: back to design"`

Show:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Design iteration #{N+1} queued. Run:
   /compact
   /cks:design {NN}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Stop here.** Do NOT continue to step 6.

### → Full review
Write REVIEW.md with summary only (no verdict — review will collect it).

Update STATE.md:
```yaml
phase_status: sprinted
next_action: "Run /cks:review {NN} for full retrospective"
```

Show:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Full review requested. Run:
   /compact
   /cks:review {NN}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Stop here.** Do NOT continue to step 6.

## Write REVIEW.md

For all verdicts, write `.prd/phases/{NN}-{name}/{NN}-REVIEW.md`:

```markdown
# Sprint Review — Phase {NN}: {name}

**Date:** {today}
**Verdict:** {Ship it | Iterate: sprint | Iterate: design | Full review}
**Source:** Inline sprint review (step-5)

## Summary
{quick summary from above}

## Acceptance Criteria
{AC checklist with pass/fail from VERIFICATION.md}

## User Verdict
{selected option + any feedback}
```
