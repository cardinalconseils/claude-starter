---
date: 2026-06-15
source: vercel
title: DeepSeek models now available via Azure on AI Gateway
priority: MEDIUM
type: OPPORTUNITY
affects: [api-design]
action_required: false
expires: 2026-12-12
---

## What Changed
Azure is now a provider for DeepSeek V4 Pro and V4 Flash on Vercel AI Gateway, adding another failover path for both models alongside existing providers. Full details at https://vercel.com/changelog/deepseek-models-now-available-via-azure-on-ai-gateway

## Impact on Agents
Agents implementing multi-model routing via Vercel AI Gateway should note Azure as a new fallback provider for DeepSeek V4. Check https://vercel.com/changelog/deepseek-models-now-available-via-azure-on-ai-gateway for updated routing configuration before implementing DeepSeek-based features.

## Required Pattern Going Forward
No pattern change required — check source URL for details.

## Reference
https://vercel.com/changelog/deepseek-models-now-available-via-azure-on-ai-gateway
