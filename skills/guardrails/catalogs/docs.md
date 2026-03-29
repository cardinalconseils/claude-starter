# Documentation Guardrail Catalog

## Trigger

Always generated — every project has documentation files.

## Template

Write the following to `.claude/rules/docs.md`:

```markdown
---
globs:
  - "**/docs/**"
  - "**/*.md"
  - "**/README*"
  - "**/CHANGELOG*"
  - "**/CONTRIBUTING*"
---

# Documentation Rules

## Content

- Documentation must describe the current state of the code — not aspirational or planned features
- Every claim must be verifiable against the codebase — if the code changes, update the docs
- Include runnable examples where possible — code blocks should work when copied
- Write for the reader who will arrive 6 months from now with no prior context

## Structure

- README.md: what it is, how to run it, how to contribute (in that order)
- CHANGELOG.md: newest entries first, one entry per release or merge to main
- API docs: one section per endpoint, with request/response examples
- Inline comments: only when the code cannot explain itself (why, not what)

## What Not to Document

- Do not add comments that restate the code: `// increment counter` above `counter++`
- Do not create documentation files unless they will be maintained
- Do not document internal implementation details that change frequently
- Do not add TODO comments without a linked issue or a plan to resolve them

## Markdown Style

- Use ATX headers (`#`) not Setext (underline style)
- One sentence per line in source (easier diffs) or flowing paragraphs — pick one per project and stay consistent
- Code blocks must specify the language for syntax highlighting
- Links must be valid — no broken references to files that do not exist

## CLAUDE.md Specifically

- Keep CLAUDE.md under 150 lines — this is a constitution, not a manual
- Every line must earn its place — if a rule is not enforced, delete it
- Update CLAUDE.md at the end of every sprint close, not mid-sprint
- Never put style rules in CLAUDE.md — those belong in .claude/rules/
```

## Customization Notes

- This catalog has no placeholders — it is stack-agnostic and always applies as-is
- If the project uses a documentation generator (JSDoc, Sphinx, rustdoc), add under "Structure": "Generated API docs use {tool} — run `{command}` to regenerate after code changes"
- If the project has a `docs/` directory with a site generator (Docusaurus, VitePress, MkDocs), add: "Documentation site source lives in `docs/` — test locally with `{dev command}` before merging"
