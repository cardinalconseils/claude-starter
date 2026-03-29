# Sub-step [5e]: Post-Deploy

<context>
Phase: Release (Phase 5)
Requires: Production live ([5d])
Produces: Changelog, docs refreshed, CLAUDE.md updated, monitoring confirmed
</context>

## Instructions

### 1. Changelog

```
Skill(skill="changelog")
```
Commit if updated.

### 2. Documentation refresh + staleness check

Run a full documentation refresh and staleness audit:
```
Agent(subagent_type="doc-generator", prompt={
  scope: "all",
  diff_only: false,
  project_root: {project_root},
  staleness_check: true
})
```

Report findings:
```
━━━ Documentation Audit ━━━
 API docs:        {N} endpoints — {ok|M undocumented}
 Architecture:    {current|stale (last updated N days ago)}
 Components:      {N} modules — {ok|M undocumented}
 Onboarding:      {current|references removed feature X}
 Stale docs:      {N} files reference deleted code
━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

If stale or undocumented items found → warn but do NOT block release. Log findings in the completion report. Commit doc updates if any were generated.

### 3. CLAUDE.md update

Scan for changes introduced by the shipped feature:
- New dependencies → Stack section
- New env vars → Environment Variables section
- New conventions → Rules section
- New workflows → Key Workflows section

```
Skill(skill="claude-md-management:revise-claude-md")
```
Or update directly. Commit if changed.

### 4. Monitoring confirmation

```
AskUserQuestion({
  questions: [{
    question: "Production deploy complete. Confirm monitoring:",
    header: "Post-Deploy Checklist",
    multiSelect: true,
    options: [
      { label: "Error monitoring active", description: "Sentry, LogRocket, etc." },
      { label: "Performance monitoring active", description: "Dashboards, alerting" },
      { label: "Success metrics tracking", description: "KPIs from Discovery being measured" },
      { label: "Rollback plan confirmed", description: "Know how to revert if needed" },
      { label: "Skip monitoring", description: "Not applicable for this project" }
    ]
  }]
})
```

### 5. Auto-retrospective

```
Skill(skill="retro", args="--auto")
```

```
  [5e] Post-Deploy            ✅ Changelog + Docs + CLAUDE.md + monitoring
```
