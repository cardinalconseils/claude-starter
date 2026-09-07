# Workflow: Interrogate — walk every unresolved decision in a plan, one at a time

Relentless plan interrogation: one `AskUserQuestion` at a time, a recommended answer for
every question, and the codebase explored before anything the code can answer is asked.
Rules live in `SKILL.md`; this is the sequence.

## 1. Load the plan

File path given → read it. Otherwise scan in order: `.prd/phases/*-PLAN.md` (newest),
`.prd/phases/*-CONTEXT.md` (newest), `PLAN.md`; none → ask the user to paste or describe
it. Read `CLAUDE.md` — conventions drive recommendations.

## 2. Build the decision tree

Extract: every explicit decision with multiple valid options; every implicit assumption
that could be wrong; every dependency between decisions (B needs A); every edge case the
plan does not handle. Sort foundational first, derived after.

Report the tree as a numbered list, then confirm:

> "I found N decisions to resolve. Does this list look complete?"
> Yes — let's go (Recommended) · Add one I missed · Some are already decided — let me say which

## 3. Walk the tree

Per node, in order:

- **Before asking**: Glob/Grep/Read to check whether the codebase already resolves it.
  If so: "Codebase already decided this: [finding] — skipping."
- **If unresolved**: one `AskUserQuestion` with 2–4 options; the recommended one labelled
  `(Recommended)`, derived from codebase patterns, `CLAUDE.md`, stated constraints, or
  least surprise.

Never advance until the current question is answered. Never invent questions after the
tree is resolved.

## 4. Close

```
GRILLING COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Decisions resolved:  N
Confirmed as-is:     N
Changed by grilling: N

Changes from original plan:
  • [decision] → [new direction]
  • [assumption] → [confirmed / invalidated]

Edge cases surfaced:
  • [edge case] — [suggested handling]

Next: [/cks:sprint to build / update plan with these decisions / share with team]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Write `.grill/{slug}/TRANSCRIPT.md` only when the user explicitly asked for a saved
transcript. Default is conversational only.
