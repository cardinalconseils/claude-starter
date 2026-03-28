# Design: Improved [4b] Retrospective Sub-step

**Date:** 2026-03-27
**Scope:**
- `skills/prd/workflows/review-phase.md` — Sub-step [4b] (primary)
- `skills/retrospective/workflows/auto-retro.md` — Step 1b artifact list (companion change)
**Approach:** Hybrid (contextual inline questions + auto-retro skill)

## Problems Solved

1. **Auto mode skips user interaction** — Retro skill called with `--auto` means user is never asked anything when skill is available
2. **Generic, non-contextual options** — Hardcoded options don't reflect what happened in the sprint
3. **Disconnected from [4a]** — Sprint Review findings aren't fed into the retro questions
4. **Split output targets** — Inline writes to REVIEW.md, skill writes to .learnings/ — never both
5. **Missing third question** — Inline only asks 2 questions; the interactive skill asks 3

## Design

### Flow

```
[4a] completes → REVIEW.md exists with sprint feedback
                    ↓
[4b] starts → Parse REVIEW.md + SUMMARY.md + VERIFICATION.md + git history
                    ↓
            Generate contextual options for 3 questions
                    ↓
            Q1: What went well? (contextual multi-select)
            Q2: What was frustrating? (contextual multi-select, seeded from [4a] issues)
            Q3: What should change next time? (contextual multi-select)
                    ↓
            Append ### Retrospective section to {NN}-REVIEW.md
                    ↓
            Call Skill(skill="retro", args="--auto") → .learnings/ enrichment
                    ↓
            Update banner: [4b] Retrospective ✅ {N} learnings captured
```

### Step-by-step

#### Step 1: Gather Context for Question Generation

Parse these sources to build contextual options:

| Source | What to extract |
|--------|----------------|
| `{NN}-REVIEW.md` (from [4a]) | Sprint review feedback, quality-check issues, feature-check results |
| `{NN}-SUMMARY.md` | Files changed, features implemented, scope changes |
| `{NN}-VERIFICATION.md` | Pass/fail counts, specific failures |
| `{NN}-DESIGN.md` | Compare DESIGN.md component list against SUMMARY.md implemented features — if >= 80% of designed components appear in summary, design was "closely followed" |
| Git history | Commit patterns (feat/fix ratio), hotspot files, velocity |

**Prerequisite check:** `{NN}-REVIEW.md` must exist from [4a]. If it does not (e.g., [4a] was skipped or failed), log a warning and proceed with SUMMARY.md + VERIFICATION.md + git data only — the questions will have fewer contextual options but will still work.

Build two lists:
- `wins[]` — things that went well (high pass rate, clean areas, scope handled well)
- `issues[]` — things that were flagged (quality-check findings, verification failures, hotspots)

#### Step 2: Question 1 — Wins (contextual)

Generate options dynamically. Each option should reference specific sprint data.

Template:
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
      // Include 1-2 sprint-specific wins detected from data:
      { label: "{contextual win}", description: "{evidence}" },
      // Always include:
      { label: "Other", description: "I'll elaborate" }
    ]
  }]
})
```

Rules for generating win options:
- If verification pass rate >= 80%: include "Strong verification results"
- If feat:fix commit ratio > 2:1: include "Clean implementation — few bug fixes needed"
- If design was followed closely: include "Design specs were accurate"
- If scope changed mid-sprint and was handled: include "Scope change handled well — {what changed}"
- Always cap at 6 options (4-5 contextual + Other)

#### Step 3: Question 2 — Frustrations (contextual, seeded from [4a])

This is the key improvement — issues from the Sprint Review should appear as pre-populated options.

Template:
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
      // Include generic fallbacks only if < 3 contextual issues:
      { label: "Requirements were unclear", description: "Had to re-discover mid-sprint" },
      { label: "Scope was too large", description: "Too much for one sprint" },
      // Always include:
      { label: "Other", description: "I'll elaborate" }
    ]
  }]
})
```

Rules for generating improvement options:
- Every quality-check issue from [4a] becomes an option (e.g., "No rate limiting on AI endpoints")
- Every verification failure becomes an option
- Files changed > 3 times become hotspot options
- If fix:feat ratio > 1:1: include "Too many bugs during implementation"
- Always cap at 7 options (up to 5 contextual + 1 generic + Other)

#### Step 4: Question 3 — What to Change Next Time (new)

This question was missing from the inline retro. Options are derived from Q2 answers + general improvements.

Template:
```
AskUserQuestion({
  questions: [{
    question: "What should we do differently next time?",
    header: "Retro — Next Time",
    multiSelect: true,
    options: [
      // Dynamic based on issues found:
      { label: "More thorough design phase", description: "Catch {issue type} earlier" },
      { label: "Add rate limiting / security hardening", description: "Address before sprint, not after" },
      { label: "Write tests first", description: "TDD to prevent regression" },
      { label: "Smaller scope per sprint", description: "Split into multiple phases" },
      { label: "Better context research", description: "Research dependencies before coding" },
      // Always include:
      { label: "Other", description: "I'll elaborate" }
    ]
  }]
})
```

