---
description: "Migrates .loops/**/*.jsonl files to schema_version:1 format. Validates existing entries and reports compliance."
allowed-tools:
  - Read
  - Agent
---

# /cks:loop migrate — Schema Migration

Validates `.loops/**/*.jsonl` entries for `schema_version:1` compliance.

```
Agent(
  subagent_type="cks:loop-orchestrator",
  prompt="sub-command: migrate, slug: {slug or empty for all}"
)
```

Parse optional slug from user input. Pass empty string to validate all loops.

## Quick Reference

```
/cks:loop migrate           Validate all loops
/cks:loop migrate <slug>    Validate one loop
```

Reports non-compliant entries. Does not auto-fix — data integrity requires user confirmation.
