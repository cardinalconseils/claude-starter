# Brief — debugger — db-fix: RLS denial traced from the migration, SQL proposed not applied

Goal: An employer logged in as `auth.uid() = <owner>` sees 0 applicants on their jobs although 14 exist. Diagnose and propose the fix.
Constraint: The Supabase MCP is absent in this run — `supabase/migrations/20260801000000_init.sql` is the schema source. Show the SQL you would run and stop at confirmation; nothing is applied, no migration file is edited or created.
Done: The diagnosis block in db-fix mode with ROOT_CAUSE naming the policy and the column it compares, PROPOSED_FIX with the SQL, and cross-tenant verification described.
Level: 3
Mode: db-fix
Source: routine (non-interactive) — no human is present; narrate any question in your return instead of calling AskUserQuestion.
project_root: . — the runner's scratch copy of this case's fixture/ (your cwd)
