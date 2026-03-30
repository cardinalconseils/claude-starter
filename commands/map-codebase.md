---
description: "Analyze codebase and produce structured docs in .prd/codebase/"
argument-hint: "[focus: all | arch | stack | concerns | structure]"
allowed-tools:
  - Read
  - Agent
---

# /cks:map-codebase — Codebase Analysis

Dispatch 4 parallel agents to analyze the codebase and produce structured documentation in `.prd/codebase/`.

## Focus Detection

Parse `$ARGUMENTS`:
- `all` (default) — generate/refresh all 7 documents
- `arch` — only ARCHITECTURE.md + CONVENTIONS.md
- `stack` — only STACK.md + INTEGRATIONS.md
- `concerns` — only CONCERNS.md
- `structure` — only STRUCTURE.md + TESTING.md

## Dispatch (parallel)

Launch agents in parallel based on focus. For `all`:

**Agent 1: Architecture + Conventions**
```
Agent(prompt="Analyze codebase at {cwd}. Produce: (1) .prd/codebase/ARCHITECTURE.md — layers, patterns, data flow, key abstractions, dependency direction. (2) .prd/codebase/CONVENTIONS.md — naming, file organization, import style, component patterns, error handling.")
```

**Agent 2: Stack + Integrations**
```
Agent(prompt="Analyze codebase at {cwd}. Produce: (1) .prd/codebase/STACK.md — every framework/library/tool with version, grouped by category. (2) .prd/codebase/INTEGRATIONS.md — external services, config, env vars, SDK patterns.")
```

**Agent 3: Structure + Testing**
```
Agent(prompt="Analyze codebase at {cwd}. Produce: (1) .prd/codebase/STRUCTURE.md — directory tree with purpose annotations, key entry points. (2) .prd/codebase/TESTING.md — test framework, locations, coverage, patterns.")
```

**Agent 4: Concerns**
```
Agent(prompt="Analyze codebase at {cwd}. Produce: .prd/codebase/CONCERNS.md — tech debt, security risks, performance issues, TODO/FIXME/HACK items, missing tests for critical paths.")
```

## Output

```
.prd/codebase/
├── ARCHITECTURE.md    — Layers, patterns, data flow
├── STACK.md           — Frameworks, libraries, versions
├── STRUCTURE.md       — Directory layout, key files
├── CONVENTIONS.md     — Naming, patterns, style
├── INTEGRATIONS.md    — External services, APIs, SDKs
├── CONCERNS.md        — Tech debt, risks, warnings
└── TESTING.md         — Test setup, coverage, patterns
```
