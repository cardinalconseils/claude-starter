# Build Workflow — Step-by-Step

Guide for building a new automation workflow from a natural language description.

## Prerequisites

- Platform detected (Step 1 of SKILL.md)
- Platform docs researched (Step 2 of SKILL.md)
- Read `references/platform-adapters.md` for the target platform

## Phase 1: Parse the Request

Extract from the user's description:

```
1. Trigger: What starts the workflow?
   - Webhook (HTTP request)
   - Schedule (cron/interval)
   - App event (new record, update, etc.)
   - Manual

2. Data flow: What data moves through the workflow?
   - Input shape (what fields come from the trigger)
   - Transformations needed
   - Output shape (what the final step expects)

3. Actions: What happens at each step?
   - API calls
   - Data lookups
   - Conditional logic
   - Notifications

4. Error handling: What if something fails?
   - Retry logic
   - Fallback actions
   - Notification on failure
```

## Phase 2: Design the Workflow

### For n8n

```
1. Search for templates that match:
   search_templates("{trigger} to {action}")
   get_templates_for_task("{description}")

2. If a good template exists:
   get_template({id}) → customize

3. If building from scratch:
   a. Search for each needed node:
      search_nodes("{integration}")
      get_node_info("{node_type}")

   b. Design node chain:
      Trigger → [Transform] → [Condition] → Action → [Error handler]

   c. For each node, get configuration details:
      get_node_essentials("{node_type}")
      get_node_documentation("{node_type}")
```

### For Make.com / Workato / Zapier

```
1. Identify available integrations on the platform
   (research via Firecrawl/WebSearch)

2. Design the module/action chain:
   Trigger → [Filter] → [Transform] → Action

3. Document configuration for each step:
   - Which app/connector
   - Which action/event
   - Field mappings
   - Expressions needed
```

## Phase 3: Build

### n8n — Direct Creation

```
1. Construct workflow JSON:
   {
     "name": "{workflow_name}",
     "nodes": [...],
     "connections": {...},
     "settings": { "executionOrder": "v1" }
   }

2. Validate BEFORE creating:
   n8n_validate_workflow({workflow_json})

   If validation fails:
   - Fix issues
   - Re-validate
   - Use validate_workflow_connections and validate_workflow_expressions for specific checks

3. Create the workflow:
   n8n_create_workflow({workflow_json})

4. Verify creation:
   n8n_get_workflow({returned_id})
```

### Make.com — Blueprint Generation

```
1. Generate scenario blueprint JSON (see platform-adapters.md for structure)
2. Present to user with import instructions:
   - Go to Make.com → Scenarios → Create
   - Click "..." → Import Blueprint
   - Paste the JSON
   - Configure credentials for each module
```

### Workato — Recipe Design

```
1. Document the recipe structure:
   - Trigger: {app} → {event}
   - Step 1: {app} → {action} (map: {field mappings})
   - Step 2: ...

2. Provide step-by-step setup instructions for Workato UI
3. Include datapill references and formula expressions
```

### Zapier — Zap Design

```
1. Document the Zap structure:
   - Trigger: {app} → {event}
   - Action 1: {app} → {action}
   - (Filter if needed)
   - Action 2: ...

2. Provide step-by-step setup instructions for Zapier editor
3. Include field mapping guidance and Formatter configurations
```

## Phase 4: Test

### n8n

```
1. If webhook trigger:
   n8n_trigger_webhook_workflow with test payload

2. Check execution:
   n8n_list_executions → find latest
   n8n_get_execution({id}) → verify success

3. If failed:
   n8n_diagnostic → identify issue
   n8n_autofix_workflow → attempt fix
   Repeat validation
```

### Other Platforms

```
1. Guide user through platform's test/preview feature
2. Suggest test data to use
3. List expected outcomes to verify
```

## Phase 5: Report

Output the build report (see SKILL.md Step 5 format).

Include:
- Workflow ID/name
- All nodes/modules used
- Credentials required (list without values)
- Test results
- Next steps (activate, configure credentials, set schedule)
