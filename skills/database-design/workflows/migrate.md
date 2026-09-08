# Workflow: Schema Migration

Generate, validate, and rollback-test a database migration. Ported from the `db-migration`
agent. Run by the builder role when a PLAN.md or TDD.md task changes the data model, and at
Release [5c] to review pending migrations.

## 1. Detect the tool

| Tool | Detection | Command |
|---|---|---|
| Prisma | `prisma/schema.prisma` | `npx prisma migrate dev` |
| Drizzle | `drizzle.config.ts` | `npx drizzle-kit generate` |
| Knex | `knexfile.js` | `npx knex migrate:make` |
| TypeORM | `ormconfig.json` or `data-source.ts` | `npx typeorm migration:generate` |
| Django | `manage.py` | `python manage.py makemigrations` |
| Alembic | `alembic.ini` | `alembic revision --autogenerate` |
| Supabase | Supabase MCP | `supabase migration new` / `apply_migration` |
| Raw SQL | `migrations/` directory | numbered SQL file |

## 2. Generate

Write the UP and DOWN migration per `SKILL.md` "Migration Discipline": one logical change,
descriptive name (`20240115_add_role_to_users`), never edit a deployed migration.

## 3. Validate before applying

1. Parse the migration — list CREATE / ALTER / DROP operations
2. Destructive operations: `DROP TABLE` / `DROP COLUMN` → data loss; `ALTER COLUMN` type
   change → potential data loss; `RENAME` → breaking change for app code. Each needs the
   `⛔ DESTRUCTIVE ACTION` block (`.claude/rules/destructive-ops.md`) and an
   `AskUserQuestion`: Proceed / Add a data backup step / Cancel.
3. Performance risks: `ALTER TABLE` on a large table → lock time; new index on a large table
   → blocking (prefer `CONCURRENTLY`)
4. Confirm the rollback migration exists
5. Apply on the dev database only

## 4. Rollback test

```bash
{migrate_up_command}
{schema_check_command}      # schema matches expected
{migrate_down_command}
{schema_check_command}      # schema back to the previous state
```

## 5. Seed data

If seed files exist, regenerate them for the new schema and confirm they load after the
migration.

## 6. Supabase

`list_migrations` (applied vs pending), `list_tables` (current schema), `execute_sql`
(validation queries), `apply_migration` (apply). RLS on any new per-user table is part of the
migration, not a follow-up (`SKILL.md` "Row Level Security").

## Output

```
Migration: {migration_name}
  Tool: {detected tool}
  Operations:
    - CREATE TABLE {name} ({columns})
    - ALTER TABLE {name} ADD COLUMN {column}
  Risks:
    - {risk description} [WARN/BLOCK]
  Rollback: {tested/untested}
  Duration estimate: {time} (on {N} rows)
```

## Safety rules

1. Never `DROP` in production without explicit confirmation
2. Always generate the rollback migration
3. Test on dev before staging; production migrations are part of the gated deploy
4. Flag breaking changes that require app code changes
