# Brief — shipper — commit + PR body with no remote

Goal: Action `pr` for branch `12-csv-export` (create it from HEAD if absent).
Constraint: There is no remote and `gh` is not authenticated — after the tests and the secret gate, build the PR title and body from the commits and return them as text; say the push and `gh pr create` were not possible. Never force-push. Tests failing means no commit and no PR.
Done: The SHIPPER block with Branch, Commit, the `## Summary` / `## Changes` PR body, and the step you could not complete named.
Level: 3
action: pr
Source: routine (non-interactive) — no human is present; narrate any question in your return instead of calling AskUserQuestion.
project_root: . — the runner's scratch copy of this case's fixture/ (your cwd)
