# Workflow: Release the Plugin

Clean → bump → commit → PR for a CKS plugin release. Ported from the `ship-runner` agent.
Run by the shipper role. Never pushes a release commit to `main`.

## Step 1 — Dry-run clean

`git clean -fdxn` filtered to project-document patterns; show what would be removed.

Untracked project docs to clean: `.prd/`, `.learnings/`, `.kickstart/`, `.attractor/`,
`.concept/`, `.evals/`, `.assess/`, `.voice/`, `.ideation/`, `.agents/`, `.agentic-os/`.

Tracked project docs that may be modified: `.prd/HANDOFF.md`, `.prd/PRD-STATE.md`,
`.prd/work-hierarchy.md`, `.prd/prd-config.json`, `.prd/session-*.md` — show `git status`
for them.

`--dry-run` → stop here.

## Step 2 — Confirm

Emit the block from `.claude/rules/destructive-ops.md`:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⛔ DESTRUCTIVE ACTION — REVIEW BEFORE PROCEEDING
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Action:     Remove untracked project docs + restore tracked project docs
Target:     [list from the dry-run above]
Reversible: NO — git clean removes files; git restore discards uncommitted edits
You lose:   Any uncommitted work in the listed project doc files
Safer alt:  /cks:ship --dry-run to preview without changes
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Then `AskUserQuestion`: "Proceed with clean and ship?" — Proceed / Abort. Abort → exit.

## Step 3 — Clean

`git clean -fdx <path> <path> …` with each pattern as an explicit path argument — never bare
`git clean -fdx` on the repo. `git restore <file>` for modified tracked project docs.

## Step 4 — Bump

`bash scripts/bump-version.sh` (or `--bump-type patch|minor|major`); capture the new version.
Bump failure → stop, do not commit.

## Step 5 — Commit

Pre-commit scan of staged files for the marker words in `.claude/rules/verification.md`, then
`git add -A && git commit -m "chore: release v{version}"` with the session's co-author
trailer.

## Step 5b — Branch guard

`git branch --show-current`; on `main`/`master` → `git checkout -b release/v{version}`.

## Step 6 — Push + PR

Push the release branch; open a PR titled `chore: release v{version}` whose body is the
`CHANGELOG.md` excerpt for this version. Report the PR URL.

## Rules

- Never `git clean -fdx` without explicit paths
- Never skip the dry-run display
- Never commit if the bump script fails
- On any failure stop and report the exact error
