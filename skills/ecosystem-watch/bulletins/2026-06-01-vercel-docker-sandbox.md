---
date: 2026-06-01
source: vercel
title: Run Docker containers inside Vercel Sandbox
priority: MEDIUM
type: OPPORTUNITY
affects: cicd-starter, environment-management
action_required: false
expires: 2026-11-28
---

## What Changed
Vercel Sandbox now supports running Docker containers without any configuration changes. Agents can build containers, install system packages, run containerized services (Redis, Postgres) as test dependencies, and validate container images — all without touching the host system. Docker installations and pulled images persist between sessions with persistent sandboxes. Full details at https://vercel.com/changelog/run-docker-containers-inside-vercel-sandbox.

## Impact on Agents
Check https://vercel.com/changelog/run-docker-containers-inside-vercel-sandbox for updated recommended patterns before implementing test environments. This enables container-native CI workflows on Vercel that were previously impractical. Update cicd-starter scaffolding to surface Docker-in-Sandbox as an option for projects requiring containerized test services.

## Required Pattern Going Forward
No pattern change required — check source URL for details.

## Reference
https://vercel.com/changelog/run-docker-containers-inside-vercel-sandbox
