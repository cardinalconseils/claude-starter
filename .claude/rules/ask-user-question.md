---
globs: "agents/*.md"
---

# AskUserQuestion Rules

## Mandatory Behavior

When an agent needs input from the user — to choose between options, confirm a decision, or resolve ambiguity — it MUST call the `AskUserQuestion` tool. Plain text questions in chat are FORBIDDEN for interactive decision points.

## What Counts as an Interactive Decision Point

- Choosing between implementation approaches
- Confirming a plan before execution
- Selecting from design or architectural options
- Any moment where the user's answer changes what the agent does next

## Required Behavior

1. Declare `AskUserQuestion` in the agent's `tools:` frontmatter — if it's not declared, it silently fails
2. Call `AskUserQuestion` with 2–4 options that cover the realistic choices
3. Always include an "Other" escape hatch (the tool provides this automatically)
4. Never substitute a plain text question for a decision that has real consequences

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "A plain text question is faster" | The tool is one call. Plain text is invisible to the UI and produces worse UX. |
| "I already described the options in prose" | Prose ≠ interactive. The tool renders clickable buttons — use it. |
| "The user can just type their answer" | Typing is error-prone and bypasses the structured response format. |
| "AskUserQuestion isn't in my tools list" | Add it. That's the fix. Undeclared = silently broken. |
