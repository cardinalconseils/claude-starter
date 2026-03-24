# CONTEXT.md Template (Discovery Output)

Use this template when the prd-discoverer agent writes discovery output to `.prd/phases/{NN}-{name}/CONTEXT.md`.

---

```markdown
# Discovery: {Feature/Phase Title}

**Phase:** {NN}
**Date:** {YYYY-MM-DD}
**Status:** {Complete | In Progress}

## Problem

{What problem does this solve? Who has it? What's the cost of not solving it?}

## Solution Direction

{High-level approach based on discussion. Not a detailed design — that's for planning.}

## Users

{Who uses this? Their goals and context.}

| User | Goal | Context |
|------|------|---------|
| {type} | {goal} | {context} |

## Scope

**In scope:**
- {what we're building}
- {what we're building}

**Out of scope:**
- {what we're NOT building} — {why}

## Technical Impact

**Files to modify:**
- `{path}` — {what changes and why}

**New files:**
- `{path}` — {purpose}

**Data model changes:**
{Description of any schema changes, or "None"}

**Dependencies:**
{New libraries, APIs, or other features this depends on}

## Acceptance Criteria

{User-confirmed testable conditions for "done".}

- [ ] {criterion}
- [ ] {criterion}
- [ ] {criterion}

## Codebase Research Notes

{What was found in the existing code that's relevant to this feature.}

- {finding}
- {finding}

## Open Questions

{Unresolved items that need answers during planning or execution.}

- [ ] {question}

## Assumptions

{Things assumed to be true during discovery. Flag for review.}

- {assumption}

## Discovery Method

{How was this discovered — interactive session, autonomous analysis, or brief-based.}
```
