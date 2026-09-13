# docs/diagrams — generated process maps

Six editorial diagrams of the CKS workforce plus a gallery index. Every file here is
**generated** — never hand-edit one; edit `scripts/generate-diagrams.py` (or the repo facts
it reads) and regenerate.

| File | Type | Reads |
|---|---|---|
| `index.html` | gallery | the card list in the generator |
| `workforce-org-chart.html` | org chart | `agents/*.md` frontmatter (name, model, first clause of description), `scripts/agent-graph.sh --edges` for the dispatch fan-in |
| `lifecycle-process.html` | process | `pipelines/sprint.dot` (`cks_agent` per node), `.claude/rules/phase-gates.md` artifact table, `.claude/rules/definition-of-done.md` |
| `routine-run-loop.html` | loop | `skills/routines/workflows/routine-run.md` step headings, `docs/hq.md` |
| `state-er.html` | ER / data model | `.claude/rules/agents.md`, `.claude/rules/telemetry.md` (Layer 2), `.claude/rules/phase-gates.md`, `.claude/rules/definition-of-done.md`, `skills/routines/templates/*.md`, `skills/routines/workflows/routine-run.md`, `docs/hq.md`, live counts of `commands/` `agents/` `skills/` `.claude/rules/` `hooks/hooks.json` |
| `plugin-layers.html` | layer stack | the Architecture Pattern block of `CLAUDE.md`, the orchestrator exception in `.claude/rules/commands.md`, live file counts |
| `dispatch-sequence.html` | sequence | `.claude/rules/commands.md`, `hooks/hooks.json` (events + handler basenames, lifecycle order) |

## Regenerate, check, verify

```bash
python3 scripts/generate-diagrams.py            # write docs/diagrams/
python3 scripts/generate-diagrams.py --check    # exit 1 on drift (wired as integrity check 13b)
python3 scripts/generate-diagrams.py --verify   # run diagram-design's geometry checker
```

Output is deterministic: same tree in, byte-identical files out. No timestamps, no hashes,
no absolute paths. `scripts/test-integrity.sh` runs `--check` so a repo fact that moved
without a regeneration fails the build.

## The design system is an external plugin

The diagrams follow the design system of **diagram-design**
(`cathrynlavery/diagram-design`, MIT) — its style-guide tokens, SVG primitives, the six
mandatory connector rules, the 4px grid and each type's complexity budget. The plugin is a
**dependency, not vendored**: nothing from it is copied into this repo.

```
/plugin marketplace add cathrynlavery/diagram-design
/plugin install diagram-design@diagram-design
```

`.diagram-design` at the repo root pins `profile: default` — the shipped skin — which also
skips the plugin's first-run style gate.

`--verify` locates a checkout via `$DIAGRAM_DESIGN_ROOT`, then
`~/.claude/plugins/cache/*/diagram-design*`, then
`~/.claude/plugins/marketplaces/diagram-design`. With none of those present it prints the
install lines and exits 0, so the plugin is never a hard build dependency.

## Deviations from the upstream type references

- `lifecycle-process.html` keeps the process grammar (lanes, header chips, role chip +
  title + artifact + tool per node, input/output data chips, single-bend right-angle
  routing, legend rows) but scales every coordinate and font size onto the 4px grid; the
  reference's own 6/6.5/9px type sizes break that grid.
- `routine-run-loop.html` renders seven stations — the file has seven numbered steps — and
  gives the hub an accent stroke so the one shared record is also the one accent element.
- `state-er.html` shows the routine profile's sixteen frontmatter keys sorted, as the union
  across `skills/routines/templates/*.md`.

## Adding or changing a diagram

For maps of CKS itself, change the generator — never hand-draw one. For anything else
(a client system, a one-off explainer), dispatch `cks:architect` with `Mode: diagram`,
which loads the plugin's skill and the one type reference it needs.
