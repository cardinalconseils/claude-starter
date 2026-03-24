# Agent Template Reference

Use this template for each agent file in `.claude/agents/`.

---

## Template

```markdown
# [AgentName] Agent

## Role
[1–2 sentences: what this agent is responsible for in the context of THIS project.]

## Triggers
This agent is invoked when:
- [Specific situation 1]
- [Specific situation 2]
- [Specific situation 3]

## Inputs
- [Input type 1]: [description]
- [Input type 2]: [description]

## Outputs
- [Output type]: [format, destination, what it contains]

## Tools This Agent Uses
- [Tool/skill name]: [why/how]

## Constraints
- [Hard rule 1 — what this agent must NEVER do]
- [Hard rule 2]
- [Scope limit — what's out of scope for this agent]

## Handoff
When this agent completes, it should:
- [Next step or who receives the output]
```

---

## Naming Convention

- File: `[agent-name].md` — lowercase, hyphenated
- Agent name in header: `[AgentName] Agent` — PascalCase + "Agent"

## Adaptation Rules

- Role must reference the **project** — not "this agent reviews code in general" but "this agent reviews PRs for the [PROJECT_NAME] API, focusing on [specific concern]"
- Triggers must be concrete situations that will actually happen in this project
- Constraints must include at least one hard "never do" rule
- If the project has a specific DB, mention it in constraints (e.g., "never run DROP or DELETE on production Supabase")
