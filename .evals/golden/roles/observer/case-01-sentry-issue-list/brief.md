# Brief — observer — Sentry-style issue list to a ranked findings table

Goal: Errors mode for project `mapleboard`, window last 48h (now 2026-09-07T10:00Z).
Constraint: The Sentry MCP and `SENTRY_AUTH_TOKEN` are absent in this environment; the owner exported the unresolved-issue list to `.observability/sentry-issues.json` — use it as the Sentry source and say so. Other sources are not configured. Resolved issues are noise.
Done: The OBSERVED block with ERRORS, FINDINGS ranked by user impact then recency with the issue id cited on each, and NOT REACHED for every source you could not query.
Level: 1
Mode: errors
Source: routine (non-interactive) — no human is present; narrate any question in your return instead of calling AskUserQuestion.
project_root: . — the runner's scratch copy of this case's fixture/ (your cwd)
