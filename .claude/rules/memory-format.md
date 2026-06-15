# Memory Format Rules (OKF-Aligned)

CKS memory bundles follow [Open Knowledge Format (OKF) v0.1](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md) — a directory of markdown files with YAML frontmatter, no schema registry, no central authority, no required tooling.

## Required Frontmatter

Every non-reserved file in `memory/` MUST have YAML frontmatter with at minimum:

```yaml
---
type: <see taxonomy below>
name: <slug or short title>
description: <one-line summary>
---
```

Consumers MUST tolerate missing optional fields and unknown type values (OKF permissive consumption rule).

## Type Taxonomy

| Type | Directory / Use | OKF Reserved? |
|---|---|---|
| `index` | `memory/index.md`, `memory/wiki/index.md` | YES — directory listings |
| `log` | `memory/log.md` | YES — chronological append history |
| `article` | `memory/wiki/*.md` — general reference pages | No |
| `decision` | `memory/wiki/decisions/*.md` — architectural choices | No |
| `learning` | `memory/wiki/learnings/*.md` — sprint retrospectives, phase learnings | No |
| `fact` | `memory/wiki/facts/*.md` — project facts, constants | No |

## Rules for Agents Writing Memory

- Wiki agent MUST inject frontmatter on every new page write
- Derive `type` from subdirectory: `wiki/learnings/` → `learning`, `wiki/decisions/` → `decision`, `wiki/` root → `article`
- `memory/log.md` is append-only — use `## [YYYY-MM-DD] Title` headers, no per-entry frontmatter
- `memory/index.md` is human-maintained — update it when new sections are added
- NEVER add OKF frontmatter to `.cks/control-plane/memory/` files — those are system append logs with per-entry headers, not per-file knowledge documents

## Self-Improvement Loop (Session Loader)

`session-loader` MUST scan `memory/wiki/learnings/` and surface the 3 most recent `type: learning` entries in the session brief under "Recent Learnings." This closes the feedback loop:

```
Act → Capture (retro/eod) → Classify (type:learning) → Surface (session-loader) → Evolve (improve agent)
```

Without this surface step, learnings are written but never read back by agents before they act.

## Verification

- [ ] All files in `memory/wiki/` have YAML frontmatter with `type` field
- [ ] `memory/log.md` exists and follows OKF reserved format
- [ ] Wiki agent injects frontmatter on write
- [ ] Session-loader Step 3 includes wiki learnings scan
