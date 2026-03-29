---
name: no-code
description: >
  No-code automation specialist — builds, debugs, migrates, and optimizes workflows
  across n8n, Make.com, Workato, and Zapier. Platform-adaptive: asks which platform
  then tailors approach, tools, and documentation. Use when: "build workflow",
  "n8n", "make.com", "automation", "no-code", "zapier", "workato", "webhook",
  "integrate", "workflow", or any variation of automation building.
---

# No-Code Automation — `/cks:no-code`

Platform-adaptive automation specialist. Builds, debugs, migrates, and optimizes
workflows across n8n, Make.com, Workato, and Zapier.

## Flow

```
/cks:no-code → parse mode → detect/ask platform → research docs → execute → validate → report
```

## Mode Detection

Parse `$ARGUMENTS` to determine mode:

| Argument Pattern | Mode | Description |
|-----------------|------|-------------|
| `build ...` | **Build** | Create a new workflow from natural language |
| `debug ...` or `fix ...` | **Debug** | Diagnose and fix a failing workflow |
| `transform ...` or `json ...` | **Transform** | JSON/data transformation helper |
| `migrate ...` or `convert ...` | **Migrate** | Cross-platform migration |
| No arguments | **Interactive** | Ask what to do |

## Step 1: Platform Detection

**Auto-detect indicators:**

```
1. Glob for n8n files: *.workflow.json, **/n8n/**
2. Check n8n MCP health: mcp__MCP_DOCKER__n8n_health_check or mcp__claude_ai_N8N__n8n_health_check
3. Glob for Make.com files: *.blueprint.json
4. Glob for Workato files: *.recipe.json
```

**If no indicators found or multiple detected** → Ask:

```
AskUserQuestion({
  questions: [{
    question: "Which automation platform are you working with?",
    header: "Platform",
    multiSelect: false,
    options: [
      { label: "n8n", description: "Self-hosted or cloud n8n — full MCP execution available" },
      { label: "Make.com", description: "Visual automation (formerly Integromat) — design + export mode" },
      { label: "Workato", description: "Enterprise iPaaS — recipe design + advisory mode" },
      { label: "Zapier", description: "Trigger/action Zaps — design + advisory mode" }
    ]
  }]
})
```

## Step 2: Research Platform Docs

**Before proceeding with any mode**, research current platform documentation:

| Platform | Primary Research | Fallback |
|----------|-----------------|----------|
| n8n | `mcp__MCP_DOCKER__search_documentation` / `mcp__claude_ai_N8N__tools_documentation` | Context7 `n8n` |
| Make.com | Firecrawl `make.com/help/...` | WebSearch `site:make.com/help` |
| Workato | Firecrawl `docs.workato.com/...` | WebSearch `site:docs.workato.com` |
| Zapier | Firecrawl `zapier.com/help/...` | WebSearch `site:zapier.com/help` |

For node/module-specific research:
- n8n: `get_node_documentation("{node}")`, `get_node_info("{node}")`
- Others: Search platform docs for the specific integration

Read `skills/no-code/references/platform-adapters.md` for platform-specific syntax and patterns.

## Step 3: Execute by Mode

### Build Mode

Read `skills/no-code/workflows/build-workflow.md` for the full build flow.

Summary:
1. Parse description → identify trigger, actions, data flow
2. Research nodes/modules for the platform
3. **n8n**: Search templates → build JSON → validate → create via MCP
4. **Others**: Design structure → generate blueprint/guide → instruct user

### Debug Mode

1. **n8n**: Get workflow → check executions → run diagnostic → autofix → validate
2. **Others**: Analyze exported JSON or error description → research docs → suggest fixes

### Transform Mode

1. Identify source and target data shapes
2. Write platform-appropriate expressions:
   - n8n: JSONata
   - Make.com: Make formulas
   - Workato: Ruby-like formulas
   - Zapier: Formatter steps or Code by Zapier
3. Test with sample data if available

### Migrate Mode

Read `skills/no-code/workflows/migrate-workflow.md` for the full migration flow.

Summary:
1. Read source workflow export
2. Map concepts between platforms (see agent's concept mapping table)
3. Translate expressions
4. Build equivalent on target
5. Document manual steps

## Step 4: Validate

| Platform | Validation |
|----------|-----------|
| n8n | `n8n_validate_workflow`, `validate_workflow_connections`, `validate_workflow_expressions` |
| Make.com | Review JSON structure, check module compatibility |
| Workato | Review recipe logic, check connector availability |
| Zapier | Review Zap structure, check app availability |

## Step 5: Report

Output a structured report:

```
Platform: {platform}
Mode: {build|debug|transform|migrate}

Result:
  - {what was accomplished}

Integrations: {list of nodes/modules/connectors used}
Validation: {status}

Next steps:
  - {credentials to configure}
  - {manual steps if needed}
  - {testing recommendations}
```

## Dispatching the Agent

For complex tasks, dispatch the `no-code-specialist` agent:

```
Agent({
  subagent_type: "cks:no-code-specialist",
  description: "Build/debug/migrate automation workflow",
  prompt: "{full context including platform and task}"
})
```

## Examples

```bash
# Build a new n8n workflow
/cks:no-code build webhook that receives form data, enriches it via API, and saves to Google Sheets

# Debug a failing workflow
/cks:no-code debug workflow 123 is failing on the HTTP node

# JSON transformation help
/cks:no-code transform nested API response to flat table for Airtable

# Migrate from Zapier to n8n
/cks:no-code migrate our Zapier zap that syncs Stripe payments to Slack

# Interactive mode
/cks:no-code
```
