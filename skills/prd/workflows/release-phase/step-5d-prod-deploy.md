# Sub-step [5d]: Production Deploy + Smoke Test

<context>
Phase: Release (Phase 5)
Requires: RC validated ([5c])
Produces: Production live with smoke test passed
</context>

## Instructions

1. Deploy to production:
```
Skill(skill="deploy")
```
Or platform-specific:
```
Skill(skill="vercel:deploy")
```

2. Post-deploy smoke test:
```
Skill(skill="browse", args="Navigate to {production_url}. Smoke test:
- App loads without errors
- Key user journey works end-to-end
- No console errors
- API responds correctly
Take screenshot of each step.")
```

3. E2E validation on production:
```
Skill(skill="browse", args="Navigate to {production_url}. Validate critical user journeys:
- {critical path 1}
- {critical path 2}
Report PASS/FAIL with screenshots.")
```

```
  [5d] Production Deploy      ✅ {platform} — smoke test passed
```
