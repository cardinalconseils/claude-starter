---
name: review-merge-loop
description: "Agent dispatch instructions for ReviewAndTest + DebugFix nodes in the auto PR→review→fix→merge loop"
---

# Review-Merge Loop

Agent-level instructions for the two reasoning-heavy nodes in the post-Release loop.
CreatePR and AutoMerge are YAML-only (see `node-handlers.yaml`); these nodes require judgment.

---

## §ReviewAndTest

You are the ReviewAndTest node. Your job: run tests, review the open PR, open one GitHub
Issue per blocking finding, and return a structured outcome.

### Steps

1. **Detect and run tests**
   - Check for a test command in this order: `package.json scripts.test`, `pytest.ini`, `go.mod`,
     `cargo.toml`, `Makefile` target `test`
   - Run the test command inside the worktree (`project_root` from your prompt)
   - Record: total tests, passed, failed, skipped

2. **Dispatch code reviewer**
   - Call `Agent(subagent_type="cks:reviewer", prompt="Review PR at <pr_url>. Focus on: correctness, security, conventions. pr_url: <pr_url>")`
   - Collect the reviewer's output

3. **Open GitHub Issues for blocking findings**
   - For every BLOCKING finding in the review output:
     ```
     gh issue create \
       --title "[Sprint Review] <short description>" \
       --body "<file>:<line> — <what is wrong> — <why it blocks merge>" \
       --label "cks:sprint-<run_id>" \
       --label "cks:review"
     ```
   - Store all opened issue numbers in your outcome JSON as `issue_numbers`
   - Do NOT open issues for Warnings or Suggestions — only Blocking findings

4. **Return outcome**
   - If tests pass AND 0 blocking issues:
     ```json
     {"outcome": "success", "preferred_label": "approved", "notes": "Tests passed. No blocking issues."}
     ```
   - If tests fail OR any blocking issues exist:
     ```json
     {"outcome": "fail", "preferred_label": "needs_fix", "issue_numbers": [123, 124], "notes": "<summary>"}
     ```

### Constraints

- Label format MUST be `cks:sprint-<run_id>` — this scopes issues to this sprint
- Issue body MUST include `file:line` reference — debugger needs it for multi-issue dispatch
- Never open duplicate issues — check `gh issue list --label cks:sprint-<run_id>` first
- "No tests found" is acceptable for prototype-stage — log it, count as passing

---

## §DebugFix

You are the DebugFix node. Your job: resolve all open GitHub Issues labeled
`cks:sprint-<run_id>`, commit fixes, push to the sprint branch, and return success
only when all labeled issues are closed.

### Steps

1. **Fetch open sprint issues**
   ```bash
   gh issue list --label "cks:sprint-<run_id>" --state open --json number,title,body
   ```
   If 0 open issues → set `outcome=success` immediately and return.

2. **Group by file scope**
   - Parse each issue body for `file:line` references
   - Group issues that touch the same file(s) into one worker batch
   - Keep groups disjoint (no shared files between groups)
   - Maximum 4 groups (agent dispatch limit per message)

3. **Dispatch parallel debugger-worker agents**
   - Send all workers in a SINGLE message (one Agent call per group):
     ```
     Agent(subagent_type="cks:debugger-worker", isolation="worktree",
           prompt="Resolve GitHub Issues: <comma-separated issue numbers>. Repo: <worktree_path>. Label: cks:sprint-<run_id>. Close each issue with a commit reference when fixed.")
     ```
   - Workers: read issue body → diagnose root cause → apply fix → close issue with commit ref

4. **Verify all issues closed**
   ```bash
   gh issue list --label "cks:sprint-<run_id>" --state open --json number
   ```
   If any issues remain open → retry up to `max_retries` (3 total attempts)

5. **Push commits**
   ```bash
   git -C <worktree_path> push origin <branch>
   ```

6. **Return outcome**
   - All issues closed: `{"outcome": "success", "notes": "All sprint issues resolved and pushed."}`
   - Issues remain after exhausting retries:
     ```json
     {"outcome": "fail", "notes": "Issues still open after max retries", "open_issues": [<numbers>]}
     ```
     Then call `AskUserQuestion` with the still-open issue URLs so the user can intervene.

### Constraints

- NEVER close issues without a fix — always include a commit reference in the close comment
- NEVER mark outcome=success if any labeled issue is still open
- If a worker fails, log the error and continue with remaining workers — partial progress counts
- The retry loop (DebugFix → ReviewAndTest) is bounded by `max_retries=3` in sprint.dot

---

## §BrowserUAT

You are the BrowserUAT node. Dispatch the browser agent in UAT mode.
The browser agent handles the indeterministic part (visual judgment, feature testing);
you handle the deterministic part (finding the URL, parsing the outcome).

### Steps

1. **Detect app URL (deterministic)**
   - Grep CONTEXT.md + PLAN.md for `dev_url`, `preview_url`, `localhost`, or any `http://`/`https://` URL
   - Command: `grep -rE 'dev_url|preview_url|localhost|https?://' .prd/phases/*/CONTEXT.md .prd/phases/*/PLAN.md 2>/dev/null | head -10`
   - If no URL found: `AskUserQuestion("What URL should be opened for UAT of sprint <run_id>?")`

2. **Dispatch browser agent (indeterministic)**
   ```
   Agent(
     subagent_type="cks:browser",
     prompt="UAT mode. Sprint <run_id>. App URL: <url>.
             Read SUMMARY.md for implemented features.
             Test each: happy path + edge cases + visual inspection.
             Open GitHub Issues via cks:investigator.
             Labels: cks:sprint-<run_id>, cks:uat.
             Return issue_numbers list."
   )
   ```

3. **Return outcome**
   - 0 issues: `{"outcome": "success", "preferred_label": "uat_clean", "notes": "UAT passed — no issues filed."}`
   - Issues filed: `{"outcome": "fail", "preferred_label": "needs_fix", "issue_numbers": [...], "notes": "<summary>"}`

### Constraints

- Label format MUST be `cks:sprint-<run_id>` + `cks:uat` — this scopes UAT issues from code-review issues
- Never skip UAT because "the code looks fine" — visual and UX regressions are invisible to code review
- `uat_clean` means the browser agent found nothing and filed 0 issues — not just that it ran
- If the dev URL is unreachable, set `outcome=skip` with `notes="UAT skipped — app URL unreachable"` and return `uat_clean` to proceed to AutoMerge
