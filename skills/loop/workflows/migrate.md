# Loop Migrate Workflow

Validates `schema_version: 1` compliance of `.loops/**/health.jsonl`. The report side runs
inline in `SKILL-ORCHESTRATOR.md` §6 (or via `/cks:loop-migrate`); `--fix` is dispatched
to `cks:operator`, which confirms with the user before touching any line.

## Report

For each `.loops/{slug}/health.jsonl` (one slug, or all when no slug):

```bash
find .loops -name "*.jsonl" 2>/dev/null | while read f; do
  total=$(wc -l < "$f" 2>/dev/null || echo 0)
  bad=$(grep -cv '"schema_version":1' "$f" 2>/dev/null || echo 0)
  echo "FILE: $f  total=$total  non-compliant=$bad"
done
```

Then, per file:

```
Migration Validation: {slug}

Total entries: {n}
Compliant (schema_version: 1): {n}
Non-compliant (missing schema_version): {n}
```

All compliant → "All entries are schema_version: 1 compliant. No migration needed."

Otherwise:
```
Found {n} entries missing schema_version.
These entries will be rejected by readers following the v1 schema.
Run /cks:loop migrate --fix {slug} to rewrite them (asks before each file).
```

## Fix (`cks:operator`, `--fix`)

For each non-compliant file: show the affected line numbers, ask the user to confirm the
file, back it up to `{file}.bak-{date}`, then add `"schema_version":1` as the first key of
each non-compliant JSON line. Re-run the report afterwards. Never rewrite without the
per-file confirmation — data integrity requires the user's say.
