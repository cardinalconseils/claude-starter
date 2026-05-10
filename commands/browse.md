---
description: "Browser automation — open websites, fill forms, click buttons, screenshot, extract data. Auto-escalates to investigator when issues are found."
argument-hint: "<url or task description>"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:browse — Browser Automation

Dispatch the `cks:browser` agent to perform the task. The agent runs the browser session, detects any issues encountered, and automatically escalates to `cks:investigator` to file GitHub issues if problems are found.

## Pre-Dispatch

If `$ARGUMENTS` is empty:
```
AskUserQuestion("What would you like to automate in the browser? (URL, task description, or portal name)")
```

## Dispatch

```
Agent(
  subagent_type="cks:browser",
  prompt="Task: {$ARGUMENTS or user's answer}. Project root: {cwd}. After completing the task, detect any issues found during the session (console errors, broken elements, HTTP errors, auth failures). If issues are found, escalate to cks:investigator to file them to GitHub."
)
```

## Quick Reference

```
/cks:browse https://myapp.com              → Open and inspect a URL
/cks:browse "fill the signup form on ..."  → Automate a task
/cks:browse "check the dashboard"          → Inspect and report any issues found
/cks:browse "configure Stripe webhook"     → Portal configuration task
```
