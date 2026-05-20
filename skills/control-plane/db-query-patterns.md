# CKS v6 DB Query Patterns

## Critical: Session Settings Before Every Query

All RLS policies use `current_setting('app.org_id', true)` and `current_setting('app.agent_id', true)`.

**Do NOT use `SET LOCAL`** — in Supabase's autocommit environment (including the MCP `execute_sql` tool), `SET LOCAL` evaporates between calls. Use `set_config()` inline instead.

### Correct pattern: CTE form

```sql
with _ as (
  select
    set_config('app.org_id',   'cardinal-conseils',  true),
    set_config('app.agent_id', 'heartbeat-agent-1',  true)
)
update heartbeats
set last_beat = now(), status = 'alive'
where agent_id = 'heartbeat-agent-1';
```

The CTE runs first, setting both config values before the main query executes. This is safe for all query types (SELECT, INSERT, UPDATE).

### Inline form (single setting only — use with caution)

```sql
select * from heartbeats
where org_id = set_config('app.org_id', 'cardinal-conseils', true);
```

**Warning:** The inline form only sets `app.org_id`. For queries where RLS checks both `app.org_id` AND `app.agent_id`, always use the CTE form — the inline form will silently leave `app.agent_id` unset, causing those policies to evaluate false and return 0 rows with no error.

### Failure mode

Forgetting to call `set_config()` causes `current_setting()` to return `null`, which makes ALL RLS `USING` clauses evaluate false. Queries return 0 rows silently — not an error, which makes this failure mode hard to detect.

## Heartbeat: Register Agent

```sql
with _ as (
  select
    set_config('app.org_id',   $org_id,   true),
    set_config('app.agent_id', $agent_id, true)
)
insert into heartbeats (agent_id, org_id, status, last_beat, state)
values ($agent_id, $org_id, 'alive', now(), $initial_state::jsonb)
on conflict (agent_id, org_id) do update
  set status = 'alive', last_beat = now(), state = excluded.state;
```

## Heartbeat: Beat (each cycle)

```sql
with _ as (
  select
    set_config('app.org_id',   $org_id,   true),
    set_config('app.agent_id', $agent_id, true)
)
update heartbeats
set last_beat = now(), status = 'alive', state = $new_state::jsonb
where agent_id = $agent_id and org_id = $org_id;
```

## Heartbeat: Read Own State (on wake)

```sql
with _ as (
  select
    set_config('app.org_id',   $org_id,   true),
    set_config('app.agent_id', $agent_id, true)
)
select state, last_beat, status
from heartbeats
where agent_id = $agent_id and org_id = $org_id;
```

## Heartbeat: Self-Orphan Detection

```sql
with _ as (
  select
    set_config('app.org_id',   $org_id,   true),
    set_config('app.agent_id', $agent_id, true)
),
current_state as (
  select last_beat, status, state
  from heartbeats
  where agent_id = $agent_id and org_id = $org_id
)
select
  last_beat,
  status,
  state,
  extract(epoch from (now() - last_beat)) / $interval_seconds as cycles_missed
from current_state;
-- If cycles_missed >= orphan_threshold_cycles → mark orphaned and log
```

## RAID Log: Append New Item

```sql
with _ as (
  select set_config('app.org_id', $org_id, true)
)
insert into raid_log (org_id, project_id, type, title, severity, owner, mitigation)
values ($org_id, $project_id, $type, $title, $severity, $owner, $mitigation);
```

## RAID Log: Query Open Items (project-scoped)

```sql
with _ as (
  select set_config('app.org_id', $org_id, true)
)
select type, title, severity, owner, mitigation
from raid_log
where status = 'open' and project_id = $project_id
order by severity desc, opened_at;
```

## RAID Log: Resolve an Item

```sql
with _ as (
  select set_config('app.org_id', $org_id, true)
)
update raid_log
set status = 'resolved', resolution = $resolution, closed_at = now()
where id = $item_id and org_id = $org_id;
```
