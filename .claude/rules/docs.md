---
globs: "**/*.md"
---

# Documentation Rules

- CLAUDE.md MUST stay under 150 lines — it's a constitution, not a manual
- Style/testing/security rules belong in `.claude/rules/`, not CLAUDE.md
- README.md command count MUST match actual `commands/*.md` file count
- `commands/help.md` MUST reflect current command names and agent list
- NEVER leave `[TOKENS]` or `[PLACEHOLDER]` markers in committed files
- Agent and command descriptions MUST be one line — used for auto-triggering and help display
