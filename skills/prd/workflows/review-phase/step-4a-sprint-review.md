# Sub-step [4a]: Sprint Review

<context>
Phase: Review (Phase 4)
Requires: Phase context loaded (Step 1)
Produces: {NN}-REVIEW.md with feedback
</context>

## Instructions

### 1. Build the Sprint Summary

Before asking the user anything, build and display a structured summary so they know exactly what they're reviewing.

**Read these files:**
- `.prd/phases/{NN}-{name}/{NN}-SUMMARY.md` — what was built
- `.prd/phases/{NN}-{name}/{NN}-VERIFICATION.md` — QA results
- `.prd/phases/{NN}-{name}/{NN}-CONTEXT.md` — original requirements (acceptance criteria)
- `.prd/phases/{NN}-{name}/{NN}-DESIGN.md` — what was designed
- `docs/prds/PRD-{NNN}-{name}.md` — PRD document

**Display this summary block (mandatory — do not skip):**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 SPRINT REVIEW — Phase {NN}: {name}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 🎯 WHAT WAS REQUESTED
 {1-2 sentence goal from CONTEXT.md — what the user asked for}

 🔨 WHAT WAS BUILT
 {bullet list of key features/changes from SUMMARY.md}
 - {feature 1}
 - {feature 2}
 - {feature 3}

 📁 FILES CHANGED
 {N} files changed: {list key files, grouped by type}
 - Routes/API: {files}
 - Components/UI: {files}
 - Database/Models: {files}
 - Tests: {files}
 - Config: {files}

 📐 DESIGN vs IMPLEMENTATION
 {compare DESIGN.md components against SUMMARY.md — what matched, what diverged}
 - Matched: {N}/{total} designed components implemented
 - Diverged: {list any deviations and why}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**If frontend feature:** Take screenshots using Chrome DevTools MCP and include them in the summary.
If screenshots aren't possible, start the dev server and provide the local URL so the user can preview.
**This is mandatory** — the user cannot review what they cannot see. If no visual evidence can be produced, explicitly state what the user should do to see the feature:
```
⚠️  To preview: run `{dev command}` and open http://localhost:{port}/{path}
```

### 2. Evidence Bundle QA Display

**Parse VERIFICATION.md front-matter** (YAML block at the top of the file). If front-matter is absent (old VERIFICATION.md without front-matter), fall back to the prose display: show AC pass/fail table and test counts from the prose body.

When front-matter is present, produce exactly these two blocks and nothing else in the QA section:

**Block A — Decision (always show, built from front-matter data):**

```
─────────────────────────────────────────────────
❓ DECISION REQUIRED
─────────────────────────────────────────────────
Sprint complete. {X} of {Y} criteria verified. {N} failed. {M} items not tested.

  1. Release as-is — ship with known gaps (tasks below still apply)
  2. Fix and re-verify — run /cks:sprint to fix {N} failure(s) first
  3. Scope down — remove the failing feature from this release

Recommended: {number} — {one sentence grounded in failure count and uncovered risk}

Reply with the number or describe what you want.
─────────────────────────────────────────────────
```

Recommendation logic:
- If any FAIL with high risk (auth, data loss, security): recommend 2
- If only low-risk FAILs and uncovered items: recommend 1 or 3 based on count
- Never recommend 1 if `confidence.overall` < 0.5

**Block B — Task list (always show, even if user chooses release):**

```
YOUR TASKS BEFORE RELEASE:

  Must fix (blocks release):
  {for each criterion where verdict=FAIL}
  [ ] {AC description from CONTEXT.md} — {why from evidence bundle}
      → {one actionable instruction: "Run /cks:sprint to fix automatically" OR specific manual step}

  Should cover (not blocking now, but needed before production):
  {for each item in uncovered list}
  [ ] {uncovered item description}
      → {one instruction: configure what's missing, run a manual check, etc.}

  {if both lists are empty: "All criteria verified. No gaps. Ready to release."}
```

Rules:
- Only these two blocks in the QA section. No verbose prose table, no raw VERIFICATION.md dump.
- Task list always shown regardless of what the user decides.
- Each task must have one actionable instruction on the → line.
- "Must fix" = `verdict: FAIL` entries. "Should cover" = `uncovered` entries.
- If both lists are empty: show "All criteria verified. No gaps. Ready to release." and skip the DECISION REQUIRED block.

### 3. Agent Team Review (complex sprints only)

**Decision: Single review vs. Agent Team**

Check sprint complexity from SUMMARY.md:
- **≤ 10 files changed, single layer** → skip team review, go to step 4
- **> 10 files or multiple layers (frontend + backend + infra)** → use Agent Team for deeper assessment

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
- Append findings to the summary block above
- Present unified review to user via AskUserQuestion
```

### 4. Collect User Feedback

Now that the user has seen the full summary, ask for their gut reaction:

```
AskUserQuestion({
  questions: [{
    question: "Based on what you see above, how does this feature feel?",
    header: "Sprint Review — Your Take",
    multiSelect: false,
    options: [
      { label: "Looks great", description: "Everything works as expected. I'm happy with it." },
      { label: "Works, but the look/feel is off", description: "The logic is right but the interface, styling, or interactions need tweaking." },
      { label: "Something isn't working right", description: "There are bugs or missing pieces in the core functionality." },
      { label: "It feels slow or heavy", description: "The feature works but performance needs improvement." },
      { label: "This needs a bigger rethink", description: "The approach or requirements need to change — not just fixes." },
      { label: "Mixed feelings — let me explain", description: "Some parts are good, some aren't. I'll describe what I see." }
    ]
  }]
})
```

If user selects "Mixed feelings", follow up with a freetext question:
```
AskUserQuestion({
  questions: [{
    question: "What specifically feels off? Describe what you'd change.",
    header: "Tell me more"
  }]
})
```

### 5. Write Review

Write the full summary + user feedback to `.prd/phases/{NN}-{name}/{NN}-REVIEW.md`.

The REVIEW.md should contain:
1. The complete sprint summary block (from step 1)
2. Evidence bundle decision + task list (from step 2)
3. Agent team findings (if applicable, from step 3)
4. User's assessment selections (from step 4)

```
  [4a] Sprint Review          ✅ Feedback collected
```
