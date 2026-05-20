# CKS Wiki

> **Version 5.1.71** | Built 2026-05-20 | `39a985d`

CKS (Claude Code Starter Kit) is a Claude Code plugin that provides a complete 5-phase feature lifecycle — from idea to production. Install it once, use `/cks:*` commands in any project, and get structured workflows, AI agents, and quality gates without writing code.

## What's New in v5.0.8

**Handoff History** — `/cks:handoff` now writes unique per-session files (`HANDOFF-{date}-{time-EST}-{branch}.md`) into `.prd/handoffs/`. Parallel sessions no longer clobber each other. `.prd/HANDOFF.md` stays as the "latest" pointer so `/cks:sprint-start` auto-detect keeps working.

**Attractor in Any Project** — `/cks:sprint` no longer errors with `No pipelines/sprint.dot` when run in a user project. The runner now resolves `sprint.dot` from `${CLAUDE_PLUGIN_ROOT}/pipelines/sprint.dot` first (where the plugin is installed), then falls back to the project root, then uses the embedded graph.

[Full release notes →](https://github.com/cardinalconseils/claude-starter/blob/main/CHANGELOG.md)

## What's New in v4.13.0

**Engineering Discipline Guardrails** — New `.claude/rules/engineering-discipline.md` enforces three principles on every change:

- **Simplicity First** — Smallest solution that works. No abstractions for hypothetical futures.
- **Minimal Impact** — Touch only what the task requires. No unrequested refactors or cleanup.
- **Root Cause Only** — Trace bugs to origin. No try/catch to silence errors without understanding them.

Each rule includes a self-test and a Common Rationalizations table so agents can't reason their way around it.

[Full release notes →](https://github.com/cardinalconseils/claude-starter/releases/tag/v4.13.0)

## Pages

| Page | Description |
|------|-------------|
| [Getting Started](getting-started.md) | Install, first-time setup, and the three entry points |
| [Commands Reference](commands.md) | All 73 commands grouped by category |
| [Agents Reference](agents.md) | All agents, their roles, and when to use each |
| [Skills Reference](skills.md) | All skills and what domain knowledge they provide |
| [The 5-Phase Lifecycle](lifecycle.md) | Phase-by-phase walkthrough from discovery to release |
| [Extending CKS](extending.md) | How to add commands, agents, and skills |

## Quick Links

```
Install:    bash <(curl -fsSL https://raw.githubusercontent.com/cardinalconseils/claude-starter/main/install.sh)
New idea:   /cks:kickstart
New feature /cks:new "feature name"
Daily work: /cks:go
What next:  /cks:next
```
