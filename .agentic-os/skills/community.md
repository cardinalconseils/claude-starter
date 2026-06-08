---
name: community
domain: Community
description: "Community skill for CKS — Claude Code Starter Kit — defines how Claude handles issue triage, PR review, announcements, and feedback response"
---

# Community — Skill

## Purpose

Covers all outward-facing community work: triaging GitHub issues, reviewing contributor PRs, writing release announcements, and responding to user feedback. Quality here shapes how users perceive CKS.

## Recurring Tasks

### Task: Triage issues

**When**: New GitHub issues arrive unlabeled or uncategorized.

**Output**: Issues labeled, reproduced where possible, and prioritized with a comment explaining next steps.

**Instructions**:
1. Read the issue title and body — identify: bug report, feature request, question, or duplicate
2. Apply the correct label: `bug`, `enhancement`, `question`, `duplicate`, `wontfix`
3. For bug reports: attempt to reproduce from the description; note reproduction result in a comment
4. For feature requests: check if a similar command or agent already exists; link if so
5. Add a priority estimate: `P1` (blocks users), `P2` (important but workaround exists), `P3` (nice to have)
6. Leave a comment confirming triage and next steps

**Quality bar**: Issue has at least one label; a comment is left; duplicates are linked and closed.

---

### Task: Review PRs

**When**: A contributor opens a PR and it needs a code review.

**Output**: PR review with actionable line comments and an overall verdict (approve, request changes, comment).

**Instructions**:
1. Read the PR description — understand the intent and the test plan
2. Read the diff — check against CKS rules: thin dispatchers, correct frontmatter, no inline workflow logic
3. Check: command under 60 lines, agent has all required frontmatter fields, no `set -e` in hooks
4. Leave specific line comments for blocking issues; praise correct patterns
5. If no blocking issues: approve. If blocking: request changes with clear fix instructions.

**Quality bar**: Every blocking finding has a specific line reference and a fix instruction; verdict is explicit (approve or request changes, not just "comment").

---

### Task: Write announcement

**When**: A new CKS version ships and community channels need to know.

**Output**: Release announcement draft covering what's new, why it matters, and how to update.

**Instructions**:
1. Read `CHANGELOG.md` entry for the new version
2. Identify the 2-3 most user-facing changes (new commands, improved workflows, bug fixes)
3. Draft announcement: headline, 2-3 bullet points of what's new, update command
4. Update command: `claude plugin update cks@cks-marketplace` (per feedback memory)
5. Keep it short — users scan, they don't read

**Quality bar**: Announcement covers what's new and how to update; update command is exact and copy-pasteable; under 200 words.

---

### Task: Respond to feedback

**When**: A user leaves feedback on an issue, PR, Discord, or other channel and needs a reply.

**Output**: Reply that acknowledges the feedback, provides clarity or next steps, and closes the loop.

**Instructions**:
1. Read the feedback fully before drafting a reply
2. Acknowledge the specific point — don't give a generic "thanks for the feedback"
3. If the feedback is actionable: open an issue or link to an existing one
4. If the feedback is a misunderstanding: explain the design decision with one sentence of rationale
5. If the feedback is praise: acknowledge and note if it influences roadmap

**Quality bar**: Reply addresses the specific feedback; actionable items are linked to issues; no generic boilerplate.

---

## Context Sources

- `memory/wiki/` — past decisions, known issues, roadmap context
- `CHANGELOG.md` — what shipped in each version
- `commands/help.md` — current command list for answering questions
- `docs/` — reference docs to link in replies

## Output Destinations

- Triage comments → GitHub issue comments
- PR reviews → GitHub PR review tool
- Announcements → `memory/output/` (draft), then community channels
- Feedback replies → GitHub / community channel
