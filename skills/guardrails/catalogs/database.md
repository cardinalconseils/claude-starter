# Database Guardrail Catalog

## Trigger

Generated when bootstrap detects `has_database: true` (ORM or DB client found in scan).

## Template

Write the following to `.claude/rules/database.md`, replacing placeholders with detected values.

```markdown
---
globs:
  - "**/db/**"
  - "**/database/**"
  - "**/migrations/**"
  - "**/prisma/**"
  - "**/drizzle/**"
  - "**/supabase/**"
  - "**/models/**"
  - "**/schema/**"
  - "**/seeds/**"
---

# Database Rules

## Migrations

- Every schema change must be a migration — never modify the database directly
- Migrations must be reversible — include both `up` and `down` (or equivalent rollback)
- Run `{MIGRATION_COMMAND}` (default: the project's migration tool) to apply changes
- Never edit a migration that has already been applied to shared environments
- Test migrations against a copy of production data before deploying

## Queries

- All queries must use {DB_CLIENT} (default: the project's ORM/query builder) — no raw SQL unless performance-critical
- Raw SQL, when needed, must use parameterized queries — never string interpolation
- All queries that return lists must have a LIMIT — no unbounded selects
- Use transactions for multi-step operations that must succeed or fail together

## Schema Design

- Every table must have a primary key
- Use foreign keys to enforce relationships — never rely on application-level checks alone
- Add indexes for columns used in WHERE, JOIN, and ORDER BY clauses
- Timestamp columns (created_at, updated_at) on every table that stores user data
- Use soft deletes (deleted_at) for user-facing data — hard deletes only for truly ephemeral records

## Row Level Security (RLS)

- If using Supabase or Postgres RLS: every user-facing table must have RLS policies enabled
- Never bypass RLS in application code without explicit documentation explaining why
- Test RLS policies — verify that users cannot access other users' rows
- Service-role keys that bypass RLS must only be used in server-side code, never exposed to clients

## Data Safety

- Never drop tables or columns in a single migration — deprecate first, then remove after confirming no reads
- Back up before destructive migrations (column drops, type changes)
- Seed data must be idempotent — running seeds twice must not create duplicates
- Never store passwords in plaintext — use bcrypt, argon2, or scrypt with appropriate cost factors
```

## Customization Notes

- If `db_client` is "prisma": adjust globs to include `"**/prisma/**"`, set migration command to `npx prisma migrate dev`, add: "Run `npx prisma generate` after schema changes" and "Use `@default(cuid())` or `@default(uuid())` for IDs"
- If `db_client` is "drizzle": adjust globs to include `"**/drizzle/**"`, set migration command to `npx drizzle-kit push` or `migrate`, add: "Schema lives in TypeScript — keep schema files in a dedicated directory"
- If `db_client` is "supabase": add full RLS section emphasis, set migration command to `supabase db push` or `supabase migration up`, add: "Use Supabase client with `anon` key on client side — never `service_role` key"
- If `db_client` is "mongoose": adjust globs to include `"**/models/**"`, remove RLS section (MongoDB), add: "Use Mongoose schema validation — define types, required fields, and defaults"
- If `db_client` is "sqlalchemy": adjust globs to include `"**/alembic/**"`, `"**/models/**"`, set migration command to `alembic upgrade head`
- If `db_client` is "knex": set migration command to `npx knex migrate:latest`
