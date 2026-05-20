-- 003_agent_sessions.sql — Phase 3 Agent Coordination
-- Safe to re-run: all statements use IF NOT EXISTS / DO $$ guards
-- Run after 002_memory.sql

create table if not exists agent_sessions (
  id                uuid primary key default gen_random_uuid(),
  session_id        text not null,
  org_id            text not null,
  project_id        text,
  task              text,
  claimed_resources text[],
  status            text check (status in ('active', 'ended', 'orphaned')) default 'active',
  started_at        timestamptz default now(),
  ended_at          timestamptz,
  updated_at        timestamptz default now()
);

create unique index if not exists agent_sessions_session_idx
  on agent_sessions (session_id, org_id);

create index if not exists agent_sessions_active_idx
  on agent_sessions (org_id, status);

alter table agent_sessions enable row level security;

do $$ begin
  if not exists (
    select 1 from pg_policies where tablename = 'agent_sessions' and policyname = 'org_members_read_sessions'
  ) then
    execute 'create policy org_members_read_sessions on agent_sessions for select
      using (org_id = current_setting(''app.org_id'', true))';
  end if;
end $$;

do $$ begin
  if not exists (
    select 1 from pg_policies where tablename = 'agent_sessions' and policyname = 'org_members_write_sessions'
  ) then
    execute 'create policy org_members_write_sessions on agent_sessions for insert
      with check (org_id = current_setting(''app.org_id'', true))';
  end if;
end $$;

do $$ begin
  if not exists (
    select 1 from pg_policies where tablename = 'agent_sessions' and policyname = 'org_members_update_sessions'
  ) then
    execute 'create policy org_members_update_sessions on agent_sessions for update
      using (org_id = current_setting(''app.org_id'', true))
      with check (org_id = current_setting(''app.org_id'', true))';
  end if;
end $$;

do $$ begin
  if not exists (
    select 1 from pg_policies where tablename = 'agent_sessions' and policyname = 'service_all_sessions'
  ) then
    execute 'create policy service_all_sessions on agent_sessions for all
      using (current_setting(''role'', true) = ''service_role'')
      with check (current_setting(''role'', true) = ''service_role'')';
  end if;
end $$;
