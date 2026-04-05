# Recipe: branch_divergence

## Detection Confirmation

Before applying this recipe, verify:
- `git status` shows unmerged paths, OR
- `git log HEAD..origin/main --oneline` shows commits ahead on main, OR
- Build/test failures appeared after pulling or rebasing

## Auto-Recovery Steps

### Step 1: Determine divergence type

| Type | Signal | Strategy |
|------|--------|----------|
| Stale branch | main has new commits not in branch | Merge-forward or rebase |
| Merge conflict | `CONFLICT` markers in files | Attempt auto-resolution |
| Detached HEAD | `HEAD detached at` | Re-attach to branch |

### Step 2: Check divergence severity

```bash
# Count commits behind main
git fetch origin main 2>/dev/null
BEHIND=$(git rev-list HEAD..origin/main --count 2>/dev/null || echo 0)
```

- **0 commits behind** → Not actually diverged. Reclassify the failure.
- **1-10 commits behind** → Safe to merge-forward automatically
- **10+ commits behind** → Escalate — large divergence needs human review

### Step 3: Merge-forward (if safe)

```bash
# Prefer merge over rebase for safety
git merge origin/main --no-edit
```

- If merge succeeds cleanly → re-run the original failed command
- If merge has conflicts → check if conflicts are in files this branch modified
  - If only in OTHER files → likely safe to accept theirs: `git checkout --theirs {file}`
  - If in files THIS branch changed → escalate (cannot auto-resolve safely)

### Step 4: Verify
- Re-run the build/test command that originally failed
- If passing → emit `recovery.succeeded` with note: "merged {N} commits from main"
- If still failing → the failure is NOT branch-related. Reclassify with a new category.

## Escalation

Report to user:
```
Failure: branch_divergence ({type})
Branch: {current branch} is {N} commits behind origin/main
Conflicts: {list of conflicting files, if any}
Attempted: {merge-forward / nothing if too diverged}
Action needed: {resolve conflicts manually / rebase interactively}
```

## Important

NEVER force-push or rebase published branches without explicit user confirmation. Merge-forward is always the safe default.
