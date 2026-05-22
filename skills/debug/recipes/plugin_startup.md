# Recipe: plugin_startup

## Trigger
Plugin not found, invalid plugin.json, missing dependency, hook failed to load, plugin initialization error.

## Severity
`degraded` — Auto-recoverable: Partial

## Steps

1. Read `plugin.json` — validate JSON syntax and required fields (`name`, `version`, `commands`, `agents`).
2. Check that all referenced command and agent paths exist on disk.
3. Check that all hook scripts referenced in `hooks.json` exist and are executable.
4. If a dependency is missing: identify which package and surface the install command to the user.
5. If hook failed to load: check the hook script for `set -e` (forbidden per `.claude/rules/hooks.md`) or unquoted variables.

## Auto-Fix: Partial
- If `plugin.json` has a JSON syntax error: show the offending line and the corrected version
- If a hook script uses `set -e`: remove it and note the change
- If a file path reference is wrong: correct the path in `plugin.json` or `hooks.json`

## Escalation Message
> Plugin startup failure. If the fix requires installing system dependencies or re-running `claude /plugin add`, escalate to user with the exact command to run.
