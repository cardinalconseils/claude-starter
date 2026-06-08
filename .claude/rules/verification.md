# Verification Before Completion Rules

## Mandatory Behavior

Claude MUST NOT declare work "done", "complete", "shipped", "ready", or run any
`git commit` without first running the maturity-appropriate verification set
and showing the evidence inline.

## Pre-Commit Scan

Before any `git commit`, scan staged files for:

- `TODO`, `FIXME`, `HACK`, `XXX` markers — create a GitHub Issue instead; reference
  `#NNN` in a comment or remove the marker entirely. Never commit raw markers.
- Commented-out code blocks — remove them. The old code lives in git history.

Evidence: `grep -rn "TODO\|FIXME\|HACK\|XXX" <staged files>` returns empty.

## Trigger Points

The rule fires before any of these:

- Saying "done", "complete", "shipped", "ready", "finished", "all set", "good to go"
- Any `git commit` invocation
- Opening a pull request
- Closing a `/cks:*` phase or task
- Reporting a feature as implemented in a status update

## Minimum Verification Set by Maturity Stage

Read `PROJECT.md` to determine maturity stage. If unspecified, infer from
presence of test infra (no tests configured → Prototype; tests + CI → Pilot+).

### Prototype Stage

- **Required:** Happy path manually verified
- **Evidence:** One of:
  - Command output showing the feature ran successfully
  - Screenshot path or file reference
  - Plain-English description of what was clicked / called / observed

### Pilot Stage

- **Required:** Build passes + happy path manually verified + at least one
  automated test for the new code (smoke or unit)
- **Evidence:** Build command output, test command output, manual check note

### Candidate / Production Stage

- **Required:** Build passes + full test suite passes + key user paths checked
  (manual or scripted) + lint / typecheck pass
- **Evidence:** All command outputs inline, screenshots for UI changes,
  citation of the test files exercised

## What Counts as Evidence

Evidence MUST be shown inline in the response that claims "done". Acceptable forms:

- **Test pass:** the exact command and its output (last ~20 lines is fine)
- **Build pass:** the exact build command and its terminal output
- **Manual check:** a one-line description with file paths, URLs, or screenshot
  references
- **Lint / typecheck:** command + output

Insufficient evidence (never accept):

- "Looks good"
- "Should work"
- "Tested mentally"
- "Same pattern as before so it should be fine"

## Maturity Exception

Prototype stage may substitute "happy path manually verified" for the full
test set. Claude MUST still describe what was verified — vague claims do not
satisfy the rule, even at Prototype.

If the project has no test command configured AND no manual check is possible,
Claude MUST say so explicitly:

> "No tests configured and no observable behavior to check manually.
>  Maturity: Prototype. Proceeding without runtime verification — flagging
>  this gap as a candidate learning."

This is the ONLY acceptable path past the rule without evidence, and the
learning must be added to `.learnings/gotchas.md`.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The change is too small to test" | Small changes break things just as often. The cost of running the test is seconds; the cost of a hotfix is hours. |
| "Tests pass in CI, that's enough" | CI runs after commit. The rule fires before commit. Local evidence is required up front. |
| "I'll fix it forward if it breaks" | The 4–8 hotfix-per-feature pattern this rule exists to stop. Verify first. |
| "It worked when I wrote it" | "Wrote it" ≠ "verified it". Run the command and show the output. |
| "User said move fast" | Speed without verification is rework. Verification is the fast path. |
| "Prototype stage means no testing" | Prototype means lighter testing. "Happy path manually verified" is still required and still has evidence. |

## Required Behavior

1. Before saying done / committing, identify the maturity stage
2. Run the maturity-appropriate verification set
3. Show the evidence inline (command output, screenshot path, manual check note)
4. Only then proceed with the "done" claim, commit, or PR

If verification fails, state the failure plainly, do not commit, and ask the
user how to proceed.

## Verification (meta — for this rule)

- [ ] Every "done" claim shows evidence inline
- [ ] Every commit is preceded by visible verification output
- [ ] Maturity-stage exception is explicit, not silent
- [ ] No "should work" / "looks good" claims pass as evidence

## Evidence Bundle Contract

Every VERIFICATION.md produced at Phase 3+ MUST begin with this YAML front-matter block:

```yaml
---
scope_changed:
  - src/auth/login.ts
uncovered:
  - "Password reset email — no email service in test env"
  # empty list = agent claims full coverage. Deliberate, not an omission.
confidence:
  overall: 0.75
  per_criterion:
    - id: AC-1
      verdict: PASS
      why: "12/12 unit tests pass"
    - id: AC-4
      verdict: FAIL
      why: "clock mock not injected — session expiry test measured wall clock"
---
```

### Required fields — agents cannot skip

| Field | Required | Rule |
|---|---|---|
| `scope_changed` | Yes | Every file the sprint touched — not just what was verified |
| `uncovered` | Yes | Empty list = full coverage claim. List with reason if anything was skipped. |
| `confidence.overall` | Yes | Must match CONFIDENCE.md gate pass rate. Not estimated — computed. |
| `confidence.per_criterion` | Yes | One entry per AC from CONTEXT.md. No AC may be omitted. |
| `verdict` per criterion | Yes | Only `PASS`, `FAIL`, or `SKIP`. No other values. |
| `why` on every FAIL | Yes | One plain-English sentence — root cause, not "test failed". |

### What agents must NOT do

- Omit `uncovered` (even an empty list must be present)
- Write `why: "test failed"` without explaining root cause
- Skip an AC in `per_criterion`
- Estimate `confidence.overall` — compute it from CONFIDENCE.md
- Use verdict values other than PASS, FAIL, SKIP

### Backward compatibility

VERIFICATION.md files created before this rule shipped are valid without front-matter.
New artifacts produced after this rule ships must include the block.

**Verification (meta — for the Evidence Bundle):**
- [ ] Every new VERIFICATION.md has valid YAML front-matter at the top
- [ ] `uncovered` list present and non-null (empty = full coverage claimed)
- [ ] `confidence.overall` matches CONFIDENCE.md gate pass rate
- [ ] `why` on every FAIL is a root-cause sentence, not a restatement
