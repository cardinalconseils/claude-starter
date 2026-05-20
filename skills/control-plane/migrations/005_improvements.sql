-- 005_improvements.sql — Phase 5 Self-Improvement Loop
-- Safe to re-run: all statements use IF NOT EXISTS / DO $$ guards
-- Run after 004_observability.sql

create table if not exists improvements (
  id           uuid primary key default gen_random_uuid(),
  org_id       text not null,
  project_id   text not null,
  proposal_id  text not null,
  status       text check (status in ('pending', 'accepted', 'rejected', 'deferred')) not null default 'pending',
  type         text check (type in ('rule', 'persona', 'workflow', 'convention')) not null,
  confidence   integer check (confidence between 0 and 100),
  impact       text check (impact in ('low', 'medium', 'high')),
  content      text not null,
  created_at   timestamptz default now(),
  updated_at   timestamptz default now()
);

create unique index if not exists improvements_natural_key_idx
  on improvements (org_id, project_id, proposal_id);

create index if not exists improvements_status_idx
  on improvements (org_id, project_id, status);

alter table improvements enable row level security;

do $$ begin
  if not exists (
    select 1 from pg_policies where tablename = 'improvements' and policyname = 'org_members_read_improvements'
  ) then
    execute 'create policy org_members_read_improvements on improvements for select
      using (org_id = current_setting(''app.org_id'', true))';
  end if;
end $$;

do $$ begin
  if not exists (
    select 1 from pg_policies where tablename = 'improvements' and policyname = 'org_members_write_improvements'
  ) then
    execute 'create policy org_members_write_improvements on improvements for insert
      with check (org_id = current_setting(''app.org_id'', true))';
  end if;
end $$;

do $$ begin
  if not exists (
    select 1 from pg_policies where tablename = 'improvements' and policyname = 'org_members_update_improvements'
  ) then
    execute 'create policy org_members_update_improvements on improvements for update
      using (org_id = current_setting(''app.org_id'', true))
      with check (org_id = current_setting(''app.org_id'', true))';
  end if;
end $$;

do $$ begin
  if not exists (
    select 1 from pg_policies where tablename = 'improvements' and policyname = 'service_all_improvements'
  ) then
    execute 'create policy service_all_improvements on improvements for all
      using (current_setting(''role'', true) = ''service_role'')
      with check (current_setting(''role'', true) = ''service_role'')';
  end if;
end $$;
