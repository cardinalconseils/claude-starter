---
description: "Configure agent persona — role, reasoning style, and domain knowledge via guided interview"
argument-hint: "[--scaffold <path>]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:persona — Agent Persona Configuration

Configure who your agent is, how it reasons, and what it knows.
Runs a guided interview and writes the skill cards to `skills/agent-persona/`.

## Routing

| Invocation | Behavior |
|------------|----------|
| `/cks:persona` | Interview mode — populate cards in this project |
| `/cks:persona --scaffold <path>` | Scaffold mode — copy structure + populate cards in `<path>` |

## Dispatch

Parse `$ARGUMENTS` for `--scaffold <path>`.

**Mode 1 — No args (interview mode):**

```
Agent(
  subagent_type="cks:persona-interviewer",
  prompt="Run the persona interview for this project. Mode: interview. base_path: skills/agent-persona/"
)
```

**Mode 2 — `--scaffold <path>`:**

```
Agent(
  subagent_type="cks:persona-interviewer",
  prompt="Run the persona interview in scaffold mode. scaffold_path: <path>. Copy skills/agent-persona/ to <path>/skills/agent-persona/, then run the interview. base_path: <path>/skills/agent-persona/"
)
```

## Quick Reference

```
/cks:persona                          # Interview + write cards for this project
/cks:persona --scaffold ./my-app      # Scaffold + interview for a target project
```

## Activating the Persona

After running `/cks:persona`, add `agent-persona` to any agent's `skills:` frontmatter:

```yaml
skills:
  - core-behaviors
  - agent-persona
```
