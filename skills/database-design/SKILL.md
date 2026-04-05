---
name: database-design
description: "Database schema design, migration discipline, and data modeling for production applications. Use when: designing database tables, creating migrations, choosing between SQL and NoSQL, adding indexes, defining relationships, or reviewing data architecture."
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# Database Design

## Overview

Domain expertise for designing database schemas, writing migrations, modeling relationships, indexing for performance, and maintaining data integrity. Covers relational design principles, naming conventions, ORM patterns, and backup strategy.

## When to Use

- Designing new database tables or modifying existing schemas
- Creating or reviewing migration files
- Choosing between SQL and NoSQL for a use case
- Adding indexes for query performance
- Defining relationships (one-to-one, one-to-many, many-to-many)
- Reviewing data architecture or normalization

## When NOT to Use

- Application-level caching strategy (Redis, Memcached)
- Database infrastructure provisioning (RDS, Cloud SQL setup)
- Data analytics or warehouse design (OLAP patterns)

## Process

### Schema Design Principles

- Every table gets: `id` (primary key), `created_at`, `updated_at`
- Use appropriate types: `uuid` for IDs, `timestamptz` for dates, `text` over `varchar` (Postgres)
- Apply constraints at the DB level: `NOT NULL`, `UNIQUE`, `CHECK`, `DEFAULT`
- The database is the last line of defense -- never rely solely on app-level validation

### Relationships

| Type | Implementation | Example |
|------|---------------|---------|
| One-to-one | Foreign key + UNIQUE constraint | user -> profile |
| One-to-many | Foreign key on the "many" side | user -> posts |
| Many-to-many | Junction table with two foreign keys | users <-> roles via user_roles |

- Junction tables: name as `{table_a}_{table_b}` in alphabetical order
- Always add foreign key constraints with `ON DELETE` behavior (CASCADE, SET NULL, or RESTRICT)

### Normalization

- **Eliminate duplication**: if the same data appears in multiple rows, extract to a related table
- **Denormalize intentionally**: for read-heavy queries where joins are expensive, duplicate data with clear ownership
- Every denormalization must have a documented justification and a sync strategy

### Indexing

- **Always index**: foreign keys, columns in `WHERE` clauses, columns in `ORDER BY`
- **Composite indexes**: column order matters -- put high-selectivity columns first
- **Don't over-index**: each index slows writes. Index what queries need, not everything.
- **Partial indexes**: for filtered queries (`WHERE status = 'active'`)
- Monitor slow queries and add indexes based on actual query patterns

### Migration Discipline

- Always write both **UP and DOWN** migrations
- Never modify a deployed migration -- create a new migration instead
- One migration per logical change (don't bundle unrelated schema changes)
- Test migrations against a copy of production data before deploying
- Name migrations descriptively: `20240115_add_role_to_users` not `migration_042`

### ORM Patterns

- Use the ORM's migration system (Prisma Migrate, Alembic, ActiveRecord Migrations)
- Watch for N+1 queries: use eager loading (`include`, `joinedload`, `includes`)
- Use raw SQL for complex reporting queries -- ORMs optimize for CRUD, not analytics
- Always review generated SQL in development (`DEBUG=knex:query`, `PRISMA_LOG=query`)

### Naming Conventions

- Tables: `snake_case`, **singular** (`user`, `order_item`)
- Columns: `snake_case` (`created_at`, `first_name`)
- Foreign keys: `{referenced_table}_id` (`user_id`, `order_id`)
- Indexes: `idx_{table}_{columns}` (`idx_user_email`)
- Constraints: `chk_{table}_{rule}`, `uq_{table}_{columns}`

### Backup Strategy

- Automated daily backups with point-in-time recovery
- Test restoration process quarterly -- untested backups are not backups
- Keep backups in a different region than production
- Document recovery runbook with estimated RTO/RPO

## Common Rationalizations

| Rationalization | Reality |
|----------------|---------|
| "We'll restructure the DB later" | Schema changes after launch require data migrations on live data. Get it close to right now. |
| "We don't need indexes yet" | Missing indexes cause 100x slower queries as data grows. Add them when creating tables. |
| "The ORM handles everything" | ORMs generate SQL. Understand what SQL they generate, especially for N+1 queries. |
| "We can skip down migrations" | Down migrations are your rollback plan. Skipping them means you cannot undo a bad deploy. |
| "NoSQL is always faster" | NoSQL trades query flexibility for write speed. If you need joins, use a relational database. |

## Red Flags

- Tables without primary keys or timestamps
- Missing foreign key constraints (relying on app logic for referential integrity)
- No indexes on foreign key columns
- Deployed migrations that have been edited after running
- Multiple unrelated changes in a single migration
- `SELECT *` in application queries
- No `ON DELETE` behavior specified on foreign keys
- String columns used for dates, booleans, or enums

## Verification

- [ ] Every table has `id`, `created_at`, `updated_at`
- [ ] All foreign keys have explicit `ON DELETE` behavior
- [ ] Foreign key columns are indexed
- [ ] Columns in frequent `WHERE`/`ORDER BY` clauses are indexed
- [ ] All migrations have both UP and DOWN
- [ ] No deployed migration has been modified
- [ ] N+1 queries identified and resolved with eager loading
- [ ] Constraints (NOT NULL, UNIQUE, CHECK) applied at DB level
- [ ] Naming follows convention (snake_case, singular tables, _id suffix)
- [ ] Backup and restoration process documented and tested
