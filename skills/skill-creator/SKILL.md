---
name: skill-creator
description: >
  Create, write, and improve skills for the CKS Claude Code plugin.
  Use when asked to "write a skill", "add a skill", "create a new skill",
  "improve a skill's description", "review my skill", or when capturing a
  recurring workflow into a reusable package. Also triggers when user wants
  a skill for any Claude Code plugin — even outside CKS.
allowed-tools: Read, Write, Grep, Glob, Bash
model: sonnet
---

# Creating CKS Skills

Skills are the domain expertise layer in the CKS architecture. They load on
trigger, bring focused knowledge into context, and stay lean so they don't
bloat every session that loads them.

## Structure

```
skills/skill-name/
├── SKILL.md          — always loaded when skill triggers (target: ≤100 lines body)
├── references/       — loaded on demand (schemas, checklists, advanced docs)
├── scripts/          — executed without reading into context
└── assets/           — templates and files used in output
```

Three loading levels:
1. **Frontmatter** (name + description) — always in context, ~100 words max
2. **SKILL.md body** — loaded when skill triggers; keep ≤100 lines
3. **references/** — loaded only when Claude needs the detail

No `plugin.json` registration needed — skills are auto-discovered from `skills/`.

## Description Format

The description is the **sole trigger mechanism**. Write it in two sentences,
≤1024 characters:

**Sentence 1** — what the skill does (one clause, active voice)
**Sentence 2** — "Use when [trigger phrases, contexts, or file types]."

Good:
```yaml
description: >
  Extract text, tables, and forms from PDF files with layout awareness.
  Use when working with PDF files, when user mentions forms or document
  extraction, or says "read this PDF", "pull data from a PDF", or "fill out a form".
```

Bad:
```yaml
description: Helps with documents.
```

Claude **undertriggers** by default — err toward more trigger phrases, not fewer.
Include synonyms, casual phrasings, and adjacent contexts where the skill would
add value even if not explicitly named.

## Writing Style

- **Imperative form in body**: "Start by reading…" not "You should read…"
- **Third-person in description**: "Use when…" or "This skill…" — never "you"
- **Explain the why** instead of writing MUST/ALWAYS/NEVER — Claude reasons
  well from rationale, poorly from unexplained mandates

## When to Split

Move to `references/` when:
- The section is only needed in specific cases
- Including it would push SKILL.md past 100 lines
- It's a lookup table, schema, or long checklist

Move to `scripts/` when the same code would be written fresh on every invocation.

## Review Checklist

- [ ] Description ≤1024 chars, two sentences, includes specific trigger phrases
- [ ] SKILL.md body ≤100 lines
- [ ] Body uses imperative form — no second person
- [ ] All referenced files (`references/`, `scripts/`) exist
- [ ] No duplicated content between SKILL.md and references/
- [ ] Manually tested: skill loads on 2–3 realistic user prompts

## Testing

Write 2–3 prompts a real user would type. If the skill doesn't trigger, the
description is the most likely cause — tighten or expand the trigger phrases.

For a full eval loop with subagent benchmarking, an HTML review viewer, and
automated description optimization, use the `skill-creator:skill-creator`
plugin (the official Anthropic skill creator).

## CKS Architecture Constraints

- Agents reference skills via `skills:` frontmatter — commands must NOT load
  skills directly
- Commands dispatch agents; agents own skill loading (see `.claude/rules/`)
- The `.claude/rules/skills.md` guardrail enforces these at review time
