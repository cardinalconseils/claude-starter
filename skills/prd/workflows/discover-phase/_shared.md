# Discover Phase: Shared Context

## State Read Pattern

At the start of discovery, the orchestrator reads:
```
Read .prd/PRD-STATE.md    → extract {NN}, {name}, {phase_status}
Read .prd/PRD-ROADMAP.md  → extract phase list
```

These variables are available to all sub-steps:
- `{NN}` — phase number (e.g., `01`)
- `{name}` — kebab-case phase name (e.g., `secrets-lifecycle-management`)
- `{phase_dir}` — `.prd/phases/{NN}-{name}/`

## Progress Banner Template

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PRD ► Phase {NN}: {name} ► DISCOVER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 [1] Discover    ▶ current
     [1a] Problem Statement      {status}
     [1b] User Stories            {status}
     [1c] Scope (In/Out)          {status}
     [1d] API Surface Map         {status}
     [1e] Acceptance Criteria     {status}
     [1f] Constraints             {status}
     [1g] Test Plan               {status}
     [1h] UAT Scenarios           {status}
     [1i] Definition of Done      {status}
     [1j] Success Metrics         {status}
 [2] Design      ○ pending
 [3] Sprint      ○ pending
 [4] Review      ○ pending
 [5] Release     ○ pending

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Status markers: `○ pending` | `▶ in progress` | `✅ done`
