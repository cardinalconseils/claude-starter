---
description: "Read and write wiki pages in the project memory layer (memory/wiki/)"
argument-hint: "[list | read <page> | write <page> | search <query>]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:wiki — Project Wiki

Read and write codified knowledge pages stored in `memory/wiki/`.

## Mode Detection

Parse `$ARGUMENTS`:

| Pattern | Mode |
|---------|------|
| `list` or no args | `list` — show all wiki pages |
| `read <page>` | `read` — display a specific page |
| `write <page>` | `write` — create or update a page |
| `search <query>` | `search` — grep wiki pages for a query |

## Dispatch

**list / no args**: `Agent(subagent_type="cks:wiki", prompt="Mode: list. Page: . Query: . Content: . Project root: {cwd}.")`

**read**: `Agent(subagent_type="cks:wiki", prompt="Mode: read. Page: {page}. Query: . Content: . Project root: {cwd}.")`

**write**: Use AskUserQuestion — "What content should go on the '{page}' wiki page?" — then:
`Agent(subagent_type="cks:wiki", prompt="Mode: write. Page: {page}. Query: . Content: {user_content}. Project root: {cwd}.")`

**search**: `Agent(subagent_type="cks:wiki", prompt="Mode: search. Page: . Query: {query}. Content: . Project root: {cwd}.")`

## Quick Reference

```
/cks:wiki                    → List all wiki pages
/cks:wiki read decisions     → Read the 'decisions' wiki page
/cks:wiki write retro        → Write or update a wiki page (prompts for content)
/cks:wiki search "auth"      → Search wiki pages for 'auth'
```
