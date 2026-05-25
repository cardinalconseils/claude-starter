---
date: 2026-05-25
source: vercel
title: New Vercel CLI login flow
priority: MEDIUM
type: ENHANCEMENT
affects: cicd-starter, environment-management
action_required: false
expires: 2026-11-21
---

## What Changed
Vercel updated the CLI login flow. The new flow changes how `vercel login` authenticates users, likely switching to a browser-based OAuth flow or updating token handling.

## Impact on Agents
When generating CI/CD setup instructions or environment bootstrap scripts that include `vercel login`, check https://vercel.com/changelog/new-vercel-cli-login-flow for the current recommended command. The old `--token` flow or interactive prompts may behave differently.

## Required Pattern Going Forward
No pattern change required — check source URL for details.

## Reference
https://vercel.com/changelog/new-vercel-cli-login-flow
