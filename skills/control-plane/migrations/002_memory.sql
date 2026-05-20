-- 002_memory.sql — Phase 2 Memory Layer
-- Safe to re-run: all statements use IF NOT EXISTS / CREATE OR REPLACE
-- Run after 001_heartbeats_raid_log.sql

create table if not exists memory (
  id           uuid primary key default gen_random_uuid(),
  org_id       text not null,
  project_id   text not null,
  memory_type  text check (memory_type in ('agent', 'project', 'session')) not null,
  agent_id     text,        -- null for project-level and session memories
  key          text not null,
  content      text not null,
  created_at   timestamptz default now(),
  updated_at   timestamptz default now()
);

create unique index if not exists memory_natural_key_idx
  on memory (org_id, project_id, memory_type, coalesce(agent_id, ''), key);

create index if not exists memory_lookup_idx
  on memory (org_id, project_id, memory_type);

alter table memory enable row level security;

do $$ begin
  if not exists (
    select 1 from pg_policies where tablename = 'memory' and policyname = 'org_members_read_memory'
  ) then
    execute 'create policy org_members_read_memory on memory for select
      using (org_id = current_setting(''app.org_id'', true))';
  end if;
end $$;

do $$ begin
  if not exists (
    select 1 from pg_policies where tablename = 'memory' and policyname = 'org_members_write_memory'
  ) then
    execute 'create policy org_members_write_memory on memory for insert
      with check (org_id = current_setting(''app.org_id'', true))';
  end if;
end $$;

do $$ begin
  if not exists (
    select 1 from pg_policies where tablename = 'memory' and policyname = 'org_members_update_memory'
  ) then
    execute 'create policy org_members_update_memory on memory for update
      using (org_id = current_setting(''app.org_id'', true))
      with check (org_id = current_setting(''app.org_id'', true))';
  end if;
end $$;

do $$ begin
  if not exists (
    select 1 from pg_policies where tablename = 'memory' and policyname = 'service_all_memory'
  ) then
    execute 'create policy service_all_memory on memory for all
      using (current_setting(''role'', true) = ''service_role'')
      with check (current_setting(''role'', true) = ''service_role'')';
  end if;
end $$;
