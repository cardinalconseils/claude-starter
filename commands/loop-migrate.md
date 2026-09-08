---
description: "Validate .loops/**/*.jsonl schema_version:1 compliance; report non-compliant entries"
argument-hint: "[slug] [--fix]"
allowed-tools:
  - Read
  - Skill
---

# /cks:loop-migrate — Schema Compliance Validator

Scan `.loops/**/*.jsonl` for `schema_version:1` compliance and report non-compliant
entries. Same path as `/cks:loop migrate`.

## Dispatch

```
Skill(skill="cks:loop")
```

sub-command: `migrate` · slug: `{slug from $ARGUMENTS, or empty for all loops}` · args:
`{--fix if present}`.

The report runs inline in the skill's `SKILL-ORCHESTRATOR.md` (`workflows/migrate.md`).
`--fix` dispatches `cks:operator`, which confirms per file before rewriting any line.

## Quick Reference

```
/cks:loop-migrate           Validate all loops
/cks:loop-migrate <slug>    Validate one loop
/cks:loop-migrate <slug> --fix   Rewrite non-compliant lines (asks per file)
```

Reports non-compliant entry counts per file. Never auto-fixes — data integrity requires
user confirmation.
