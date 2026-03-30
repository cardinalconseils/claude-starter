# Hooks

Event-driven automation that runs without user action. Hooks fire on Claude Code events and execute shell scripts.

## Active Hooks

| Event | Handler | What It Does |
|-------|---------|-------------|
| **SessionStart** | `session-start.sh` | Shows PRD status or onboarding prompt, detects version updates, injects last session context |
| **PreToolUse** | `pre-commit-guard.sh` | Blocks commits containing secrets, debug code, .env files, or large files (>1MB) |
| **PostToolUse** | `post-edit-guard.sh` | Warns about console.log and TODO/FIXME markers after file edits |
| **Stop** | `stop.sh` | Reminds about uncommitted changes and missing session close |
| **Stop** | `session-learnings.sh` | Captures branch, commits, changed files, and TODOs into `.learnings/session-{date}.md` |

## How It Works

`hooks.json` maps events to handler scripts. Claude Code fires events automatically — no user action needed.

```
Event fires → hooks.json routes to handler → handler script runs → output shown to Claude/user
```

Exit codes matter:
- `exit 0` — success, no action
- `exit 2` — **block** the tool call (used by pre-commit-guard to prevent bad commits)
- Any output is shown to Claude as context

## Customization

### Disabling a hook

Remove its entry from `hooks.json`. Don't delete the script — you might want it back.

### Adjusting behavior

Edit the handler scripts in `handlers/`:

- **Secret patterns**: Edit `SECRET_PATTERNS` array in `pre-commit-guard.sh` to add/remove detection patterns
- **Debug code detection**: Edit `DEBUG_PATTERNS` in `pre-commit-guard.sh`
- **Edit warnings**: Edit `post-edit-guard.sh` to change what triggers warnings (e.g., add linting)
- **Session status**: Edit `session-start.sh` to change the onboarding or resume display
- **Learnings capture**: Edit `session-learnings.sh` to change what data is persisted

### Adding your own hooks

1. Create a script in `handlers/` (e.g., `handlers/my-hook.sh`)
2. Add an entry in `hooks.json`:

```json
{
  "PostToolUse": [
    {
      "matcher": "tool == \"Bash\"",
      "hooks": [
        {
          "type": "command",
          "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/handlers/my-hook.sh"
        }
      ]
    }
  ]
}
```

### Available events

| Event | Fires When | Common Use |
|-------|-----------|-----------|
| `SessionStart` | Claude Code session begins | Load context, show status |
| `PreToolUse` | Before a tool executes | Validate, block dangerous actions |
| `PostToolUse` | After a tool executes | Warn about issues, log activity |
| `Stop` | Session ends | Capture learnings, remind about cleanup |
| `SubagentStop` | Subagent finishes | Post-process agent output |
| `UserPromptSubmit` | User sends a message | Validate input, inject context |
| `PreCompact` | Before context compression | Save state before compression |
| `Notification` | Notification event | Custom alerting |

## File Structure

```
hooks/
├── hooks.json              Event → handler mapping
└── handlers/
    ├── session-start.sh     SessionStart handler
    ├── pre-commit-guard.sh  PreToolUse handler (git commit)
    ├── post-edit-guard.sh   PostToolUse handler (Edit/Write)
    ├── stop.sh              Stop handler (uncommitted reminder)
    └── session-learnings.sh Stop handler (capture session data)
```
