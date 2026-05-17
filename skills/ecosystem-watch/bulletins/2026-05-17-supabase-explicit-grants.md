---
date: 2026-05-17
source: supabase-blog
title: Explicit Grants — New Default Starting May 30 2026
priority: HIGH
type: BREAKING_CHANGE
affects: [database-design, migrations, rls]
action_required: true
expires: 2026-09-01
---

## What Changed

Starting May 30 2026, new Supabase projects require explicit `GRANT` statements for tables to be accessible via the PostgREST Data API. Previously, tables in the `public` schema were auto-exposed. The two roles affected are `anon` (unauthenticated) and `authenticated` (JWT-verified users).

**Scope:** New projects created after May 30 2026. Existing projects are not migrated automatically but should adopt explicit grants as hygiene.

## Impact on Agents

For any Supabase project created after May 30 2026:

- **Always add a `002_grants.sql` migration file** after `001_schema.sql` — never rely on auto-exposure
- **Never use `GRANT ALL ON ALL TABLES IN SCHEMA public`** — grant per table explicitly
- **Grant `USAGE ON SEQUENCE`** when using `SERIAL`/`BIGSERIAL` or Supabase default int8 IDs — INSERT will fail without it
- **Do not grant INSERT/UPDATE/DELETE to `anon`** unless explicitly required (e.g. public form submissions)
- **n8n workflows using `anon` key** will fail on ungrated tables — check which key the Supabase credential uses

## Required Pattern Going Forward

Add this block after every `CREATE TABLE` in new projects:

```sql
-- Run after every CREATE TABLE in projects created after May 30 2026

GRANT USAGE ON SCHEMA public TO anon, authenticated;

-- Public read
GRANT SELECT ON TABLE public.your_table TO anon;

-- Authenticated read + write
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.your_table TO authenticated;

-- If using sequences (SERIAL / BIGSERIAL / default int8 IDs)
GRANT USAGE, SELECT ON SEQUENCE public.your_table_id_seq TO authenticated;
```

Migration file structure:
```
supabase/migrations/
  001_schema.sql    ← CREATE TABLE statements
  002_grants.sql    ← GRANT statements (new — required)
  003_rls.sql       ← RLS policies
```

Quick audit SQL to check existing grants:
```sql
SELECT grantee, table_schema, table_name, privilege_type
FROM information_schema.role_table_grants
WHERE table_schema = 'public'
ORDER BY table_name, grantee, privilege_type;
```

## Reference

Source: Supabase blog announcement, May 2026
