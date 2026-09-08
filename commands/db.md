---
description: "Database operations — investigate schema/RLS, fix issues, debug errors, generate ERD, or run the audit+fix pipeline"
argument-hint: "[investigate | fix | debug | erd | pipeline] [--project <ref>]"
allowed-tools:
  - Read
  - Agent
  - Skill
  - AskUserQuestion
---

# /cks:db — Database Operations

Parse `$ARGUMENTS` for the sub-command and optional `--project <ref>`. Pass
`project_ref` when given; otherwise the role discovers or asks.

## Routing

| Invocation | Dispatch |
|------------|----------|
| `/cks:db investigate` | `cks:reviewer` — full schema + RLS audit (`skills/database-design`) |
| `/cks:db fix` | `cks:debugger` — propose fixes, show SQL, apply only after confirmation |
| `/cks:db debug` | `cks:debugger` — trace errors, slow queries, RLS failures |
| `/cks:db erd` | `cks:architect` — Mermaid ERD from the live schema |
| `/cks:db pipeline` | `Skill(skill="cks:attractor")` with `pipeline: db` — Inspect → Diagnose → Gate → Fix → Verify |
| `/cks:db` (no args) | Ask which mode |

If no sub-command, use `AskUserQuestion`:
```
What would you like to do with the database?
Options: ["Investigate (schema + RLS audit)", "Fix (propose + apply fixes)", "Debug (trace errors/slow queries)", "ERD (generate diagram)", "Pipeline (audit + fix with approval gate)"]
```

## Dispatch

```
Agent(subagent_type="cks:reviewer",  prompt="Mode: db-investigate. Project ref: {ref or 'discover'}. Audit Supabase schema, RLS policies, migrations, security advisors. Report findings with table:policy references; do not change anything.")
Agent(subagent_type="cks:debugger",  prompt="Mode: db-fix. Project ref: {ref or 'discover'}. Diagnose RLS gaps, schema issues, advisor warnings; generate migration SQL; always show the SQL and ask before applying.")
Agent(subagent_type="cks:debugger",  prompt="Mode: db-debug. Project ref: {ref or 'discover'}. Trace Supabase errors, RLS failures, slow queries, edge-function DB issues to root cause.")
Agent(subagent_type="cks:architect", prompt="Mode: db-erd. Project ref: {ref or 'discover'}. Generate a Mermaid entity-relationship diagram from the live schema.")
```

`pipeline` is an Orchestrator Exception path (`.claude/rules/commands.md`): the attractor
engine runs `pipelines/db.dot` top-level — inline `db_inspect`, `cks:reviewer` Diagnose,
the `Gate` hexagon (`AskUserQuestion` on the SQL), `cks:debugger` Fix, inline `db_verify`.

## Quick Reference

```
/cks:db investigate                    → Full schema + RLS audit
/cks:db investigate --project abc123   → Audit specific Supabase project
/cks:db fix                            → Propose + apply schema/RLS fixes
/cks:db debug                          → Trace DB errors and slow queries
/cks:db erd                            → Generate Mermaid ERD from schema
/cks:db pipeline                       → Audit + fix pipeline with approval gate
```
