# 4Ds Framework Analysis — Applied to CKS

> How Delegation, Description, Discernment, and Diligence manifest in the CKS architecture — and how to push further via Automation, Augmentation, and Agency.

## Overview

The 4Ds framework provides a lens for evaluating how well an AI-assisted system distributes cognitive work between humans and machines. Each "D" maps to a fundamental question:

| D | Question | CKS Mechanism |
|---|----------|---------------|
| **Delegation** | Who does what? | Commands → Agents → Skills → Workflows |
| **Description** | How clearly is work specified? | YAML frontmatter, system prompts, skill files, state files |
| **Discernment** | What's the right call? | Quality gates, maturity stages, iteration loops, pushback tables |
| **Diligence** | Is the work done right? | Pre-commit guards, confidence ledgers, verification agents, session learnings |

Each D can be delivered through three modes:

| Mode | Definition | Human Role |
|------|-----------|------------|
| **Automation** | System acts without human input | Observer — monitors outcomes |
| **Augmentation** | System proposes, human decides | Decision-maker — chooses from options |
| **Agency** | System acts autonomously with judgment | Supervisor — reviews at milestones |

---

## 1. DELEGATION — "Who does what?"

### Current State in CKS

CKS implements a strict 4-layer delegation hierarchy:

```
Command (thin dispatcher, ~40 lines)
  → Agent (specialist with tools + skills declared in frontmatter)
    → Skill (domain expertise, read by agent at startup)
      → Workflow (progressive disclosure, read step-by-step on demand)
```

**Key examples:**

| Layer | File | Pattern |
|-------|------|---------|
| Command | `commands/go.md` | Parses action arg, dispatches `go-runner` agent |
| Agent | `agents/prd-orchestrator.md` | Drives 5-phase lifecycle, dispatches sub-agents |
| Skill | `skills/prd/SKILL.md` | 250 lines of domain expertise + command reference |
| Workflow | `skills/prd/workflows/discover-phase.md` | 10 sub-step files, each <100 lines |

**Orchestrator pattern:** `prd-orchestrator` and `kickstart-orchestrator` coordinate specialists without doing their work — pure delegation.

**Agent specialization:** Each agent owns a narrow domain:
- `prd-discoverer` — gathers 11 Elements (never designs or codes)
- `prd-designer` — creates UX flows and screens (never implements)
- `prd-executor` — implements code (never discovers or designs)
- `prd-verifier` — validates quality (never writes production code)

### How to Push Further

| Mode | Opportunity | Implementation |
|------|-------------|----------------|
| **Automation** | **Intent Router** — Users currently must know the right `/cks:` command. Add a meta-agent that interprets natural language and auto-dispatches the right specialist. | New agent: `intent-router.md` with `model: haiku` for speed. Reads PRD-STATE.md for context, maps user intent to command, dispatches. |
| **Augmentation** | **Delegation Transparency** — When an orchestrator plans its delegation chain, show it to the user first: "I'll use discoverer, then designer — approve?" | Add a `--preview` flag to orchestrator agents. Before dispatching, display the planned chain and use `AskUserQuestion` for confirmation. |
| **Agency** | **Dynamic Sub-Agent Spawning** — Let agents spawn specialists they weren't pre-configured to use. If `prd-discoverer` finds a security concern, it spawns `security-auditor` on the fly. | Add `Agent` to discoverer's tools list. Define spawn criteria in the system prompt: "If you detect {pattern}, dispatch {agent}." |

---

## 2. DESCRIPTION — "How clearly is work specified?"

### Current State in CKS

CKS is specification-heavy by design. Every component declares itself:

**Agent frontmatter** (declarative capability spec):
```yaml
name: prd-discoverer
subagent_type: prd-discoverer
tools: [Read, Write, Glob, Grep, Agent, AskUserQuestion, "mcp__*"]
model: opus
skills: [prd, product-maturity]
```

**Skill descriptions** (keyword-rich for auto-triggering):
```yaml
description: >
  Product Requirement Document creation and feature lifecycle management —
  5-phase cycle from discovery through design, sprint execution, review,
  and release management with a living roadmap.
```

**State files** (grep-able, machine-readable):
```
Active Phase: 3
Phase Status: IN_PROGRESS
Suggested Command: /cks:sprint
```

