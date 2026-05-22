# Recipe: branch_divergence

## Trigger
Merge conflict, branch behind origin/main, non-fast-forward push, diverged branch.

## Severity
`blocking` — Auto-recoverable: Yes

## Steps

1. Run `git status` and `git log --oneline origin/main..HEAD` to understand divergence.
2. If behind main: run `git fetch origin && git rebase origin/main`.
3. If merge conflicts: list conflicting files, show the conflict markers, ask the user which version to keep.
4. After rebase/merge: run build and tests to confirm nothing broke.
5. Report: rebased N commits, N conflicts resolved (or escalated).

## Auto-Fix: Yes (rebase without conflicts)
If rebase completes cleanly, it's auto-recoverable. If conflicts exist, escalate to user.

## Escalation Message
> Merge conflict requires human resolution. List the conflicting files and the two versions of each conflict for the user to choose between.
