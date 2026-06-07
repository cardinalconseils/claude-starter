---
name: hermes-agent
description: >
  Hermes Agent integration for CKS — project scaffolding, AGENTS.md generation,
  skill mapping, and Hermes-native templates. Use when the user asks for Hermes
  support, multi-harness scaffolding, or when generating AGENTS.md. Maps Hermes
  concepts (skills, memory, profiles, MCP tools, cron jobs) to CKS equivalents.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
model: sonnet
---

# Hermes Agent Integration for CKS

Teaches CKS about Hermes Agent so generated projects work across both Claude Code
and Hermes. Key insight: a "modern AI harness" project has AGENTS.md for Hermes
AND CLAUDE.md for Claude Code — sometimes alongside .cursorrules for Cursor.

## What Hermes Agent Is

Hermes is an AI agent platform by Nous Research. It runs as a CLI, TUI, or
background daemon. Key concepts:

| Hermes Concept | CKS Equivalent | Notes |
|----------------|----------------|-------|
| Skills (`.hermes/skills/`) | CKS skills (`skills/`) | Procedural knowledge loaded on demand |
| AGENTS.md | CLAUDE.md | Standing orders for the agent session |
| Memory (persistent store) | `.learnings/` | Cross-session facts vs session artifacts |
| Profiles (per-project config) | `.prd/` config | Hermes isolates by profile, CKS by project |
| MCP tools | CKS `tools/` | Model Context Protocol servers |
| Cron jobs (scheduled) | `scheduled-agents/` | Recurring agent tasks |
| Toolsets | `allowed-tools` frontmatter | Named capability groups |

## Hermes Project Architecture

When CKS scaffolds a project intended to work with Hermes, generate this structure:

```
project/
├── AGENTS.md                 ← Standing orders for Hermes (required)
├── CLAUDE.md                 ← Standing orders for Claude Code (optional)
├── .hermes/
│   ├── config.yaml           ← Hermes profile config
│   ├── rules/                ← Glob-scoped guardrails (same concept as .claude/rules/)
│   ├── plans/                ← Plan files (like CKS plan files)
│   └── skills/               ← Project-local Hermes skills
├── .claude/                  ← Only if Claude Code is also needed
├── skills/                   ← Shared CKS skills (loaded by both)
├── src/
├── tests/
├── package.json / pyproject.toml
└── README.md
```

## Rule: When to Generate Which Files

| User Goal | Generate |
|-----------|----------|
| "I use Hermes" | AGENTS.md + .hermes/ |
| "I use Claude Code" | CLAUDE.md + .claude/ |
| "I use both" | AGENTS.md + CLAUDE.md + shared `skills/` |
| "I use Cursor/Codex/Copilot" | .cursorrules or appropriate config |

## AGENTS.md Template (Hermes Standing Orders)

Use this template when generating AGENTS.md:

```markdown
# AGENTS.md — Standing Orders

## Auto-Load Skills
Always load these skills silently at session start:
- {skill-dependencies}

## Pre-Ship Invariant
Before ANY deploy, release, or production-adjacent action:
1. Run the security gate (defined below)
2. If CRITICAL findings exist, STOP and demand fix
3. Document in .hermes/decisions/

## Maturity Stage
Current stage: {maturity-stage}

Behaviors per stage:
- **Prototype**: Speed over perfection. Never commit secrets, never skip auth.
- **Pilot**: Full security audit before any user-facing change.
- **Candidate**: All gates must pass.
- **Production**: No deploy without passing CI.

## Proactive Behaviors
- Flag security issues immediately
- Suggest tests BEFORE implementing
- Document decisions in .hermes/decisions/
- Never say "that's a good idea" to disabling security

## Memory Sync
At session end, capture:
- Branch and commits
- Security findings (even if resolved)
- Architecture decisions made
```

## Hermes config.yaml Template

```yaml
# Hermes profile config
provider: openrouter  # or anthropic, openai
model: deepseek/deepseek-v4-flash  # or claude-sonnet-4, etc.

# Auto-load skills at session start
skills:
  - ciso-security
  - soul-framework

# MCP server configuration
mcp_servers:
  - package: n8n
    args:
      baseUrl: ...  # n8n webhook URL
  # Add project-specific MCP servers here

# Tool configuration
tools:
  enabled_toolsets:
    - terminal
    - file
    - web
    - browser
```

## Hermes Skills vs CKS Skills

Hermes skills live under `~/.hermes/skills/<name>/` or project-local `.hermes/skills/<name>/`.
They use the same YAML frontmatter + markdown structure as CKS skills.

**Key difference:** Hermes skills are auto-loaded by name via AGENTS.md, not by
plugin discovery. CKS skills are loaded by agent frontmatter.

When generating skills during `/cks:kickstart`, create them in `.hermes/skills/`
if the user uses Hermes, and `skills/` if they use Claude Code.

## Hermes-Compatible MCP Server Templates

When the project needs MCP servers (the modern pattern for AI tool integration),
generate an MCP config section and reference the cks-stack stack-layers:

```yaml
# In .hermes/config.yaml or project MCP server list
mcp_servers:
  - package: filesystem
    args:
      allowed_directories: ["./"]
  - package: github
    args: {}
  # Custom per-project MCP servers
```

## Verification

- [ ] AGENTS.md has standing orders matching CKS project lifecycle
- [ ] .hermes/config.yaml has correct provider and model
- [ ] Skills referenced in AGENTS.md exist in skills/ directory
- [ ] MCP server config matches project requirements
- [ ] Security gates defined for pre-ship invariant
