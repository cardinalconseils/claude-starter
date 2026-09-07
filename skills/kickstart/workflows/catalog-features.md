# Workflow: Catalog Features — inventory an existing codebase for `/cks:adopt`

Scan an existing codebase for feature clusters, confirm and classify each one with the
user, and produce the features catalog. Scan first, ask second; one question at a time,
always via `AskUserQuestion`.

Output: `.bootstrap/features-catalog.md`. When the interviewing role's write scope does
not include `.bootstrap/`, return the finished table and the operator writes it.

## 0. Exclusion list

If `.bootstrap/features-catalog.md` exists, read it, show it to the user, and extract the
feature names (column 2) as a case-insensitive exclusion list — skip matching candidates
silently in every later step.

## 1. Scan for signals

- **Route/page clusters** — `app/` (App Router segments), `pages/`, `src/api/` or
  `routes/`, `src/views/` or `src/screens/`. Glob, group by top-level segment; each segment
  is a candidate (`app/dashboard/` → "Dashboard").
- **Module directories** — `src/lib/`, `src/modules/`, `src/features/`, `src/domain/`.
- **Git history** — `git log --oneline -50`, grouped by prefix or area
  ("feat: auth", "fix: dashboard").

## 2. Candidate list

Merge and dedupe. Per candidate: title-case name, one-line inferred description, signal
source(s). Empty codebase or no signals → skip to step 3 and ask open-endedly.

## 3. Confirm candidates — one at a time

> "I detected a '{Name}' feature ({source}: {path or commits}). Description: {inferred}.
> What would you like to do?" — Confirm as-is · Rename it · Skip — not a real feature

Rename → free-text follow-up "What should this feature be called?"

## 4. Missing features

> "Are there any features not detected above?" — No, that's everything · Yes — I'll
> describe them now

## 5. Classify — one at a time

> "What is the status of '{Feature}'?" — shipped · in-progress · planned

## 6. Catalog

New file:

```markdown
# Features Catalog

**Cataloged:** {YYYY-MM-DD}

## Features

| ID | Name | Status | Description |
|----|------|--------|-------------|
| F-01 | {Name} | {shipped|in-progress|planned} | {one line} |
```

Existing file: continue IDs from the last one, append only new rows, never rewrite or
remove existing rows, update the `**Cataloged:**` date. Produce the file (or the rows to
append) before reporting completion.
