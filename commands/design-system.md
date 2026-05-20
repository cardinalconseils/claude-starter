---
description: "Generate a DESIGN.html — interactive HTML design system with rendered swatches, live type specimens, and mini-site nav"
argument-hint: "[URL or 'inspired by BRAND']"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:design-system

Generate a complete DESIGN.html at the project root.

## Re-run Detection

Check for existing `DESIGN.html`:
- If exists → ask:
  ```
  AskUserQuestion:
    question: "DESIGN.html already exists. How to proceed?"
    options:
      - "Update — regenerate from current brand sources"
      - "Keep — exit without changes"
  ```

## Dispatch

```
Agent(subagent_type="cks:design-system-generator", prompt="Generate a complete DESIGN.html for this project. Arguments: $ARGUMENTS. Check for .kickstart/brand.md first. If the user provided a URL, extract design tokens from it. If 'inspired by BRAND', reference the design-md-examples for that brand's style.")
```

## Quick Reference

| Usage | Example |
|-------|---------|
| From website | `/cks:design-system https://example.com` |
| From brand | `/cks:design-system` (reads `.kickstart/brand.md`) |
| Inspired by | `/cks:design-system inspired by Linear` |
| Guided Q&A | `/cks:design-system` (no args, no brand file) |
