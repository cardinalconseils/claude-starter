# Sub-step [5a]: Dev Deploy + Internal Validation

<context>
Phase: Release (Phase 5)
Requires: Preflight passed (Step 0)
Produces: Dev/preview URL validated
</context>

**Quality Gate: Dev → Staging**

## Instructions

1. Ensure code is on a feature branch (create if on main)
2. Push to remote
3. Deploy to development/preview environment:
   - Vercel: PR auto-generates preview URL
   - Railway: deploy to dev environment
   - Other: `Skill(skill="deploy")` if available

4. Internal validation:
```
AskUserQuestion({
  questions: [{
    question: "Dev deployment ready at {preview_url}. Internal validation:",
    header: "Dev → Staging Gate",
    multiSelect: false,
    options: [
      { label: "Validated — promote to Staging", description: "No major bugs, acceptance criteria met, data flow verified" },
      { label: "Issues found", description: "Bugs or problems discovered — go back to Sprint" },
      { label: "Skip to Staging", description: "Already validated externally" }
    ]
  }]
})
```

If "Issues found" → update STATE.md to `iterating_sprint`, exit release.

```
  [5a] Dev Deploy             ✅ {url} — validated
```
