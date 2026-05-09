# Git Hygiene Rules

## Branch Naming
- One branch per issue: `{issue-number}-short-description` (e.g., `42-fix-auth-redirect`)
- No freeform branch names — the issue number makes ownership and purpose traceable

## Branch Lifecycle
- Branches must be deleted after merge (enable "Automatically delete head branches" in GitHub repo settings)
- Any branch untouched for 30+ days with a closed or unassigned linked issue is a candidate for deletion
- Run `git branch -r --no-merged main` monthly to surface stale branches

## What Counts as Stale
A remote branch is stale when ALL of the following are true:
- Last commit is 30+ days old
- No open PR is linked
- Linked issue is closed or unassigned

## On Deletion
Before deleting a stale branch, check `git log --oneline origin/{branch} ^main` — if there are commits not in main, confirm with the author before deleting.
