---
description: Analyze codebase and produce structured docs in .prd/codebase/
argument-hint: "[focus: all | arch | stack | concerns | structure]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - Agent
---

# /cks:map-codebase — Codebase Analysis

Analyze the codebase with parallel agents and produce structured documentation in `.prd/codebase/`. This replaces GSD's `map-codebase` command.

## What It Produces

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

## How It Works

### Step 1: Determine Focus

Parse `$ARGUMENTS`:
- `all` (default) — Generate/refresh all 7 documents
- `arch` — Only ARCHITECTURE.md
- `stack` — Only STACK.md
- `concerns` — Only CONCERNS.md
- `structure` — Only STRUCTURE.md

### Step 2: Dispatch Parallel Agents

Launch up to 4 agents in parallel using the Agent tool, each with a specific focus area:

**Agent 1: Architecture + Conventions**
```
Analyze the codebase at {project_root}. Produce two documents:

1. ARCHITECTURE.md — Overall architecture pattern, layers (presentation, business logic, data, infrastructure), data flow between layers, key abstractions, dependency direction.

2. CONVENTIONS.md — Naming conventions, file organization patterns, import style, component patterns, error handling patterns, state management approach.

Read: package.json, tsconfig.json, key source files in src/, CLAUDE.md
Write to: .prd/codebase/ARCHITECTURE.md and .prd/codebase/CONVENTIONS.md
```

**Agent 2: Stack + Integrations**
```
Analyze the codebase at {project_root}. Produce two documents:

1. STACK.md — Every framework, library, and tool with version. Group by: runtime, UI, data, AI, testing, build, deployment.

2. INTEGRATIONS.md — External services (Firebase, AI APIs, etc.), how they're configured, environment variables needed, SDK patterns used.

Read: package.json, .env.example, config files, source files with API calls
Write to: .prd/codebase/STACK.md and .prd/codebase/INTEGRATIONS.md
```

**Agent 3: Structure + Testing**
```
Analyze the codebase at {project_root}. Produce two documents:

1. STRUCTURE.md — Directory tree with purpose annotations. Key entry points. File naming conventions. Where to add new features.

2. TESTING.md — Test framework, test file locations, how to run tests, coverage status, testing patterns used.

Read: directory listing, test files, package.json scripts
Write to: .prd/codebase/STRUCTURE.md and .prd/codebase/TESTING.md
```

**Agent 4: Concerns**
```
Analyze the codebase at {project_root}. Produce:

CONCERNS.md — Technical debt, security concerns, performance risks, missing error handling, hardcoded values, deprecated patterns, TODO/FIXME/HACK comments, missing tests for critical paths.

Read: all source files, grep for TODO/FIXME/HACK, check for .env patterns, look for anti-patterns
Write to: .prd/codebase/CONCERNS.md
```

### Step 3: Report

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PRD ► CODEBASE MAPPED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 Generated:
   ✓ ARCHITECTURE.md — {summary}
   ✓ STACK.md — {N} dependencies mapped
   ✓ STRUCTURE.md — {N} directories documented
   ✓ CONVENTIONS.md — {N} patterns identified
   ✓ INTEGRATIONS.md — {N} services documented
   ✓ CONCERNS.md — {N} issues flagged
   ✓ TESTING.md — {summary}

 Location: .prd/codebase/
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## When to Run

- At project start (part of `/cks:new`)
- After major architectural changes
- Before planning a new PRD that touches unfamiliar code
- When onboarding to understand the codebase
