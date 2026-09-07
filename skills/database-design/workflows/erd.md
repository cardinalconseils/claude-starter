# Workflow: ERD — Mermaid entity-relationship diagram from a live Supabase schema

Generate `.db/erd.md` from the project's schema. Prefer Supabase + pgvector for AI
features (`SKILL.md` "Database Type Selection") — an ERD for a vector store is still a
Postgres ERD.

## 1. Project

`project_ref` not in the brief → `mcp__claude_ai_Supabase__list_projects` when granted,
else ask via `AskUserQuestion`; roles without `list_projects` ask.

## 2. Schema

`mcp__claude_ai_Supabase__list_tables` (schema `public`) returns tables, columns, types,
primary keys, and foreign-key relationships — enough for the diagram. Roles holding
`execute_sql` may instead run the `information_schema` queries below; roles without it
never try to work around the missing grant.

Columns and PKs:
```sql
SELECT t.table_name, c.column_name, c.data_type, c.is_nullable, c.column_default,
  CASE WHEN pk.column_name IS NOT NULL THEN 'PK' ELSE '' END AS pk_flag
FROM information_schema.tables t
JOIN information_schema.columns c ON t.table_name = c.table_name
LEFT JOIN (SELECT ku.table_name, ku.column_name
  FROM information_schema.table_constraints tc
  JOIN information_schema.key_column_usage ku ON tc.constraint_name = ku.constraint_name
  WHERE tc.constraint_type = 'PRIMARY KEY' AND tc.table_schema = 'public') pk
  ON c.table_name = pk.table_name AND c.column_name = pk.column_name
WHERE t.table_schema = 'public' AND t.table_type = 'BASE TABLE'
ORDER BY t.table_name, c.ordinal_position;
```

Foreign keys:
```sql
SELECT tc.table_name AS from_table, kcu.column_name AS from_column,
  ccu.table_name AS to_table, ccu.column_name AS to_column
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage ccu ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY' AND tc.table_schema = 'public';
```

## 3. Mermaid

```
erDiagram
    USERS { uuid id PK  text email  timestamptz created_at }
    POSTS { uuid id PK  uuid user_id FK  text title }
    USERS ||--o{ POSTS : "has"
```

Relationships: one-to-many `||--o{` · many-to-many `}o--o{` via join table · one-to-one
`||--||` · optional FK `o|--o{`. Type map: `uuid`→`uuid`; `text`/`varchar`→`string`;
`integer`/`bigint`→`int`; `boolean`→`boolean`; `timestamptz`→`datetime`; `jsonb`→`json`;
`numeric`→`decimal`; `vector(n)`→`vector`.

Readability: drop `created_at`/`updated_at` above 8 columns; above 15 columns show PK,
FK, and key business columns only.

## 4. Render

A Mermaid render tool (e.g. `validate_and_render_mermaid_diagram`) when granted, else
`npx -y @mermaid-js/mermaid-cli`; a failed render still saves the raw source.

## 5. Output `.db/erd.md`

```markdown
# Database ERD
Generated: {date} · Project: {name} ({ref}) · Tables: {n} · Relationships: {n}

## Diagram
{rendered image or the Mermaid block}

## Raw Mermaid
```mermaid
{source}
```

## Table Summary
| Table | Columns | Rows (est.) | RLS | Role Mapping |
|-------|---------|-------------|-----|--------------|
```

RLS status is decision-relevant — always include it. When `PERMISSIONS-MATRIX.md` exists
or `project_type: multi-role-saas` is set, make roles first-class: call out `role`
columns, render `user_roles` / `role_permissions` as entities, fill Role Mapping from the
matrix (`skills/saas-dashboard-sequence/references/permissions-matrix-template.md`).
