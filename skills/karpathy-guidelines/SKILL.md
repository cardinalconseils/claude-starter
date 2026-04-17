---
name: karpathy-guidelines
description: >
  Behavioral guardrails derived from Andrej Karpathy's observations on LLM coding pitfalls.
  Use when: writing, reviewing, or refactoring code; agent is over-engineering; agent is
  making silent assumptions; agent is modifying code outside its scope; agent is not defining
  success criteria before starting work.
allowed-tools: Read, Grep, Glob
---

# Karpathy Guidelines

Four principles that directly address the most common LLM coding failure modes, derived from [Andrej Karpathy's observations](https://x.com/karpathy/status/2015883857489522876).

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing anything non-trivial:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them — don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Test: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it — don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

Test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria upfront. Loop until verified.**

Transform imperative tasks into verifiable goals before writing any code:

| Instead of... | Transform to... |
|---|---|
| "Add validation" | "Tests for invalid inputs pass; valid inputs still work" |
| "Fix the bug" | "A test reproducing the bug passes; no other tests break" |
| "Refactor X" | "Tests pass before and after; behavior is identical" |

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria enable independent looping. Weak criteria ("make it work") require constant clarification interruptions.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The intent is obvious" | Obvious to whom? State it and confirm. |
| "I'll just add this while I'm here" | Unrequested additions are unrequested maintenance burden |
| "100 lines feels right for this" | If 30 lines suffice, 100 lines is a failure |
| "I'll clean up this dead code too" | Pre-existing dead code is not your mess |
| "It looks right so it's done" | "Looks right" is not evidence. Provide verification output. |
| "This is too simple for success criteria" | Simple tasks with unclear goals produce wrong outputs |

## Verification

- [ ] Assumptions stated before starting — no silent interpretations
- [ ] Simpler approach considered and either taken or explicitly rejected
- [ ] Success criteria defined before multi-step work began
- [ ] Only requested code was changed; orphans from your changes removed
- [ ] Pre-existing dead code mentioned, not deleted
- [ ] Evidence of correctness provided (tests, build output, runtime confirmation)
