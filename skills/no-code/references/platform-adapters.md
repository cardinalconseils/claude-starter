# Platform Adapters Reference

Per-platform reference for expression syntax, node patterns, MCP tools, and migration mappings. Read this file when working with any no-code platform.

---

## n8n

**Execution mode:** Full — MCP tools available for direct workflow management.

### MCP Tool Sets

Two tool sets exist (try both, use whichever responds):

| Set | Prefix | Use Case |
|-----|--------|----------|
| Local Docker | `mcp__MCP_DOCKER__n8n_*` | Self-hosted n8n instance |
| Cloud | `mcp__claude_ai_N8N__*` | n8n cloud instance |

### Key MCP Tools

```
# Discovery
search_nodes("{keyword}")              — Find available nodes
get_node_info("{node_type}")           — Node parameters and options
get_node_documentation("{node_type}")  — Full node docs
get_node_essentials("{node_type}")     — Quick reference
search_templates("{task}")             — Find workflow templates
get_templates_for_task("{task}")       — Task-oriented template search

# Workflow CRUD
n8n_create_workflow                    — Create new workflow
n8n_get_workflow({id})                 — Get workflow by ID
n8n_list_workflows                     — List all workflows
n8n_update_full_workflow               — Full workflow update
n8n_update_partial_workflow            — Partial update (add/modify nodes)
n8n_delete_workflow({id})              — Delete workflow

# Validation
n8n_validate_workflow                  — Full validation
validate_workflow_connections          — Check node connections
validate_workflow_expressions          — Check expression syntax

# Debugging
n8n_diagnostic                         — Diagnose workflow issues
n8n_autofix_workflow                   — Auto-fix common issues
n8n_list_executions                    — List execution history
n8n_get_execution({id})                — Get execution details

# Testing
n8n_trigger_webhook_workflow           — Trigger webhook for testing

# System
n8n_health_check                       — Check n8n availability
n8n_list_available_tools               — List all available MCP tools
```

### Expression Syntax — JSONata

n8n uses JSONata for expressions. Wrap in `{{ }}` within node parameters.

```jsonata
// Access input data
{{ $json.fieldName }}

// Nested access
{{ $json.customer.email }}

// Array operations
{{ $json.items[price > 100] }}

// String manipulation
{{ $uppercase($json.name) }}

// Date formatting
{{ $moment($json.date).format("YYYY-MM-DD") }}

// Conditional
{{ $json.status = "active" ? "Yes" : "No" }}

// Reference other nodes
{{ $node["HTTP Request"].json.data }}

// Current timestamp
{{ $now() }}
```

### Common Node Patterns

```
Webhook → IF → [Branch A] → HTTP Request → Set → Respond to Webhook
                [Branch B] → Slack → NoOp

Schedule Trigger → HTTP Request → Function → Google Sheets

Webhook → Switch → [Case 1] → Action
                   [Case 2] → Action
                   [Default] → Error notification
```

---

## Make.com (formerly Integromat)

**Execution mode:** Design only — no MCP tools. Generate blueprints and guide user.

### Expression Syntax — Make Formulas

```
// Variable access
{{1.fieldName}}            // Output from module 1

// String functions
{{lower(1.email)}}
{{substring(1.name; 0; 5)}}

// Date functions
{{formatDate(1.date; "YYYY-MM-DD")}}
{{addDays(now; 7)}}

// Math
{{1.price * 1.quantity}}

// Conditional (IF function)
{{if(1.status = "active"; "Yes"; "No")}}

// Array
{{join(1.tags; ", ")}}

// Parse JSON
{{parseJSON(1.body)}}
```

### Key Concepts

| Concept | Description |
|---------|-------------|
| **Scenario** | A complete automation (= workflow) |
| **Module** | A single step (= node) — triggers, actions, searches, transformers |
| **Router** | Splits execution into multiple paths (= IF/Switch) |
| **Filter** | Conditions between modules that gate execution |
| **Iterator** | Breaks arrays into individual items for processing |
| **Aggregator** | Combines items back into an array |
| **Data Store** | Built-in key-value database |
| **Webhook** | Custom HTTP endpoint to trigger scenarios |

### Blueprint JSON Structure

```json
{
  "name": "My Scenario",
  "flow": [
    {
      "id": 1,
      "module": "gateway:CustomWebHook",
      "version": 1,
      "parameters": { "hook": 12345 },
      "mapper": {}
    },
    {
      "id": 2,
      "module": "http:ActionSendData",
      "version": 3,
      "parameters": {},
      "mapper": {
        "url": "https://api.example.com",
        "method": "POST",
        "body": "{{1.body}}"
      }
    }
  ]
}
```

---

## Workato

**Execution mode:** Design only — no MCP tools. Design recipes and guide user.

### Expression Syntax — Ruby-like Formulas

