# Loop Events Schema — v1

**Format:** JSONL (newline-delimited JSON)
**Path pattern:** `.loops/{slug}/health.jsonl`
**Mode:** append-only — no edits, no deletes, no array wrappers

---

## Fields

| Field | Type | Required | Description |
|---|---|---|---|
| `schema_version` | int | **YES** | Always `1`. Reader MUST reject entries where this field is absent. |
| `loop_slug` | string | YES | Identifier for the loop (matches directory name under `.loops/`) |
| `run_id` | string (uuid) | YES | Unique ID for this execution. Used as LangSmith trace ID when configured. |
| `ts` | string (ISO 8601 UTC) | YES | Timestamp of run completion, e.g. `"2026-06-17T14:32:00Z"` |
| `outcome` | `"pass"` \| `"fail"` | YES | Result of the iteration. Fail captures: exceptions, stop-condition violations, task errors. |
| `summary` | string | YES | One-line human-readable description of what happened in this run. |
| `iteration` | int (1-based) | YES | Monotonically increasing counter for this loop's runs. Starts at 1. |

---

## Rules

- Every line MUST be a valid JSON object — no trailing commas, no array wrapper
- `schema_version` MUST be present on every line; **reader MUST reject** entries where it is absent or not the integer `1`
- File is append-only. Agents write new lines; they never overwrite or delete existing lines
- `run_id` MUST be a UUID v4 (e.g. generated via `uuidgen` or equivalent)
- `ts` MUST be UTC — never local time
- `iteration` MUST increment by 1 each run; gap in sequence indicates a missed or deleted run

---

## Example Entry

```json
{"schema_version":1,"loop_slug":"daily-digest","run_id":"f47ac10b-58cc-4372-a567-0e02b2c3d479","ts":"2026-06-17T14:32:00Z","outcome":"pass","summary":"Processed 12 new items, wrote 3 findings to output","iteration":42}
```

---

## Validation

When reading entries, agents MUST:

1. Parse each line as JSON
2. Reject (skip + log warning) any entry where `schema_version` is absent or not `1`
3. Reject any entry missing required fields (`loop_slug`, `run_id`, `ts`, `outcome`, `summary`, `iteration`)

Migration: see `/cks:loop migrate` — validates all existing entries and reports compliance.
