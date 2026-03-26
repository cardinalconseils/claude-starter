# Workflow: Compaction Points

## Purpose

Defines when Claude should suggest `/compact` during the PRD lifecycle to prevent context degradation in long sessions. These are injected between phases automatically.

## When to Suggest Compaction

### Phase Boundaries (ALWAYS suggest)

After each phase completes, before the next begins:

```
/cks:discover completes → 💡 "Discovery complete. Context captured in {NN}-CONTEXT.md.
                            Run /compact before starting design to free context for the next phase."

/cks:design completes   → 💡 "Design complete. Specs saved to {NN}-DESIGN.md.
                            Run /compact before starting sprint to maximize implementation context."

/cks:sprint completes   → 💡 "Sprint complete. Run /compact before review."

/cks:review completes   → 💡 "Review complete. Run /compact before release."
```

### Within Sprint (suggest at sub-phase boundaries)

```
[3a] Planning done    → suggest compact if session > 50% context
[3c] Implementation   → suggest compact if session > 60% context
[3d] Code review done → suggest compact before QA
```

### After These Events

- After a failed approach (debugging dead end) → compact before trying new approach
- After research/exploration → compact before implementation
- After large file reads (>500 lines) → compact if not immediately using the content

## What Survives Compaction

Users need to know what persists and what's lost:

```
✅ SURVIVES compaction:
  - CLAUDE.md (project instructions)
  - TodoWrite items (task list)
  - Git state (branch, commits)
  - All files on disk (.prd/*, source code)
  - PRD-STATE.md (phase tracking)
  - Working Notes (session context)

❌ LOST on compaction:
  - File contents you read (re-read as needed)
  - Reasoning chains and conversation history
  - Tool call history
  - Variable names and partial implementation context
```

## Implementation

Each phase workflow file should include a compaction suggestion at the end:

```markdown
### Final Step: Compaction Suggestion

Output:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ {Phase Name} complete

All artifacts saved to disk. Consider running /compact
before the next phase to free context for {next phase name}.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Anti-Patterns

**NEVER suggest compaction:**
- Mid-implementation (active coding)
- During code review (need diff context)
- While debugging (need error trace)
- When user is in a conversation about design decisions
