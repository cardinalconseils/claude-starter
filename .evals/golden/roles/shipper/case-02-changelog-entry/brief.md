# Brief — shipper — changelog entry from git history

Goal: Action `changelog` — add the entry for the commits since tag `v1.4.2` (no tag exists: use the full history) under `## [Unreleased]` in `CHANGELOG.md`.
Constraint: Match the existing style, categorized, short hashes kept, merge commits skipped. Version bump is skipped (not a plugin) — say so.
Done: `CHANGELOG.md` updated in place, nothing else written.
Level: 3
action: changelog
Source: routine (non-interactive) — no human is present; narrate any question in your return instead of calling AskUserQuestion.
project_root: . — the runner's scratch copy of this case's fixture/ (your cwd)
