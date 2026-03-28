---
description: "End a work session — runs adherence check, captures learnings, updates CLAUDE.md if needed"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - Skill
  - AskUserQuestion
---

# /cks:sprint-close — Session Closing Ritual

Wraps up a work session by auditing rule adherence, capturing what was learned, and proposing updates to the project constitution (CLAUDE.md) if warranted.

## How It Relates to Other Commands

- `/cks:sprint-start` — loads context (session open)
- `/cks:sprint-close` — audits + captures learnings (session close)
- `/cks:eod` — writes DEVLOG journal entry (daily log)
- `/cks:standup` — reads DEVLOG (morning review)

Sprint-close is the **governance** close. EOD is the **journal** close.
Run sprint-close first, then eod if you want both.

## Steps

### 1. Quick Adherence Check

Run the adherence audit in quick mode (changed files only):

```
Skill(skill="cks:review-rules", args="--quick")
```

This produces the per-rule compliance report. Display the summary.

If no rules exist, skip this step and note: "No guardrails to audit — consider running /cks:bootstrap."

### 2. Gather Session Activity

```bash
git log --since="8 hours ago" --oneline
git diff --stat HEAD~1..HEAD 2>/dev/null
git diff --stat 2>/dev/null
```

Read `.learnings/session-$(date +%Y-%m-%d).md` if it exists.

### 3. Ask for Learnings

```
AskUserQuestion({
  questions: [{
    question: "Anything learned this session that should shape future work?",
    header: "Session Learnings",
    multiSelect: false,
    options: [
      { label: "Nothing new", description: "No changes to conventions or rules" },
      { label: "New convention", description: "A pattern or rule we should adopt" },
      { label: "Rule update", description: "An existing rule needs to change" },
      { label: "Rule removal", description: "A rule is no longer relevant" }
    ]
  }]
})
```

If user selects anything other than "Nothing new", ask for details with a follow-up AskUserQuestion.

### 4. Propose CLAUDE.md Updates (if applicable)

Only propose updates if ANY of these are true:
- User provided learnings that affect conventions
- Adherence check found a rule that consistently fails (3+ violations of same rule)
- New patterns were established in this session's commits

**When proposing changes:**

Read current CLAUDE.md. Check line count.

```
AskUserQuestion({
  questions: [{
    question: "Proposed CLAUDE.md update:",
    header: "{description of proposed change}",
    multiSelect: false,
    options: [
      { label: "Apply", description: "Update CLAUDE.md with this change" },
      { label: "Skip", description: "Don't update — revisit later" },
      { label: "Modify", description: "I want to adjust the wording" }
    ]
  }]
})
```

**CLAUDE.md rules when updating:**
- Must stay under 150 lines — if at limit, something must be removed to add something
- Style rules do NOT go in CLAUDE.md — they belong in `.claude/rules/`
- Only add rules that apply project-wide, not file-scoped
- Never remove rules without user confirmation

### 5. Propose Rule Updates (if applicable)

If the adherence check found patterns worth codifying, or the user suggested rule changes:

```
AskUserQuestion({
  questions: [{
    question: "Should we update .claude/rules/?",
    header: "Rule Update",
    multiSelect: false,
    options: [
      { label: "Add new rule", description: "Add a bullet to {rule_file}" },
      { label: "Modify rule", description: "Change wording in {rule_file}" },
      { label: "Remove rule", description: "Delete a rule that doesn't apply" },
      { label: "Skip", description: "No rule changes" }
    ]
  }]
})
```

Apply changes to the specific `.claude/rules/{file}.md` if approved.

### 6. Save Session Learnings

Write or append to `.learnings/session-{YYYY-MM-DD}.md`:

```markdown
## Session Close — {time}

### Adherence
- Overall: {grade from review-rules}
- Violations: {count} ({breakdown by rule file})

### Learnings
- {user's learnings or "None"}

### CLAUDE.md Changes
- {applied/skipped/none}

### Rule Changes
- {applied/skipped/none}
```

### 7. Display Summary

```
Sprint Close — {today's date}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Session:
  Commits:     {N} commits in last 8 hours
  Files:       {N} files changed

Adherence:     {overall grade} ({N} violations)
CLAUDE.md:     {Updated / No changes}
Rules:         {Updated / No changes}
Learnings:     {Captured / None}

Next session: run /cks:sprint-start
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Rules

1. **Always run adherence check first** — this is the key differentiator from /cks:eod
2. **Never auto-update CLAUDE.md** — always ask the user first
3. **Respect the 150-line cap** — if CLAUDE.md is at limit, propose a swap (remove + add), not just an add
4. **Rule changes require confirmation** — never modify .claude/rules/ silently
5. **Graceful if no rules exist** — skip adherence, still capture learnings
6. **Fast** — no agent dispatching, no heavy research
