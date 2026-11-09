-- 007_ops_console.sql — Ops Console Phase 1: telemetry sink + approvals queue
-- Safe to re-run: tables/indexes use IF NOT EXISTS / DO $$ guards; the three
-- authenticated-role policies use drop-if-exists + create so a re-run always
-- lands the current definition, even over a deployment that still has an older
-- (e.g. `using (true)`) version of the same policy name.
-- Run after 006_health_log.sql
--
-- RLS choices (kept minimal — neither table carries org_id/project_id, unlike
-- 001-006, so tenant-scoped policies don't apply here):
--   ops_admins — allowlist of console operators. RLS enabled, no authenticated policies
--               at all: only service_role can read or write it, so signing up for
--               Supabase Auth (public email signups are on by default) grants nothing.
--               A user is an admin only once the service role inserts their auth.users
--               id here. Membership is checked via the is_ops_admin() security-definer
--               function below, not a direct authenticated select — see its comment.
--   events    — service_role: full access (the only writer, via telemetry-ship.sh's
--               service key). authenticated: read-only, gated on is_ops_admin()
--               — an authenticated user who isn't an admin sees zero rows.
--   approvals — service_role: full access. authenticated: can read and can update only
--               the status/decided_at/decided_by columns, both gated on is_ops_admin().
--               The column-level GRANT stops even an admin from rewriting
--               action/affects/reversible after the fact; the is_ops_admin() check on top
--               of it stops a merely-signed-up user from approving anything at all.
--   Belt-and-braces: authenticated has insert/delete revoked on both tables outright —
--   RLS gates rows, the grants remove the write paths RLS doesn't need to touch.

create table if not exists ops_admins (
  user_id     uuid primary key references auth.users(id) on delete cascade,
  created_at  timestamptz default now()
);

alter table ops_admins enable row level security;
-- No authenticated policies on purpose — service_role bypasses RLS by default, so this
-- table has no policy that grants anyone else access. Membership is service-role-only.

-- security definer, owned by the migration role (table owner of ops_admins): RLS on a
-- referenced table is enforced for the CALLING role even inside another table's policy,
-- so a raw `exists (select ... from ops_admins ...)` evaluated as `authenticated` would
-- always read zero rows and every admin check would fail-closed for real admins too.
-- Running as the owner (who bypasses RLS on ops_admins) makes the lookup actually see
-- the row while still never exposing ops_admins itself to authenticated directly.
create or replace function is_ops_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (select 1 from ops_admins where user_id = auth.uid())
$$;

revoke all on function is_ops_admin() from public;
grant execute on function is_ops_admin() to authenticated;

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

-- Dropped and recreated unconditionally: an existing deployment may still carry the
-- old `using (true)` definition, which "if not exists" would leave in place.
drop policy if exists authenticated_read_events on events;
create policy authenticated_read_events on events for select
  to authenticated using ( is_ops_admin() );

do $$ begin
  if not exists (
    select 1 from pg_policies where tablename = 'events' and policyname = 'service_all_events'
  ) then
    execute 'create policy service_all_events on events for all
      using (current_setting(''role'', true) = ''service_role'')
      with check (current_setting(''role'', true) = ''service_role'')';
  end if;
end $$;

revoke insert, update, delete on events from authenticated;

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

-- Dropped and recreated unconditionally: an existing deployment may still carry the
-- old `using (true)` definition, which "if not exists" would leave in place.
drop policy if exists authenticated_read_approvals on approvals;
create policy authenticated_read_approvals on approvals for select
  to authenticated using ( is_ops_admin() );

drop policy if exists authenticated_update_approvals on approvals;
create policy authenticated_update_approvals on approvals for update
  to authenticated using ( is_ops_admin() )
  with check ( is_ops_admin() );

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
-- Without this, authenticated_update_approvals lets an admin rewrite action/affects too.
revoke update on approvals from authenticated;
grant update (status, decided_at, decided_by) on approvals to authenticated;
revoke insert, delete on approvals from authenticated;
