---
description: "[DEPRECATED] Use /cks:release instead — Phase 5: Release Management"
argument-hint: "[phase number or 'all']"
allowed-tools:
  - Skill
---

# /cks:ship — DEPRECATED

⚠️ **This command has been replaced by `/cks:release`.**

`/cks:ship` was the final step in the old 6-step workflow. The new Phase 5: Release Management includes proper environment promotion (Dev → Staging → RC → Production) with quality gates.

The new 5-phase lifecycle is:
```
/cks:discover  → Phase 1: Discovery (9 Elements)
/cks:design    → Phase 2: Design (Stitch SDK)
/cks:sprint    → Phase 3: Sprint Execution
/cks:review    → Phase 4: Review & Retro
/cks:release   → Phase 5: Release Management
```

**Redirecting to `/cks:release`...**

```
Skill(skill="release", args="$ARGUMENTS")
```
