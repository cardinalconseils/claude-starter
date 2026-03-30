# CKS — Claude Code Starter Kit

> Max 150 lines — this is a constitution, not a manual.
> Style/security/testing/database/docs rules live in `.claude/rules/` (auto-generated, glob-scoped).

## What This Project Is
A Claude Code plugin providing a 5-phase feature lifecycle toolkit — discover, design, sprint, review, release. Includes AI agents, structured workflows, quality gates, and environment promotion. From idea to production.

## Stack
- **Claude Code Plugin Framework**: Markdown commands, YAML frontmatter agents, shell hooks
- **Language**: Markdown (commands, agents, skills), Bash (hooks, scripts), JSON (config)
- **Deployment**: GitHub (`cardinalconseils/claude-starter`), installed via `claude /plugin add`

## Project Structure
```
.claude-plugin/       — Plugin manifest (plugin.json)
agents/               — 30+ agent definitions (YAML frontmatter + system prompt)
commands/             — 47 slash commands (/cks:* prefix)
hooks/                — Event hooks (SessionStart, PreToolUse, PostToolUse, Stop)
  handlers/           — Hook handler scripts
scripts/              — Utility scripts (cks-log.sh, bump-version.sh)
skills/               — Domain expertise loaded by agents via skills: frontmatter
  prd/                — PRD lifecycle knowledge + workflows
  kickstart/          — Project enabler knowledge + workflows
  deep-research/      — Multi-hop research knowledge
  retrospective/      — Learning extraction knowledge
  cicd-starter/       — Bootstrap/scaffold patterns + assets
tools/                — Plugin tool definitions
docs/                 — Specs, plans, workflow documentation
.claude/rules/        — Glob-scoped guardrails (commands, agents, skills, hooks, docs)
```

## Key Workflows

### Running the Project
This is a plugin, not an app. To test changes:
- Install locally: `claude /plugin add /path/to/Claude-Starter`
- Run any command: `/cks:help`, `/cks:status`, etc.
- Check hooks: open a new Claude Code session and verify SessionStart output

### Adding a New Command
1. Create `commands/{name}.md` with YAML frontmatter (`description`, `allowed-tools`)
2. Write as thin dispatcher: parse args, dispatch agent, show quick reference
3. Keep under 60 lines — domain logic belongs in agents
4. Update `commands/README.md` count and table
5. Update `commands/help.md` command list

### Adding a New Agent
1. Create `agents/{name}.md` with frontmatter (`name`, `subagent_type`, `description`, `tools`, `model`, `color`, `skills`)
2. Body is the system prompt — write instructions, not documentation
3. Reference via `Agent(subagent_type="{name}")` in commands

## Architecture Pattern
```
Command (thin dispatcher, ~40 lines)
  → Agent (skills: loaded at startup, tools: declared in frontmatter)
    → Skill (domain expertise, read by agent)
      → Workflow (progressive disclosure, read on demand)
Hook (automation: logging, guarding — no agent dispatch)
```

## Commands
- `/cks:go` — Build + commit + push + PR
- `/cks:new` — Create feature + enter lifecycle
- `/cks:sprint-start` — Load context at session start
- `/cks:sprint-close` — Audit rules + capture learnings at session end
- `/cks:status` — Project dashboard
- `/cks:help` — All commands

## Critical Constraints
- Never expose API keys or secrets in code
- Commands MUST be thin dispatchers — no inline workflow logic
- Agents declare their own tools and skills — commands don't pass these
- CLAUDE.md stays under 150 lines — rules go in `.claude/rules/`
- Always use branch + PR for changes — never commit directly to main

## Environment Variables
No env vars required for the plugin itself. Target projects using CKS may need:
- Project-specific env vars detected by `/cks:bootstrap` and `/cks:adopt`

## Do Not
- Embed workflow logic in commands (use agents)
- Reference `${CLAUDE_PLUGIN_ROOT}/skills/` in commands (agents load skills via frontmatter)
- Use `Skill(skill=...)` to load expertise in commands (dispatch agents instead)
- Commit directly to main (use branch + PR)
- Add verbose report templates to commands (agents own output format)
