# Design Phase: Shared Context

## State Read Pattern

At the start of design, the orchestrator reads:
```
Read .prd/PRD-STATE.md    → extract {NN}, {name}, {phase_status}
Read .prd/PRD-ROADMAP.md  → extract phase list
```

These variables are available to all sub-steps:
- `{NN}` — phase number (e.g., `01`)
- `{name}` — kebab-case phase name (e.g., `invoice-management`)
- `{phase_dir}` — `.prd/phases/{NN}-{name}/`

## Progress Banner Template

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PRD ► Phase {NN}: {name} ► DESIGN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 [1] Discover    ✅ done
 [2] Design      ▶ current
     [2a] UX Research            {status}
     [2b] API Contract           {status}
     [2c] Screen Generation      {status}
     [2d] Design Iteration       {status}
     [2e] Component Specs        {status}
     [2f] Design Review          {status}
 [3] Sprint      ○ pending
 [4] Review      ○ pending
 [5] Release     ○ pending

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Status markers: `○ pending` | `▶ in progress` | `✅ done` | `⏭ N/A`
