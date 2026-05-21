# Code as Agent Harness — Gap Analysis & CKS Upgrades

> Source survey: [Awesome-Code-as-Agent-Harness-Papers](https://github.com/YennNing/Awesome-Code-as-Agent-Harness-Papers)
> This document maps the survey's paradigm onto CKS, scores where CKS already
> embodies it, identifies three gaps, and records the upgrades that close them.

## 1. What the survey says

The "code as agent harness" paradigm reframes code from *artifact* to *interface*:
the agent reasons by writing, running, and inspecting code, and the runtime —
not a chat transcript — is the source of truth. The survey organizes the work
into a three-layer model and a set of recurring capabilities:

- **Execution-grounded loop** — the agent acts, observes real execution
  feedback (tests, errors, output), and iterates until a verifiable goal is met.
  Convergence is driven by signal, not by a fixed number of tries.
- **Memory & skill library** — the agent accumulates reusable, executable
  skills from its own successes (the Voyager pattern), so later tasks reuse
  proven procedures instead of rediscovering them.
- **Sandboxing & isolation** — code-writing happens in a contained, reversible
  environment so exploration cannot corrupt shared state.
- **Tool/interface grounding** — capabilities are exposed as inspectable,
  composable code interfaces the agent can call and recombine.

## 2. Survey capability → CKS component (evidence)

| Survey capability | CKS component | Evidence |
|---|---|---|
| Execution-grounded loop | sprint plan → execute → verify chain | `agents/prd-orchestrator.md` (Phase 3), `agents/prd-verifier.md` |
| Verifiable goals | acceptance criteria + DoD + verification gates | `.claude/rules/definition-of-done.md`, `.claude/rules/verification.md` |
| Failure signal | verifier failure taxonomy + confidence ledger | `agents/prd-verifier.md:174-181`, `:302-317` |
| Memory & skill library | retrospective → rules promotion + skills layer | `skills/retrospective/SKILL.md`, `skills/`, `agents/retrospective.md` |
| Sandboxing & isolation | worktree-isolated code-writing agents | `.claude/rules/dispatch-first.md` |
| Tool/interface grounding | thin command → agent → skill → workflow layering | `CLAUDE.md` (Architecture Pattern), `commands/`, `agents/`, `skills/` |

## 3. Maturity scorecard (before this change)

| Capability | Rating | Why |
|---|---|---|
| Execution-grounded loop | MODERATE | Plan/execute/verify exists, but the loop capped at "max 1 retry" and didn't feed failure classification back as a fix recipe. |
| Memory & skill library | MODERATE | Learnings promoted to *declarative* rules only; solved *procedures* never became reusable skills. |
| Sandboxing & isolation | MODERATE | Worktree isolation was mandated by rule but unenforced — no hook detected violations. |
| Tool/interface grounding | STRONG | Command→agent→skill→workflow layering is mature and consistent. |

## 4. The three gaps (with evidence)

**Gap 1 — Shallow execution loop.** `agents/prd-orchestrator.md:128-130,252`
hardcoded "first failure → retry once; second failure → log and continue." The
verifier already produced rich signal — a per-track `failure_type`
(`agents/prd-verifier.md:174-181`) and a 2-FAIL anti-loop on confidence gates
(`agents/prd-verifier.md:302-317`) — but the orchestrator neither iterated to
convergence nor consumed that classification. The signal existed; the loop
ignored it.

**Gap 2 — No procedural memory.** `skills/retrospective/SKILL.md:113-191`
promoted high-confidence learnings only into `.claude/rules/{topic}.md` —
declarative constraints. A learning shaped like a *procedure* ("here's the
sequence that fixed the flaky migration") had nowhere to land as a reusable,
triggerable skill. The survey's signature self-accumulating skill library was
absent.

**Gap 3 — Isolation advisory only.** `.claude/rules/dispatch-first.md` mandates
worktree isolation for code-writing agents, but nothing observed tool calls to
catch a violation — `hooks/hooks.json` had no guard on Edit/Write/MultiEdit.

## 5. What this change implements

**U1 — Convergence-driven sprint loop** (`agents/prd-orchestrator.md`,
`.prd/prd-config.json`). Phase 3 now repeats *implement → QA* until the verifier
verdict is PASS or a configured bound is hit (`convergence.max_sprint_iterations`,
default 3). On each failure the orchestrator reads the verifier's `failure_type`
and confidence-gate state and re-dispatches the executor with a **targeted fix
recipe** (classified failure + specific failing acceptance criteria + evidence) —
never a blind retry. The loop is inherently bounded: it defers to the verifier's
existing 2-FAIL `AskUserQuestion` escalation instead of double-escalating, and
stops at the configured ceiling. This consumes signal CKS already produced.

**U2 — Self-accumulating skill library** (`skills/retrospective/SKILL.md`,
`agents/retrospective.md`). Promotion Review now splits candidates by shape:
*declarative* learnings still promote to `.claude/rules/{topic}.md`; *procedural*
learnings promote to a **project-local skill** at `.claude/skills/{topic}/SKILL.md`,
authored per the `skill-creator` skill. The same ≥85 confidence threshold and the
same Approve/Amend/Decline/Defer `AskUserQuestion` flow apply. Auto mode never
auto-creates skills — it queues procedural candidates in `.learnings/conventions.md`
("Proposed for Promotion (skill)") for interactive approval, mirroring the existing
guardrail for standalone rule files. The retrospective agent gains `skill-creator`
in its `skills:` frontmatter so it carries skill-authoring knowledge.

**U3 — Worktree-isolation guard** (`hooks/handlers/worktree-isolation-guard.sh`,
`hooks/hooks.json`, `hooks/README.md`). A new PreToolUse hook on
Edit/Write/MultiEdit detects edits to target-project production code
(`src/ app/ lib/ packages/ server/ api/`) made outside a git worktree and emits a
short advisory pointing at `.claude/rules/dispatch-first.md`. It is **advisory
only** (always exits 0, never blocks — per `.claude/rules/hooks.md`) and excludes
docs, state files, and the CKS plugin's own sources to avoid false positives.

## 6. Notes & sequencing

- **U1 safety.** The loop cannot run away: the per-feature ceiling
  (`max_sprint_iterations`) and the verifier's 2-FAIL anti-loop are independent
  brakes. U1 reuses both rather than inventing new control flow — minimal impact,
  root-caused at the orchestrator where the cap lived.
- **U2 safety.** Skills are only ever created with explicit interactive approval;
  auto mode queues, never writes. This preserves the existing
  "auto mode does not auto-create topic files" invariant.
- **U3 scope.** Advisory by design — enforcement (blocking) would risk false
  positives on legitimate orchestrator edits to plugin sources, which CLAUDE.md
  explicitly permits. A future iteration could promote it to a soft block behind a
  config flag once false-positive rates are observed.
- **Updated scorecard.** With U1/U2/U3 the first three capabilities move from
  MODERATE toward STRONG; tool/interface grounding was already STRONG.
