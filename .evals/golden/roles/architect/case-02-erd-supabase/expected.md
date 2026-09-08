# Expected — architect — ERD from Supabase migrations

## Artifact shape
- exists: .db/erd.md
- contains: .db/erd.md :: erDiagram
- heading: .db/erd.md :: Table Summary
- contains: .db/erd.md :: applicants
- contains: .db/erd.md :: employers

## Must not
- writes-only-under: .db
- unchanged: supabase/migrations/20260801000000_init.sql
- tool-not-called: AskUserQuestion, Agent

## Return shape
- return-section: DESIGN —
- return-matches: \.db/erd\.md
- return-matches: (?i)RLS|row level
