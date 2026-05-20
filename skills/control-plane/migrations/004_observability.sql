-- 004_observability.sql — Phase 4 Observability / Cost Tracking
-- Safe to re-run: all statements use IF NOT EXISTS / DO $$ guards
-- Run after 003_agent_sessions.sql

create table if not exists observability_sessions (
  id                uuid primary key default gen_random_uuid(),
  org_id            text not null,
  project_id        text not null,
  session_id        text not null,
  start_ts          timestamptz,
  end_ts            timestamptz,
  branch            text,
  tool_calls        integer default 0,
  cks_commands      integer default 0,
  duration_seconds  integer,
  created_at        timestamptz default now()
);

create unique index if not exists obs_sessions_natural_key_idx
  on observability_sessions (org_id, project_id, session_id);

create index if not exists obs_sessions_lookup_idx
  on observability_sessions (org_id, project_id, start_ts desc);

alter table observability_sessions enable row level security;

do $$ begin
  if not exists (
    select 1 from pg_policies where tablename = 'observability_sessions'
      and policyname = 'org_members_read_obs'
  ) then
    execute 'create policy org_members_read_obs on observability_sessions for select
      using (org_id = current_setting(''app.org_id'', true))';
  end if;
end $$;

do $$ begin
  if not exists (
    select 1 from pg_policies where tablename = 'observability_sessions'
      and policyname = 'service_all_obs'
  ) then
    execute 'create policy service_all_obs on observability_sessions for all
      using (current_setting(''role'', true) = ''service_role'')
      with check (current_setting(''role'', true) = ''service_role'')';
  end if;
end $$;
