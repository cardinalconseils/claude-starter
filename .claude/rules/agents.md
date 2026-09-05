---
globs: "agents/*.md"
---

# Agent Rules

- YAML frontmatter MUST include: `name`, `subagent_type`, `description`, `tools`, `model`, `color`, `skills`
- `subagent_type` MUST match the value used in `Agent(subagent_type=...)` calls
- `skills` MUST list all domain knowledge the agent needs — agents don't inherit parent skills
- `tools` MUST list all tools the agent needs — agents don't inherit parent tools
- `model` MUST be one of the three tier aliases — `haiku`, `sonnet`, `opus`. Never pin a
  dated model ID: the plugin ships to other people's machines and a pinned ID rots on the
  next model release, while an alias tracks the newest model in its tier automatically.
- Assign the tier from what the agent actually decides, not from how important it feels:

| Tier | Use for | Signal |
|---|---|---|
| `haiku` | Mechanical work — reads files, formats output, CRUD on state, status dashboards, setup wizards with a fixed script | Every correct outcome could be enumerated ahead of time |
| `sonnet` | Default. Writes code, follows a plan, applies a known pattern, produces content | Judgment inside a well-defined fence |
| `opus` | Blast-radius or open-ended reasoning — security, DB schema and RLS, payments, legal, architecture and ADRs, orchestration, verification gates, discovery | A wrong call is expensive or hard to reverse |

- When torn between two tiers, ask what a wrong answer costs. Cheap and visible → go down
  a tier. Expensive, silent, or hard to reverse → go up.
- Agents dispatched N-at-a-time in parallel pay their tier N times — weigh that before
  putting a fan-out worker on `opus`.
- Agent body is the system prompt — write it as instructions to the agent, not documentation
- NEVER reference `${CLAUDE_PLUGIN_ROOT}` paths in agent body — use skill content instead
- Agents own their output format — commands should NOT duplicate report templates
