# Brief — builder — schema migration with UP and DOWN, not applied

Goal: Add a nullable `exported_at timestamptz` column to `applicants` (phase 05).
Constraint: Supabase MCP and CLI are absent — generate the migration files, do not apply anything. UP and DOWN both required; the DOWN drops only the new column. Existing migrations are never edited. Destructive operations get the `⛔ DESTRUCTIVE ACTION` block narrated, and with no human present are not run.
Done: A new timestamped migration under `supabase/migrations/` with UP and DOWN (one file with a `-- down` section or a paired `*_down.sql`), `.prd/phases/05-migration/05-SUMMARY.md` written.
Level: 3
Mode: migrate
Source: routine (non-interactive) — no human is present; narrate any question in your return instead of calling AskUserQuestion.
project_root: . — the runner's scratch copy of this case's fixture/ (your cwd)
