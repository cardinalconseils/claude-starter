# Brief — reviewer — security quick scan: planted secret and missing RLS

Goal: Security quick scan of the changed files `src/config.js` and `supabase/migrations/20260801000000_init.sql`.
Constraint: Secrets are reported as pattern and location only — never the value. Every table without RLS is a named finding. Security findings in full prose. Supabase MCP absent — the SQL is the schema source.
Done: The graded REVIEW block with OWASP category and remediation per finding.
Level: 3
Mode: security
Source: routine (non-interactive) — no human is present; narrate any question in your return instead of calling AskUserQuestion.
project_root: . — the runner's scratch copy of this case's fixture/ (your cwd)
