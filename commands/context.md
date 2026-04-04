---
description: "Research a topic, library, or API and save a persistent context brief to .context/"
argument-hint: '"topic to research" [--refresh]'
allowed-tools:
  - Read
  - Write
  - Bash
  - Glob
  - Grep
  - WebSearch
  - WebFetch
  - Skill
  - "mcp__*"
---

# /cks:context — Auto-Research Before Coding

Research a topic and produce a persistent brief in `.context/`.

## Quick Reference

```
/cks:context "Stripe subscriptions with Next.js"
/cks:context "Supabase RLS policies"
/cks:context "React Server Components" --refresh
```

## Argument Handling

- **Required**: Topic string (quoted)
- `--refresh`: Force re-research even if a context file already exists

## Output

Creates `.context/<slugified-topic>.md` with:
- API patterns and key concepts
- Code examples and gotchas
- Links to official docs
- Date researched (for staleness detection)
