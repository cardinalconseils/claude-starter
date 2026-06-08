---
name: code-excellence
description: >
  Positive model of what good code looks like across five structural dimensions:
  naming, function boundaries, error handling, testability, and idiom conformance.
  Use when writing new code, reviewing quality, refactoring for clarity, or when
  a reviewer flags "hard to read", "unclear intent", or "hard to test". Not for
  simplicity (see karpathy-guidelines), anti-pattern detection (see anti-patterns),
  or TDD mechanics (see testing-discipline) — this covers the gaps those leave.
allowed-tools: Read, Grep, Glob
---

# Code Excellence

Five structural dimensions that define what good code looks like. Each has a concrete, testable check — not a preference.

---

## 1. Naming and Cognitive Load

A name succeeds when a reader can state the function's contract from the call-site alone, without opening the definition.

- **Functions:** verb phrase for actions (`fetchUser`, `validateToken`); noun phrase for values (`userEmail`, `tokenExpiry`)
- **Booleans:** `is/has/can/should` prefix; never negated names (`isDisabled` not `notEnabled`)
- **No type encoding in name:** `userString`, `idList` — the type system carries that; the name should carry intent
- **No "and" test:** if describing a function requires the word "and", it has two responsibilities — split it
- **Cognitive load target:** a new reader states the contract in one sentence from the name alone; if they can't, rename before refactoring

**Check:** Cover the definition. Read only the call-site. State what the function does. If you hedged, the name failed.

---

## 2. Function and Module Boundaries

"One responsibility" is not a feeling — it has concrete signals.

- **30-line budget per function:** if a function exceeds 30 lines, the excess is almost always a second responsibility masquerading as detail
- **Return shape consistency:** a function that can return `User | null | undefined | Error` has four responsibilities at the call boundary — pick one error strategy and own it
- **Module exports = coherent concept:** if two exports have nothing to say to each other, they belong in different modules
- **Dependency direction:** modules at the same layer must not import each other in cycles; data flows in, results flow out
- **No "utils" dumping ground:** a utility module with 20 unrelated helpers is 20 modules waiting to be born

**Check:** List every exported symbol from a module. State the module's purpose in one noun phrase. Every export that doesn't fit that phrase is a boundary violation.

---

## 3. Error Handling Strategy

The anti-patterns skill catches silent failures. This dimension defines the positive model.

- **Pick one strategy per layer, stay consistent:** exceptions (throw/catch), result types (`{ data, error }`), or discriminated unions — mixing within one module forces callers to handle all three shapes
- **Type errors at boundaries:** errors that cross a module boundary must be typed, not raw `Error`; callers need to know *what* failed, not just *that* something failed
- **Recovery hierarchy:**
  1. Can this function recover? → recover and return a result
  2. Can the caller recover? → throw a typed, named error
  3. Nobody can recover? → let it propagate; log exactly once at the outermost layer
- **Catch means handle or rethrow:** a catch block that logs and returns `null` is a silent failure with extra steps — it counts as the anti-pattern, not a fix
- **Error messages are for developers:** include system context (`"UserService.create failed: duplicate constraint on users.email"`), not user-facing strings — those belong in the presentation layer

**Check:** For each catch block, answer: does it handle (return a result) or rethrow? If neither, it's a silent failure.

---

## 4. Testability as a Design Property

Distinct from testing-discipline (which covers the TDD cycle). This covers how to *write* code that is testable — before a test is written.

- **Pure functions preferred:** a function with no side effects and deterministic output requires zero mocking; every impure function is a testing tax that compounds
- **Inject dependencies at entry, not inside:** `createUser(db, email)` is testable; `createUser(email)` that internally imports `db` is not — the import is a hidden global
- **Isolate side effects at the edges:** put all I/O (DB writes, API calls, file writes) at the boundary of a unit; the logic in the middle becomes pure and testable
- **Avoid testing-hostile patterns:** static singletons, global state mutated on import, `Date.now()` or `Math.random()` called directly — each requires environment hacks that always leak between tests
- **The 2-mock signal:** if writing a test for a function requires more than 2 mocks, the function is doing too much — refactor the function, not the test

**Check:** Count mocks required to test a function in isolation. More than 2 → the function has hidden coupling; redesign the function.

---

## 5. Idiom Conformance

Every novel pattern introduced creates a learning debt for every future reader.

- **Search before inventing:** before writing a new abstraction, grep the codebase for how the same problem is solved elsewhere; match the existing pattern even if a different approach is objectively cleaner
- **Framework before library before custom:** use the framework's built-in mechanism first; reach for a library only if the framework can't solve it; write custom code only if no library can
- **The novelty bar:** a new pattern is justified only if existing patterns *provably* cannot solve the problem — not "this is cleaner" or "I prefer this"
- **Idiomatic code reads naturally:** it uses the language's control flow without fighting it, it doesn't require a comment to explain *why* it's structured that way, and it doesn't surprise a developer fluent in the language/framework

**Check:** For each novel construct, name the existing pattern it replaces. If you can't name one, the existing pattern wasn't considered.

---

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The name is clear in context" | Names travel: logs, stack traces, search results, PR reviews. Context is not always present. |
| "This function is long but it's all one thing" | If it's >30 lines, name the hidden second responsibility — it's almost always there. |
| "I'll add typed errors later" | The first caller writes a `switch` on `error.message`. That pattern calcifies immediately. |
| "Pure functions are too rigid for this use case" | Rigid by design. If the use case resists purity, the side effects are hidden dependencies. |
| "We already use pattern X; adding Y is fine for this case" | Two patterns for the same problem double cognitive load for every new engineer on the codebase. |
| "This is idiomatic in language Z" | Idiomatic for Z may not match this codebase's established conventions. Search first. |
| "Adding more mocks is easier than refactoring" | Mocks are symptoms. The function has hidden coupling. Fix the design. |

---

## Verification

- [ ] Every function name states its contract; no "and" needed to describe it
- [ ] Functions under 30 lines; any longer has a stated reason
- [ ] Error handling strategy is consistent within each module (not mixed shapes)
- [ ] Errors crossing module boundaries are typed, not raw `Error`
- [ ] No catch blocks that swallow without handling or rethrowing
- [ ] Side-effect-free logic is pure; I/O isolated at edges
- [ ] Dependencies injected at entry point, not imported inside function body
- [ ] No new patterns introduced when existing codebase patterns cover the case
