# Step 5: Completion Banner & Context Reset

<context>
Phase: Sprint (Phase 3)
Requires: State updated (Step 4)
Produces: Completion banner + compaction suggestion
</context>

## First Sprint Completion Banner

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PRD ► Phase {NN}: {name} ► SPRINT COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 [3a] Sprint Planning        ✅ {N} tasks
 [3b] Design & Architecture  ✅ TDD: {level}
 [3c] Implementation         ✅ {N} files changed
 [3c+] De-Sloppify           ✅ cleaned
 [3d] Code Review            ✅ {status}
 [3e] QA Validation          ✅ {X}/{Y} criteria
 [3f] UAT                    ✅ {N}/{M} scenarios
 [3g] Merge to Main          ✅ PR #{number}
 [3h] Documentation Check    ✅ {status}

 Next: /cks:review {NN}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Iteration Sprint Completion Banner

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PRD ► Phase {NN}: {name} ► ITERATION #{iteration} COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 Iteration reason: {iteration_reason}

 [3a] Iteration Planning     ✅ {N} backlog items scoped
 [3b] Design & Architecture  ✅ {updated | no changes needed}
 [3c] Implementation         ✅ {N} files changed, {N}/{M} backlog items resolved
 [3c+] De-Sloppify           ✅ cleaned
 [3d] Code Review            ✅ {status}
 [3e] QA Validation          ✅ {X}/{Y} criteria
 [3f] UAT                    ✅ {N}/{M} scenarios
 [3g] Merge to Main          ✅ PR #{number} (Iteration #{iteration})
 [3h] Documentation Check    ✅ {status}

 Iteration History:
   Sprint (initial)     ✅ → Review → Iterate
   {for each past iteration:}
   Iteration #{N}       ✅ → Review → {Iterate | current}

 Next: /cks:review {NN}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "phase.sprint.completed" "{NN}-{name}" "Sprint phase completed"`

## Context Reset & Compaction

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Sprint artifacts saved to disk. Run /compact before review
to free context — all state is persisted:

  ✅ PRD-STATE.md    — phase tracking
  ✅ PLAN.md         — sprint plan
  ✅ SUMMARY.md      — implementation record
  ✅ VERIFICATION.md — test results
  ✅ Working Notes   — session context (auto-captured)

  /compact
  /cks:next

Nothing is lost.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Do NOT chain to the next workflow via Skill().** Stop here.
