# Workflow: Database Fix

Propose and apply fixes for RLS gaps, missing policies, schema problems, and advisor warnings.
Ported from the `db-fixer` agent. Run by the debugger role (db-fix mode). Every change is
shown as SQL and confirmed before it runs.

## Inputs

Read `.db/investigation.md` if it exists (written after
`skills/database-design/workflows/supabase-audit.md`). Otherwise run that audit inline first
with `list_tables`, `execute_sql`, and the advisor query.

## Fix categories

### 1. RLS gaps

For every table without RLS:

```sql
ALTER TABLE public.{table_name} ENABLE ROW LEVEL SECURITY;
```

Then ask which access pattern applies (`AskUserQuestion`):
- Owner-only (users see their own rows)
- Authenticated users read, owner write
- Public read, authenticated write
- Admin only (`service_role`)
- Custom — describe it

Owner-only policy set:

```sql
CREATE POLICY "{table_name}_owner_select" ON public.{table_name} FOR SELECT
  USING (auth.uid() = user_id);
CREATE POLICY "{table_name}_owner_insert" ON public.{table_name} FOR INSERT
  WITH CHECK (auth.uid() = user_id);
CREATE POLICY "{table_name}_owner_update" ON public.{table_name} FOR UPDATE
  USING (auth.uid() = user_id);
CREATE POLICY "{table_name}_owner_delete" ON public.{table_name} FOR DELETE
  USING (auth.uid() = user_id);
```

### 2. Advisor warnings

For each ERROR/WARN from the advisors, generate the recommended fix SQL from the advisor
metadata.

### 3. Missing indexes

FK columns without indexes:

```sql
CREATE INDEX CONCURRENTLY idx_{table}_{column} ON public.{table}({column});
```

`CONCURRENTLY` avoids table locks on live databases.

## Confirmation before applying

Show the complete SQL for the batch and ask (`AskUserQuestion`): "Apply these {N} changes to
{project_name}?" — Apply all / Review each change individually / Cancel.

## Applying

Run the confirmed SQL with `execute_sql` as one statement per change. Migration-file work
(generating a numbered migration, rollback testing — `skills/migrations`) belongs to the
builder: return to the chief of staff with the SQL and ask for a builder dispatch when the
fix must land as a versioned migration rather than a live change.

## Post-fix verification

After an RLS fix, verify it holds with `execute_sql`:

1. **Cross-tenant check** (always) — run the query as a second test user/tenant and confirm
   the other tenant's rows are not returned (the leak test in
   `skills/database-design/SKILL.md`).
2. **Cross-role check** (when `project_type: multi-role-saas` in `.kickstart/state.md` or
   `.bootstrap/scan-context.md`) — run the query as a second, lower-privilege role and
   confirm the policy still denies appropriately.

Record both results in `.db/fixes-{date}.md` next to the applied SQL.

## Output format

```
Database Fix Plan
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Project: {project_name}

PROPOSED FIXES ({N} total)
──────────────────────────
[1] Enable RLS — {table_name}
    {sql}
[2] Add owner policy — {table_name}
    {sql}
[3] {advisor fix title}
    {sql}

SUMMARY
───────
  RLS gaps fixed:     {count}
  Policies added:     {count}
  Advisor fixes:      {count}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Safety rules

1. Never apply without explicit confirmation — always show SQL first
2. Never `DROP` or `TRUNCATE` — escalate if an advisor recommends it (`.claude/rules/destructive-ops.md`)
3. `CONCURRENTLY` for index creation on live databases
4. Any paid operation is gated — return `GATED:` rather than confirming cost yourself
5. Save applied fixes to `.db/fixes-{date}.md` for the audit trail
