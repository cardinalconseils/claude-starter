---
date: 2026-06-15
source: anthropic
title: Introducing Claude Opus 4.8
priority: MEDIUM
type: OPPORTUNITY
affects: [api-design]
action_required: false
expires: 2026-12-12
---

## What Changed
Anthropic released Claude Opus 4.8 (model ID: `claude-opus-4-8`), an upgrade to the Opus model class with stronger performance across coding, agentic tasks, and professional work. Designed specifically for consistency on long-running autonomous workloads — uses tools cleanly and follows instructions reliably across extended sessions. Full details at https://www.anthropic.com/news/claude-opus-4-8

## Impact on Agents
Agents selecting models for agentic/autonomous tasks should evaluate Opus 4.8 as the preferred choice for long-running sprints and multi-step workflows where consistency matters more than speed. Check https://www.anthropic.com/news/claude-opus-4-8 for updated pricing and context window before switching model assignments in CKS agent frontmatter.

## Required Pattern Going Forward
No pattern change required — check source URL for details.

## Reference
https://www.anthropic.com/news/claude-opus-4-8
