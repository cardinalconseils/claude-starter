---
name: parallel-dispatch
description: "Parallel worker dispatch for the Build node — task grouping rules (disjoint file paths, max 4 groups, domain split), worktree lifecycle, sequential merge strategy"
allowed-tools:
  - Agent
  - Bash
  - Read
  - Glob
  - Grep
---

# Parallel Dispatch — Concurrent Worker Execution

## Overview

Parallel dispatch is the Build node's task execution layer. The Build node dispatches up to 4 concurrent `cks:prd-executor-worker` agents, each in a git worktree with disjoint file domains. All agents run in a single message (concurrent). Results are merged sequentially back into the feature branch. This isolates workers from each other, prevents merge conflicts during concurrent editing, and enables parallel development at scale.

## Task Grouping Rules

Groups MUST have no shared file paths. Disjointness is enforced at the file level, not directory level.

**Max 4 groups per dispatch** — this is a hard message limit. Agent message count cannot exceed 4 agents per message.

**Default domain split** when PLAN.md grouping is ambiguous:
- **Domain A**: `tools/`, `scripts/`, `.claude-plugin/`
- **Domain B**: `agents/`, `pipelines/`
- **Domain C**: `commands/`
- **Domain D**: `docs/`, `skills/`, `.github/`

If two groups share a domain but touch different files, they are safe to parallelize. Example: Group 1 modifies `commands/foo.md` and Group 2 modifies `commands/bar.md` — disjoint files, parallel-safe.

If grouping is unclear after checking PLAN.md, default to 2 groups: backend/tools (Domains A+B) vs commands/docs (Domains C+D). Never leave grouping implicit — always validate disjointness before dispatch.

## Worktree Lifecycle

Step-by-step execution of parallel workers:

**1. Dispatch Phase**
Runner calls `Agent(subagent_type="cks:prd-executor-worker", isolation="worktree", prompt=taskGroup)` for each group — ALL in one message. Workers execute concurrently.

**2. Worker Phase**
Each worker has its own isolated worktree; it cannot see or touch other workers' files. Worker is independent: it reads its own code, writes/commits its own changes, generates SUMMARY.md, and returns to the runner.

**3. Collection Phase**
Runner reads each SUMMARY.md from completed workers. Collects results in memory.

**4. Merge Phase**
For each worktree with changes: merge branch into feature branch (sequential, one at a time). For each worktree with no changes: auto-cleaned (no branch created, no merge needed).

**5. State Recording Phase**
Runner updates PRD-STATE `worktree_summaries` array with all merge results: which worktrees succeeded, which failed, which had no changes.

## Sequential Merge Strategy

Merges happen ONE AT A TIME after all workers complete. Order: merge group 1, then group 2, then group 3, then group 4.

**Why sequential:** Parallel merges cause branch conflicts. If Worker A and Worker B both try to update the feature branch at the same instant, git will reject one of the merges. Sequential execution prevents this entirely.

**On conflict:** When a merge fails (two workers unknowingly touched the same file): log the conflict, mark `mergeStatus: "conflict"` in that worktree's summary entry, skip that branch, and continue with the next merge. Runner continues with partial results — a failed worker does not block other merges. The team lead resolves conflicts manually after the build node completes.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "These two groups touch the same directory, that's close enough to disjoint" | Directory ≠ file. Two groups touching `commands/foo.md` and `commands/bar.md` are safe. Two groups both touching `commands/foo.md` are not. |
| "I can dispatch 6 workers, the limit is per message not per node" | Max 4 per message is a hard limit. Collapse excess groups. |
| "I'll merge all worktrees at once to save time" | Parallel merges cause conflicts. Always sequential. |
| "The PLAN.md doesn't specify groups, I'll figure it out at runtime" | Default to Domain A+B vs C+D split. Never leave grouping implicit. |
| "A worker with no changes still needs a merge step" | No-change worktrees are auto-cleaned. No merge, no PR. |

## Verification

- [ ] PLAN.md task groups are read and validated for disjointness before dispatch
- [ ] Max 4 groups enforced — excess groups collapsed and logged
- [ ] All workers dispatched in a single Agent message (concurrent)
- [ ] Each worker uses `isolation: "worktree"`
- [ ] Merges happen sequentially after ALL workers complete
- [ ] PRD-STATE `worktree_summaries` updated after merge loop
- [ ] No-change worktrees cleaned up, not merged
