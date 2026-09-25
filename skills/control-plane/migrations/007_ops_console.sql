-- 007_ops_console.sql — Ops Console Phase 1: telemetry sink + approvals queue
-- Safe to re-run: all statements use IF NOT EXISTS / DO $$ guards
-- Run after 006_health_log.sql
--
-- RLS choices (kept minimal — neither table carries org_id/project_id, unlike
-- 001-006, so tenant-scoped policies don't apply here):
--   events    — service_role: full access (the only writer, via telemetry-ship.sh's
--               service key). authenticated: read-only (the ops console dashboard).
--   approvals — service_role: full access. authenticated: can read every row and can
--               update only the status/decided_at/decided_by columns — enforced with a
--               column-level GRANT alongside the row-level policy, since RLS alone only
--               gates rows, not columns, and the console must not let a viewer edit
--               action/affects/reversible after the fact.

create table if not exists events (
  id            bigserial primary key,
  ts            timestamptz not null default now(),
  kind          text not null check (kind in ('tool', 'dispatch', 'jev', 'lifecycle')),
  repo          text,
  venture       text,
  session_id    text,
  tool_use_id   text,
  role          text,
  model         text,
  cost_usd      numeric,
  payload       jsonb not null,
  dedupe_key    text not null,
  received_at   timestamptz default now()
);

create unique index if not exists events_dedupe_key_idx on events (dedupe_key);
create index if not exists events_ts_idx on events (ts desc);
create index if not exists events_kind_ts_idx on events (kind, ts);
create index if not exists events_tool_use_id_idx on events (tool_use_id);
create index if not exists events_role_ts_idx on events (role, ts);

alter table events enable row level security;

do $$ begin
  if not exists (
    select 1 from pg_policies where tablename = 'events' and policyname = 'authenticated_read_events'
  ) then
    execute 'create policy authenticated_read_events on events for select
      to authenticated using (true)';
  end if;
end $$;

do $$ begin
  if not exists (
    select 1 from pg_policies where tablename = 'events' and policyname = 'service_all_events'
  ) then
    execute 'create policy service_all_events on events for all
      using (current_setting(''role'', true) = ''service_role'')
      with check (current_setting(''role'', true) = ''service_role'')';
  end if;
end $$;

create table if not exists approvals (
  id            uuid primary key default gen_random_uuid(),
  created_at    timestamptz default now(),
  action        text not null,
  affects       text,
  reversible    boolean,
  status        text check (status in ('pending', 'approved', 'rejected')) not null default 'pending',
  requested_by  text,
  source_run    text,
  decided_at    timestamptz,
  decided_by    text,
  note          text
);

create index if not exists approvals_status_idx on approvals (status, created_at);

alter table approvals enable row level security;

do $$ begin
  if not exists (
    select 1 from pg_policies where tablename = 'approvals' and policyname = 'authenticated_read_approvals'
  ) then
    execute 'create policy authenticated_read_approvals on approvals for select
      to authenticated using (true)';
  end if;
end $$;

do $$ begin
  if not exists (
    select 1 from pg_policies where tablename = 'approvals' and policyname = 'authenticated_update_approvals'
  ) then
    execute 'create policy authenticated_update_approvals on approvals for update
      to authenticated using (true) with check (true)';
  end if;
end $$;

do $$ begin
  if not exists (
    select 1 from pg_policies where tablename = 'approvals' and policyname = 'service_all_approvals'
  ) then
    execute 'create policy service_all_approvals on approvals for all
      using (current_setting(''role'', true) = ''service_role'')
      with check (current_setting(''role'', true) = ''service_role'')';
  end if;
end $$;

-- RLS grants "update" the row; it does not restrict which columns a role may write.
-- Without this, authenticated_update_approvals lets a viewer rewrite action/affects too.
revoke update on approvals from authenticated;
grant update (status, decided_at, decided_by) on approvals to authenticated;