```ruby
# String
"Hello " + datapill.name
datapill.email.downcase
datapill.name.strip.capitalize

# Date
datapill.created_at.strftime("%Y-%m-%d")
datapill.created_at + 7.days
now

# Number
datapill.price.to_f * 1.1
datapill.quantity.to_i

# Conditional
datapill.status.present? ? "Active" : "Inactive"

# Array
datapill.tags.join(", ")
datapill.items.where("status": "active")
datapill.items.pluck("name")

# Hash/Object
datapill.to_json
datapill.dig("nested", "field")
```

### Key Concepts

| Concept | Description |
|---------|-------------|
| **Recipe** | A complete automation (= workflow) |
| **Trigger** | Event that starts the recipe |
| **Action** | Step that performs an operation |
| **Connector** | Integration with an app/service |
| **Datapill** | Dynamic reference to data from previous steps |
| **Lookup table** | Reusable reference data |
| **Callable recipe** | Sub-recipe invoked by other recipes (= sub-workflow) |
| **Error monitor** | Try/catch block for error handling |

---

## Zapier

**Execution mode:** Design only — no MCP tools. Design Zaps and guide user.

### Expression Syntax — Template Syntax

```
// Step references (numbered from trigger)
{{zap.trigger.field_name}}
{{steps.action_1.field_name}}

// In Code by Zapier (JavaScript)
const data = inputData.field;
output = [{ result: data.toUpperCase() }];

// In Formatter steps:
// - Text: Extract Pattern, Replace, Trim, Capitalize, etc.
// - Number: Format Number, Math operations
// - Date: Format, Add/Subtract Time, Compare
// - Utilities: Lookup Table, Line Item to Text
```

### Key Concepts

| Concept | Description |
|---------|-------------|
| **Zap** | A complete automation (= workflow) |
| **Trigger** | Event that starts the Zap (1 per Zap) |
| **Action** | Step that performs an operation |
| **Search** | Find an existing record |
| **Path** | Conditional branching (= IF/Router) |
| **Filter** | Continue only if conditions met |
| **Formatter** | Built-in data transformation |
| **Webhooks by Zapier** | Custom HTTP send/receive |
| **Code by Zapier** | JavaScript/Python code step |
| **Storage** | Simple key-value store |
| **Sub-Zap** | (not native — use webhooks to chain) |

---

## Migration Mapping

### Concept Equivalence

| Concept | n8n | Make.com | Workato | Zapier |
|---------|-----|----------|---------|--------|
| Workflow | Workflow | Scenario | Recipe | Zap |
| Start event | Trigger node | Trigger module | Trigger | Trigger |
| Step | Node | Module | Action | Action |
| Branching | IF / Switch | Router | IF condition | Paths |
| Loop | SplitInBatches | Iterator | Repeat for each | Looping |
| Error handling | Error Trigger | Error handler | Error monitor | (limited) |
| Variables | `$json`, `$node` | `{{N.field}}` | Datapills | `{{steps.X.field}}` |
| Sub-workflow | Execute Workflow | Call scenario | Callable recipe | Webhooks chain |
| Webhook | Webhook node | Webhook module | Webhook trigger | Webhooks by Zapier |
| HTTP call | HTTP Request | HTTP module | HTTP action | Webhooks by Zapier |
| Schedule | Schedule Trigger | Scheduling | Scheduled trigger | Schedule trigger |
| Data store | (external) | Data Store | Lookup table | Storage |
| Code step | Code / Function | (limited) | Ruby code | Code by Zapier |

### Expression Translation Examples

| Operation | n8n (JSONata) | Make.com | Workato | Zapier |
|-----------|--------------|----------|---------|--------|
| Access field | `{{$json.name}}` | `{{1.name}}` | `datapill.name` | `{{trigger.name}}` |
| Lowercase | `{{$lowercase($json.name)}}` | `{{lower(1.name)}}` | `datapill.name.downcase` | Formatter: Lowercase |
| Date format | `{{$moment($json.date).format("YYYY-MM-DD")}}` | `{{formatDate(1.date; "YYYY-MM-DD")}}` | `datapill.date.strftime("%Y-%m-%d")` | Formatter: Format Date |
| Conditional | `{{$json.x ? "A" : "B"}}` | `{{if(1.x; "A"; "B")}}` | `datapill.x.present? ? "A" : "B"` | Paths or Filter |
| JSON parse | `{{$parseJson($json.body)}}` | `{{parseJSON(1.body)}}` | `datapill.body.parse_json` | Code by Zapier |

### Common Migration Gotchas

| From → To | Watch Out For |
|-----------|--------------|
| Zapier → n8n | Zapier has 1 trigger per Zap; n8n supports multiple trigger nodes. Formatter steps → use Set/Function nodes. |
| Make.com → n8n | Router with filters → use IF/Switch nodes. Iterator/Aggregator → SplitInBatches + Merge. Data Store → external DB. |
| Workato → n8n | Callable recipes → Execute Workflow node. Ruby formulas → JSONata (significant syntax change). Error monitor → Error Trigger workflow. |
| n8n → Make.com | Execute Workflow → scenario linking. JSONata → Make formulas. Error Trigger → Error handler route. |
| n8n → Zapier | Complex branching (Switch with many cases) → multiple Paths or separate Zaps. Sub-workflows → webhook chaining. |
