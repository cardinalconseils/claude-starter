# Context Fork Rule

## Mandatory Behavior

At 75% context window consumption, `hooks/handlers/context-guard.sh` (UserPromptSubmit hook) blocks the current message and instructs the user to run `/fork`. The hook exits 1, preventing message processing until the user forks.

This is a deterministic rail, not a suggestion — the block fires every time the threshold is crossed.

## What /fork Does

Claude Code's native `/fork` branches the conversation at the current point. The new branch inherits full history but starts with a fresh context budget. Work continues uninterrupted in the forked branch.

Fallback if `/fork` is unavailable: `/compact` then `/clear`, then resume with `/cks:sprint-start`.

## Why 75%

- Below 75%: auto-compact is still effective; no intervention needed
- At 75%: enough headroom remains for `/fork` to capture full state cleanly
- Above 80%: risk of truncation in the forked branch

## What the Hook Cannot Do

The hook detects and blocks. It cannot programmatically invoke `/fork` — that is always a user action. This is the correct pattern per `setup-philosophy.md`: deterministic detection + user-executed action.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The user can dismiss the block and keep going" | Exit 1 hard-blocks the message. They cannot proceed without forking or restarting. |
| "Auto-compact is good enough" | Auto-compact loses tool output and truncates history. /fork preserves it. |
| "Lower thresholds give more warning time" | The previous 48%/55% system fired too early and was non-blocking. One threshold at 75% that actually blocks is more effective. |
| "The hook should just warn, not block" | Warnings are ignored. The block is the enforcement. See `setup-philosophy.md` — rules without enforcement have zero adoption. |
