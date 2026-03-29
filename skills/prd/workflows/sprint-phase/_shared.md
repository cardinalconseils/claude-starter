# Sprint Phase: Shared Context

## State Read Pattern

At the start of sprint, the orchestrator reads:
```
Read .prd/PRD-STATE.md    → extract {NN}, {name}, {phase_status}, {iteration_count}
Read .prd/PRD-ROADMAP.md  → extract phase list
```

These variables are available to all sub-steps:
- `{NN}` — phase number (e.g., `01`)
- `{name}` — kebab-case phase name (e.g., `invoice-management`)
- `{phase_dir}` — `.prd/phases/{NN}-{name}/`
- `{iteration}` — iteration count (0 for first sprint, 1+ for iterations)

## First Sprint Banner Template

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PRD ► Phase {NN}: {name} ► SPRINT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 [1] Discover    ✅ done
 [2] Design      ✅ done
 [3] Sprint      ▶ current
     [3a] Sprint Planning        {status}
     [3b] Design & Architecture  {status}
     [3c] Implementation         {status}
     [3c+] De-Sloppify           {status}
     [3d] Code Review            {status}
     [3e] QA Validation          {status}
     [3f] UAT                    {status}
     [3g] Merge to Main          {status}
     [3h] Documentation Check    {status}
 [4] Review      ○ pending
 [5] Release     ○ pending

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Iteration Sprint Banner Template

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PRD ► Phase {NN}: {name} ► SPRINT — Iteration #{iteration}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 Iteration reason: {iteration_reason from STATE.md}
 Backlog items:    {N} from BACKLOG.md

 [1] Discover    ✅ done
 [2] Design      ✅ done
 [3] Sprint      ✅ done (initial)
 [4] Review      ✅ done → iterate
 [3] Sprint      ▶ Iteration #{iteration}
     [3a] Iteration Planning     {status}  ← scoped to BACKLOG.md
     [3b] Design & Architecture  {status}  ← updates only
     [3c] Implementation         {status}  ← fixes from backlog
     [3c+] De-Sloppify           {status}
     [3d] Code Review            {status}
     [3e] QA Validation          {status}
     [3f] UAT                    {status}
     [3g] Merge to Main          {status}
     [3h] Documentation Check    {status}
 [4] Review      ○ pending
 [5] Release     ○ pending

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Status markers: `○ pending` | `▶ in progress` | `✅ done`
