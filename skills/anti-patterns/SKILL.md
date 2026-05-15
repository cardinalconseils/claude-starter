---
name: anti-patterns
description: >
  Catalog of patterns to detect and reject before they ship. Use when: reviewing code,
  writing SUMMARY.md, doing code review, verifying sprint output, or any time you are
  about to claim work is done. Four categories: code, process, output, PRD/doc.
allowed-tools: Read, Grep, Glob
---

# Anti-Patterns Catalog

A pattern is an anti-pattern when it makes output *look* done without *being* done, or
introduces future problems while appearing to solve current ones.

For each: **detect** the signal → **name** it → **reject** the output → **fix** it.

---

## Code Anti-Patterns

### Wrapper Bloat
**Detect:** A function that calls one other function and adds no logic.
**Reject:** `const getUser = (id) => fetchUser(id)` — adds nothing.
**Fix:** Inline the call. Wrappers are only justified at explicit package boundaries.

### Defensive Noise
**Detect:** Null checks or optional chains where the type system guarantees non-null.
**Reject:** `if (user && user.id)` when `user: User` can't be null at that call site.
**Fix:** Remove the check. If the invariant is non-obvious, add a WHY comment instead.

### Silent Failure
**Detect:** `catch (e) {}` or `catch (e) { return null }` — swallowing errors silently.
**Reject:** Any catch block that hides failures from callers and from logs.
**Fix:** Log the error, re-throw, or return a typed error result. Never swallow silently.

### Premature DRY
**Detect:** A shared utility function used in exactly one place.
**Reject:** `const formatUserLabel = (u) => ...` used only in `UserCard.tsx`.
**Fix:** Inline it. Extract only when the second call site appears.

### Feature-Flag Creep
**Detect:** A boolean env/config flag controlling behavior that is always the intent.
**Reject:** `if (process.env.ENABLE_NEW_AUTH)` when old auth is being replaced, not A/B tested.
**Fix:** Just change the code. Flags are for rollout control, not permanent code paths.

---

## Process Anti-Patterns

### Undocumented Completion
**Detect:** "Done" or "complete" claimed without evidence (output, screenshot path, test results).
**Reject:** Any done claim without inline evidence.
**Fix:** Show the output. If you can't run it, say so explicitly and note the gap.

### Phase Bypass
**Detect:** "We know what we're building, let's skip discovery" or implementing without a PLAN.md.
**Reject:** Starting implementation before acceptance criteria are written and agreed.
**Fix:** 10 minutes on discovery saves hours of implementation rework.

### Silent Decision
**Detect:** An architectural choice (new dependency, data model change, API contract change) made without surfacing it.
**Reject:** Any choice that affects the system's public surface without a `❓ DECISION REQUIRED` block.
**Fix:** Surface the decision. The user approves before it ships.

### Shadow Implementation
**Detect:** Re-implementing something that already exists (same utility, hook, or helper).
**Reject:** `const useCurrentUser` when `useAuth().user` already does this.
**Fix:** Search before building. Extend what exists; don't duplicate it.

### Band-Aid Fix
**Detect:** A try/catch, default value, or early return that silences an error without knowing the root cause.
**Reject:** `|| []` on a query result because "sometimes it's null" without understanding why.
**Fix:** Trace to the source. Fix the cause. If blocked, document why explicitly.

---

## Output Anti-Patterns

### Narrated Execution
**Detect:** Multi-paragraph summary at the end of a response describing what was just done.
**Reject:** "I've now created the file, updated the imports, added the tests, and verified..."
**Fix:** Show the diff or test output. Code speaks; narration is noise.

### Speculative Done
**Detect:** "Should work", "this might need", "probably", "I think" in any delivery statement.
**Reject:** Hedged completion claims.
**Fix:** Verify before claiming done. If you can't verify, say so — that's different from "should work."

### Dead Comment
**Detect:** A comment explaining WHAT code does rather than WHY.
**Reject:** `// Fetches the user by ID` above `fetchUserById(id)`.
**Fix:** Delete it. If the WHY needs explanation, write that instead.

### Invisible Evidence
**Detect:** "Tests pass" or "build succeeds" without showing the command or output.
**Reject:** Any verification claim without terminal output inline.
**Fix:** Paste the last ~20 lines of test output. That is the evidence.

---

## PRD / Doc Anti-Patterns

### Unverifiable Criterion
**Detect:** An acceptance criterion that can't be tested true/false.
**Reject:** "Users will find the interface intuitive" or "Performance should be good."
**Fix:** "Page loads under 2s (Lighthouse 3G)" or "User completes checkout in ≤3 clicks."

### Missing Exclusions
**Detect:** A scope section that only lists what's IN, with no OUT column.
**Reject:** A PLAN.md with no explicit "Out of scope for this sprint" section.
**Fix:** Add the out-of-scope list. It prevents scope creep and makes review faster.

### Tautological Done
**Detect:** DoD field filled with "code complete", "feature built", or "implementation done."
**Reject:** Any DoD that just restates the task.
**Fix:** "All acceptance criteria pass (test output shown), deployed to staging, health check green."

### Aspirational Summary
**Detect:** SUMMARY.md written in the future tense or before implementation is complete.
**Reject:** "This PR will add X and improve Y."
**Fix:** Write SUMMARY.md after the work is done. Describe what was *actually* built, including what was skipped and why.

---

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "This anti-pattern is just style preference" | These patterns hide failures or ship incomplete work. Not style. |
| "It's a small wrapper, it's fine" | Wrappers accumulate. Each one is a future reader's question. |
| "I'll remove the TODO before shipping" | You won't. Remove it now or flag it as an explicit known issue. |
| "Tests passing is proof enough" | Tests prove the test cases pass. Functional E2E proves the feature works. |
| "The user didn't ask for evidence" | Evidence is for future-you and the Attractor's auto-criteria, not just today's reviewer. |
