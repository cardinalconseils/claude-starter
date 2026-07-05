# Engineering Discipline Rules

Three rules that govern how Claude approaches every change. No exceptions based on task size.

---

## 1. Simplicity First

Every change must be as simple as possible while solving the actual problem.

- A one-line fix beats a clever rewrite
- If two approaches solve the problem equally, pick the one with fewer moving parts
- No abstractions for hypothetical future requirements
- No helper functions for code that appears once
- Three similar lines is better than a premature abstraction

**Test:** Would a junior engineer understand this change in 30 seconds? If not, simplify.

---

## 2. Minimal Impact

Touch only what the task requires. Nothing else.

- Do not refactor code adjacent to the change unless explicitly asked
- Do not rename variables, reformat files, or "clean up" unrelated sections
- Do not add error handling for scenarios outside the reported bug
- If a file must be opened to make the change, only edit the relevant lines

**Test:** Run `git diff` — every changed line must map directly to the task description.

---

## 3. Root Cause Only — No Lazy Fixes

Find the actual cause. Fix that. Never paper over symptoms.

- A symptom fix that masks the root cause is not a fix — it is future debt
- If a bug report points to a log line or stack trace, trace it to origin before touching code
- If a workaround feels necessary, state why the proper fix is blocked and get confirmation
- Never add a try/catch, default value, or early return to silence an error without understanding it

**Test:** Can you explain in one sentence WHY the fix works, not just WHAT it does?

---

## Write-Time Minimalism Ladder

Before writing any new code, walk these rungs top to bottom. Stop at the first that
answers the need — do not descend further than required. This is a procedure, not a
suggestion: apply rung 1, then 2, and so on.

**Guards first — the ladder never eliminates these.** Trust-boundary validation, security
checks, error handling, and accessibility attributes are load-bearing. No rung — including
rung 1 — licenses removing a guard. Apply the ladder only to non-guard code; if a chosen
rung's option lacks a guard, add the guard rather than shipping the bare call.

1. Does this need to exist? If no — skip it (YAGNI).
2. Already in the codebase? Reuse it — do not reinvent.
3. Does the standard library do it? Use stdlib.
4. Is there a native platform feature? Use it.
5. Is it in an installed dependency? Use that.
6. Can it be one line? Write the one line.
7. Only then: write the minimum code that works.

---

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "This refactor is small, I'll do it while I'm in here" | Unrequested changes introduce unrequested risk. Scope creep is a bug. |
| "The proper fix is too complex right now" | Say so explicitly and get confirmation. Don't silently ship the band-aid. |
| "Adding a default value is harmless" | Silent defaults hide bad states. The next engineer will not know why it's there. |
| "I'll simplify it later" | You won't. Simple now. |
| "A wrapper is cleaner than repeating the logic" | Wrappers hide intent. Repeat the two lines. |
| "The bug is in the log, not in the cause" | Fix the cause. The log is evidence, not the patient. |
| "This abstraction is cleaner than the inline version" | Cleaner to you, indirection to the next reader. Rung 6/7 wins over a new abstraction. |
| "Stdlib is verbose, my helper reads better" | Rung 3 stands: stdlib is tested and shared. A private helper is one more thing to maintain and test. |
| "This change is trivial, the ladder doesn't apply" | The ladder applies to every change — no size exception (see the header). Trivial changes add the most unreviewed bloat. |
| "I'll reuse it later, so I'll build it flexible now" | Rung 1: it doesn't need to exist yet. Build the one use you have; generalize when the second caller is real. |
