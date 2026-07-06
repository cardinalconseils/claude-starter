---
date: 2026-07-06
source: supabase
title: Developer Update - June 2026
priority: MEDIUM
type: ENHANCEMENT
affects: database-design, migrations, rls, authentication, api-design, monitoring
action_required: false
expires: 2027-01-02
---

## What Changed
Supabase June 2026 developer update covers: logs usage now metered (Pro/Team plans include 5 GB ingest + 1,000 GB query/month; existing orgs migrated July 1), Auth passkeys support in beta (Face ID, Touch ID, Windows Hello, hardware keys), postgresql log_connections default changed from on to off for new and migrated projects (July 9+), and Multigres v0.1 alpha availability for high-availability Postgres.

## Impact on Agents
Database-design and migrations agents: the log_connections default change affects new projects — existing RLS or audit-logging patterns that relied on connection logs should be audited. Authentication agents: passkeys are now a first-class auth method available to all projects. Monitoring agents: log pricing is now metered — advise users to size their log retention appropriately. Check https://supabase.com/changelog/46689-developer-update-june-2026 for the full changelog.

## Required Pattern Going Forward
No pattern change required — check source URL for details.

## Reference
https://supabase.com/changelog/46689-developer-update-june-2026
