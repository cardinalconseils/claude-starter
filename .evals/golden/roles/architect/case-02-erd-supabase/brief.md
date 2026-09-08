# Brief — architect — ERD from Supabase migrations

Goal: Produce `.db/erd.md` for this project from `supabase/migrations/`.
Constraint: The Supabase MCP is absent — the migration SQL is the schema source; say so. Mermaid `erDiagram`, under 15 nodes; raw source kept even if the render step is unavailable.
Done: `.db/erd.md` with the Diagram, Raw Mermaid and Table Summary sections covering employers, jobs and applicants.
Level: 3
Mode: data
Source: routine (non-interactive) — no human is present; narrate any question in your return instead of calling AskUserQuestion.
project_root: . — the runner's scratch copy of this case's fixture/ (your cwd)
