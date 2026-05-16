# Plan: Expand cks:persona Across CKS Agents

## Status: Backlog idea — not yet scheduled

---

## What cks:persona Is Today

`/cks:persona` runs a guided interview and writes 3 skill card files into `skills/agent-persona/`:
- `persona-card.md` — role, tone, always/never rules, escalation conditions
- `behavior-rules.md` — reasoning postures the AI applies before responding
- `knowledge-index.md` — domain knowledge sources (static files, RAG endpoints, fine-tuned models)

The `agent-persona` skill loads these files and injects them into any agent that declares it in `skills:` frontmatter.

## The Gap

**Zero production CKS agents use `agent-persona` today.** It's opt-in scaffolding — designed for users building their own AI products on top of CKS, not for CKS-internal agents. The persona system is inert unless manually wired.

This means: if you run `/cks:persona` and configure a rich project persona, none of the CKS lifecycle agents (discoverer, planner, executor, reviewer) will ever see it or act on it.

## The Vision

Wire `agent-persona` into CKS lifecycle agents so the project's configured persona propagates automatically. A project with a defined persona should feel like every agent already "knows" the project context and the intended AI character.

## Relationship to /cks:me

These are complementary, not competing:

| System | About | Scope |
|--------|-------|-------|
| `cks:persona` | The AI agent's character | Per-project, committed to repo |
| `cks:me` | The human operator | Global, per-machine, never committed |

Both can be active simultaneously. When both are loaded, an agent knows who it's supposed to be AND who it's talking to.

## Suggested Next Steps

### Phase 1 — Wire persona into lifecycle agents (low effort)

Add `agent-persona` to the `skills:` frontmatter of:
- `agents/prd-discoverer.md` — discovery asks better questions in-persona
- `agents/prd-planner.md` — plans reflect the project's domain posture
- `agents/prd-executor.md` — implementation follows persona constraints
- `agents/prd-verifier.md` — verification checks persona-defined "never" constraints
- `agents/sprint-reviewer.md` — review evaluates against persona expectations

These are additive changes — if `skills/agent-persona/persona-card.md` doesn't exist, the skill gracefully skips.

### Phase 2 — Prompt for persona during bootstrap (medium effort)

In `/cks:bootstrap` and `/cks:kickstart`, after project setup, add a step:
```
💡 SUGGESTION — Run /cks:persona to configure your project's AI character.
   It takes 5 minutes and makes every lifecycle agent context-aware.
```

### Phase 3 — Persona consistency checking (larger effort)

Add a verification step to `prd-verifier` that checks agent outputs against `persona-card.md` never-constraints. Flag violations before merge.

## Files to Modify (Phase 1)

- `agents/prd-discoverer.md` — add `- agent-persona` to skills
- `agents/prd-planner.md` — add `- agent-persona` to skills
- `agents/prd-executor.md` — add `- agent-persona` to skills
- `agents/prd-verifier.md` — add `- agent-persona` to skills
- `agents/sprint-reviewer.md` — add `- agent-persona` to skills

## Notes

- The `agent-persona` skill already handles missing files gracefully — safe to add everywhere
- Phase 1 is a one-PR change: 5 frontmatter additions, no logic changes
- The bigger investment is Phase 3 (consistency checking) — needs a clear spec before starting
