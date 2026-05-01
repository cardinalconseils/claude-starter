---
name: github-issues
description: "Auto-file GitHub issues at CKS lifecycle events (verification failure, retro, backlog punt) and gate deploy/release on open blocking issues. Dark Factory: file then notify, never prompt before filing."
allowed-tools:
  - "mcp__plugin_github_github__issue_write"
  - "mcp__plugin_github_github__list_issues"
  - Bash
  - AskUserQuestion
---

# GitHub Issues — CKS Integration

## Philosophy: Dark Factory

Issues are filed automatically at lifecycle events. The user is notified after filing, not asked before. This ensures quality debt is captured even when the user isn't watching.

## When to File Issues

| Lifecycle Event | Trigger | Label |
|----------------|---------|-------|
| Verification FAIL/PARTIAL | Acceptance criterion fails | `cks:blocking` |
| Retrospective action items | Agent identifies a bug or regression | `cks:blocking` |
| Retrospective improvements | Agent identifies enhancement or tech-debt | `cks:enhancement` |
| Backlog punt (4c) | User picks "ship now, fix later" | `cks:backlog` |

## Availability Check

Before filing, check if GitHub MCP is available:

```
Try: mcp__plugin_github_github__list_issues(owner, repo, state="open", per_page=1)
If error → log "GitHub MCP unavailable — skipping issue filing" and continue
If success → proceed with filing
```

Never block the lifecycle when GitHub MCP is unavailable. Degrade gracefully.

## Get Repo Coordinates

```bash
git remote get-url origin
# Parse: https://github.com/{owner}/{repo}.git → owner, repo
# Or: git@github.com:{owner}/{repo}.git → owner, repo
```

## Issue Title Format

```
[CKS] {emoji} {summary} ({phase-slug})
```

Emojis by type:
- `🔴` blocking (verification failure, bug)
- `🟡` backlog (punted scope)
- `🔵` enhancement (tech-debt, improvement)

Example: `[CKS] 🔴 Auth token not refreshed on expiry (03-auth-refresh)`

## Issue Body Template

```markdown
## Summary
{one-line description of the problem}

## Source
- **Phase:** {NN} — {phase-name}
- **Trigger:** {verification failure | retro | backlog punt}
- **Filed by:** CKS auto-filing (Dark Factory)
- **Date:** {YYYY-MM-DD}

## Details
{acceptance criterion text, or retro finding, or punted scope description}

## Evidence
{file path, test output excerpt, or verification result that surfaced this}
```

## Label Setup (one-time, idempotent)

Before the first filing, ensure labels exist using `gh` CLI:

```bash
gh label create "cks:auto-filed"  --color "6B7280" --description "Filed automatically by CKS" --repo {owner}/{repo} 2>/dev/null || true
gh label create "cks:blocking"    --color "EF4444" --description "Blocks deploy/release"       --repo {owner}/{repo} 2>/dev/null || true
gh label create "cks:backlog"     --color "F59E0B" --description "Punted scope, non-blocking"  --repo {owner}/{repo} 2>/dev/null || true
gh label create "cks:enhancement" --color "3B82F6" --description "Tech-debt or improvement"   --repo {owner}/{repo} 2>/dev/null || true
```

The `2>/dev/null || true` makes this idempotent — safe to run on every filing event.
If `gh` is not available → skip label creation, file issue without labels, include label intent in body.

## Label Taxonomy

| Label | Color | Meaning |
|-------|-------|---------|
| `cks:auto-filed` | `#6B7280` | Filed automatically by CKS |
| `cks:blocking` | `#EF4444` | Blocks deploy/release |
| `cks:backlog` | `#F59E0B` | Punted scope, non-blocking |
| `cks:enhancement` | `#3B82F6` | Tech-debt or improvement |

Always apply `cks:auto-filed` plus one category label.

## Dedup Strategy

Before filing, check for existing open issues with the same title:

```
mcp__plugin_github_github__list_issues(owner, repo, state="open", labels="cks:auto-filed")
```

If an issue with the same `[CKS]` title prefix and phase slug already exists → skip filing and note "already tracked as #{number}".

## Gate Check (for deploy and release)

Before deploying or releasing, check for open blocking issues:

```
issues = mcp__plugin_github_github__list_issues(
  owner, repo,
  state="open",
  labels="cks:blocking"
)
```

**If issues found:**
```
AskUserQuestion:
  question: "{N} open blocking issue(s) found. Proceed with deploy?"
  options:
    - "Deploy anyway — I'll fix these after"
    - "Stop — I'll resolve issues first"
```

If user chooses stop → exit without deploying. Do not bypass silently.

**If no issues found:** proceed normally.

## Soft Warning (for /cks:new)

Before starting a new feature, check total open issues:

```
issues = mcp__plugin_github_github__list_issues(owner, repo, state="open", labels="cks:auto-filed")
```

If any exist → display count and titles as a brief warning. Do NOT block. Let the user proceed.

```
⚠️  {N} open CKS issue(s) from previous features:
  #{n} — {title}
  #{n} — {title}
  ...
Proceeding with new feature. Run /cks:status to review.
```

## Factory Pickup — /cks:factory Integration

The `/cks:factory` command reads issues labeled `cks:factory` or `cks:backlog` and runs the full pipeline for each one.

### Label: `cks:factory`

New label for explicit opt-in queueing. Apply to any issue you want the factory to implement:

```bash
gh issue edit #{number} --add-label "cks:factory"
```

| Label | Pickup Trigger | Meaning |
|-------|---------------|---------|
| `cks:factory` | Always picked up by `/cks:factory` | Explicitly queued for autonomous implementation |
| `cks:backlog` | Also picked up by `/cks:factory` | Punted scope from a previous sprint |

### After Factory Processes an Issue

1. A PR is opened with `Closes #{number}` in the body
2. A comment is posted on the issue with the PR link
3. The `cks:factory` or `cks:backlog` label is removed
4. The issue stays open until the PR merges (GitHub auto-closes it)

### Label Setup (add to one-time script)

```bash
gh label create "cks:factory" --color "8B5CF6" --description "Queued for AFK factory pipeline" --repo {owner}/{repo} 2>/dev/null || true
```

## Common Rationalizations

| Rationalization | Reality |
|----------------|---------|
| "GitHub MCP might not be set up" | Always check first and degrade gracefully — never assume |
| "The user will remember to check VERIFICATION.md" | They won't. That's why Dark Factory exists. |
| "Filing feels intrusive" | One notification is less intrusive than shipping a bug |
| "The issue might be a fluke" | File it anyway. Closing a false positive costs 2 seconds. |
