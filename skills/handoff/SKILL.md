---
name: handoff
description: >
  Compact the current session into a pickup document for the next Claude session.
  Use when: "handoff", "picking up tomorrow", "switching sessions", "context for next session",
  "don't lose context", "continue later", "save state". Also invoke before /compact on long sessions.
allowed-tools: Read, Write, Bash, Glob, Grep
model: sonnet
---

# Handoff — Session Context Bridge

Produces `.prd/HANDOFF.md` — a terse pickup doc so a fresh session resumes without re-discovery.

## Rule: Do Not Duplicate Artifacts

Never copy content already captured in:
- `.prd/PRD-STATE.md` — reference it by path
- `.prd/*/CONTEXT.md`, `DESIGN.md`, `PLAN.md` — reference by path
- Git commits, PR bodies, ADRs — reference by SHA or URL
- `.learnings/` entries — reference by path

Write pointers, not copies. Fresh session reads originals.

## What to Capture

### 1. Where We Are
- Active phase + step (e.g., "Phase 03 → [3c] Implementation — 60% done")
- Branch name and any open PRs
- Last commit SHA + message

### 2. What Was Done This Session
- Bullet list of completed work (max 8 items)
- Key decisions made and WHY (these are the hardest to reconstruct)

### 3. What Is Pending
- Incomplete items with their exact state ("halfway through X", "blocked on Y")
- Files being edited but not committed
- Tests written but not passing

### 4. Blockers / Watch-Outs
- Auth issues, missing env vars, failing tests, ambiguous requirements
- Anything that tripped us up that the next session should know upfront

### 5. Exact Next Steps
- Numbered list of what to do first, second, third
- Include the exact `/cks:` command(s) to run to resume
- If the user passed arguments, treat them as the focus for next session and tailor steps accordingly

### 6. Skills / Agents for Next Session
- Which CKS skills will be needed (`prd`, `testing-discipline`, etc.)
- Which agent to dispatch first

## Format

```markdown
# Handoff — {date} {time}

**Branch:** {branch}  **Phase:** {phase} → {step}  **Commit:** {sha} {message}

## Done This Session
- {item}

## Decisions Made
- {decision}: {why} (avoid re-opening this)

## Pending
- {item} — {exact state}

## Blockers
- {blocker}

## Resume Steps
1. {first action}
2. {second action}
3. Run: `{exact cks command}`

## Next Session Skills
{skill list}

## ⚡ Next Step
> {single line — the ONE thing to do first when opening the next session}
```

The `⚡ Next Step` line is mandatory. It must be the last thing in the doc — one sentence,
one action, copy-pasteable command or clear instruction. If the user passed arguments, use
that focus to determine the next step. This is the TL;DR for someone who reads nothing else.

## Save Location

Write to **two paths** — both are required:

1. **Unique archive:** `.prd/handoffs/HANDOFF-{timestamp}-{branch-slug}.md`
   - Timestamp: `TZ=America/New_York date '+%Y-%m-%d-%H%M'`
   - Branch slug: `git branch --show-current | tr '/' '-' | tr '[:upper:]' '[:lower:]' | cut -c1-30`
   - Create `.prd/handoffs/` if it does not exist
2. **Latest pointer:** `.prd/HANDOFF.md` (overwrite — session-start auto-detects this)

After writing both files, output both paths and first 10 lines of the archive file.
If `.prd/` does not exist, save to `HANDOFF.md` in the project root (no archive).

The pointer file is consumed and deleted automatically by the next session's session-start hook. The archive in `.prd/handoffs/` is permanent history.

## Verification

- [ ] File written and path shown to user
- [ ] No artifact content duplicated — only paths referenced
- [ ] Resume steps are specific enough to act on without reading this conversation
- [ ] Next session would know what NOT to redo
- [ ] `⚡ Next Step` present as the final line — one action, no ambiguity
