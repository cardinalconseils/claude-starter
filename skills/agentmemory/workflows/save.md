# Save a decision or a lesson

Write at the moment of resolution, not at the end of the session. The hooks own the
end-of-session summary; a manual recap duplicates it and arrives without the reasons.

## Decision or gotcha → `memory_save`

```json
memory_save {
  "content": "Chose cursor pagination over offset; offset scans broke past 100k rows in db/list.ts.",
  "concepts": "cursor-pagination, offset-scan-limit",
  "files": "src/db/list.ts",
  "project": "<repo basename>"
}
```

| Field | Shape | Rule |
|---|---|---|
| `content` | one or two sentences | The decision **and** the reason. A conclusion without its reason is not worth storing. |
| `concepts` | comma-separated string, 2–5 items, lowercased | Specific beats generic — `cursor-pagination` retrieves, `database` does not. |
| `files` | comma-separated string of real repo-relative paths | Paths that exist. Empty when the decision names none; never guessed. |
| `project` | repo basename | The same value the recall side uses, so a sibling checkout never matches. |

To correct a stored fact, save the corrected version outright — near-duplicate content
supersedes the old record instead of forking a variant.

## Correction → `memory_lesson_save`

A correction to the approach is a lesson, not a memory. Lessons carry confidence, strengthen
when the same content is saved again, and resurface before similar work.

```json
memory_lesson_save {
  "content": "Run the integration suite with the seeded fixture; the bare command starts an empty DB and every case false-passes.",
  "context": "any run of the integration suite in this repo",
  "confidence": 0.7,
  "project": "<repo basename>"
}
```

| Field | Rule |
|---|---|
| `content` | One imperative rule plus the consequence that makes it matter. Not the incident story. |
| `context` | The trigger situation — the moment a future session should apply it. |
| `confidence` | `0.7` for a direct correction from the owner; `0.5` for a pattern noticed without being told. |
| `project` | Set for a repo-specific rule; omit for a universal one. |

A repeat correction reuses the **exact** prior `content`, which strengthens the existing
lesson rather than forking a near-duplicate.

## Never save

Secrets or credentials in any form — keys, tokens, connection strings, `.env` contents
(`.claude/rules/secrets.md`). Anything readable from the repo. Transient state: branch names,
in-flight diffs, todo lists. Narration of what was done, which the hooks already captured.

## Relationship to the wiki

A decision the workforce should keep also belongs in the OKF wiki, written by `cks:historian`
with its frontmatter. The wiki entry is the source of truth; the agentmemory record is the
project-scoped echo of it. When the backend is absent the wiki entry is still written — the
save is what is skipped, never the durable record.

## Checklist

- [ ] Saved at the moment the decision settled, not in an end-of-session batch
- [ ] `content` carries the reason, not only the conclusion
- [ ] `concepts` are 2–5 specific lowercased phrases
- [ ] `files` are real paths, or empty
- [ ] Corrections went to `memory_lesson_save`, with `context` and a confidence
- [ ] No secret, no repo-readable fact, no transient state entered memory
- [ ] The wiki entry, where one is owed, was written regardless of the backend
