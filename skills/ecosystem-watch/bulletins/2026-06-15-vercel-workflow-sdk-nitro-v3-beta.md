---
date: 2026-06-15
source: vercel
title: Workflow SDK's native Nitro v3 integration is now in beta
priority: MEDIUM
type: OPPORTUNITY
affects: [cicd-starter, environment-management]
action_required: false
expires: 2026-12-12
---

## What Changed
Vercel Workflow SDK now natively integrates with Nitro v3 in beta. Steps run inside the same bundled runtime as the rest of the app — instead of a separate bundle — and Nitro's `useStorage()` and other server-side APIs work directly inside `"use step"` functions. Full details at https://vercel.com/changelog

## Impact on Agents
CKS agents scaffolding Vercel-based workflows should check the Nitro v3 beta integration before implementing custom step bundling. Check https://vercel.com/changelog for updated recommended patterns before implementing server-side step functions with Nitro.

## Required Pattern Going Forward
No pattern change required — check source URL for details.

## Reference
https://vercel.com/changelog
