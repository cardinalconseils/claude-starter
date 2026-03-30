---
name: language-rules
description: "Language-specific coding rules — generated at bootstrap time based on detected stack"
triggers:
  - "/cks:bootstrap"
  - "manual"
allowed-tools: Read, Grep, Glob, Write
model: sonnet
---

# Language-Specific Rules

## Purpose

During `/cks:bootstrap`, after detecting the project's tech stack, generate language-specific coding rules that Claude follows for all code in this project. Rules are written to `.claude/rules/` and loaded automatically.

## Rule Generation

Based on detected stack, generate rules from the catalogs below. Only generate rules for languages/frameworks actually used in the project.

## Available Rule Catalogs

### TypeScript / JavaScript

Write to `.claude/rules/typescript.md`:

```markdown
# TypeScript Rules

## Strict Mode
- Always use `strict: true` in tsconfig.json
- No `any` type — use `unknown` if type is truly unknown
- No `@ts-ignore` — fix the type error or use `@ts-expect-error` with explanation

## Patterns
- Prefer `const` over `let`, never `var`
- Use discriminated unions over type casting
- Prefer `interface` for object shapes, `type` for unions/intersections
- Use `satisfies` operator for type-safe object literals
- Explicit return types on exported functions

## Error Handling
- Never catch and ignore — at minimum log
- Use typed errors (extend Error class)
- Never `throw` strings — always Error objects

## Imports
- Use path aliases (configured in tsconfig)
- No circular imports
- Barrel exports only at package boundaries

## React (if applicable)
- Functional components only
- Custom hooks for shared logic
- No inline styles — use CSS modules or styled components
- Keys on list items — never use index as key
- Memoize expensive computations (useMemo, useCallback with deps)
```

### Python

Write to `.claude/rules/python.md`:

```markdown
# Python Rules

## Type Hints
- All function signatures must have type hints
- Use `from __future__ import annotations` for modern syntax
- Use `TypeVar` and `Generic` for generic functions/classes

## Patterns
- f-strings over .format() or % formatting
- Dataclasses or Pydantic models for structured data
- Context managers for resource management
- List comprehensions over map/filter (when readable)
- `pathlib.Path` over `os.path`

## Error Handling
- Specific exception types — never bare `except:`
- Custom exceptions for domain errors
- Don't use exceptions for control flow

## Imports
- Standard library → third-party → local (isort order)
- Absolute imports over relative
- No wildcard imports (`from x import *`)

## Django (if applicable)
- Fat models, thin views
- Always use `get_object_or_404` in views
- Queryset annotations over Python-side computation
- Never raw SQL unless performance-critical (and then parameterized)
```

### Go

Write to `.claude/rules/go.md`:

```markdown
# Go Rules

## Error Handling
- Always check errors — never `_ = someFunc()`
- Wrap errors with context: `fmt.Errorf("doing X: %w", err)`
- Use sentinel errors for expected conditions
- Custom error types for domain errors

## Patterns
- Accept interfaces, return structs
- Table-driven tests
- Context propagation through call chains
- Prefer composition over inheritance
- Short variable names in small scopes, descriptive in large

## Concurrency
- Don't communicate by sharing memory; share memory by communicating
- Always use `context.Context` for cancellation
- Close channels from the sender side
- Use `sync.WaitGroup` for goroutine coordination

## Project Structure
- Follow standard Go project layout
- Internal packages for private code
- `cmd/` for entry points
```

### Rust

Write to `.claude/rules/rust.md`:

```markdown
# Rust Rules

## Ownership
- Prefer borrowing over cloning
- Use `Cow<str>` when ownership is conditional
- Minimize `Arc<Mutex<T>>` — prefer message passing

## Error Handling
- Use `thiserror` for library errors, `anyhow` for application errors
- Never `unwrap()` in production code — use `?` operator
- Custom error enums for domain logic

## Patterns
- Prefer iterators over indexed loops
- Use `impl Trait` for return types when possible
- Builder pattern for complex struct construction
- Derive macros for common traits (Debug, Clone, PartialEq)
```

## Bootstrap Integration

During `/cks:bootstrap`, after stack detection:

```
1. Detect languages: scan for tsconfig.json, pyproject.toml, go.mod, Cargo.toml, etc.
2. Detect frameworks: scan for next.config.*, django settings, express patterns
3. Generate only relevant rule files to .claude/rules/
4. Report: "Generated coding rules for: TypeScript, React, Python"
```

## Rule File Location

```
{project_root}/
  .claude/
    rules/
      typescript.md    ← Generated if TS detected
      python.md        ← Generated if Python detected
      go.md            ← Generated if Go detected
      rust.md          ← Generated if Rust detected
```

## Customization

This skill ships with opinionated defaults. Review and adapt to your needs:

- **Rule catalogs**: Language-specific coding rules — edit inline catalogs in SKILL.md or see `references/catalog-index.md`
- **Framework rules**: React, Django, etc. sub-sections — edit within language catalogs
- **Strictness level**: How strict the rules are (e.g., "no any" vs "minimize any") — edit catalogs
- **Detection logic**: Which config files trigger which languages — edit SKILL.md
- **allowed-tools**: Currently `Read, Grep, Glob, Write`. Add tools if needed.
- **model**: Currently `sonnet`. Remove to use your default model.

## Constraints

- Only generate rules for detected languages — never speculatively
- Rules should be opinionated but mainstream (follow community standards)
- Keep each rule file under 100 lines to minimize context budget
- Framework-specific rules go in the language file (not separate files)
