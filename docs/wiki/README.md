# CKS Wiki

> **Version 5.1.173** | Built 2026-06-17 | `761e17f`

CKS (Claude Code Starter Kit) is a Claude Code plugin that provides a complete 5-phase feature lifecycle — from idea to production. Install it once, use `/cks:*` commands in any project, and get structured workflows, AI agents, and quality gates without writing code.

## What's New in v5.1.137

**Luv Creative Suite** — Full creative production team added: `luv-ads-copywriter` (Joel Klettke VoC persona), `luv-long-form-copywriter` (TBWA\Media Arts Lab), `luv-brand-strategist` (April Dunford + Seth Godin), `luv-photo-creator` (Peter Belanger + OpenAI `gpt-image-1`), `luv-video-creator` (Kling API). New `/cks:creative` command bypasses CMO hierarchy for direct creative dispatch.

[Full release notes →](https://github.com/cardinalconseils/claude-starter/blob/main/CHANGELOG.md)

## What's New in v5.1.134

**Distributed Pattern Auto-Invocation** — `.claude/rules/arch-patterns.md` detects 12 distributed resilience patterns (DLQ, Saga, Circuit Breaker, CQRS, Event Sourcing, Outbox, Idempotency, Retry/Backoff, Bulkhead, Service Mesh, Fan-out/Fan-in, Health-aware Routing) at 3 lifecycle gates. Planning gate `[3a]` is mandatory — fires `cks:architecture-generator` before PLAN.md. Sprint gate `[3c]` is non-blocking catch. Review gate `[4a]` presents a DECISION REQUIRED block.

[Full release notes →](https://github.com/cardinalconseils/claude-starter/blob/main/CHANGELOG.md)

## Pages

| Page | Description |
|------|-------------|
| [Getting Started](getting-started.md) | Install, first-time setup, and the three entry points |
| [Commands Reference](commands.md) | All 123 commands grouped by category |
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
