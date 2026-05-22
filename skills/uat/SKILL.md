---
name: uat
description: "End-of-feature User Acceptance Testing methodology — acceptance-criteria-driven, preflight-aware UAT using browser automation. Use when running /cks:uat, operating in BrowserUAT pipeline node, or verifying a feature's definition of done via browser."
allowed-tools: Read, Write, Grep, Bash, Agent, AskUserQuestion
---

# UAT — User Acceptance Testing

## Core Principle

UAT verifies the feature against the **acceptance criteria that were defined before development started** — not against what was built. The question is not "does it work technically?" but "does the vibe coder see what they asked for?"

Two-tier verification:
1. **Browser automation** — technical pass/fail against AC (objective, logged in report)
2. **Human sign-off** — vibe coder watches a GIF per AC and confirms "yes, that's what I asked for" (final verdict)

Both tiers must pass. Browser automation finding no errors does not override a vibe coder saying "that's not right."

## AC Source Priority

Always use the most upstream definition of done available:

| Priority | Source | Where |
|----------|--------|-------|
| 1 (best) | PREFLIGHT.md §E — Establish | `.preflight/{NN}-*/PREFLIGHT.md` |
| 2 | CONTEXT.md DoD field | `.prd/phases/{NN}-*/CONTEXT.md` |
| 3 (fallback) | SUMMARY.md implemented features | `.prd/phases/{NN}-*/SUMMARY.md` |

If no AC source exists → block and ask. Never invent acceptance criteria.

## Test Matrix Generation

For each acceptance criterion, derive three test cases:

### Happy Path
The normal flow that proves the AC is true.
- What does the user click, fill, or navigate to?
- What content or state change confirms success?
- Example — AC "user can log in with valid credentials":
  - Happy: enter valid email + password → land on dashboard → no error toast

### Edge Case
A boundary condition that must also pass. Pull from PREFLIGHT §E if written there; otherwise infer from the AC statement:
- Empty input, maximum length input, special characters
- Zero-state (empty list, no data), single item, large dataset
- Concurrent or rapid repeat actions
- Example: enter valid email + wrong-then-correct password → succeed on retry

### Error State
What happens when the input is invalid or a dependency fails:
- Invalid format, missing required field, duplicate entry
- Server error response (5xx) — does the UI show a message, not a blank screen?
- Auth expiry mid-flow
- Example: enter non-existent email → show "account not found" message

## Feature Type Patterns

When AC is terse, use these patterns to infer test cases:

**Auth features** (login, signup, logout, password reset)
- Happy: valid creds → success state
- Edge: valid creds after failed attempt, session expiry handling
- Error: invalid creds → informative error, not generic 500

**CRUD features** (create, list, edit, delete)
- Happy: create → appears in list → edit → updated in list → delete → gone
- Edge: empty list state, maximum field length, special characters in name
- Error: duplicate entry, required field blank, cancel mid-edit preserves state

**Dashboard / reporting features**
- Happy: data present → renders correctly
- Edge: zero-data state → shows empty state UI (not blank)
- Error: data fetch fails → shows error message, not spinner forever

**Form features**
- Happy: valid input → submission success → feedback shown
- Edge: all optional fields blank, maximum characters in every field
- Error: required field missing → inline validation, not generic error

## Browser Pass/Fail Criteria

A UAT test **passes** when ALL of the following are true:
- Expected content is visible on the page
- No console errors with severity `error` (warnings acceptable)
- No HTTP 5xx responses in network requests
- The AC statement is verifiably true (not just "page loaded")

A UAT test **fails** when ANY of the following occur:
- Expected content is absent or incorrect
- Console errors related to the feature under test
- HTTP 5xx from API calls triggered by the test
- UI shows a loading spinner or blank state instead of expected content
- The AC cannot be verified because a UI element is missing

A UAT test is **skipped** (not failed) when:
- The criterion tests something not observable in the browser (background job, email delivery, cron)
- The app URL is unreachable (network/infra issue — file a separate infra issue)

Skipped ≠ passed. Skipped ACs must be noted in the report with a manual verification path.

## Preflight Integration

The PREFLIGHT.md "E — Establish" section IS the UAT spec. It was written before a line of code was touched, when the team had clearest intent about what success looks like.

Read it first. If it has AC + edge cases, use them verbatim — do not reinterpret. If it has partial coverage, supplement from CONTEXT.md DoD. Never replace PREFLIGHT ACs with SUMMARY.md content.

## Severity Classification (for GitHub issues)

| Severity | Definition | Example |
|----------|------------|---------|
| `blocking` | AC fails — feature is not done | Login returns 500 |
| `ux` | AC passes but UX is broken | Error message is `undefined` |
| `cosmetic` | AC passes, minor visual issue | Button misaligned by 2px |

File GitHub issues for `blocking` and `ux` severity. Log `cosmetic` in the UAT report only.

## Common Rationalizations

| Rationalization | Reality |
|----------------|---------|
| "PREFLIGHT.md is missing, I'll just check SUMMARY.md" | SUMMARY.md says what was built, not what was promised. Fall back to CONTEXT.md DoD, not SUMMARY.md. |
| "The code looks correct, UAT is redundant" | UAT tests UX and integration, not code correctness. Code review cannot catch a broken redirect or a missing empty state. |
| "This AC can't be tested in a browser" | Mark it `skip` with a manual verification note — never `pass`. |
| "All edge cases would take too long" | The test matrix is one happy + one edge + one error per AC. Three tests per criterion, not exhaustive QA. |
| "UAT found only cosmetic issues, it's clean" | Cosmetic issues pass UAT. Blocking and UX issues do not. Be precise about which is which. |

## Verification Checklist

- [ ] AC source identified and documented in report (PREFLIGHT / CONTEXT / SUMMARY)
- [ ] Test matrix covers every AC (happy + edge + error)
- [ ] Browser agent dispatched with explicit AC list in prompt
- [ ] Each AC marked pass / fail / skip with evidence
- [ ] Blocking and UX failures filed as GitHub issues
- [ ] `.uat/UAT-{date}-{run_id}.md` written before completion
- [ ] Next step stated: "UAT clean — ready to merge" OR "Fix issues {list}, re-run /cks:uat"
- [ ] GIF recorded per AC and paths presented to vibe coder
- [ ] Human sign-off obtained via AskUserQuestion (vibe coder confirmed "yes, it works")
