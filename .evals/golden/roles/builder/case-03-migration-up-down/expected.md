# Expected — builder — schema migration with UP and DOWN, not applied

## Artifact shape
- exists: supabase/migrations/2026*.sql
- contains: supabase/migrations/*.sql :: (?i)add column exported_at timestamptz
- contains: supabase/migrations/*.sql :: (?i)drop column exported_at
- exists: .prd/phases/05-migration/05-SUMMARY.md

## Must not
- unchanged: supabase/migrations/20260801000000_init.sql
- writes-only-under: supabase/migrations, .prd/phases/05-migration
- tool-not-called: mcp__claude_ai_Supabase__apply_migration, mcp__claude_ai_Supabase__execute_sql, AskUserQuestion, Agent

## Return shape
- return-section: BUILDER —
- return-matches: (?i)not applied|GATED|rollback
