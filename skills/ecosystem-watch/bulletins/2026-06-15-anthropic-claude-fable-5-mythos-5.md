---
date: 2026-06-15
source: anthropic
title: Claude Fable 5 and Claude Mythos 5
priority: MEDIUM
type: OPPORTUNITY
affects: [api-design]
action_required: false
expires: 2026-12-12
---

## What Changed
Announced: Claude Fable 5 and Claude Mythos 5. Fable 5 is Anthropic's latest frontier model (model ID: `claude-fable-5`); Mythos 5 is a specialized companion model released alongside it. Full details at https://www.anthropic.com/news/claude-fable-5-mythos-5

## Impact on Agents
Agents implementing LLM calls should evaluate Fable 5 as the new default frontier option. Check https://www.anthropic.com/news/claude-fable-5-mythos-5 for capability benchmarks, context windows, and pricing before choosing between Fable 5, Opus 4.8, and Sonnet 4.6 for new integrations. Note: US government has issued a temporary suspension of Fable 5 and Mythos 5 for foreign nationals — see pending-review.md before deploying these models to international users.

## Required Pattern Going Forward
No pattern change required — check source URL for details.

## Reference
https://www.anthropic.com/news/claude-fable-5-mythos-5
