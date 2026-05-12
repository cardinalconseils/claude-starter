---
description: "Launch any CKS command as a background session — appears in Agent View"
allowed-tools:
  - Bash
  - AskUserQuestion
---

# /cks:bg — Background Session Launcher

Launch any CKS command as a background Claude Code session. The session appears in Agent
View (left arrow or `claude agents`) so you can monitor it without blocking your current session.

## Argument Parsing

`$ARGUMENTS` format: `[cks-command] [remaining args]`

- First token: the CKS sub-command (e.g. `sprint-run`, `sprint-auto`, `discover`)
- Remaining tokens: passed through to that command unchanged
- No arguments → default to `sprint-run`
- `--help` or `help` → show Quick Reference and exit

## Dispatch

Parse `$ARGUMENTS`:

1. If `$ARGUMENTS` is empty or not provided, set command to `sprint-run` with no args.
2. If first token is `--help` or `help`, print the Quick Reference block below and stop.
3. Otherwise, split: first token → `SUBCMD`, remainder → `SUBCMD_ARGS`.

Run:

```bash
claude --bg "/cks:$SUBCMD $SUBCMD_ARGS"
```

After a successful launch (exit 0), tell the user:

> Background session launched. Open Agent View (left arrow or `claude agents`) to monitor progress.

If `claude --bg` exits non-zero, show the error output and tell the user:

> Launch failed. You may need a newer version of Claude Code that supports Agent View (`claude --version`). Try updating with `claude update`.

## Quick Reference

```
/cks:bg                     Launch sprint-run in background (default)
/cks:bg sprint-run          Same as above, explicit
/cks:bg sprint-auto         Run full auto sprint in background
/cks:bg discover            Run discovery phase in background
/cks:bg sprint-run --resume Resume a sprint in background
```
