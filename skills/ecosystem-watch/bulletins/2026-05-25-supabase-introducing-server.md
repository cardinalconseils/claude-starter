---
date: 2026-05-25
source: supabase
title: Introducing @supabase/server
priority: MEDIUM
type: OPPORTUNITY
affects: authentication, api-design
action_required: false
expires: 2026-11-21
---

## What Changed
Supabase released `@supabase/server` in public beta — a new package that handles auth verification, client setup, request context, and common server-side boilerplate automatically. This reduces the setup code required for server-rendered Supabase apps.

## Impact on Agents
For new Supabase server-side integrations (Next.js API routes, Edge Functions, server components), prefer `@supabase/server` over manual client setup. Check https://supabase.com/blog/introducing-supabase-server for the updated initialization pattern before implementing auth-gated endpoints.

## Required Pattern Going Forward
No pattern change required — check source URL for updated initialization pattern.

## Reference
https://supabase.com/blog/introducing-supabase-server
