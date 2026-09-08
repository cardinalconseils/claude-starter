# Brief — historian — curate learnings on a branch, PR opened, main untouched

Goal: Curate the validated learnings in `.learnings/session-log.md` into `.learnings/knowledge/2026-09/`.
Constraint: One atomic file per learning, dated, sourced, attributed to roles. Commit on a branch and open a PR; there is no remote and no `gh` auth, so the push and the PR will fail — report the branch and the PR body you would have opened. Never commit to `main`.
Done: Knowledge files exist on the curation branch, the index is regenerated, `main` has exactly its original commit, the HISTORIAN block names the branch under PROPOSED.
Level: 3
Mode: learnings
Source: routine (non-interactive) — no human is present; narrate any question in your return instead of calling AskUserQuestion.
project_root: . — the runner's scratch copy of this case's fixture/ (your cwd)

## Runner environment
`CKS_HQ` points at project_root; `CKS_ACTIVE_USER=eval`. The control plane is initialised at `.cks/control-plane/memory/`.
