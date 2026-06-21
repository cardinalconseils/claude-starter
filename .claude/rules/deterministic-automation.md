---
globs: "agents/no-code-specialist.md,skills/no-code/**,skills/strategic-frameworks/workflows/pre-mortem.md,agents/concept-orchestrator.md,.claude/rules/*.md"
---

# Deterministic vs Indeterministic Automation Rules

## Purpose

Use deterministic tooling for facts, account state, deployment, validation, and repeatable automation. Use agent judgment only for design choices, prioritization, synthesis, and ambiguity that cannot be resolved by an API, CLI, MCP tool, file, or test.

If the system can know or do it through a tool, do not guess.

## Mandatory Classification

Before building any automation, integration, scenario, workflow, loop, or MCP-backed feature, classify each step as deterministic or indeterministic in the implementation notes or design artifact.

| Step type | Classification | Required behavior |
|---|---|---|
| List existing resources | Deterministic | Use CLI/MCP/API. Never ask the user to name resources that can be listed. |
| Read account/team/org/scenario/workflow state | Deterministic | Use CLI/MCP/API and cite the returned ID/name. |
| Create, update, activate, deactivate, run, or delete automation | Deterministic | Use CLI/MCP/API when credentials exist. Validate before write. Confirm destructive operations. |
| Validate schema, blueprint, workflow JSON, expressions, connections | Deterministic | Run validator or CLI dry-run where available. If no validator exists, do structural checks and state the gap. |
| Credentials, OAuth, browser login, billing, plan upgrades, CAPTCHA | Human-controlled deterministic blocker | Surface `▶ ACTION REQUIRED`; never ask the agent to type or expose secrets. |
| Choose architecture, module sequence, filters, data mappings | Indeterministic | Agent proposes based on requirements, docs, and observed constraints. |
| Risk scoring, prioritization, trade-off framing | Indeterministic | Agent judgment allowed, but include evidence and assumptions. |
| Copy, positioning, explanation, summary | Indeterministic | Agent judgment allowed. Keep output concise and concrete. |
| Klein pre-mortem cause generation | Indeterministic first, deterministic artifact second | Use past-tense Klein framing, then write the required YAML/FEASIBILITY artifact. |

## Make.com Account Rule

When the user asks for Make.com automation, default to the authenticated Make toolchain:

1. Check Make CLI access first:
   - `make-cli whoami --output json`
   - `make-cli organizations list --output json`
   - `make-cli teams list --organization-id <org_id> --output json`
2. If Make MCP tools are available in the current Claude/MCP session, use them for account/scenario operations when they provide the needed capability.
3. If both Make CLI and Make MCP are available, use this order:
   - MCP for rich scenario/resource operations exposed as tools
   - `make-cli` for deterministic account state, scenario CRUD, executions, hooks, connections, keys, data stores, and repeatable scripts
   - Blueprint files only as a fallback or review artifact
4. If neither Make CLI nor Make MCP is available, stop and surface `▶ ACTION REQUIRED` with the exact missing setup. Do not fall back to pure advisory mode unless the user explicitly asks for a design-only blueprint.

## Deterministic Make CLI Operations

These are tool-first, not prose-first:

| Need | Command family |
|---|---|
| Auth/account check | `make-cli whoami`, `make-cli organizations list`, `make-cli teams list` |
| Scenario discovery | `make-cli scenarios list/get/interface` |
| Scenario build/update | `make-cli scenarios create/update --blueprint ... --team-id ...` |
| Scenario execution test | `make-cli scenarios run <id> --data ... --responsive` |
| Activation control | `make-cli scenarios activate/deactivate <id>` |
| Execution debugging | `make-cli executions list/get` |
| Webhook management | `make-cli hooks list/get/create/update/delete` |
| Data store work | `make-cli data-stores ...`, `make-cli data-store-records ...` |
| Credentials inventory | `make-cli connections list`, `make-cli keys list` |

Never print API keys, connection secrets, OAuth tokens, or raw credential payloads. Mask anything credential-like before surfacing output.

## Indeterministic Make Work

Agent judgment is allowed for:

- Choosing whether a scenario should be webhook-triggered, scheduled, or app-triggered
- Choosing Make modules, routers, filters, iterators, aggregators, and error handlers
- Translating messy business intent into a scenario design
- Naming scenarios and folders
- Recommending retry/error-handling policy
- Writing test payloads and expected outcomes

But after the design choice, the build/test/deploy step becomes deterministic and must use Make CLI/MCP if available.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I can just describe the Make scenario for the user to build" | If CLI/MCP access exists, build or inspect it directly. Design-only is fallback. |
| "The user can tell me the team ID" | The CLI can list it. Use the tool. |
| "The scenario looks right" | Run a deterministic validation or test execution when available. |
| "Credentials are annoying, I'll ask for the token" | Never ask for secrets in chat. Ask the user to run login/OAuth/setup. |
| "Risk scoring is subjective, so no tools are needed" | Scoring is subjective; evidence collection is not. Gather facts first. |
