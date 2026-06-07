---
name: "source-command-ship"
description: "Dev-only: bump version, update all docs + wiki, commit, push, PR, review, auto-merge"
---

# source-command-ship

Use this skill when the user asks to run the migrated source command `ship`.

## Command Template

# /ship — Full Plugin Release Pipeline

Local-only dev command. Runs the entire release pipeline autonomously:
1. Bump version + update all docs (bump-version.sh handles this)
2. Write CHANGELOG entry
3. Commit everything, push, open PR
4. Agent reviews the PR
5. Auto-merge if review passes

## Execution

```javascript
// Step 1 — bump version (stages version files + CHANGELOG automatically)
const newVersion = Bash("cd /Users/pmc/Documents/DEV/Codex-Starter && bash scripts/bump-version.sh")

// Step 2 — update wiki version stamps (bump-version.sh covers README + WORKFLOW + wiki/README.md already)

// Step 3 — stage remaining uncommitted changes
Bash("git add -A")

// Step 4 — commit
Bash(`git commit -m "chore: release v${newVersion}"`)

// Step 5 — push current branch
Bash("git push -u origin HEAD")

// Step 6 — create PR
Bash(`gh pr create --title "Release v${newVersion}" --body "Automated release commit. Bumps version, updates docs and wiki."`)

// Step 7 — get PR number and URL
const prUrl = Bash("gh pr view --json url -q .url")

// Step 8 — dispatch reviewer agent
Agent(subagent_type="cks:reviewer", prompt=`Review PR at ${prUrl}. Check: version bump is consistent across plugin.json, marketplace.json, VERSION, README.md, CHANGELOG.md, docs/wiki/README.md. Check CHANGELOG has an entry for the new version. No secrets exposed. Approve if clean, reject with blocking reason if not.`)

// Step 9 — if review passed, auto-merge
Bash("gh pr merge --squash --auto --delete-branch")
```

## Run it

Invoke `/ship` and walk away. The command runs end-to-end without requiring input.
If the reviewer finds a blocking issue, it will be printed and the merge will be skipped.
