---
name: cks:factory-orchestrator
description: AFK software factory loop — reads labeled GitHub Issues, seeds a CONTEXT.md per issue, runs the attractor sprint pipeline in --auto mode for each, comments the PR back and clears the label. Runs in the top-level session so Agent() dispatch works.
allowed-tools:
  - Read
  - Write
  - Bash
  - Glob
  - Grep
  - Agent
  - Skill
  - AskUserQuestion
  - "mcp__plugin_github_github__list_issues"
  - "mcp__plugin_github_github__issue_write"
  - "mcp__plugin_github_github__add_issue_comment"
---

# Factory — The Loop

You are the AFK software factory, running at the top level of the session. `SKILL.md` is
the doctrine (Dark Factory: file then notify, labels, availability check). You drain a
queue of labeled issues by running the attractor sprint pipeline once per issue.

Inputs: `--label <label>` (default `cks:factory` + `cks:backlog`), `--dry-run`,
`--limit N`, `--auto`.

---

## 1. Startup

Banner `FACTORY ► AFK Software Pipeline` with label filter and mode (dry-run | live).

Repo coordinates from `git remote get-url origin` (HTTPS or SSH forms). No remote → stop:
"No GitHub remote found. /cks:factory requires a GitHub-connected repo."

GitHub MCP probe: `mcp__plugin_github_github__list_issues(owner, repo, state="open",
per_page=1)`. Error → stop: "GitHub MCP unavailable. Ensure the GitHub plugin is connected."

## 2. Fetch the queue

`list_issues(state="open", labels=<label>, per_page=50)` per target label; deduplicate;
sort by `created_at` ascending; apply `--limit`. Empty → banner `FACTORY ► Queue empty`
naming the labels and how to queue work; stop.

## 3. Show queue + confirm

List `#{number} — {title} [{label}]`. `--dry-run` → stop with "Dry run complete."

Not `--auto` →
```
AskUserQuestion:
  question: "Run the full CKS pipeline for {N} issue(s)? Each gets a branch, PR, and review cycle."
  header: "Factory"
  options: ["Yes — run all {N}", "Run first issue only", "No — cancel"]
```

## 4. Ensure labels

```bash
gh label create "cks:factory" --color "8B5CF6" --description "Queued for AFK factory pipeline" --repo {owner}/{repo} 2>/dev/null || true
```
(The lifecycle labels come from the github-issues skill during normal runs.)

## 5. Per issue

**5a. Announce** — `FACTORY ► #{number} — {title}` with `{N of total}` and timestamp.

**5b. Seed CONTEXT.md** so the Discover node starts with context instead of questions:
```bash
SLUG=$(echo "{title}" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | cut -c1-30 | sed 's/-$//')
CONTEXT_DIR=".prd/phases/{next-NN}-${SLUG}"; mkdir -p "$CONTEXT_DIR"
```
Write `$CONTEXT_DIR/CONTEXT.md`: `# Context — {title}`; Source (issue number, URL, label);
Goal (issue body, first 500 chars cut at a sentence boundary; title only when the body is
empty); Notes ("Seeded automatically by /cks:factory", "Scope: minimal — implement only
what the issue describes").

**5c. Run the sprint pipeline** — you are top-level, so load the attractor orchestrator
rather than dispatching a runner:
```
Skill(skill="cks:attractor")
  pipeline: sprint
  Arguments: --auto
  project_root: {absolute cwd}
  context_hint: {CONTEXT_DIR}/CONTEXT.md is pre-seeded from GitHub issue #{number}; read it at the Discover node
  github_issue: #{number} — include "Closes #{number}" in the PR body
```
Attractor gives checkpoints (resumable), goal gates (Plan + Implement + Verify) and a
fresh worktree per issue — what an unattended run needs. Capture the PR URL from the
checkpoint or completion banner, then return here.

**5d. Success** — comment on the issue (`🏭 **CKS Factory** — Pipeline complete`, PR URL,
phases, timestamp, "implemented autonomously by /cks:factory"); `issue_write` with the
existing labels minus `cks:factory` and `cks:backlog`; log `Issue #{number} ✅ — {N}/{total}`.

**5e. Failure** — comment `🏭 **CKS Factory** — Pipeline failed` with the error summary and
retry hint; leave the label (retry-safe); log ❌; continue with the next issue.

## 6. Final report

`FACTORY ► Complete` — processed, success and failure counts, PRs opened, and
`To review: gh pr list --label cks:auto-filed`.

## Error handling

| Situation | Action |
|---|---|
| No GitHub remote / MCP unavailable | Stop immediately, explain |
| Issue has no body | Title only as the brief |
| Pipeline timeout | Comment + skip, continue |
| PR creation fails | Comment with error, keep the label |
| All issues fail | Report every failure, exit non-zero |

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The issue might be too vague to implement" | Run it — the strategist infers from the codebase at Discover. Worst case: a PR with questions. |
| "Ask before each issue?" | No. Confirm once at the start; the rest is AFK. |
| "The pipeline is taking too long" | Let it run; abort only when truly hung. |
| "Skip design for backend issues?" | The pipeline decides at its gates; never pre-trim the graph. |
