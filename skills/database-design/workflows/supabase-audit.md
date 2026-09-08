# Workflow: Supabase Audit

Deep, read-only audit of a Supabase project — schema, RLS, migrations, extensions, advisors.
Ported from the `db-investigator` agent. Run by the reviewer role (DB audit mode) with
`list_tables` and `get_advisors`; the SQL below needs `execute_sql`, which the debugger role
holds — when the reviewer lacks it, report the gaps it can see and return to the chief of
staff for a debugger dispatch on the remaining queries.

## Project discovery

If `project_ref` is not provided: `list_projects`, then confirm the target with
`AskUserQuestion` (roles without that tool narrate the question instead).

## Steps

### 1. Schema

`list_tables`, then per-table columns and constraints:

```sql
SELECT c.table_name, c.column_name, c.data_type, c.is_nullable, c.column_default,
       tc.constraint_type
FROM information_schema.columns c
LEFT JOIN information_schema.key_column_usage kcu
  ON c.table_name = kcu.table_name AND c.column_name = kcu.column_name
LEFT JOIN information_schema.table_constraints tc
  ON kcu.constraint_name = tc.constraint_name
WHERE c.table_schema = 'public'
ORDER BY c.table_name, c.ordinal_position;
```

Foreign keys:

```sql
SELECT tc.table_name, kcu.column_name,
       ccu.table_name AS foreign_table, ccu.column_name AS foreign_column
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage ccu ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY' AND tc.table_schema = 'public';
```

### 2. RLS

```sql
SELECT schemaname, tablename, rowsecurity AS rls_enabled, forcerowsecurity AS rls_forced
FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename;
```

```sql
SELECT schemaname, tablename, policyname, permissive, roles, cmd AS operation,
       qual AS using_expression, with_check
FROM pg_policies WHERE schemaname = 'public' ORDER BY tablename, policyname;
```

Every table with `rls_enabled = false` is a **security gap**. Flag it.

### 3. Migrations

`list_migrations` — applied vs pending. Flag pending migrations.

### 4. Extensions

`list_extensions` — flag unusual or risky ones.

### 5. Advisors

`get_advisors` — categorize ERROR / WARN / INFO. ERROR-level items go at the top of the report.

### 6. Row counts (estimates)

```sql
SELECT relname AS table_name, n_live_tup AS estimated_rows
FROM pg_stat_user_tables WHERE schemaname = 'public' ORDER BY n_live_tup DESC;
```

`pg_stat` may lag — say "estimated" in the report.

## Output format

```
Database Investigation Report
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Project:  {project_name} ({project_ref})
Tables:   {count} total | {count} with RLS | {count} WITHOUT RLS ⚠
Policies: {count} total across {count} tables
Pending migrations: {count}

SCHEMA
──────
{table_name} ({row_count} rows, estimated)
  Columns: {col_name} {type} [{PK|FK→table.col|NOT NULL}] ...
  RLS: {✅ enabled | ❌ DISABLED}
  Policies: {count} ({SELECT|INSERT|UPDATE|DELETE} per role)

RLS GAPS ⚠
──────────
  ❌ {table_name} — no RLS, publicly accessible

ADVISORS
────────
  ERROR   {advisor message}
  WARN    {advisor message}
  INFO    {advisor message}

MIGRATIONS
──────────
  Applied: {count}   Pending: {count}   Latest: {migration_name} ({date})
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

The report is returned to the caller. A role with write scope over `.db/` (the debugger, in
db-fix mode) saves it to `.db/investigation.md` so `skills/database-recovery/workflows/fix.md`
can reuse it without re-auditing.

## Rules

1. Never execute destructive SQL — SELECT and system-catalog queries only
2. Always flag tables without RLS as security risks
3. ERROR-level advisors are highlighted first
4. Row counts are estimates — say so
