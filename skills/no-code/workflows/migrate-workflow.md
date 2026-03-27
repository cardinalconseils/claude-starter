# Migrate Workflow — Cross-Platform

Guide for migrating automation workflows between no-code platforms.

## Prerequisites

- Source and target platforms identified
- Read `references/platform-adapters.md` — especially the Migration Mapping section
- Source workflow exported or described

## Phase 1: Analyze Source Workflow

```
1. Get the source workflow:
   - n8n: n8n_get_workflow({id}) or n8n_get_workflow_details({id})
   - Make.com: Ask user to export scenario blueprint JSON
   - Workato: Ask user to describe recipe or export
   - Zapier: Ask user to describe Zap steps or share screenshot

2. Map the workflow structure:
   - Trigger type and configuration
   - Each step/node/module and its purpose
   - Data flow between steps
   - Conditional logic and branching
   - Error handling
   - Sub-workflows or called recipes

3. Identify integrations used:
   - List all apps/services connected
   - Note any platform-specific features (Data Stores, Storage, etc.)
   - Flag integrations that may not exist on target platform
```

## Phase 2: Assess Migration Complexity

Score each aspect:

| Aspect | Easy | Medium | Hard |
|--------|------|--------|------|
| Trigger | Same type exists | Different config needed | No equivalent |
| Steps | 1:1 node mapping | Expression translation | Custom code needed |
| Branching | Simple IF → IF | Router → Switch | Complex paths |
| Expressions | Similar syntax | Translatable | Rewrite needed |
| Error handling | Both support it | Different approach | Manual rebuild |
| Sub-workflows | Both support it | Different mechanism | Flatten needed |

Report complexity and estimated effort before proceeding.

## Phase 3: Map Components

Use the concept equivalence table from `references/platform-adapters.md`.

For each source component, document:

```
Source: {platform} {component_type} "{name}"
  Config: {key settings}
  Expressions: {list expressions used}

Target: {platform} {equivalent_component}
  Config: {translated settings}
  Expressions: {translated expressions}
  Notes: {differences, manual steps, limitations}
```

### Expression Translation

Translate every expression using the translation table in `references/platform-adapters.md`.

Common translation patterns:
```
Make.com → n8n:
  {{1.field}}           → {{ $json.field }}
  {{lower(1.field)}}    → {{ $lowercase($json.field) }}
  {{if(1.x; "A"; "B")}} → {{ $json.x ? "A" : "B" }}
  {{formatDate(...)}}   → {{ $moment(...).format(...) }}

Zapier → n8n:
  {{trigger.field}}     → {{ $json.field }} (on trigger output)
  Formatter: Lowercase  → {{ $lowercase($json.field) }}
  Paths                 → IF node or Switch node
  Code by Zapier        → Code node (JS)

Workato → n8n:
  datapill.field        → {{ $json.field }}
  .downcase             → $lowercase()
  .present?             → != null and != ""
  .strftime(...)        → $moment().format(...)
```

## Phase 4: Build Target Workflow

### If target is n8n

```
1. Build node by node using the mapping from Phase 3
2. For each node:
   search_nodes("{integration}") → find correct node type
   get_node_info("{node}") → get parameter schema
   Configure with translated expressions

3. Construct full workflow JSON
4. Validate: n8n_validate_workflow
5. Fix any issues
6. Create: n8n_create_workflow
```

### If target is another platform

```
1. Design the equivalent workflow structure
2. Generate blueprint/config if possible (Make.com JSON)
3. Provide step-by-step instructions for manual setup
4. Include all translated expressions
```

## Phase 5: Validate Migration

```
1. Compare source and target:
   - Same number of logical steps?
   - All integrations accounted for?
   - All expressions translated?
   - Error handling preserved?

2. Test with same input data:
   - Run source workflow (or reference last execution)
   - Run target workflow with same trigger data
   - Compare outputs

3. Document differences:
   - Features that couldn't be migrated (with workarounds)
   - Behavioral differences (timing, retry, etc.)
   - Credentials that need reconfiguring
```

## Phase 6: Migration Report

```
Migration: {source_platform} → {target_platform}
Workflow: "{source_name}" → "{target_name}"

Components migrated:
  - {N} nodes/modules → {N} equivalent nodes/modules
  - {N} expressions translated
  - {N} conditions/branches mapped

Not migrated (manual action needed):
  - {list of features requiring manual setup}
  - {credentials to reconfigure}

Behavioral differences:
  - {any timing, retry, or execution differences}

Test status: {passed/pending}

Next steps:
  1. Configure credentials on target platform
  2. {any manual steps}
  3. Run parallel for {N} days to verify equivalence
  4. Deactivate source workflow
```
