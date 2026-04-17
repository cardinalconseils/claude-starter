# Karpathy Guardrail Catalog

## Trigger

Always generated — applies to every project regardless of stack.

## Template

Write the following to `.claude/rules/karpathy.md`:

```markdown
# Coding Behavior Rules

Four principles that address the most common LLM coding failure modes.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

Before implementing anything non-trivial:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them — don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Test: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it — don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

Test: Every changed line should trace directly to the user's request.

## 4. Define Success, Then Verify

Before starting non-trivial work, transform the task into a verifiable goal:

```
Task: "fix the bug"
→ Success: test that reproduces the bug passes; no other tests break
```

For multi-step tasks, state a brief plan with a verify step for each:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
```

Then loop until every verify step produces evidence. "Seems right" is not done.
```

## Customization Notes

- This catalog has no placeholders — it is stack-agnostic and always applies as-is
- No `globs:` frontmatter needed — these rules apply to all file types
