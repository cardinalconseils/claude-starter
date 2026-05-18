---
date: 2026-05-18
source: vercel
title: "Introducing vercel.ts: Programmatic project configuration"
priority: MEDIUM
type: OPPORTUNITY
affects: [cicd-starter, environment-management]
action_required: false
expires: 2026-11-14
---

## What Changed
Vercel introduced `vercel.ts`, a TypeScript-based configuration file that lets you define routing, request transforms, caching rules, and cron jobs as code — replacing the static `vercel.json` approach. Full details at https://vercel.com/changelog/vercel-ts.

## Impact on Agents
Check https://vercel.com/changelog/vercel-ts for updated recommended patterns before implementing cicd-starter or environment-management configuration. `vercel.ts` is now the preferred approach for complex Vercel project configuration.

## Required Pattern Going Forward
No pattern change required — check source URL for details.

## Reference
https://vercel.com/changelog/vercel-ts
