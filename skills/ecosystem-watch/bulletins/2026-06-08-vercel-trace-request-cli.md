---
date: 2026-06-08
source: vercel
title: Trace any Vercel request from the CLI
priority: MEDIUM
type: OPPORTUNITY
affects: monitoring, performance
action_required: false
expires: 2026-12-05
---

## What Changed
Vercel added a `vercel curl --trace` CLI command that generates an OpenTelemetry trace to any specified endpoint directly from the terminal, enabling request-level tracing without browser tooling. Full details at https://vercel.com/changelog/trace-any-vercel-request-from-the-cli.

## Impact on Agents
Check https://vercel.com/changelog/trace-any-vercel-request-from-the-cli for updated recommended patterns before implementing monitoring or debugging workflows. Monitoring and performance agents should incorporate `vercel curl --trace` into debugging runbooks for Vercel-hosted projects — it provides a CLI-native path to OpenTelemetry traces.

## Required Pattern Going Forward
No pattern change required — check source URL for details.

## Reference
https://vercel.com/changelog/trace-any-vercel-request-from-the-cli
