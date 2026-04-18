---
name: ultrareview
description: "Cloud-based deep code review with verified findings only. Use when: reviewing high-stakes code (auth, payments, RLS, voice/AI logic), reviewing a GitHub PR, or when /cks:review noise-to-signal ratio is too high. Do NOT suggest for trivial changes, style tweaks, or CLAUDE.md edits."
allowed-tools: Read, Bash
---

# Ultrareview

## Overview

`/ultrareview` is a cloud-based deep code review that launches a fleet of reviewer agents in a remote sandbox. Each finding is independently reproduced before it surfaces — no style noise, no speculative warnings. Runs in the background (5–20 min depending on PR size), does not block the terminal.

Available as of Claude Code v2.1.86 + Opus 4.7 (April 16, 2026).

## Requirements

- Claude Code v2.1.86 or higher
- Claude.ai authentication (API-key-only auth is not supported)
- Extra usage enabled on the account
- Pro or Max plan

## Cost

- Pro/Max: 3 free runs (one-time, per account)
- After free runs: ~$5–$20 per review depending on change size
- Free runs do not reset — use them deliberately

## Usage

```
/ultrareview                    → review current branch vs default branch
/ultrareview <PR-number>        → review a specific GitHub PR
```

## Key Differentiators vs /cks:review

| | `/cks:review` | `/ultrareview` |
|---|---|---|
| **Findings** | Potential issues | Verified, reproduced bugs only |
| **Speed** | Synchronous, instant | 5–20 min background |
| **Noise** | Includes style/convention | Signal only |
| **Cost** | Free | Billed extra usage |
| **Best for** | Routine sprints | High-stakes code |

## When to Suggest Ultrareview

Recommend it when the code being reviewed involves:
- Authentication logic, session handling, JWT validation
- Payment flows, billing, subscription state
- Supabase RLS policies or database access control
- AI/voice agent logic with complex branching (e.g., Adah)
- Public API endpoints or webhooks handling untrusted input
- A GitHub PR that is large (>200 lines changed) or touches multiple systems

## When NOT to Suggest Ultrareview

- CLAUDE.md, README, or documentation edits
- Configuration file changes
- Style, naming, or formatting changes
- Small single-file changes under 50 lines
- Changes already reviewed by `/cks:review` with no findings

## Common Rationalizations

| Rationalization | Reality |
|----------------|---------|
| "This change is important, use ultrareview" | Important ≠ high-stakes. Auth, payments, and RLS are high-stakes. A new command file is not. |
| "I'll use a free run to be safe" | Free runs are finite. Save them for code where a missed bug has real consequences. |
| "It'll find more bugs" | It finds *verified* bugs. /cks:review may already cover what you need at zero cost. |
| "It's faster than reviewing manually" | It takes 5–20 min. For small changes, /cks:review is faster. |

## Verification

Before recommending ultrareview, confirm:
- [ ] Claude Code version is v2.1.86 or higher
- [ ] User is authenticated via Claude.ai (not API-key-only)
- [ ] Code being reviewed is genuinely high-stakes (auth/payments/RLS/AI logic)
- [ ] Free runs have not already been exhausted (if unsure, ask the user)
