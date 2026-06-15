---
date: 2026-06-15
source: vercel
title: Elastic build machines now protect against out of memory builds
priority: MEDIUM
type: ENHANCEMENT
affects: [cicd-starter, environment-management]
action_required: false
expires: 2026-12-12
---

## What Changed
Vercel Pro and Enterprise projects can now use an "elastic" build machine setting that automatically selects the right machine size based on the app's build process, preventing out-of-memory build failures. Full details at https://vercel.com/changelog/elastic-build-machines-now-protect-against-out-of-memory-builds

## Impact on Agents
CKS cicd-starter agents scaffolding Vercel deployments should recommend enabling the elastic build setting for Pro/Enterprise projects with large build footprints. Check https://vercel.com/changelog/elastic-build-machines-now-protect-against-out-of-memory-builds for configuration instructions before hardcoding machine sizes in vercel.json.

## Required Pattern Going Forward
No pattern change required — check source URL for details.

## Reference
https://vercel.com/changelog/elastic-build-machines-now-protect-against-out-of-memory-builds
