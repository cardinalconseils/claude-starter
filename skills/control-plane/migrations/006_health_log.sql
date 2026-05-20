-- 006_health_log.sql — Phase 6 Health Log (optional)
-- Persists control plane health snapshots for trend analysis.
-- Safe to re-run: CREATE TABLE IF NOT EXISTS throughout.
-- Run after 005_improvements.sql

create table if not exists cp_health_log (
  id          uuid primary key default gen_random_uuid(),
  org_id      text not null,
  project_id  text not null,
  recorded_at timestamptz default now(),
  overall     text check (overall in ('ok', 'degraded')) not null,
  components  jsonb not null,
  queue_depth int default 0
);

create index if not exists cp_health_log_lookup_idx
  on cp_health_log (org_id, project_id, recorded_at desc);

alter table cp_health_log enable row level security;

do $$ begin
  if not exists (
    select 1 from pg_policies where tablename = 'cp_health_log'
    and policyname = 'org_members_read_health_log'
  ) then
    execute 'create policy org_members_read_health_log on cp_health_log for select
      using (org_id = current_setting(''app.org_id'', true))';
  end if;
end $$;

do $$ begin
  if not exists (
    select 1 from pg_policies where tablename = 'cp_health_log'
    and policyname = 'service_all_health_log'
  ) then
    execute 'create policy service_all_health_log on cp_health_log for all
      using (current_setting(''role'', true) = ''service_role'')
      with check (current_setting(''role'', true) = ''service_role'')';
  end if;
end $$;
