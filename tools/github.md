# GitHub Tool

## What It Is
GitHub hosts the [PROJECT_NAME] repository and manages pull requests,
issues, and CI/CD triggers.

## Repository
- URL: `[GITHUB_REPO_URL]`
- Main branch: `[MAIN_BRANCH]`
- Production branch: `[MAIN_BRANCH]` (merges here trigger deployment)

## Key Operations

### Clone
```bash
git clone [GITHUB_REPO_URL]
```

### Create a branch
```bash
git checkout -b feature/[branch-name]
```

### Open a PR
Push branch, then open PR via GitHub UI or:
```bash
gh pr create --title "[title]" --body "[description]"
```

### Check CI status
```bash
gh pr checks [pr-number]
```

### Merge (after approval)
```bash
gh pr merge [pr-number] --squash
```

## Branch Conventions
- `[MAIN_BRANCH]` — production, protected, requires PR + review
- `feature/*` — new features
- `fix/*` — bug fixes
- `chore/*` — maintenance, non-functional changes

## Subtree Commands (for claude-starter sync)

```bash
# Pull updates from claude-starter
git subtree pull --prefix .claude [GITHUB_REPO_URL] main --squash

# Push new components to claude-starter
git subtree push --prefix .claude [GITHUB_REPO_URL] main
```

## Constraints
- Never force push to `[MAIN_BRANCH]`
- Never merge without passing CI
- Never commit secrets, env var values, or credentials
