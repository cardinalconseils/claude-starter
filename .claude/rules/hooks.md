---
globs: "hooks/**/*.{sh,json}"
---

# Hook Rules

- Hook scripts MUST exit 0 on success — non-zero blocks the triggering action
- NEVER use `set -e` in hooks — a failing grep/find should not block the user
- Always quote variables: `"$STATE_FILE"` not `$STATE_FILE`
- Use `2>/dev/null` on file checks that may not exist
- Hook scripts are for automation (logging, guarding) — NEVER dispatch agents or interact with user
- `hooks.json` entries MUST use `${CLAUDE_PLUGIN_ROOT}` for script paths
- Keep hook scripts under 30 lines — complex logic belongs in `scripts/`
