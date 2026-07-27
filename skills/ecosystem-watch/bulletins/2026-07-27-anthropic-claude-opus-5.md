---
date: 2026-07-27
source: anthropic
title: Introducing Claude Opus 5
priority: MEDIUM
type: OPPORTUNITY
affects: api-design
action_required: false
expires: 2027-01-27
---

## What Changed
Anthropic launched Claude Opus 5 on July 24, 2026 — a major flagship model with a 1-million-token context window, 128K output tokens, and thinking on by default. It becomes the new default on Claude Max and delivers step-change improvements for long-running agents, coding, and professional work at the same cost as Opus 4.8.

## Impact on Agents
CKS agents that invoke Claude via API should evaluate Opus 5 as the new premium tier for reasoning-heavy tasks. Check https://www.anthropic.com/news/claude-opus-5 for model IDs, pricing, and API format before updating agent `model:` frontmatter. The new effort-level toggle (low/medium/high) enables cost/capability balancing per-call.

## Required Pattern Going Forward
No pattern change required — check source URL for details.

## Reference
https://www.anthropic.com/news/claude-opus-5
