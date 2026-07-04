---
globs: "commands/*.md"
---

# Command Rules

- Commands MUST be thin dispatchers — route to agents, don't embed workflow logic
- `allowed-tools` MUST only list tools the command itself uses, not tools agents need
- Thin dispatchers use at most: `Read`, `Agent`, `AskUserQuestion`
- NEVER reference `${CLAUDE_PLUGIN_ROOT}/skills/` — agents load skills via `skills:` frontmatter
- NEVER use `Skill(skill=...)` to load expertise — dispatch an agent with the skill instead
- YAML frontmatter MUST include `description` and `allowed-tools`
- Include a `## Quick Reference` section with usage examples
- Keep commands under 60 lines — if longer, logic belongs in an agent

## Orchestrator Exception

Orchestrator commands (`/cks:sprint`, `/cks:sprint-run`) that must dispatch agents from
the top-level session MUST use `Skill(skill="cks:attractor")` instead of `Agent()`. 
This is the only permitted exception to the thin-dispatcher rule — required by the Claude Code 
constraint that sub-agents cannot dispatch further agents. These commands use `Skill()` to load 
the pipeline orchestration into the current (top-level) session, which then dispatches domain 
agents normally.
