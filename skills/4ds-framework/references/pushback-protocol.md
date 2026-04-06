# Pushback Protocol — Agent Precondition Checks

## Purpose

Agents MUST verify preconditions before executing. If preconditions fail, the agent
stops and reports why — it does NOT build on a shaky foundation.

## Protocol

At agent startup, before any work:

1. Read the precondition checklist for your phase (below)
2. Check each item
3. If ANY blocking precondition fails:
   - STOP immediately
   - Report: which precondition failed, what's missing, how to fix it
   - Suggest the correct command to run first
4. If only warning preconditions fail:
   - Report the warning
   - Continue with explicit acknowledgment

## Precondition Checklists

### prd-discoverer (Phase 1)
| Check | Type | How to verify |
|-------|------|---------------|
| `.prd/` exists | blocking | Glob for `.prd/PRD-STATE.md` |
| Feature entry in ROADMAP | blocking | Grep ROADMAP.md for feature name |
| No stale discovery in progress | warning | Check STATE.md `phase_status` != `discovering` |

### prd-designer (Phase 2)
| Check | Type | How to verify |
|-------|------|---------------|
| CONTEXT.md exists | blocking | Glob for `{NN}-CONTEXT.md` |
| All 11 Elements present | blocking | Grep CONTEXT.md for each element header |
| User stories confirmed | blocking | Grep for `[confirmed]` markers |

### prd-planner (Phase 3a)
| Check | Type | How to verify |
|-------|------|---------------|
| CONTEXT.md exists | blocking | Glob for `{NN}-CONTEXT.md` |
| DESIGN.md exists (if Phase 2 ran) | warning | Glob for `{NN}-DESIGN.md` |
| No uncommitted changes | warning | `git status --short` is empty |

### prd-executor (Phase 3c)
| Check | Type | How to verify |
|-------|------|---------------|
| PLAN.md exists | blocking | Glob for `{NN}-PLAN.md` |
| PRD exists | blocking | Glob for `{NN}-PRD.md` |
| Branch is clean | warning | `git status --short` is empty |
| Tests pass before starting | warning | Run test command, check exit code |

### prd-verifier (Phase 3e)
| Check | Type | How to verify |
|-------|------|---------------|
| Implementation exists | blocking | SUMMARY.md or recent commits |
| Acceptance criteria defined | blocking | Grep CONTEXT.md for criteria |
| Build passes | blocking | Run build command |

## Pushback Report Format

When a blocking precondition fails:

```
PUSHBACK — {agent-name} cannot proceed
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Failed: {precondition description}
  Missing: {what artifact or state is missing}
  Fix: Run {suggested command} first
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Integration

Add to any agent's system prompt:

```
## Pushback Protocol
Before executing, read `references/pushback-protocol.md` from the 4ds-framework skill.
Check all preconditions for your phase. If any blocking precondition fails, STOP and
report using the pushback format. Do NOT proceed with partial inputs.
```
