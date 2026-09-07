# Workflow: Database Debug

Trace Supabase problems — RLS denials, query errors, slow queries, edge-function database
failures, connection-pool exhaustion. Ported from the `db-debugger` agent. Run by the debugger
role (db-fix mode, diagnosis half) with `execute_sql` and `list_tables`.

## Triage

If no specific error is given, ask (`AskUserQuestion`): RLS blocking a query that should
work / Query returning unexpected results / Slow query or timeout / Edge function DB error /
Migration failure / I'll describe it.

## Modes

### 1. RLS failure tracing

```sql
SELECT policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies WHERE tablename = '{table}' AND schemaname = 'public';
```

Simulate the failing user inside one transaction:

```sql
SET LOCAL role TO authenticated;
SET LOCAL request.jwt.claims TO '{"sub": "{user_id}"}';
SELECT * FROM public.{table} LIMIT 5;
```

```sql
SELECT auth.uid(), auth.role(), current_user;
```

```sql
EXPLAIN (ANALYZE, VERBOSE) SELECT * FROM public.{table} WHERE {rls_using_expression};
```

Diagnose: policy missing for role, wrong column in USING, JWT claim not set, role not in
policy. Always check both USING and WITH CHECK.

### 2. Slow query analysis

```sql
SELECT pid, now() - pg_stat_activity.query_start AS duration, query, state
FROM pg_stat_activity
WHERE state != 'idle' AND query_start < now() - interval '5 seconds'
ORDER BY duration DESC;
```

```sql
SELECT schemaname, tablename, attname AS column_name, n_distinct, correlation
FROM pg_stats WHERE schemaname = 'public' AND tablename = '{table}' ORDER BY n_distinct;
```

```sql
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT) {user_provided_query};
```

Look for sequential scans on large tables, nested loops over many rows, missing FK indexes,
high buffer hits.

### 3. Error log tracing

Read recent Postgres errors (Supabase logs via the observer role when the debugger lacks a
logs grant — return to the chief of staff). Patterns:

- `new row violates row-level security policy` → RLS issue (mode 1)
- `column "{name}" does not exist` → schema mismatch, stale migration
- `permission denied` → role/grant issue
- `remaining connection slots are reserved` → pool exhaustion (mode 5)
- `deadlock detected` → concurrent write conflict

### 4. Edge-function DB errors

Edge-runtime logs → database stack traces; cross-reference PostgREST logs for the same
window.

### 5. Connection pool

```sql
SELECT datname, usename, application_name, client_addr, state, wait_event_type, wait_event,
       now() - state_change AS time_in_state
FROM pg_stat_activity WHERE datname = current_database()
ORDER BY time_in_state DESC NULLS LAST;
```

Flag idle connections never released and long transactions blocking others.

## Output format

```
Database Debug Report
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Project:  {project_name}
Issue:    {issue description}
Mode:     {RLS | Slow Query | Error Log | Edge Function | Connection Pool}

ROOT CAUSE
──────────
{diagnosis — specific, actionable}

EVIDENCE
────────
{query output or log excerpt}

FIX
───
{SQL or config change — apply via workflows/fix.md}

PREVENTION
──────────
{how to avoid recurrence}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Rules

1. `EXPLAIN ANALYZE` only on dev/staging — production needs user confirmation
2. Never `SET ROLE` permanently — `SET LOCAL` inside a transaction only
3. Save reports to `.db/debug-{date}.md`
