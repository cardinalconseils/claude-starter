# Setup Philosophy — Deterministic Rails vs Non-Deterministic Calls

A Claude Code setup is not a pile of config. It's a series of decisions about **where judgment is allowed and where it isn't.** Every CKS component is either a **deterministic rail** (same behavior every time, no model discretion) or a **non-deterministic call** (you *want* Claude to reason, adapt, decide).

The governing test, applied to every file added to the kit:

> **Same every time → enforce it** (hook, config, hard rule, script).
> **Needs judgment → guide it** (skill, agent, command prompt).
> **Never put a deterministic rule somewhere the model can reinterpret it, and never script something that actually needs reasoning.**

## The Two Failure Modes

**Rule-as-prose drift.** A rule written as prose in a skill or CLAUDE.md guidance paragraph gets reasoned around the moment a request makes it inconvenient. Test: if you'd be angry to find it skipped, it's deterministic — enforce it in a hook or a flat hard-rule imperative, not in a paragraph.

**Judgment-as-script brittleness.** A decision tree hardcoded for cases you enumerated shatters on inputs you didn't foresee. Test: if you can't list every correct outcome in advance, it's non-deterministic — guide it with a skill or agent prompt.

When you're unsure which bucket a new piece goes in, that uncertainty *is* the first half of the answer. Write down whether you could enumerate every correct outcome ahead of time. Yes → rail. No → judgment.

## The Seven Layers

| Layer | Bucket | Deterministic part | Non-deterministic part |
|---|---|---|---|
| 1. Global `CLAUDE.md` | Mixed | Stack defaults, paths, naming, hard rules | "How to think" guidance, judgment cues |
| 2. Project `CLAUDE.md` | Mixed | Paths, schema, env var names, stack deviations | Project intent, what "done" means here |
| 3. Power commands | Mixed | Trigger + entry point (the door) | The work the command reasons through (the room) |
| 4. Commit hooks | **Pure rail** | Everything — block or pass, no model in the loop | Nothing |
| 5. Agents | Non-deterministic, fenced | Scope, model, return format (the fence) | The reasoning inside the fence |
| 6. Skills | Non-deterministic, railed | Embedded hard rules (paths, packaging cmd) | The methodology / how-to-think |
| 7. Plugins | **Pure rail** | Packaging + distribution of all the above | Nothing — it's a bundler |

**Priority order equals trust order** — earlier layers win on conflict. That override is itself a deterministic rule.

## Setup Order for New Projects

Rails go down *before* judgment layers — build the floor before you let anyone walk on it.

1. Drop global `CLAUDE.md` (or symlink it) — deterministic baseline arrives first
2. Generate project `CLAUDE.md` — lock paths/schema/conventions, write intent guidance
3. Wire commit hooks **before any code** — this is the step that gets skipped and regretted
4. Add power commands for entry points you'll hit repeatedly
5. List skills in project `CLAUDE.md` for discoverability
6. Add agents only when parallel work justifies the coordination cost
7. Bundle into a plugin once the setup has proven itself across 2+ projects

If you're moving fast and want to skip steps, skip 4–6. Never skip 1–3. The rails are the part that makes the speed safe.

## Relationship to Other Rules

This file defines the **why** across all 7 layers. Layer-specific rules define the **how**:

- `commands.md` — how to write commands (thin dispatchers, tool declarations)
- `agents.md` — how to write agents (frontmatter, scope, model selection)
- `skills.md` — how to write skills (size, workflow extraction, rationalizations table)
- `hooks.md` — how to write hooks (exit codes, no `set -e`, no agent dispatch)
- `dispatch-first.md` — when to dispatch vs work inline

**On conflict: the layer-specific rule wins.** This file is context for why those rules exist, not an override.

## Enforcement Trigger

When evaluating a new CKS component (command, agent, skill, hook, rule, integration), apply the bucket test from this file **before** writing any file. Specifically:

- In `/cks:concept` evaluations: Technology Fit pillar scoring must check whether the candidate belongs in the deterministic or non-deterministic layer appropriate to its type
- In sprint reviews: scan new components for rule-in-prose or judgment-in-script violations — flag as a finding if either pattern is detected
- In `prd-discoverer` and `prd-planner`: when a feature adds a new CKS-layer artifact, confirm its bucket before adding it to PLAN.md

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "It's just a guideline, not a hard rule" | Every guideline that must hold every time is a hard rule. Move it to a hook or hard-rule block. |
| "The skill will remind Claude to follow the rule" | Skills are judgment layers. Reminders in skills get skipped when inconvenient. |
| "The script handles this edge case fine" | You enumerated the cases you knew. Scripts shatter on the ones you didn't. |
| "I'll add enforcement later" | Per pre-mortem finding #1: rules without enforcement triggers have zero adoption. Add it in the same PR. |
| "This is too philosophical for a rules file" | `engineering-discipline.md` and `karpathy.md` are also philosophy. Rules files hold both principles and guardrails. |
| "The seven layers are obvious to experienced users" | They're obvious *after* you've felt both failure modes. The doc exists for before that. |

## Verification

- [ ] Every new component added to the kit can be classified as deterministic rail or non-deterministic call
- [ ] No deterministic rule lives only in a skill, agent prompt, or CLAUDE.md guidance prose (grep for "always", "never", "must" in non-rule files — confirm each has a hook or rule backing it)
- [ ] No non-deterministic decision is scripted without an explicit "why this can be enumerated" note
- [ ] New rule files (like this one) include both a Verification block and a Common Rationalizations table
- [ ] This file is referenced in `concept-evaluation.md` tech-fit checklist or equivalent enforcement point
