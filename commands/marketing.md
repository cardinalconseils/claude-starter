---
description: "Luv Marketing — dispatch the CMO for any marketing task: campaigns, copy, brand, content, IA, landing pages"
argument-hint: "[marketing task or goal]"
allowed-tools: Read, Agent, AskUserQuestion
---

# /cks:marketing — Marketing Execution

Dispatches the Luv Marketing CMO. She reads the brief, picks the right specialists, chains them in the correct order, and quality-gates the output. Covers campaigns, copy, brand, content, IA, and landing pages.

## Quick Reference

```
/cks:marketing Write a launch campaign for our new AI feature
/cks:marketing Rewrite the hero copy — current messaging isn't converting
/cks:marketing Create a 30-day content calendar for LinkedIn
/cks:marketing Design the IA and navigation for our app
/cks:marketing Build a landing page for our webinar
/cks:marketing Run a competitive analysis and write a positioning brief
```

## Dispatch

**with args:** `Agent(subagent_type="luv:cmo", prompt="Marketing task: {$ARGUMENTS}. Orchestrate the right specialists, chain them in sequence, and report outcomes.")`

**no args:** AskUserQuestion — "What marketing work should we do?" with options: Write a campaign / Create copy / Build a landing page / Design navigation/IA / Brand and design work / Content strategy
