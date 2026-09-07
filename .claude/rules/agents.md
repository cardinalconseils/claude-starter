---
globs: "agents/*.md"
---

# Agent Rules

- YAML frontmatter MUST include: `name`, `subagent_type`, `description`, `tools`, `model`, `color`, `skills`
- `subagent_type` MUST match the value used in `Agent(subagent_type=...)` calls
- `skills` MUST list all domain knowledge the agent needs — agents don't inherit parent skills
- `tools` MUST list all tools the agent needs — agents don't inherit parent tools
- `model` MUST be a tier alias — `haiku`, `sonnet`, `opus` (`fable` also exists). Never pin a
  dated model ID: the plugin ships to other people's machines and a pinned ID rots on the
  next model release, while an alias tracks the newest model in its tier automatically.
- Assign the tier from what the agent actually decides, not from how important it feels:

| Tier | Use for | Signal |
|---|---|---|
| `haiku` | Mechanical work with no live decision point — reads files, formats output, CRUD on state, status dashboards | Every correct outcome could be enumerated ahead of time |
| `sonnet` | Default. Writes code, follows a plan, applies a known pattern, produces content | Judgment inside a well-defined fence |
| `opus` | Blast-radius or open-ended reasoning — security, DB schema and RLS, payments, legal, architecture and ADRs, orchestration, verification gates, discovery | A wrong call is expensive or hard to reverse |

- An agent that declares `AskUserQuestion` in `tools` MUST NOT be `haiku`. Its whole job is
  making a live tool call at a decision point; `skills/prd/references/model-strategy.md`
  records that lower tiers narrate the question as text instead of calling the tool, which
  turns a gate into a silent autonomous run. Interactivity outranks how mechanical the rest
  of the work looks.
- When torn between two tiers, ask what a wrong answer costs. Cheap and visible → go down
  a tier. Expensive, silent, or hard to reverse → go up.
- Agents dispatched N-at-a-time in parallel pay their tier N times — weigh that before
  putting a fan-out worker on `opus`.
- Agent body is the system prompt — write it as instructions to the agent, not documentation
- NEVER reference `${CLAUDE_PLUGIN_ROOT}` paths in agent body — use skill content instead
- Agents own their output format — commands should NOT duplicate report templates
