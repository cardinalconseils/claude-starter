-- CKS v6 Phase 1 Migration: heartbeats + raid_log
-- Run via: supabase db push  OR  Supabase MCP apply_migration tool
-- Safe to re-run: all CREATE statements use IF NOT EXISTS

-- ============================================================
-- 1. heartbeats table
-- ============================================================
create table if not exists heartbeats (
  id          uuid primary key default gen_random_uuid(),
  agent_id    text not null,
  org_id      text not null,
  last_beat   timestamptz,
  state       jsonb,                  -- persisted across heartbeat cycles
  status      text check (status in ('alive', 'sleeping', 'orphaned', 'dead')),
  created_at  timestamptz default now(),
  unique (agent_id, org_id)           -- one row per agent per org
);

-- Index for heartbeat status checks (used by /cks:heartbeat status)
create index if not exists heartbeats_org_status_idx on heartbeats (org_id, status);

-- ============================================================
-- 2. heartbeats RLS
-- ============================================================
alter table heartbeats enable row level security;

-- Agents insert their own row only
create policy "agents_insert_own_heartbeat"
on heartbeats for insert
with check (
  org_id = current_setting('app.org_id', true)
  and agent_id = current_setting('app.agent_id', true)
);

-- Agents read their own row only
create policy "agents_read_own_heartbeat"
on heartbeats for select
using (
  org_id = current_setting('app.org_id', true)
  and agent_id = current_setting('app.agent_id', true)
);

-- Agents update their own row only
create policy "agents_update_own_heartbeat"
on heartbeats for update
using (
  agent_id = current_setting('app.agent_id', true)
)
with check (
  agent_id = current_setting('app.agent_id', true)
);

-- Service role: full access (used by /cks:heartbeat status to read all org rows)
create policy "service_all_heartbeats"
on heartbeats for all
to service_role
using (true)
with check (true);

-- ============================================================
-- 3. raid_log table
-- ============================================================
create table if not exists raid_log (
  id              uuid primary key default gen_random_uuid(),
  org_id          text not null,
  project_id      text not null,
  type            text check (type in ('risk', 'assumption', 'issue', 'dependency')) not null,
  title           text not null,
  severity        text check (severity in ('low', 'medium', 'high', 'critical')) not null,
  status          text check (status in ('open', 'mitigated', 'resolved', 'accepted')) default 'open',
  owner           text,
  details         text,
  mitigation      text,
  resolution      text,
  linked_goal_id  text,           -- no FK in Phase 1; tasks/goals tables don't exist until Phase 4
  linked_task_id  uuid,           -- FK to tasks(id) added in Phase 4 migration
  opened_at       timestamptz default now(),
  closed_at       timestamptz     -- agents set this when updating status to 'resolved' or 'accepted'
);

-- Index for open RAID item lookups (agents query only open items for current project)
create index if not exists raid_log_open_idx on raid_log (org_id, project_id, status);

-- ============================================================
-- 4. raid_log RLS
-- ============================================================
alter table raid_log enable row level security;

-- All org members can read RAID items for their org
create policy "org_members_read_raid_log"
on raid_log for select
using (org_id = current_setting('app.org_id', true));

-- All org members can append (INSERT) new RAID items
create policy "org_members_insert_raid_log"
on raid_log for insert
with check (org_id = current_setting('app.org_id', true));

-- All org members can update RAID item status (lifecycle: open → mitigated → resolved/accepted)
-- Includes setting closed_at = now() when resolving
create policy "org_members_update_raid_log"
on raid_log for update
using (org_id = current_setting('app.org_id', true))
with check (org_id = current_setting('app.org_id', true));

-- Service role: full access
create policy "service_all_raid_log"
on raid_log for all
to service_role
using (true)
with check (true);
