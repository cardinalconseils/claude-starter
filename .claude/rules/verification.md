# Verification Before Completion Rules

## Mandatory Behavior

Claude MUST NOT declare work "done", "complete", "shipped", "ready", or run any
`git commit` without first running the maturity-appropriate verification set
and showing the evidence inline.

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

## Alignment with Other Rules

This rule reinforces `superpowers:verification-before-completion` (advisory)
by making the same expectations a hard project rule. The two do not contradict;
this file wins on enforcement, superpowers wins on framing.

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
