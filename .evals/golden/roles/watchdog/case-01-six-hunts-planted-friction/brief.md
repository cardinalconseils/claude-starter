# Brief — watchdog — the hunts on a repo with planted friction

Goal: Run every hunt on this repo and report the friction nobody filed.
Constraint: Report only. Cite a file, line, run id or date for every finding. At most seven findings, oldest silence first.
Done: The WATCHDOG block with FRICTION, AGENCY KPIs (or COULD NOT CHECK for what is unreadable here), CHECKED, CLEAN, and COULD NOT CHECK.
Level: 1
Source: routine (non-interactive) — no human is present; narrate any question in your return instead of calling AskUserQuestion.
project_root: . — the runner's scratch copy of this case's fixture/ (your cwd)

## Context
Today is 2026-09-07. The repo has no remote, so open PRs and branch ages cannot be read — say so. Agency traces under `.prd/logs/agents/` are absent.
