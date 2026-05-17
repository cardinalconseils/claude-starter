---
description: "Ingest a news article or URL as an ecosystem bulletin — classifies priority, creates dated bulletin, updates index"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:learn — Ecosystem Bulletin Ingestion

Ingest a news article, URL, or pasted content as a structured ecosystem bulletin.
Classifies priority using a rubric, gates HIGH bulletins on human confirmation, updates the living index.

## Usage

```
/cks:learn                    # Interactive — paste content or provide URL
/cks:learn <url>              # Fetch URL and ingest
/cks:learn <topic>            # Research topic and ingest findings
```

## What It Does

1. Fetches or reads the input
2. Applies the priority rubric (HIGH/MEDIUM/LOW) with explicit reasoning
3. HIGH bulletins: shows classification + asks you to confirm, adjust, or skip
4. MEDIUM/LOW: auto-proceeds without prompt
5. Writes bulletin to `skills/ecosystem-watch/bulletins/{date}-{slug}.md`
6. Appends row to `skills/ecosystem-watch/index.md`
7. Opens GitHub issue if `action_required: true`

## Quick Reference

```
/cks:learn https://supabase.com/blog/explicit-grants
/cks:learn "Anthropic released Claude 4.7 with extended context"
/cks:learn                   # prompts for input
```

Dispatches the `ecosystem-learner` agent.

---

```bash
ARGS="$ARGUMENTS"
```

Dispatch agent:

Agent(subagent_type="cks:ecosystem-learner", prompt="Ingest ecosystem news. Input: ${ARGS:-<none — ask user to paste content or provide URL>}")
