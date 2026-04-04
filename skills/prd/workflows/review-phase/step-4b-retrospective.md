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

## Step 2: Question 1 — What Went Well (simple, contextual)

Generate 3-5 options from `wins[]` using plain language. Keep it conversational.

```
AskUserQuestion({
  questions: [{
    question: "What felt good about this sprint?",
    header: "Quick Retro — The Good Stuff",
    multiSelect: true,
    options: [
      // Dynamic options from wins[] — use plain language, max 5:
      { label: "The feature turned out well", description: "{X}/{Y} acceptance criteria passed" },
      { label: "We followed the plan closely", description: "What we built matched what we designed" },
      { label: "Got it done quickly", description: "Clean implementation, few detours" },
      { label: "Caught issues before shipping", description: "Review process found real problems early" },
      // Always include:
      { label: "Something else", description: "I'll share what I liked" }
    ]
  }]
})
```

**Option rules:** Cap at 5 options. Use data from wins[] but translate to plain English.
If user selects "Something else", ask freetext follow-up.

## Step 3: Question 2 — What Was Hard (simple, contextual)

```
AskUserQuestion({
  questions: [{
    question: "What made this sprint difficult or frustrating?",
    header: "Quick Retro — The Hard Parts",
    multiSelect: true,
    options: [
      // Dynamic from issues[] — use plain language, max 5:
      { label: "Things took longer than expected", description: "Underestimated the complexity" },
      { label: "Had to fix the same thing multiple times", description: "{hotspot file} changed {N} times" },
      { label: "Requirements changed mid-sprint", description: "Scope shifted while coding" },
      { label: "Bugs kept popping up", description: "Fix one thing, break another" },
      { label: "Nothing major — it went smoothly", description: "No significant blockers" },
      // Always include:
      { label: "Something else", description: "I'll explain what was hard" }
    ]
  }]
})
```

**Option rules:** Cap at 6 options. Seed from issues[] but use everyday language.
If user selects "Something else", ask freetext follow-up.

## Step 4: Question 3 — What to Improve (simple, derived from Q2)

Based on what the user said was hard, suggest ONE concrete improvement (not a menu of 6).

```
AskUserQuestion({
  questions: [{
    question: "For the next feature, what's the one thing we should do differently?",
    header: "Quick Retro — One Change",
    multiSelect: false,
    options: [
      // Derive from Q2 answers — pick the top 3-4 most relevant:
      { label: "Spend more time on design upfront", description: "Get the plan solid before we start coding" },
      { label: "Break it into smaller pieces", description: "Ship more often, keep each chunk small" },
      { label: "Test as we go", description: "Check things work while building, not just at the end" },
      { label: "Get clearer requirements first", description: "Make sure we know exactly what we're building" },
      { label: "Nothing — keep doing what we're doing", description: "The process worked well enough" }
    ]
  }]
})
```

**Option rules:** Max 5 options. Single-select (ONE improvement, not a laundry list).
Map from Q2: "took longer" → "break into smaller pieces"; "bugs" → "test as we go"; "requirements changed" → "get clearer requirements"; "same thing multiple times" → "spend more time on design".

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
