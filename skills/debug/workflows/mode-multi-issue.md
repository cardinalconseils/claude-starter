# Mode 5: Multi-Issue Orchestrator Workflow

You received a comma-separated list of issue numbers and a repo. Your job: fix all of them in parallel. Follow these steps in order.

## Step 1: Read All Issues

Call `mcp__plugin_github_github__issue_read(owner, repo, issue_number=N)` for each issue number **in parallel** (all calls in one message).

From each issue body, extract:
- **Evidence** — file paths mentioned (e.g., `src/auth/login.ts:42`)
- **Failure Classification** — type and severity
- **Suggested Fix** direction
- **Dependencies** — the `## Dependencies` section: `depends-on`, `file-scope`, `root-cause`, `symptom-of` (used by Step 1.5)

## Step 1.5: Build Dependency Waves

Before grouping by file scope, sort the issues into dependency **waves** so prerequisites are fixed before the issues that depend on them.

1. **Parse** the `## Dependencies` section from each issue body read in Step 1: `depends-on`, `file-scope`, `root-cause`, `symptom-of`.
   - **Graceful fallback:** if an issue is **missing** the `## Dependencies` section entirely (e.g. filed before this schema existed), treat it as `depends-on: empty` → it lands in **wave 1**. Do NOT crash.
2. **Deduplicate symptoms:** if an issue declares `symptom-of: #N` and `#N` is also in the current run set, **drop the symptom issue from dispatch** (record it in the Step 5 report as "skipped — symptom of #N"). Fixing the root cause is expected to resolve the symptom.
3. **Build an adjacency list** from `depends-on` edges (issue → the issues it blocks on). Restrict edges to issues in the current run set; ignore `depends-on` numbers outside the run.
4. **Topological sort → assign wave numbers.** Issues with no in-run dependencies land in **wave 1**. An issue's wave = `max(wave of its in-run deps) + 1`.
5. **Cycle guard:** if the dependency graph contains a cycle, **report the cycle explicitly and STOP** — do NOT attempt to auto-resolve (mirror the merge-conflict policy in Step 4). Ask the user to fix the declared `depends-on` values.
6. **Apply wave labels** to each issue:
   ```bash
   gh issue edit {n} --add-label "cks:wave-{N}" 2>/dev/null || true
   ```
   Idempotent — `gh` creates the label on first use; `2>/dev/null || true` keeps it from blocking.

Carry the wave assignment forward: Steps 2–4 run **once per wave, in wave order**.

## Step 2: Build a File-Scope Map (per wave)

**Process one wave at a time, in wave order.** For the current wave's issues only, list the files each touches (from the `file-scope` / evidence section).

Group the issues so that:
- Issues touching the **same file** go to the **same worker**
- No two workers may modify the same file

This prevents merge conflicts between parallel workers.

## Step 3: Dispatch Parallel Workers (per wave)

For the **current wave only**, dispatch up to 4 workers in a **SINGLE message** (all Agent calls at once). Each worker handles one file-scope group within this wave.

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

**Wave gate:** Steps 2–4 are scoped to the current wave. **Do not start the next wave** until every worker in the current wave has completed and its branch has merged. Repeat Steps 2–4 for wave 2, then wave 3, and so on. Issues skipped as symptoms in Step 1.5 are never dispatched.

## Step 5: Report Summary

```
DEBUG SUMMARY
━━━━━━━━━━━━━
Mode:    multi-issue
Issues:  {N} total — {N} fixed · {N} failed · {N} needs-human · {N} skipped (symptom)
Waves:   {N} waves — wave 1: [#..], wave 2: [#..], ...
Branches merged: {list or "none"}

RESULTS
━━━━━━━
#{N} (wave {W}) ✅ Fixed — {one-sentence summary} (branch: {branch})
#{N} (wave {W}) ❌ Failed — {reason} (issue remains open)
#{N} (wave {W}) 🔶 Needs human — {why auto-fix wasn't possible}
#{N} ⏭️ Skipped — symptom of #{M} (resolved by root-cause fix)

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
