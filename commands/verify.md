---
description: "[DEPRECATED] Use /cks:sprint instead — QA Validation is sub-step [3e]"
argument-hint: "[phase number]"
allowed-tools:
  - Skill
---

# /cks:verify — DEPRECATED

⚠️ **This command has been absorbed into `/cks:sprint`.**

QA Validation [3e] and UAT [3f] are now sub-steps of Phase 3: Sprint Execution.

The new 5-phase lifecycle is:
```
/cks:discover  → Phase 1: Discovery (9 Elements)
/cks:design    → Phase 2: Design (Stitch SDK)
/cks:sprint    → Phase 3: Sprint Execution (includes QA + UAT)
/cks:review    → Phase 4: Review & Retro
/cks:release   → Phase 5: Release Management
```

**Redirecting to `/cks:sprint`...**

```
Skill(skill="sprint", args="$ARGUMENTS")
```
