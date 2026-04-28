---
description: "Database operations — investigate schema/RLS, fix issues, debug errors, generate ERD"
argument-hint: "[investigate | fix | debug | erd] [--project <ref>]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:db — Database Operations

Parse the sub-command and dispatch the appropriate agent.

## Routing

| Invocation | Agent |
|------------|-------|
| `/cks:db investigate` | db-investigator — full schema + RLS audit |
| `/cks:db fix` | db-fixer — propose and apply fixes |
| `/cks:db debug` | db-debugger — trace errors, slow queries, RLS failures |
| `/cks:db erd` | db-erd — generate Mermaid ERD from live schema |
| `/cks:db` (no args) | Ask user which mode |

## Dispatch

Parse `$ARGUMENTS` for sub-command (`investigate` / `fix` / `debug` / `erd`) and optional `--project <ref>`.

If no sub-command, use `AskUserQuestion`:
```
What would you like to do with the database?
Options: ["Investigate (schema + RLS audit)", "Fix (propose + apply fixes)", "Debug (trace errors/slow queries)", "ERD (generate diagram)"]
```

Then dispatch:
```
Agent(subagent_type="cks:db-investigator", ...)
Agent(subagent_type="cks:db-fixer", ...)
Agent(subagent_type="cks:db-debugger", ...)
Agent(subagent_type="cks:db-erd", ...)
```

Pass `project_ref` from `--project` flag if provided, otherwise agents will discover or ask.

## Quick Reference

```
/cks:db investigate                    → Full schema + RLS audit
/cks:db investigate --project abc123   → Audit specific Supabase project
/cks:db fix                            → Propose + apply schema/RLS fixes
/cks:db debug                          → Trace DB errors and slow queries
/cks:db erd                            → Generate Mermaid ERD from schema
```