**Workflow steps** (structured with context/instructions/success/failure):
```xml
<context>Phase 1, Step 4: Dispatch discoverer</context>
<instructions>Execute discovery for all 11 Elements</instructions>
<success_condition>{NN}-CONTEXT.md exists with all elements</success_condition>
<on_failure>Re-prompt user for missing elements</on_failure>
```

### How to Push Further

| Mode | Opportunity | Implementation |
|------|-------------|----------------|
| **Automation** | **Auto-Description Generation** — When agents consistently use certain tools/patterns, auto-update their frontmatter. The `guardrails` skill already auto-generates rules at bootstrap — extend to agents. | New hook: `PostToolUse` on Agent — track tool usage per agent, flag drift from declared frontmatter. |
| **Augmentation** | **Structured Intake Interviews** — Add a `/cks:describe` command that uses frameworks (Jobs-to-be-Done, User Story Mapping) to help users articulate what they want before entering the lifecycle. The `kickstart-ideator` partially does this. | New command: `describe.md` dispatching an `intake-interviewer` agent with skills: `[ideation, kickstart]`. |
| **Agency** | **Decision Logs** — Let agents write narrative descriptions of what they did and why, not just state updates. Future agents can learn from past decisions. | Add `decisions.jsonl` to `.prd/logs/`. Each agent appends: `{timestamp, agent, decision, rationale, alternatives_considered}`. |

---

## 3. DISCERNMENT — "What's the right call?"

### Current State in CKS

Discernment is embedded in multiple mechanisms:

**Common Rationalizations tables** (prevent corner-cutting):
```
| Rationalization | Reality |
| "Too simple for a PRD" | Simple features in unknown systems create cascading bugs |
| "We already know what to build" | Knowing what without documenting why → scope creep |
```

**Product Maturity Stages** (different quality bars):
- **Prototype** — Skip deep testing, skip monitoring
- **Pilot** — Add auth, validation
- **Candidate** — Full testing, performance, accessibility
- **Production** — Security hardening, observability, rollback plans

**Iteration Loop** (Phase 4 Review routes to the right fix):
```
"UX issues"            → back to Phase 2 (Design)
"Logic bugs"           → back to Phase 3 (Sprint)
"Requirements changed" → back to Phase 1 (Discovery)
"Ready to release"     → forward to Phase 5 (Release)
```

**Anti-Loop Breaker** (prevents retry hell):
- First failure → auto-fix attempt (one try)
- Second failure → escalate to user via AskUserQuestion
- User decides: fix, skip, or mark as known issue

**Hard Gates in Discovery** (4 items require explicit user confirmation):
1. User Stories (3+ confirmed)
2. Acceptance Criteria (2+ per story)
3. Test Plan (reviewed)
4. UAT Scenarios (3+ approved)

### How to Push Further

| Mode | Opportunity | Implementation |
|------|-------------|----------------|
| **Automation** | **Complexity Gate** — Before Phase 3 (Sprint), auto-estimate complexity. If >500 LOC or >10 files, flag for decomposition. | New workflow step: `step-0b-complexity.md` in sprint-phase. Reads PLAN.md, counts estimated files/LOC, warns if thresholds exceeded. |
| **Augmentation** | **Trade-Off Surfacing** — When agents skip quality steps (e.g., "skip E2E tests because Prototype"), surface it explicitly: "Skipping E2E because maturity=Prototype. Override?" | Add a `skipped_gates` array to PRD-STATE.md. Each skip logged with reason. `/cks:audit` displays all skips. |
| **Agency** | **Pushback Protocols** — Agents refuse to proceed if preconditions aren't met. If `prd-executor` detects CONTEXT.md is incomplete, it stops and requests re-discovery. | Add precondition checks to agent system prompts: "Before executing, verify: {checklist}. If any item fails, STOP and report why." |

---

## 4. DILIGENCE — "Is the work done right?"

### Current State in CKS

**Pre-Commit Guard** (`hooks/handlers/pre-commit-guard.sh`):
- Blocks commits with secrets (11 regex patterns: OpenAI, AWS, GitHub, GitLab, Slack keys)
- Warns about debug code (console.log, debugger, breakpoint)
- Blocks .env/.pem/.key files
- Warns about large files (>1MB)

