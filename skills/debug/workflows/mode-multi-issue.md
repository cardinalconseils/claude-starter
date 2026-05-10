# Mode 5: Multi-Issue Orchestrator Workflow

You received a comma-separated list of issue numbers and a repo. Your job: fix all of them in parallel. Follow these steps in order.

## Step 1: Read All Issues

Call `mcp__plugin_github_github__issue_read(owner, repo, issue_number=N)` for each issue number **in parallel** (all calls in one message).

From each issue body, extract:
- **Evidence** — file paths mentioned (e.g., `src/auth/login.ts:42`)
- **Failure Classification** — type and severity
- **Suggested Fix** direction

## Step 2: Build a File-Scope Map

For each issue, list the files it touches (from the evidence section).

Group the issues so that:
- Issues touching the **same file** go to the **same worker**
- No two workers may modify the same file

This prevents merge conflicts between parallel workers.

## Step 3: Dispatch Parallel Workers

Dispatch up to 4 workers in a **SINGLE message** (all Agent calls at once). Each worker handles one group.

```
Agent(
  subagent_type="cks:debugger-worker",
  isolation="worktree",
  model="sonnet",
  prompt="
    issue_numbers: [{comma-separated numbers for this group}]
    issue_bodies: {paste full issue text for each issue in this group}
    repo: {owner/repo}
    project_root: {project_root}
    file_scope: [{files this worker may modify — from evidence above}]

    For each issue: diagnose the root cause, apply the fix, run verification, close the issue if fixed.
    Return a WORKER_RESULT block for each issue.
  "
)
```

Every issue — even a single one — must go through a worker with `isolation="worktree"`. Never call `Edit` directly from the orchestrator.

## Step 4: Merge Worker Branches

After all workers complete, collect the `branch` fields from each WORKER_RESULT block.

For each branch that contains changes:
```bash
git merge --no-ff "{branch}" -m "fix: merge debugger-worker branch {branch}"
```

If a merge conflict occurs:
- Run `git merge --abort`
- Report the conflict explicitly — do NOT attempt to auto-resolve
- Ask the user to resolve manually before continuing

## Step 5: Report Summary

```
DEBUG SUMMARY
━━━━━━━━━━━━━
Mode:    multi-issue
Issues:  {N} total — {N} fixed · {N} failed · {N} needs-human
Branches merged: {list or "none"}

RESULTS
━━━━━━━
#{N} ✅ Fixed — {one-sentence summary} (branch: {branch})
#{N} ❌ Failed — {reason} (issue remains open)
#{N} 🔶 Needs human — {why auto-fix wasn't possible}

NEXT STEPS
━━━━━━━━━━
{for each failed/needs-human issue}
  /cks:debug --issue {N}    → manual debug session
```

## Step 6: Ship the Fixes

If at least one issue was fixed (any worker returned `status: fixed`):

```
Agent(
  subagent_type="cks:go-runner",
  prompt="
    action: pr
    args: fix: resolve {N} issue(s) — {comma-separated issue numbers}
    project_root: {project_root}
  "
)
```

This commits the merged fixes, pushes the branch, and opens a PR. If the go-runner encounters conflicts or quality gate failures, it will surface them for manual resolution.
