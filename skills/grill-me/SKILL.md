---
name: grill-me
description: >
  Relentless plan/design interrogator — one question at a time, recommends an answer per question, explores codebase before asking. Use when user says "grill me", "stress-test my plan", "interrogate this design", or invokes /cks:grill.
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
  - AskUserQuestion
---

# Grill-Me

Relentlessly interview a plan or design until every decision is resolved. Walk the full decision tree in dependency order. One question at a time. Recommend an answer for every question.

## Core Rules

**1. Recommend before asking**
Every AskUserQuestion MUST include a `(Recommended)` option — the agent's best answer derived from the codebase, project conventions, or stated constraints. Never present a choice without a recommendation.

**2. Explore before asking**
Before any AskUserQuestion: check if the codebase already answers the question (Glob/Grep/Read). If found, report the finding and skip the question. "The codebase already decided this" is a valid answer.

**3. One question at a time**
Never batch multiple questions. Each AskUserQuestion resolves before the next fires. Walking the tree requires order — jumping ahead creates contradictions.

**4. Walk dependency order**
Resolve foundational decisions first. If Decision B depends on Decision A, ask A first. Map the tree before asking anything.

**5. Terminate cleanly**
When the tree is fully resolved, produce a summary: what changed vs the original plan, what was confirmed, and what edge cases were surfaced. Stop — do not invent more questions.

## Decision Tree Protocol

1. Read the plan/design document (or recent CONTEXT.md/PLAN.md if none given)
2. Extract every unresolved decision, assumption, and dependency
3. Sort into dependency order (foundational → derivative)
4. For each node:
   a. Check codebase — if answered, skip and note the finding
   b. If unanswered: form one AskUserQuestion with 2–4 options + `(Recommended)` label on best option
5. When all nodes resolved: write the closing summary

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "This question is obvious, I'll skip it" | Obvious questions surface hidden assumptions. Ask it. |
| "I'll batch two related questions" | Batching creates dependency confusion. One at a time. |
| "No recommendation — it's genuinely 50/50" | 50/50 means you haven't checked the codebase yet. Check first. |
| "The plan is simple, no need to grill it" | Simple plans have the fewest written assumptions and the most hidden ones. |
| "I'll ask what the codebase already shows" | Explore first. Never ask what a Grep can answer. |

## Verification

- [ ] Every AskUserQuestion has a `(Recommended)` option
- [ ] No question was asked without a prior Glob/Grep/Read check
- [ ] Questions fired one at a time — no batching
- [ ] Closing summary produced when tree resolved
- [ ] Zero writes unless user explicitly requested a transcript
