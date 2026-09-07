# Mode: Fix — apply, verify, close

Apply a diagnosed fix inside a file scope, verify it, close the issue on a confirmed pass.
Ported from the `debugger-worker` agent. Run by the debugger role after `mode-issue-driven.md`
(or a prior diagnosis) has named the root cause and the files. The role has `Edit` and no
`Write`: a fix that needs a new file is returned to the chief of staff for the builder.

## Input contract

`issue_numbers`, `issue_bodies` (pre-loaded), `repo` (`owner/repo`), `project_root`,
`file_scope` (the only files that may change), `proposed_fix` (from the diagnosis).

## Per issue

### 1. Parse

From the issue body: Evidence (file:line), Failure Classification, Suggested Fix.

### 2. Read the evidence

Every cited file:line plus 30 lines of context.

### 3. Confirm the root cause

Trace upstream to where bad data or state was introduced, not where it was detected. The
minimal change that fixes that origin is the fix — one root cause per issue, no bundling.

### 4. Apply

`Edit` within `file_scope` only. A fix that must touch a file outside the scope, or create a
file → do not apply; report `status: needs-human` (or `needs-builder` for a new file) and
leave the issue open.

### 5. Verify

```bash
npm run build 2>&1 | tail -20 || npx tsc --noEmit 2>&1 | tail -20 || true
npm test -- --testPathPattern="{relevant pattern}" 2>&1 | tail -30 || true
```

Run the issue's repro command if it has one. Prefer the Prove-It pattern from
`skills/testing-discipline`: a test that failed before the fix and passes after.

### 6. Close or report

Verification passes → `issue_write(state="closed")` with
`Fixed in {branch}. Root cause: {one sentence}. Verification: {what passed}. Fix applied to:
{file:line}`. Fails → leave open, say what still has to happen. GitHub MCP unavailable →
apply, skip closing, remind the caller to close #{N} manually.

## Output

One block per issue:

```
WORKER_RESULT:
  issue: #{N}
  status: fixed | failed | needs-human | needs-builder
  branch: {worktree branch, or "none"}
  summary: {one sentence}
  verification: {what passed, what failed, or "not run"}
  files_modified:
    - {path}
```

## Constraints

- `file_scope` is a hard boundary
- Never close an issue whose verification failed
- `AskUserQuestion` only for genuinely ambiguous destructive changes — never for routine fixes
- Clean up any `[DEBUG]` instrumentation you added before returning
