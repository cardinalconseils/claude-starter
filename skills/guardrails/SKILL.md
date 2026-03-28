---
name: guardrails
description: "Domain guardrail rules — generated at bootstrap time based on detected stack. Produces scoped .claude/rules/ files for security, testing, database, and docs."
triggers:
  - "/cks:bootstrap"
  - "manual"
---

# Domain Guardrails

## Purpose

During `/cks:bootstrap`, after language rules are generated (Step 6), this skill generates domain-specific guardrail files. Each guardrail is scoped via `globs:` frontmatter so Claude Code only loads it when the user touches relevant files.

## Invocation

This skill is invoked by bootstrap with scan context. It does NOT run standalone — it depends on the scan data collected in bootstrap Step 2.

**Expected input from bootstrap:** The caller passes a summary of detected concerns:

```
has_api_routes:    true/false   (from Step 2b — API route directories found)
has_auth:          true/false   (from Step 2b — auth patterns detected)
has_tests:         true/false   (from Step 2b — test framework detected)
has_database:      true/false   (from Step 2b — ORM/DB client detected)
test_framework:    jest|vitest|pytest|go-test|cargo-test|none
db_client:         prisma|drizzle|supabase|mongoose|sqlalchemy|knex|none
auth_method:       clerk|supabase-auth|next-auth|passport|lucia|jwt|none
api_style:         REST|GraphQL|tRPC|none
api_directory:     path (e.g. "app/api/" or "routes/")
```

## Rule Generation Logic

For each concern detected, load the corresponding catalog and write the rule file:

```
1. ALWAYS generate:
   - .claude/rules/docs.md (every project has documentation)

2. IF has_api_routes OR has_auth:
   - Load catalogs/security.md
   - Customize with: auth_method, api_style, api_directory
   - Write to .claude/rules/security.md

3. IF has_tests:
   - Load catalogs/testing.md
   - Customize with: test_framework
   - Write to .claude/rules/testing.md

4. IF has_database:
   - Load catalogs/database.md
   - Customize with: db_client
   - Write to .claude/rules/database.md
```

## Customization

When writing each rule file, replace catalog placeholders with project-specific values:

- `{AUTH_METHOD}` → detected auth method (e.g., "Clerk", "Supabase Auth")
- `{API_DIRECTORY}` → detected API route directory
- `{TEST_FRAMEWORK}` → detected test framework name
- `{TEST_COMMAND}` → detected test run command (from package.json scripts)
- `{DB_CLIENT}` → detected database client/ORM
- `{MIGRATION_COMMAND}` → detected migration command (if any)

If a placeholder has no detected value, use the generic default from the catalog.

## Output

After generating, report to the caller:

```
Guardrails generated:
  .claude/rules/security.md    ← API routes + {auth_method} detected
  .claude/rules/testing.md     ← {test_framework} detected
  .claude/rules/database.md    ← {db_client} detected
  .claude/rules/docs.md        ← Always included
```

Only list files that were actually generated.

## Constraints

- Only generate rules for detected concerns — never speculatively
- Each rule file must have valid `globs:` frontmatter for Claude Code scoping
- Keep each file under 80 lines — guardrails must be scannable, not encyclopedic
- Rules must be actionable ("do X", "never Y") — no explanatory prose
- Do not duplicate content from language-rules — guardrails cover domain concerns, not syntax
