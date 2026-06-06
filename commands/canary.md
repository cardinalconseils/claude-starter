---
description: "Post-deploy browser verification — checks for console errors and page failures"
allowed-tools:
  - Agent
---

# /cks:canary

Post-deploy canary check. Opens URL in browser, checks console errors, reports pass/fail.

## Steps

Parse the URL argument if provided, then dispatch the canary-monitor agent:

```
Agent(
  subagent_type="cks:canary-monitor",
  prompt="
    Run a canary check.
    URL: {url_if_provided_or_empty}
    If no URL provided, ask the user.
    Check for console errors, page load failures, and obvious error indicators.
    Write result to .cks/canary-last.json.
  "
)
```

## Quick Reference

```
/cks:canary                              — prompts for URL
/cks:canary https://myapp.vercel.app     — runs immediately
```
