---
name: changelog
description: "Auto-generate a CHANGELOG.md entry from git history"
argument-hint: "[--since <tag|commit|date>]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
---

# /cks:changelog — Auto-Generate Changelog

Generate a clean, categorized changelog entry from git history.

## Argument Handling

- No args: Changes since the last git tag (or all commits if no tags exist)
- `--since v1.0.0`: Changes since tag v1.0.0
- `--since 2024-01-01`: Changes since date

## Steps

### 1. Determine Range

```bash
# Find the starting point
if [[ "$ARGUMENTS" == *"--since"* ]]; then
  # Extract the value after --since
  SINCE="<user-provided value>"
else
  # Use last tag, or first commit if no tags
  SINCE=$(git describe --tags --abbrev=0 2>/dev/null || git rev-list --max-parents=0 HEAD)
fi
```

### 2. Gather Commits

```bash
git log ${SINCE}..HEAD --oneline --no-merges
```

### 3. Categorize

Parse commit messages using conventional commit prefixes. If commits don't follow conventions, infer category from the message content:

| Category | Prefixes / Signals |
|----------|-------------------|
| Features | `feat:`, `add:`, "add", "new", "implement" |
| Fixes | `fix:`, `bugfix:`, "fix", "resolve", "patch" |
| Refactoring | `refactor:`, `chore:`, "refactor", "clean", "restructure" |
| Documentation | `docs:`, "doc", "readme", "comment" |
| Performance | `perf:`, "optimize", "speed", "cache" |
| Breaking Changes | `BREAKING:`, `!:`, "breaking" |

### 4. Generate Entry

Format as a new entry at the top of CHANGELOG.md:

```markdown
## [Unreleased] — YYYY-MM-DD

### Features
- Description of feature ([commit-hash])

### Fixes
- Description of fix ([commit-hash])

### Refactoring
- Description of refactor ([commit-hash])
```

### 5. Write to File

- If `CHANGELOG.md` exists: insert new entry after the title line
- If `CHANGELOG.md` doesn't exist: create it with a `# Changelog` header

### 6. Report

```
✅ Changelog updated: CHANGELOG.md
   Range: ${SINCE}..HEAD
   Commits: ${N} total
   Features: ${N} | Fixes: ${N} | Refactoring: ${N}
```

## Rules

1. **Never overwrite existing entries** — only prepend new ones
2. **Link commits** — include short hash in parentheses
3. **Human-readable descriptions** — rewrite terse commit messages into clear descriptions
4. **Skip merge commits** — they add noise
5. **Group by category** — omit empty categories
