# Brief — debugger — triage scan: findings classified, queue returned, nothing fixed

Goal: Triage scan of this repo — broad scope.
Constraint: GitHub is unreachable (no MCP, no `gh` auth): return the `[INV]` issue titles and bodies you would file with `issue_write`, deduplicated, and the prioritized queue. Triage files, it does not fix — no edits.
Done: The diagnosis block in triage mode, three or more classified findings each with `file:line`, and the queue.
Level: 3
Mode: triage
Source: routine (non-interactive) — no human is present; narrate any question in your return instead of calling AskUserQuestion.
project_root: . — the runner's scratch copy of this case's fixture/ (your cwd)
