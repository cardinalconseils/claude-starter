# Workflow: Interactive Retrospective

## Overview

User-invoked guided reflection. Shows recent work summary, asks reflection questions,
combines user insight with automated analysis, and produces actionable learnings.
Can also review and apply pending convention proposals to CLAUDE.md.

## Prerequisites
- Git repository with history
- Optionally: `.prd/` directory with phase artifacts

## Process

### Step 1: Show Recent Work Summary

Gather recent activity (same data collection as auto-retro Step 1, but present it to the user):

```
Recent Work Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

{If .prd/ exists:}
  Phase: {NN} — {name}
  Status: {phase_status}
  Verification: {pass/fail summary}

{Always:}
  Recent commits ({count}):
    {hash} {message} ({files} files)
    {hash} {message} ({files} files)
    ...

  Files most changed:
    {file} ({count} times)
    {file} ({count} times)

{If .learnings/ exists:}
  Previous retros: {count}
  Pending convention proposals: {count}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 2: Guided Reflection

Ask the user three questions using AskUserQuestion. Run all automated analysis in parallel.

**Question 1: What went well?**
```
What went well in this work session? (Select all that apply)
Options:
- Clean implementation — code worked as expected first try
- Good planning — the PRD/plan was accurate and complete
- Fast iteration — dev workflow was smooth
- Good tooling — tests, linting, CI/CD helped catch issues
(Other: free text)
```

**Question 2: What was frustrating?**
```
What was frustrating or could be improved?
Options:
- Too many bugs — had to fix things repeatedly
- Unclear requirements — had to re-discover what to build
- Tooling gaps — missing tests, slow builds, bad DX
- Context switching — lost context between sessions
(Other: free text)
```

**Question 3: Future improvements**
```
Anything you want me to do differently next time?
Options:
- More thorough planning before coding
- Write tests first (TDD approach)
- Smaller commits, more incremental
- Better context research before starting
(Other: free text)
```

### Step 3: Combine Analysis

Merge user responses with automated findings from Step 1:

**From user "went well" + automated analysis:**
- If user says "clean implementation" AND fix:feat ratio is low → HIGH confidence convention from the patterns used
- If user says "good planning" → note the planning approach for this phase as a positive pattern

**From user "frustrating" + automated analysis:**
- If user says "too many bugs" AND hotspots exist → GOTCHA entries for hotspot files
- If user says "unclear requirements" → CONVENTION: "Discuss phase should cover {specific gaps found}"
- If user says "context switching" → CONVENTION: "Always save state to .prd/ before ending session"

**From user "improvements" + automated analysis:**
- Map each improvement to a specific, actionable convention
- Cross-reference with existing conventions.md to avoid duplicates

### Step 4: Review Pending Proposals

If `.learnings/conventions.md` has items under "Proposed":

```
Pending Convention Proposals
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

{For each pending proposal:}

  [{N}] {Convention description}
      Source: Phase {NN} retro ({date})
      Confidence: {HIGH|MEDIUM}

      Apply to CLAUDE.md? (yes / no / skip)
```

For each "yes":
1. Read current CLAUDE.md
2. Find the appropriate section (usually "## Always Follow These Rules")
3. Add the convention
4. Move from "Proposed" to "Applied" in conventions.md with date

For each "no":
- Remove from conventions.md (user explicitly rejected)

For "skip":
- Leave in Proposed for next retro

### Step 5: Generate New Learnings

Combine all inputs into structured learnings (same format as auto-retro Step 3):

For each learning, ask if it's worth adding as a convention:
```
New learning: "{description}"

This could become a project convention. Add to proposals?
  - Yes, propose for CLAUDE.md
  - Save as pattern only (no CLAUDE.md change)
  - Skip
```

### Step 6: Save Everything

Same save process as auto-retro Step 4, but with richer data from user input.

The session-log entry includes an additional section:

```markdown
### User Reflection
- **Went well:** {user's response}
- **Frustrating:** {user's response}
- **Improvements:** {user's response}
```

### Step 7: Final Summary

```
Retrospective Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Learnings captured: {count}
    Conventions proposed: {count}
    Conventions applied: {count}
    Patterns recorded: {count}
    Gotchas documented: {count}

  CLAUDE.md updated: {yes — {count} rules added | no changes}

  Velocity trend: {improving / stable / needs attention}
    Avg duration: {time} ({trend} from last 3 phases)
    Retry rate: {%} ({trend})

  All saved to .learnings/

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Next: /cks:next to continue development
```

## Rules

1. **User input is gold** — user observations are higher confidence than automated analysis
2. **Don't overload** — max 3 questions, max 5 proposals to review per session
3. **Specific conventions only** — "Always use Zod for API validation" not "Write good code"
4. **Show before applying** — always show the CLAUDE.md diff before writing
5. **Respect "no"** — if user rejects a proposal, remove it, don't re-propose
