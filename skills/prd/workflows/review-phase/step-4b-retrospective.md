# Sub-step [4b]: Retrospective

<context>
Phase: Review (Phase 4)
Requires: Sprint review feedback ([4a])
Produces: Retro answers appended to REVIEW.md, .learnings/ updated
</context>

**Always interactive.** The retro asks 3 contextual questions seeded from sprint data, then optionally feeds the learning system.

## Step 1: Gather Context for Question Generation

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

## Step 2: Question 1 — Wins (contextual)

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

## Step 3: Question 2 — Frustrations (contextual, seeded from [4a])

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

## Step 4: Question 3 — What to Change Next Time

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

## Step 5: Save to REVIEW.md

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

## Step 6: Feed the Learning System

After saving to REVIEW.md, call the retro skill in auto mode to extract learnings into `.learnings/`:

```
Skill(skill="retro", args="--auto")
```

The auto-retro workflow reads REVIEW.md (containing both [4a] feedback and [4b] retro answers) and enriches its session-log, conventions, gotchas, and metrics analysis with the user's input.

If the retro skill is not available (not installed in this project), skip this step silently — the user's retro answers are already persisted in REVIEW.md.

## Step 7: Update Banner

```
  [4b] Retrospective          ✅ {N} retro items reflected on
```

Where N = count of wins + frustrations + next-time items selected by the user.
