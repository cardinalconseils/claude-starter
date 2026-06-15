---
date: 2026-06-15
source: openai
title: Better memory for a more helpful ChatGPT
priority: MEDIUM
type: ENHANCEMENT
affects: [api-design]
action_required: false
expires: 2026-12-12
---

## What Changed
OpenAI released memory management improvements for ChatGPT (June 2, 2026) — users can now delete specific memories from their memory summary page and selectively disable memory per session. Full details at https://openai.com/news/product-releases/

## Impact on Agents
CKS agents building ChatGPT-integrated or memory-aware features should note the updated memory controls as a user-facing privacy feature. Check https://openai.com/news/product-releases/ for API-level memory management APIs before implementing custom memory persistence on top of ChatGPT.

## Required Pattern Going Forward
No pattern change required — check source URL for details.

## Reference
https://openai.com/news/product-releases/
