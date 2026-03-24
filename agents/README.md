# Agents

Sub-agent definitions for specialized tasks. Each `.md` file defines one agent with its role, tools, triggers, and constraints.

## Available Agents

| Agent | Role |
|-------|------|
| `reviewer.md` | Reviews PRs and code changes |
| `deployer.md` | Manages Railway deployments |
| `prd-discoverer.md` | Interactive requirements discovery for features |
| `prd-planner.md` | Writes PRD documents and execution plans |
| `prd-executor.md` | Implements planned phases |
| `prd-verifier.md` | Checks acceptance criteria |
| `prd-orchestrator.md` | Drives the full PRD lifecycle |
| `prd-researcher.md` | Investigates codebase and tech options |
| `prd-refactorer.md` | Refactors code with safety checks |
| `aeo-geo-specialist.md` | Answer Engine / Generative Engine Optimization |
| `seo-strategist.md` | SEO strategy and analysis |

## How Agents Are Used

Agents are dispatched by skills and commands via the `Agent()` tool. For example, `/prd:discuss` dispatches `prd-discoverer`, and `/prd:autonomous` orchestrates multiple agents in sequence.

## Creating New Agents

After `/bootstrap`, add new agents by creating a `.md` file here with:
- **Role** — what the agent does
- **Triggers** — when it activates
- **Tools** — which tools it can use
- **Constraints** — what it must not do
- **Handoff** — what it produces and who receives it
