# Shared: Review Phase Variables & Banners

## Variables

- `{NN}` — phase number (e.g., `01`)
- `{name}` — phase name (e.g., `user-authentication`)
- `{iteration_count}` — number of iterations completed
- `{number}` — PR number from Sprint [3g]

## Progress Banner Template

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PRD ► Phase {NN}: {name} ► REVIEW {iteration_count > 0 ? "— after Iteration #"+iteration_count : ""}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 [1] Discover    ✅ done
 [2] Design      ✅ done
 [3] Sprint      ✅ done (PR #{number}) {iteration_count > 0 ? "— Iteration #"+iteration_count : ""}
 [4] Review      ▶ current
     [4a] Sprint Review          ○ pending
     [4b] Retrospective          ○ pending
     [4c] Backlog Refinement     ○ pending
     [4d] Iteration Decision     ○ pending
 [5] Release     ○ pending

 {if iteration_count > 0:}
 Iteration History:
   Sprint (initial)     ✅ → Review → Iterate
   {for each iteration 1..iteration_count:}
   Iteration #{N}       ✅ → Review {N == iteration_count ? "▶ current" : "→ Iterate"}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Completion Banner — Releasing

```
  [4] Review      ✅ done — proceeding to Release
      Sprint Review: feedback collected
      Retrospective: {N} retro items
      Backlog: {N} items (all resolved or deferred)
      Decision: RELEASE
      Next: /cks:release {NN}
```

## Completion Banner — Iterating

```
  [4] Review      ✅ done — iterating
      Sprint Review: feedback collected
      Retrospective: {N} retro items
      Backlog: {N} items to address
      Decision: ITERATE → Phase {X} ({phase_name})
      Iteration: #{iteration_count}
      Next: /cks:{command} {NN}
```
