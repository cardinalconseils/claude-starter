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

## Show the User What Was Built (MANDATORY)

Before asking any questions, the user MUST see the actual result — not just file counts.

### For Frontend/UI Features:

1. **Start dev server** (if not already running):
   ```bash
   # Auto-detect and start: npm run dev / yarn dev / python manage.py runserver / etc.
   ```

2. **Take screenshots** of the key screens/components that were built or changed.
   Use Chrome DevTools MCP if available, or take terminal screenshots of CLI output.
   For each acceptance criterion from CONTEXT.md, capture visual evidence:
   ```
   Screenshot 1: {AC-1 description} — {screenshot or description of what user sees}
   Screenshot 2: {AC-2 description} — {screenshot or description of what user sees}
   ```

3. **Show before/after** if this was a change to existing UI:
   ```
   BEFORE: {what it looked like before this sprint}
   AFTER:  {what it looks like now}
   ```

4. **Provide the local URL** so the user can test it themselves:
   ```
   🌐 Preview: http://localhost:{port}/{relevant-path}
   ```

### For Backend/API Features:

1. **Show example API calls and responses:**
   ```
   curl -X POST http://localhost:{port}/api/{endpoint} -d '{"example": "data"}'
   → 200 OK: {"result": "..."}
   ```

2. **Show database changes** (new tables, schema changes):
   ```
   New tables: {table_name} ({N} columns)
   Modified: {table_name} (added {column})
   ```

### For CLI/Library Features:

1. **Show example usage and output:**
   ```bash
   $ {command} --example-flag
   {actual output}
   ```

### If Nothing Can Be Shown:

If the dev server can't start or screenshots can't be taken, explicitly tell the user:
```
⚠️  Could not preview the feature automatically.
    To see it yourself: {instructions to run/test manually}
```

**NEVER skip this step.** The user cannot review what they cannot see.

---

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
    question: "How does this feature feel to you?",
    header: "Phase {NN}: {name} — What's Next?",
    multiSelect: false,
    options: [
      { label: "Looks good — ship it!", description: "Feature is ready. We'll merge the code, tag a release, and mark it done." },
      { label: "Almost there — needs code fixes", description: "The idea is right but there are bugs or missing pieces. We'll go back and fix them, then review again." },
      { label: "Needs a rethink — back to design", description: "The approach or layout needs to change before more coding. We'll redesign, then re-build." },
      { label: "I'm not sure — get a detailed review", description: "Run the full review process with AI reviewers to help you decide." }
    ]
  }]
})
```

### Iteration Guard

If `iteration_count >= 3`, show this INSTEAD of the verdict:

```
AskUserQuestion({
  questions: [{
    question: "This feature has been revised {N} times. What should we do?",
    header: "Phase {NN}: {name} — Multiple Revisions",
    multiSelect: false,
    options: [
      { label: "Ship it now", description: "We've invested enough. Release it and address remaining issues in a future update." },
      { label: "One final round of fixes", description: "Last chance — one more round of coding, then we ship no matter what." },
      { label: "Pause and move on", description: "Park this feature for now. Move to the next one. We can come back to it later." }
    ]
  }]
})
```

If "Pause and move on" → set `phase_status: shelved` in STATE.md, stop.
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
