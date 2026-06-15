---
date: 2026-06-15
source: anthropic
title: Enabling Claude Code to work more autonomously
priority: MEDIUM
type: OPPORTUNITY
affects: [api-design]
action_required: false
expires: 2026-12-12
---

## What Changed
Anthropic launched Dynamic Workflows in research preview for Claude Code on the web. Claude can now plan large tasks and spin up hundreds of parallel subagents within a single session to execute them — dramatically expanding the scope of autonomous engineering tasks. Full details at https://www.anthropic.com/news/enabling-claude-code-to-work-more-autonomously

## Impact on Agents
CKS sprint agents and orchestrators should monitor this capability. Dynamic workflows could replace or complement the current CKS multi-agent dispatch pattern for large-scale tasks. Check https://www.anthropic.com/news/enabling-claude-code-to-work-more-autonomously for research preview access requirements and limitations before designing new agentic flows.

## Required Pattern Going Forward
No pattern change required — check source URL for details.

## Reference
https://www.anthropic.com/news/enabling-claude-code-to-work-more-autonomously
