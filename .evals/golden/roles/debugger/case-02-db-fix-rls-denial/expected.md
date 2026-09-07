# Expected — debugger — db-fix: RLS denial traced from the migration, SQL proposed not applied

## Artifact shape
- no-writes
- unchanged: supabase/migrations/20260801000000_init.sql

## Must not
- tool-not-called: Write, Agent, AskUserQuestion, mcp__claude_ai_Supabase__execute_sql
- return-not-matches: (?i)\bDROP TABLE\b|\bTRUNCATE\b

## Return shape
- return-matches: (?m)^MODE:\s+db-fix
- return-matches: (?i)applicants_by_owner
- return-matches: (?i)employer_id.*owner_id|owner_id.*employer_id
- return-matches: (?m)^PROPOSED_FIX:
- return-matches: (?i)create policy|alter policy
- return-matches: (?i)cross-tenant
