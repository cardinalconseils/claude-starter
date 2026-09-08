# Workflow: Canary Verify — post-deploy check of one URL

Two paths, same verdict table (see `SKILL.md`). Which path a role can take depends on
its grants; say which one you ran.

## Browser path (roles holding the browser tools)

1. **URL** — from the brief; otherwise ask for it.
2. **Open** — get tab context, create a tab, navigate, wait ~3s for load.
3. **Console** — read console messages; keep ERROR entries, note WARN entries.
4. **Page text** — scan title and first `<h1>` for the failure keywords in `SKILL.md`.
5. **Read page** — visual sanity: content rendered, not blank or spinner-only.
6. **Verdict** — PASS / FAIL / PASS_WITH_WARNINGS per the criteria table.
7. **Result file** — when the role may write, save `.cks/canary-last.json` in the schema
   from `SKILL.md`; otherwise return the JSON block for the caller to save.

## Fetch path (roles holding only `WebFetch`)

1. **URL** — from the brief; otherwise return "URL needed".
2. **Fetch** — `WebFetch` the URL. Record HTTP status and whether a body came back.
3. **Page text** — scan the fetched title and first `<h1>` for the failure keywords.
4. **Console** — not observable without a browser. State it explicitly:
   `Console errors: not checked (no browser tools) — a tester browser canary is needed for a
   full verdict`.
5. **Verdict** — FAIL on non-2xx, no body, or a failure keyword; otherwise
   `PASS (fetch-only)`. Never claim a full PASS from a fetch.
6. **Result** — return the JSON block; do not write `.cks/canary-last.json`.

## Output

```
Canary: {URL}
Path: browser | fetch-only
Status: PASS | FAIL | PASS_WITH_WARNINGS | PASS (fetch-only)
HTTP: {status}
Console errors: {N | not checked}
{error list if any}
Result: {saved to .cks/canary-last.json | returned inline}
```

Caveman voice; full prose for error details.
