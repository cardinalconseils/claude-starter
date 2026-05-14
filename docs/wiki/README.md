# CKS Wiki

> **Version 4.13.11** | Built 2026-05-13 | `0ccd808`

CKS (Claude Code Starter Kit) is a Claude Code plugin that provides a complete 5-phase feature lifecycle — from idea to production. Install it once, use `/cks:*` commands in any project, and get structured workflows, AI agents, and quality gates without writing code.

## What's New in v4.14.0

**Session Handoff** — New `/cks:handoff` command writes a structured handoff document (`.handoff/YYYY-MM-DD-HH-MM.md`) with branch state, uncommitted diff, open decisions, blockers, and next steps. Solves the cross-session context-loss problem — run it before compaction or when passing work to another session.

**Caveman Skill Strengthened** — The `caveman` skill now includes:
- **Persistence** — explicitly active every response, no filler drift, no revert across turns
- **Abbreviation rules** — `DB/auth/config/req/res/fn/impl/env/ctx/msg`
- **Arrow causality** — `token missing → req fail → auth break`
- **Output pattern** — `[thing] [action] [reason]. [next step].`
- **Not/Yes examples** — replaces verbose Before/After format with scannable pairs

**Context-Guard Tighter** — Context window warning now fires at 48% ("run `/cks:handoff` soon") and stop at 55% ("run `/cks:handoff` NOW"), aligned with the handoff trigger point.

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
