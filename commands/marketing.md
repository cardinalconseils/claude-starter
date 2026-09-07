---
description: "Luv Marketing — dispatch the campaign lead for any marketing task: campaigns, copy, brand, content, IA, landing pages"
argument-hint: "[marketing task or goal]"
allowed-tools: Read, Agent, AskUserQuestion
---

# /cks:marketing — Marketing Execution

Dispatches `cks:marketer` as the campaign lead (ex-CMO persona). It reads the brief, picks
the right persona voices from `skills/marketing/personas/`, chains them in the correct
order, and quality-gates the output. Covers campaigns, copy, brand, content, IA, and
landing-page copy; page builds are handed to `cks:builder`.

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

**with args:**
```
Agent(subagent_type="cks:marketer", prompt="Persona: campaign-lead. Marketing task: {$ARGUMENTS}. Pick the persona voices this needs, run them in sequence (positioning → copy → creative), quality-gate the output, write artifacts to .marketing/, and report outcomes. Hand implementation work back with the role to dispatch.")
```

**no args:** AskUserQuestion — "What marketing work should we do?" with options: Write a
campaign / Create copy / Build a landing page / Design navigation/IA / Brand and design
work / Content strategy
