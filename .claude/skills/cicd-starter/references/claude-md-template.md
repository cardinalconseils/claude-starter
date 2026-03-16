# CLAUDE.md Template Reference

Use this template when generating CLAUDE.md. Replace ALL tokens with project-specific content from the intake.

---

## Template

```markdown
# [PROJECT_NAME]

## What This Project Is
[PROJECT_DESCRIPTION — from Q2. 2–4 sentences. Clear, specific, no jargon.]

## Stack
- **[Primary framework]**: [How Claude should interact with it]
- **[Database/storage]**: [Conventions, schema location, migration rules]
- **[External services]**: [How to call them, where credentials live]
- **[Deployment]**: [Platform, how to trigger deploys, what branch = production]

## Key Workflows

Claude supports these workflows in this project:

[For each item in Q4, write a block like this:]

### [Workflow Name]
[2–3 sentences describing what Claude does, what inputs it receives, what output it produces.]

## Commands Available

[List each command from Q6 with one-line description:]
- `/[command]` — [what it does]

## Agents Available

[List each agent from Q5 with one-line description:]
- **[AgentName]** — [what it is responsible for]

## Always Follow These Rules

[From Q10. Written as imperative bullet points:]
- [Rule 1]
- [Rule 2]

## Environment Variables

Required for this project:
[From Q9 — list each variable name with a one-line description of what it's for:]
- `[VAR_NAME]` — [purpose]

## File Structure

[Generate a tree of the key project directories relevant to Claude's work]

## Do Not

- Modify production database directly without explicit confirmation
- [Add project-specific constraints from Q10 or inferred from stack]
```

---

## Adaptation Notes

- If Q10 = "none", omit the "Always Follow" section entirely — don't write "N/A"
- If Q9 = "none", write "Environment variables TBD — add to this file as they are identified"
- Stack section must name actual tools from Q3, not generic categories
- Workflows must match Q4 exactly — don't invent workflows not mentioned
- The file should read as if written by someone who knows this project deeply
