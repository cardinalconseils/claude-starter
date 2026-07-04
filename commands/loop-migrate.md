---
description: "Validate .loops/**/*.jsonl schema_version:1 compliance; report non-compliant entries"
allowed-tools:
  - Read
  - Bash
---

# /cks:loop-migrate — Schema Compliance Validator

Scan `.loops/**/*.jsonl` files for `schema_version:1` compliance and report non-compliant entries.

```bash
# Scan all .loops/ JSONL files for missing schema_version
find .loops -name "*.jsonl" 2>/dev/null | while read f; do
  total=$(wc -l < "$f" 2>/dev/null || echo 0)
  bad=$(grep -cv '"schema_version":1' "$f" 2>/dev/null || echo 0)
  echo "FILE: $f  total=$total  non-compliant=$bad"
done
```

Parse optional slug from `$ARGUMENTS` to scope to one loop. If no slug, scan all.

## Quick Reference

```
/cks:loop-migrate           Validate all loops
/cks:loop-migrate <slug>    Validate one loop
```

Reports non-compliant entry counts per file. Does not auto-fix — data integrity requires user confirmation.
