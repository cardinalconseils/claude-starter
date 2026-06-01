---
date: 2026-06-01
source: supabase
title: Introducing Branching 2.0
priority: MEDIUM
type: OPPORTUNITY
affects: database-design, migrations, cicd-starter
action_required: false
expires: 2026-11-28
---

## What Changed
Supabase released Branching 2.0, making branching without Git the default for all projects. Teams can now create database branches directly from the dashboard without requiring a GitHub integration. Full details at https://supabase.com/blog/branching-2-0.

## Impact on Agents
Check https://supabase.com/blog/branching-2-0 for updated recommended patterns before implementing database branching workflows. The no-Git-required path changes the recommended setup for projects that previously needed GitHub integration for branching. Update cicd-starter patterns to reflect the dashboard-first branching flow.

## Required Pattern Going Forward
No pattern change required — check source URL for details.

## Reference
https://supabase.com/blog/branching-2-0
