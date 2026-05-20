---
description: "Generate the design system — canonical DESIGN.md plus a rendered DESIGN.html view with swatches, type specimens, and mini-site nav"
argument-hint: "[URL or 'inspired by BRAND']"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:design-system

Generate the project design system — `DESIGN.md` (canonical) and `DESIGN.html` (rendered view) — at the project root.

## Re-run Detection

Check for an existing `DESIGN.md` or `DESIGN.html`:
- If either exists → ask:
  ```
  AskUserQuestion:
    question: "A design system already exists. How to proceed?"
    options:
      - "Update — regenerate from current brand sources"
      - "Keep — exit without changes"
  ```

## Dispatch

```
Agent(subagent_type="cks:design-system-generator", prompt="Generate the design system for this project — write canonical DESIGN.md and a matching DESIGN.html view. Arguments: $ARGUMENTS. Check for .kickstart/brand.md first. If the user provided a URL, extract design tokens from it. If 'inspired by BRAND', reference the design-md-examples for that brand's style.")
```

## Quick Reference

| Usage | Example |
|-------|---------|
| From website | `/cks:design-system https://example.com` |
| From brand | `/cks:design-system` (reads `.kickstart/brand.md`) |
| Inspired by | `/cks:design-system inspired by Linear` |
| Guided Q&A | `/cks:design-system` (no args, no brand file) |
