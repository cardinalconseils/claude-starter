# Model Strategy Reference

Default model assignments by task type. Workflows read `prd-config.json` models section and pass `model:` to `Agent()` dispatch calls. Agent frontmatter `model:` is the fallback when no config exists.

## Tiers

| Tier | Model | Purpose |
|------|-------|---------|
| **reason** | opus | Decisions, judgment, user interaction, architecture |
| **execute** | sonnet | Implementation, mechanical tasks, deployment |
| **bulk** | haiku | Batch processing, scanning, cost analysis |

## Agent → Tier Map

### Reason (opus)
| Agent | Why |
|-------|-----|
| prd-discoverer | Gathers requirements via user interaction |
| prd-designer | Design decisions require user judgment |
| prd-planner | Architecture and trade-off decisions |
| sprint-reviewer | Evaluates quality, makes iteration decisions |
| prd-orchestrator | Coordinates full lifecycle with judgment calls |
| prd-refactorer | Refactoring requires architectural reasoning |
| security-auditor | Security judgment, OWASP analysis |
| debugger | Root cause analysis |
| deep-researcher | Multi-hop reasoning |
| reviewer | Code review requires judgment |
| monetize-evaluator | Business strategy evaluation |

### Execute (sonnet)
| Agent | Why |
|-------|-----|
| prd-executor | Code writing, following a plan |
| prd-verifier | Running tests, checking criteria |
| deployer | Following deployment steps |
| go-runner | Build/commit/push mechanics |
| tdd-runner | RED/GREEN/REFACTOR cycle |
| db-migration | Schema changes from a plan |
| session-loader | Reading files, displaying status |
| code-simplifier | Refactoring with clear rules |
| prd-researcher | Information gathering |
| rules-auditor | Checking rules compliance |
| standup-reader | Reading logs, summarizing |
| session-journalist | Writing DEVLOG entries |
| kickstart-intake | Guided Q&A (structured) |
| kickstart-orchestrator | Sequencing phases |
| kickstart-designer | Generating design artifacts |
| kickstart-handoff | Scaffolding from artifacts |
| bootstrap-generator | Generating config files |
| launch-readiness | Running checklist |
| remotion-specialist | Video code implementation |
| no-code-specialist | Workflow automation |
| monetize-discoverer | Structured data gathering |
| monetize-researcher | Market research |
| migrator | File migration |
| health-checker | Running diagnostics |
| peer-coordinator | Status coordination |
| retrospective | Extracting patterns |
| seo-strategist | SEO analysis |
| aeo-geo-specialist | AEO/GEO analysis |
| design-system-generator | Design token extraction |

### Bulk (haiku)
| Agent | Why |
|-------|-----|
| prd-executor-worker | Parallel file generation |
| doc-generator | Batch documentation |
| cost-analyzer | Spreadsheet-like calculations |
| bootstrap-scanner | File scanning |
| monetize-reporter | Report assembly |
| changelog-generator | Git history processing |
| cost-researcher | Price lookups |
| kickstart-brand | Brand extraction |
| kickstart-ideator | Brainstorming (creative but low-stakes) |

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
