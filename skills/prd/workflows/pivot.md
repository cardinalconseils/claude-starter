# Workflow: Pivot — formalize a direction change from research evidence

Turn a research insight or discovered market reality into updated discovery artifacts.
Extract the signal, confirm with the user, patch CONTEXT.md, and hand the learning to the
historian so the pivot is never lost.

## 1. Load current state

Read `.prd/PRD-STATE.md`; find the active CONTEXT.md (`.prd/phases/{NN}-*/*CONTEXT.md`)
and read it. None → note it and proceed with the pivot input alone.

## 2. Extract the pivot signal

From the transcript, file, or flags in the brief:
- **Broken assumption** — what the project believed that turned out wrong
- **Triggering evidence** — competitor launch, user test, research finding
- **New direction** — ICP, positioning, feature set
- **What stays** — the core insight or technology still valid

Input minimal or empty → `AskUserQuestion` with these four as prompts.

## 3. Confirm before writing — mandatory

Show the summary via `AskUserQuestion`:

```
Broken assumption: [X]
Evidence: [Y]
New direction: [Z]
CONTEXT.md fields that will change: [list]
Proceed with this pivot?
```

Options: Yes, update now · Adjust the summary first · Cancel.

## 4. Patch CONTEXT.md — minimal edits

Only the fields that actually changed:
- Element 1 — problem statement / value proposition
- Element 2 — ICP and primary persona
- Element 5 — criteria that referenced the old direction
- Element 10 — leading indicators for the new ICP

Append at the bottom:
```
## Pivot Record
**Pivoted:** {date}
**From:** {old direction}
**To:** {new direction}
**Evidence:** {one-sentence trigger}
```

## 5. Return the learning (historian writes it)

```markdown
# Pivot: {slug}

**Date:** {date}
**Project:** {name from CONTEXT.md}

## Broken Assumption
## Evidence That Broke It
## New Direction
## What Stays Valid
## Artifacts Updated
- CONTEXT.md: {fields changed}
```

Destination `.learnings/pivots/{YYYY-MM-DD}-{slug}.md` is the historian's write scope —
return the block and name the dispatch. Also return the PRD-STATE Working Notes row
`| {date} | {branch} | — | pivot: {slug} — {new direction in 8 words} |` for the
project-manager.

## Constraints

- Never write before Step 3 confirms.
- No branch creation — artifact updates only.
- One pivot per run; note extra pivots in the learning block.