**Post-Edit Guard** (`hooks/handlers/post-edit-guard.sh`):
- Warns about console.log in non-test files
- Flags TODO/FIXME/HACK markers

**Confidence Ledger** (`.prd/phases/{NN}-{name}/CONFIDENCE.md`):
- Auto-detects applicable gates (lint, types, unit tests, integration tests)
- Records pass/fail + evidence for each gate
- Anti-loop: 2 failures → escalate, don't retry

**Failure Taxonomy** (`skills/failure-taxonomy/SKILL.md`):
- Classifies failures: compile, test, branch_divergence, trust_gate, mcp_startup, infra, prompt_delivery
- Maps each to recovery recipe + auto-recoverability flag

**Session Learnings** (`hooks/handlers/session-learnings.sh`):
- Captures decisions, conventions, gotchas at session end
- Re-injects context at next session start

**Lifecycle Logging** (`.prd/logs/lifecycle.jsonl`):
- Every phase transition, gate pass/fail, recovery attempt logged as structured JSON
- Enables post-hoc analysis of project health

### How to Push Further

| Mode | Opportunity | Implementation |
|------|-------------|----------------|
| **Automation** | **Auto-Lint/Test Hook** — Run linter and type-checker after every Edit/Write, not just at sprint end. Catch issues immediately. | New `PostToolUse` hook: detect project type, run lint command, inject warnings into agent context. |
| **Augmentation** | **`/cks:audit` Command** — Diligence dashboard showing quality depth per feature: which have tests, security review, design sign-off, skipped gates. | New command + agent. Reads `.prd/phases/*/CONFIDENCE.md` + `lifecycle.jsonl`. Produces a quality heatmap. |
| **Agency** | **Background Diligence Agent** — Watches code changes during sprints. Injects warnings about code smells, untested paths, missing error handling into the next agent's context. The `code-simplifier` exists but is manual — make it automatic. | New `SubagentStop` hook: after `prd-executor` completes, auto-dispatch `code-simplifier` as a review pass before `prd-verifier`. |

---

## The 4Ds x 3 Modes Matrix

| | Automation | Augmentation | Agency |
|---|---|---|---|
| **Delegation** | Hooks auto-guard (pre-commit, post-edit) | AskUserQuestion for all decisions | `/cks:autonomous` runs full lifecycle |
| **Description** | Frontmatter auto-declares capabilities | Skill descriptions enable auto-triggering | Agents read workflows progressively |
| **Discernment** | Anti-loop breaker stops retry hell | Maturity stages set quality bars | Iteration loop routes to correct fix |
| **Diligence** | Secret scanning, integrity checks | Confidence ledger surfaces evidence | Failure taxonomy enables self-recovery |

## Implementation Priorities

### Tier 1 — Quick Wins (Automation)
1. **Auto-lint PostToolUse hook** — Catch issues at edit time, not sprint end
2. **Complexity gate** — Warn before oversized sprints
3. **Skipped-gates tracking** — Log what was skipped and why

### Tier 2 — High Impact (Augmentation)
4. **`/cks:audit` command** — Quality dashboard across all features
5. **Trade-off surfacing** — Explicit "I skipped X because Y — override?"
6. **Decision log** — `.prd/logs/decisions.jsonl` with rationale

### Tier 3 — Ambitious (Agency)
7. **Intent router** — Natural language → right agent, no command memorization
8. **Pushback protocols** — Agents refuse work when preconditions fail
9. **Background diligence agent** — Auto-review after every sprint execution

---

## Conclusion

CKS already embodies the 4Ds framework implicitly through its architecture:
- **Delegation** is the core pattern (commands → agents → skills → workflows)
- **Description** is the configuration mechanism (frontmatter, state files, skill docs)
- **Discernment** is enforced through quality gates, maturity stages, and rationalization tables
- **Diligence** is automated through hooks, confidence ledgers, and failure taxonomies

Making the 4Ds explicit — as a named framework within CKS — would:
1. Give users a mental model for understanding how CKS works
2. Guide future feature development (every new feature should strengthen at least one D)
3. Enable `/cks:audit` to score projects on each D dimension
4. Create a shared vocabulary between human and AI about quality expectations
