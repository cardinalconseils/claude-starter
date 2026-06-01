---
date: 2026-06-01
source: vercel
title: Function invocations now billed per unit
priority: MEDIUM
type: ENHANCEMENT
affects: environment-management
action_required: false
expires: 2026-11-28
---

## What Changed
Vercel has moved function invocations from package-based to per-unit billing for Pro and new Enterprise customers. The new rate is $0.0000006 per invocation. Billing takes effect from the next billing cycle. Full details at https://vercel.com/changelog/function-invocations-now-billed-per-unit.

## Impact on Agents
Check https://vercel.com/changelog/function-invocations-now-billed-per-unit for updated cost estimation patterns. When advising on Vercel function architectures, update cost projections to use per-unit pricing rather than package-based assumptions. High-invocation workloads may see different cost profiles — review before recommending serverless patterns.

## Required Pattern Going Forward
No pattern change required — check source URL for details.

## Reference
https://vercel.com/changelog/function-invocations-now-billed-per-unit
