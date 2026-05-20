---
description: "Phase 0: Ideation — brainstorm, refine, and stress-test a project idea"
argument-hint: "[rough idea or problem statement]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:ideate — Phase 0: Ideation

Dispatch the **kickstart-ideator** agent (which has `skills: ideation, kickstart` loaded at startup).

## Dispatch

Before dispatching, use the Read tool to check whether `.kickstart/state.md` exists.

- If it exists → `MODE=kickstart`
- If it does not exist → `MODE=standalone`

Then dispatch:

```
Agent(subagent_type="cks:kickstart-ideator", prompt="Run Phase 0: Ideation. mode={MODE}. Help the user brainstorm and refine their project idea. Read workflows/ideate.md for step-by-step process. Write output to the appropriate location based on mode. Arguments: $ARGUMENTS")
```

(Replace `{MODE}` with the actual resolved value — `kickstart` or `standalone` — before dispatching.)

## Quick Reference

Structured brainstorming using creative frameworks to refine a project idea.

### Brainstorming Tracks

| Track | When | Framework |
|-------|------|-----------|
| A | Vague idea | SCAMPER (Substitute, Combine, Adapt, Modify, Put to use, Eliminate, Reverse) |
| B | Problem, no solution | 5 Whys + How Might We |
| C | Multiple ideas to compare | Quick-score comparison matrix |
| D | No idea at all | Skills/interests discovery + seed generation |
| E | Scattered notes/thoughts | Regroup — cluster, connect, interpret, propose narratives |

### Output

- **Kickstart mode:** `.kickstart/ideation.md` — feeds into Phase 1 (Intake)
- **Standalone mode:** `.ideation/{topic-slug}.md` — reusable brainstorming artifact

## Argument Handling

- No args: Open brainstorm — agent asks what brings you here
- With args: Uses the text as the starting idea pitch