Rules for generating next-time options (derived from Q2 issues):
- If Q2 included a verification failure → include "Write tests first — TDD to prevent regression"
- If Q2 included a hotspot file → include "More thorough design phase — catch structural issues earlier"
- If Q2 included "Requirements were unclear" → include "Better context research — research dependencies before coding"
- If Q2 included security/rate-limiting issues → include "Add security hardening earlier — address before sprint, not after"
- If Q2 included scope-related issues → include "Smaller scope per sprint — split into multiple phases"
- If Q2 included "Too many bugs" → include "Write tests first" (if not already added)
- If fewer than 3 contextual options generated, add generic options: "More thorough planning", "Smaller commits, more incremental"
- Always cap at 6 options (contextual + Other). "Other" always counts toward the cap.

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

After saving to REVIEW.md, call the retro skill in auto mode:

```
Skill(skill="retro", args="--auto")
```

**Companion change required:** The auto-retro workflow (`skills/retrospective/workflows/auto-retro.md`, Step 1b) must be updated to also read `{NN}-REVIEW.md` as part of its artifact gathering. Currently it reads CONTEXT, PLAN, SUMMARY, and VERIFICATION — REVIEW.md must be added so that user feedback from [4a] and retro answers from [4b] inform the learning extraction.

If the retro skill is not available (not installed in this project), skip this step silently — the user's retro answers are already saved in REVIEW.md.

#### Step 7: Update Banner

```
  [4b] Retrospective          ✅ {N} retro items reflected on
```

Where N = count of wins + frustrations + next-time items selected by the user. This is distinct from "learnings" (CONVENTION/PATTERN/GOTCHA extracted by auto-retro) to avoid conflating user selections with machine-extracted learnings.

## What Does NOT Change

- The standalone `/cks:retro` command and its interactive workflow — unchanged
- The `.learnings/` output structure — unchanged
- Sub-steps [4a], [4c], [4d] — unchanged

## Companion Change: auto-retro.md

The auto-retro workflow (`skills/retrospective/workflows/auto-retro.md`) requires a small update:

**Step 1b artifact list** — add `{NN}-REVIEW.md`:
```
Read .prd/phases/{NN}-{name}/{NN}-CONTEXT.md     → what was planned
Read .prd/phases/{NN}-{name}/{NN}-PLAN.md         → how it was planned
Read .prd/phases/{NN}-{name}/{NN}-SUMMARY.md      → what was built
Read .prd/phases/{NN}-{name}/{NN}-VERIFICATION.md → what passed/failed
Read .prd/phases/{NN}-{name}/{NN}-REVIEW.md       → sprint review feedback + retrospective answers (NEW)
```

Extract from REVIEW.md:
- Sprint review assessment (feature-check, quality-check, metrics-check results)
- User's retro answers (wins, frustrations, next-time items)
- Use these to enrich the "What Worked" and "Issues Encountered" sections of the session-log entry

If REVIEW.md does not exist, skip — this maintains backward compatibility with phases that were shipped without going through [4b].

## Option Generation Rules Summary

**"Other" always counts toward the cap for each question.**

| Question | Condition | Generates | Cap |
|----------|-----------|-----------|-----|
| Q1 Wins | Verification pass rate >= 80% | "Strong verification results" | 6 |
| Q1 Wins | feat:fix ratio > 2:1 | "Clean implementation" | |
| Q1 Wins | >= 80% of DESIGN.md components in SUMMARY.md | "Design specs were accurate" | |
| Q1 Wins | Mid-sprint scope change detected + handled | "Scope change handled well — {what changed}" | |
| Q1 Wins | Always | "Other — I'll elaborate" | |
| Q2 Frustrations | Quality-check issue from [4a] | "{specific issue}" (one per issue) | 7 |
| Q2 Frustrations | Verification failure | "Failed: {criterion}" | |
| Q2 Frustrations | File changed > 3 times in git | "{file} needed repeated changes" | |
| Q2 Frustrations | fix:feat ratio > 1:1 | "Too many bugs during implementation" | |
| Q2 Frustrations | < 3 contextual issues generated | Add generic: "Requirements unclear", "Scope too large" | |
| Q2 Frustrations | Always | "Other — I'll elaborate" | |
| Q3 Next Time | Q2 included verification failure | "Write tests first — TDD to prevent regression" | 6 |
| Q3 Next Time | Q2 included hotspot file | "More thorough design phase" | |
| Q3 Next Time | Q2 included "Requirements unclear" | "Better context research" | |
| Q3 Next Time | Q2 included security/rate-limiting issue | "Add security hardening earlier" | |
| Q3 Next Time | Q2 included scope issue | "Smaller scope per sprint" | |
| Q3 Next Time | Q2 included "Too many bugs" | "Write tests first" (if not already added) | |
| Q3 Next Time | < 3 contextual options | Add generic: "More thorough planning", "Smaller commits" | |
| Q3 Next Time | Always | "Other — I'll elaborate" | |

### "Other" Free-Text Handling

When the user selects "Other", issue a follow-up `AskUserQuestion` with a single open-ended text question:
```
AskUserQuestion({
  questions: [{
    question: "What else would you add?",
    header: "Retro — {current question header}"
  }]
})
```
Append the free-text response to the corresponding section in REVIEW.md.
