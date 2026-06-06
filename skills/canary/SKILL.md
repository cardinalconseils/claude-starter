---
name: cks:canary
description: Post-deploy canary verification domain knowledge — console errors, page load, pass/fail criteria
allowed-tools:
  - Bash
  - Write
---

# Canary — Post-Deploy Browser Verification

## What a Canary Check Verifies

1. **Page loads** — URL responds, no network failure
2. **Console errors** — no ERROR-level browser console messages
3. **Obvious failure signals** — page title/h1 does not contain "Error", "404", "500", "Not Found", "Something went wrong", "Internal Server Error"
4. **Visual sanity** — page renders content (not blank, not spinner-only)

## Pass / Fail / Warning Criteria

| Result | Condition |
|--------|-----------|
| **PASS** | No console ERRORs. Page loads. No failure keywords in title/h1. |
| **FAIL** | Any console ERROR. Page fails to load. Failure keyword in title/h1. |
| **PASS_WITH_WARNINGS** | Console WARNs only. Page loads fine otherwise. |

Warnings do not block deploy. Errors do.

## Console Level Definitions

- **ERROR** — Always a FAIL signal. Unhandled exceptions, network failures, script errors.
- **WARN** — Flag as warning, do not fail. Deprecated API usage, fallback paths.
- **INFO / LOG** — Ignore for canary purposes.

## Failure Keyword Scan

Check title tag and first `<h1>` for (case-insensitive):
- `404`, `500`, `503`
- `not found`, `page not found`
- `error`, `something went wrong`
- `internal server error`
- `forbidden`, `unauthorized` (if URL is meant to be public)

## Output Format

Brief. Lead with verdict. Show errors if any.

```
Canary: https://example.com
Status: PASS
Console errors: 0
Result saved: .cks/canary-last.json
```

Or on failure:

```
Canary: https://example.com
Status: FAIL
Console errors: 2
  - TypeError: Cannot read property 'x' of undefined (app.js:142)
  - Failed to load resource: 500 /api/health
Result saved: .cks/canary-last.json
```

## Result File Schema

`.cks/canary-last.json`:
```json
{
  "url": "https://example.com",
  "timestamp": "2024-01-15T10:30:00Z",
  "status": "pass",
  "error_count": 0,
  "errors": [],
  "warnings": ["Deprecated: componentWillMount"]
}
```

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The deploy script said success, that's enough" | Deploy success = files transferred. Canary = app actually works. Both required. |
| "Console warns are fine to ignore" | Warns = PASS_WITH_WARNINGS, not FAIL. But log them — they compound. |
| "The page loaded, no need to check console" | Invisible JS errors break user flows silently. Check console always. |

## Verification

- [ ] URL navigated successfully
- [ ] Console messages read and filtered
- [ ] Page text scanned for failure keywords
- [ ] Verdict matches criteria table above
- [ ] `.cks/canary-last.json` written with correct schema
