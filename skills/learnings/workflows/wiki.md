# Workflow: Wiki

Read and write pages in `memory/wiki/` with OKF frontmatter. Ported from the `wiki` agent.
Run by the historian role. Format contract: `.claude/rules/memory-format.md`.

## Modes

**list** — `Glob("memory/wiki/**/*.md")`; show relative paths without `.md`. No directory →
`No wiki pages found. Use "write <page>" to create the first one.`

**read `<page>`** — show `memory/wiki/<page>.md`; missing → `Page not found: … — use "write
<page>" to create it.`

**write `<page>`** — content from the `Content:` field of the dispatch (none → ask what the
page should contain). Then:
1. Derive `type` from the subdirectory: `wiki/learnings/` → `learning`, `wiki/decisions/` →
   `decision`, `wiki/facts/` → `fact`, anything else under `wiki/` → `article`; `output/` →
   `report`; `gatekeeper/` → `log`
2. Prepend frontmatter — `type`, `name` (slug, last path segment), `description` (one line,
   from the first heading or the dispatch)
3. Write the file (`Write` creates parent directories); print `✅ Written: memory/wiki/<page>.md`

**edit `<page>`** — read the page; extract the existing frontmatter block; apply the change to
the body only; write frontmatter + new body; never change `type`, `name`, or `description`
unless the dispatch explicitly asks; print `✅ Edited: … (frontmatter preserved)`.

**search `<query>`** — `Grep("memory/wiki/", query)`; show files and matching lines; none →
`No results for "<query>" in memory/wiki/.`

**index** — `memory/index.md` and `memory/wiki/index.md` are `type: index` and human-maintained:
update them when a new section is added, never regenerate them wholesale.

## OKF validation (write and edit)

Before finalizing, confirm all three fields are present: `type` ∈ {index, log, article,
decision, learning, fact, report}, `name`, `description`. Missing → do not write; surface:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
▶ ACTION REQUIRED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Run:    Provide the missing OKF field(s): {list}
Why:    memory-format.md requires type + name + description on every memory/ file
Then:   Re-run the write/edit with the missing fields filled in
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Rules

- Never delete pages — append or overwrite only
- `memory/log.md` is append-only: `## [YYYY-MM-DD] Title` headers, no per-entry frontmatter
- Relative paths in output; page slugs are case-sensitive, keep the caller's spelling
- Mode unclear → ask: list, read, write, edit, or search
