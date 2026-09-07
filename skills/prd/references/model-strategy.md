# Model Strategy Reference

Default model assignments by task type. Workflows read `prd-config.json` models section and pass `model:` to `Agent()` dispatch calls. Agent frontmatter `model:` is the fallback when no config exists.

## Hard Overrides (cannot be configured away)

These agents MUST always run on `opus` regardless of `prd-config.json` overrides. They require live `AskUserQuestion` tool calls — sonnet/haiku skip these, producing silent autonomous runs:

| Agent | Why it must be opus |
|-------|---------------------|
| `cks:strategist` (discover) | Makes live AskUserQuestion calls during discovery — sonnet outputs text questions instead of calling the tool |
| `cks:architect` (design) | Makes live AskUserQuestion calls at [2a]/[2b]/[2d]/[2f] checkpoints — sonnet skips these entirely |

## Tiers

| Tier | Model | Purpose |
|------|-------|---------|
| **reason** | opus | Decisions, judgment, user interaction, architecture |
| **execute** | sonnet | Implementation, mechanical tasks, deployment |
| **bulk** | haiku | Batch processing, scanning, cost analysis |

## Role → Tier Map

Eighteen roles (`agents/*.md`, `docs/v6-workforce.md`). The tier is the role's frontmatter
`model:`; a `Mode:` in the brief never changes it. `/cks:model set <role> <model>` overrides one role.

### Reason (opus)
| Role | Why |
|------|-----|
| chief-of-staff | Triage, dispatch decisions, one brief — loaded as a skill, not dispatched |
| strategist | Discovery, intake, ideation, monetize scoring — live user interaction |
| architect | Design, planning, ADRs, ERDs — architecture and trade-off decisions |
| reviewer | Code review, security, compliance — judgment, no writes |
| debugger | Root cause analysis before any fix |
| marketer | Positioning, campaign strategy, persona-driven copy |

### Execute (sonnet)
| Role | Why |
|------|-----|
| builder | Code writing from PLAN.md, TDD, refactor, migrations |
| tester | Running tests, verifying criteria, UAT, evals |
| shipper | Build/commit/push/PR, deploy steps, changelog |
| operator | Bootstrap, scaffolds, integrations, routines — mechanical setup |
| project-manager | Issues, board state, handoffs |
| assistant | Inbox and calendar drafts, reminders, daily brief |
| finops | Cost audits, margins, invoices from structured data |
| watchdog | Friction hunts against rules and state — read-only |
| observer | Log, Sentry, LangSmith, canary reads — read-only |
| researcher | Information gathering, multi-hop research |
| historian | Learnings, retro, wiki, memory persistence |

### Bulk (haiku)
| Role | Why |
|------|-----|
| writer | Batch documentation, contract drafts from templates |

## Sprint Sub-Step Model Map

Sprint is the most expensive phase — mixed models optimize cost vs. quality:

| Sub-step | Tier | Model | Why |
|----------|------|-------|-----|
| [3a] Planning | reason | opus | Architecture decisions, scope judgment |
| [3a+] Secrets pre-conditions | execute | sonnet | Mechanical: inject secrets into plan |
| [3b] Technical Design | reason | opus | Trade-offs, patterns, design choices |
| [3b+] Secrets gate | execute | sonnet | Mechanical: verify secrets exist |
| [3c] Implementation | execute | sonnet | Code writing from a plan |
| [3c] Workers | bulk | haiku | Parallel file generation |
| [3c+] De-sloppify | execute | sonnet | Cleanup with clear rules |
| [3d] Code Review | reason | opus | Judgment, finding bugs, security |
| [3e] QA Validation | execute | sonnet | Running tests, checking results |
| [3f] UAT | reason | opus | User interaction, acceptance |
| [3g] Merge | execute | sonnet | Mechanical: git operations |
| [3h] Docs | bulk | haiku | Documentation generation |

## Configuration

`prd-config.json` models section:

```json
{
  "models": {
    "default": {
      "reason": "opus",
      "execute": "sonnet",
      "bulk": "haiku"
    },
    "overrides": {}
  }
}
```

### Override Examples

```json
{
  "models": {
    "default": {
      "reason": "opus",
      "execute": "sonnet",
      "bulk": "haiku"
    },
    "overrides": {
      "prd-executor": "opus",
      "prd-verifier": "opus"
    }
  }
}
```

### Cost-Saving Mode (all sonnet)

```json
{
  "models": {
    "default": {
      "reason": "sonnet",
      "execute": "sonnet",
      "bulk": "haiku"
    }
  }
}
```

## How Workflows Use This

1. Read `prd-config.json` → extract `models.default` and `models.overrides`
2. For each `Agent()` dispatch, determine the tier from this reference
3. Check `overrides` first — if agent name matches, use that model
4. Otherwise use `default[tier]`
5. Pass `model="{resolved_model}"` to `Agent()` call
6. If no `prd-config.json` or no `models` section → use agent frontmatter `model:` as fallback
