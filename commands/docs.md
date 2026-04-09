---
description: "Generate or update project documentation — API docs, architecture, component docs, onboarding guide"
argument-hint: "[api | arch | components | onboarding | all | --diff]"
allowed-tools:
  - Read
  - Agent
---

# /cks:docs — Documentation Generator

Dispatch the **doc-generator** agent (which has `skills: api-docs` loaded at startup).

## Dispatch

Read `CLAUDE.md` and `.prd/PRD-STATE.md` (if they exist) for project context, then:

```
Agent(subagent_type="cks:doc-generator", prompt="Generate project documentation. Scope: {$ARGUMENTS or 'all'}. Project root: {cwd}. Read CLAUDE.md for project conventions. Read .prd/PRD-STATE.md for current phase context. Detect existing docs in docs/. Arguments: $ARGUMENTS")
```

## Quick Reference

```
/cks:docs              → Generate/refresh all documentation types
/cks:docs api          → API endpoint documentation only
/cks:docs arch         → Architecture documentation only
/cks:docs components   → Component/module documentation only
/cks:docs onboarding   → Developer onboarding guide only
/cks:docs --diff       → Only document new/changed code since last tag
```

The doc-generator agent handles: scope detection, codebase scanning, generation of API/architecture/component/onboarding docs, staleness detection, and output to `docs/`.
