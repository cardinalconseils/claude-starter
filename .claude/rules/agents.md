---
globs: "agents/*.md"
---

# Agent Rules

- YAML frontmatter MUST include: `name`, `subagent_type`, `description`, `tools`, `model`, `color`, `skills`
- `subagent_type` MUST match the value used in `Agent(subagent_type=...)` calls
- `skills` MUST list all domain knowledge the agent needs — agents don't inherit parent skills
- `tools` MUST list all tools the agent needs — agents don't inherit parent tools
- Use `model: sonnet` for mechanical tasks, `model: opus` for reasoning-heavy tasks
- Agent body is the system prompt — write it as instructions to the agent, not documentation
- NEVER reference `${CLAUDE_PLUGIN_ROOT}` paths in agent body — use skill content instead
- Agents own their output format — commands should NOT duplicate report templates
