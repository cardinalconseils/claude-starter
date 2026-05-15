---
name: attractor
description: "Attractor pipeline orchestrator — YAML node handlers, auto-decision criteria, review-merge-loop instructions for the CKS sprint lifecycle"
allowed-tools:
  - Read
  - Write
  - Bash
  - Agent
---

# Attractor Skill

Provides deterministic handlers and decision criteria for the `pipelines/sprint.dot` runner.
Instead of embedding all logic in `agents/attractor-runner.md`, mechanics are split by format:

- **Commands / bash steps** → YAML (deterministic, no LLM reinterpretation)
- **Pass/fail criteria** → YAML (same scoring every run)
- **Reasoning-heavy agent instructions** → `.md` workflows (judgment required)
- **Graph structure + edges** → `.dot` (authoritative)

## Format Registry

| node_type | file | section / key |
|-----------|------|---------------|
| Inline: Worktree setup | `skills/attractor/node-handlers.yaml` | `worktree` |
| Inline: CreatePR | `skills/attractor/node-handlers.yaml` | `create_pr` |
| Inline: AutoMerge | `skills/attractor/node-handlers.yaml` | `auto_merge` |
| Inline: Learnings | `skills/attractor/node-handlers.yaml` | `learnings` |
| Inline: Sprint completion | `skills/attractor/node-handlers.yaml` | `sprint_completion` |
| Inline: Startup banner | `skills/attractor/node-handlers.yaml` | `startup` |
| Auto-decision: ReviewPlan | `skills/attractor/auto-decisions.yaml` | `review_plan` |
| Auto-decision: SprintReview | `skills/attractor/auto-decisions.yaml` | `sprint_review` |
| Agent: ReviewAndTest | `skills/attractor/workflows/review-merge-loop.md` | `§ReviewAndTest` |
| Agent: DebugFix | `skills/attractor/workflows/review-merge-loop.md` | `§DebugFix` |

## Loading Protocol

Runner reads each file on first use for that node type — lazy, not at startup.
This keeps the runner context window at ~120 lines instead of 679.

Variables available when executing YAML `cmd` fields:
- `${BRANCH}` — current sprint branch name
- `${WORKTREE_PATH}` — `.claude/worktrees/<branch>`
- `${FEATURE_SLUG}` — lowercased, hyphenated feature name
- `${RUN_ID}` — checkpoint run ID
- `${PR_URL}` — set after create_pr completes
- `${DATE}` — YYYY-MM-DD
