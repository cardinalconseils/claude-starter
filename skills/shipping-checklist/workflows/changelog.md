# Workflow: Changelog

Categorized `CHANGELOG.md` entry from git history. Ported from the `changelog-generator`
agent. Run by the shipper role (its `CHANGELOG.md` edit scope).

## Range

`since` arg (tag, hash, or date) if given; else `git describe --tags --abbrev=0`..HEAD; no
tags → last 50 commits.

## Collect

```bash
git log {range} --pretty=format:"%H|%s|%an|%ad" --date=short
```

Skip merge commits.

## Categorize

| Prefix | Category |
|---|---|
| `feat:` | Features |
| `fix:` | Bug Fixes |
| `refactor:` | Refactoring |
| `docs:` | Documentation |
| `style:` | Style |
| `test:` | Tests |
| `chore:` | Maintenance |
| `perf:` | Performance |
| `ci:` | CI/CD |
| none | Other |

## Entry

```markdown
## [{version or date}] — {YYYY-MM-DD}

### Features
- {commit message} ({short hash})

### Bug Fixes
- {commit message} ({short hash})
```

Group by category, sort by date within each, include the short hash.

## Write

`CHANGELOG.md` exists → prepend the entry after the title line, matching the existing style
(`scripts/bump-version.sh` may already have inserted a heading — extend it, do not duplicate).
Absent → create with `# Changelog` + the entry. Report the commit count categorized.
