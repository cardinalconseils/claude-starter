# Code Comment Rules

Rules for comments in code files produced by CKS agents. These govern what
gets written into source files — not AI chat output (see `output-voice.md`)
and not documentation artifacts (see `docs.md`).

## Mandatory Behavior

When writing or modifying any source file, CKS agents MUST:

- Write comments that explain **WHY**, never WHAT or HOW — the code does that
- Leave no commented-out code blocks in any committed file
- Leave no empty doc-comment stubs (`/** */`, `# TODO: add docs`, etc.)
- Add no authorship or task signatures — git history is the record
- Default to **no comment** — add one only when the WHY is non-obvious

## What Counts as a Justified Comment

A comment earns its place when it captures something a reader cannot infer from
the code itself:

- A hidden constraint: "must run before X initializes or Y throws"
- A subtle invariant the code relies on but doesn't enforce
- A workaround for a specific upstream bug, with a reference
- A non-obvious performance trade-off that the caller needs to understand
- A counter-intuitive choice that would otherwise trigger a "fix this" refactor

If removing the comment would not confuse a future reader, remove it.

## What Does Not Belong in Code

| Pattern | Why it's wrong |
|---|---|
| `// Get the user by ID` above `getUser(id)` | Restates the code. Delete it. |
| `// TODO: handle error properly` | Create a GitHub Issue. Reference `#NNN` or remove. |
| `// Added for the login flow` | Task context belongs in the PR description, not the file. |
| `/* old implementation kept for reference */` followed by commented code | Delete it. The old code is in git history. |
| `/** @param id the user's id */` with no further content | Empty stub — delete it. |

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "This code is complex, it needs explaining" | If it needs explaining, simplify it first. A comment on complex code is a smell, not a solution. |
| "Future readers won't know why I did this" | Correct — write the WHY comment. But that's one line max, not a paragraph. |
| "I'll clean up the TODOs later" | Later never comes. Create the Issue now, reference it, remove the marker. |
| "The commented-out block is a useful reference" | `git log` is the reference. Delete the block. |
| "Every method should have a docstring" | Only if the interface is public and the behavior is non-obvious from the name. Otherwise: no. |

## Verification

- [ ] No commented-out code blocks in staged files (`grep -n "^\s*//" ` for suspicious blocks)
- [ ] No TODO/FIXME/HACK/XXX markers left uncommitted (see `verification.md` pre-commit scan)
- [ ] Every comment present explains WHY, not WHAT
- [ ] No empty doc stubs
