---
date: 2026-05-18
source: vercel
title: New Vercel CLI login flow
priority: MEDIUM
type: ENHANCEMENT
affects: [cicd-starter, environment-management]
action_required: false
expires: 2026-11-14
---

## What Changed
The `vercel login` command was updated to use OAuth 2.0 Device Flow, replacing the previous browser-redirect approach for more secure and intuitive authentication. Full details at https://vercel.com/changelog/new-vercel-cli-login-flow.

## Impact on Agents
Check https://vercel.com/changelog/new-vercel-cli-login-flow for updated CLI authentication patterns before writing cicd-starter or environment-management setup scripts that invoke `vercel login`.

## Required Pattern Going Forward
No pattern change required — check source URL for details.

## Reference
https://vercel.com/changelog/new-vercel-cli-login-flow
