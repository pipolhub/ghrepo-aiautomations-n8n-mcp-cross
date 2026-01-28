# MCP Tools Guide

Complete reference for using the n8n MCP server tools to manage workflows programmatically.

---

## Available Tools (22 total)

### Workflow Management

#### `list_workflows`
List all workflows with optional filtering.

```javascript
list_workflows({ active: true, limit: 10 })
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `active` | boolean | Filter by active status (optional) |
| `limit` | integer | Max results (default: 100) |
| `cursor` | string | Pagination cursor |

---

#### `get_workflow`
Get a workflow by ID with full details.

```javascript
get_workflow({ id: "abc123" })
```

Returns: Complete workflow JSON including nodes, connections, settings.

---

#### `create_workflow`
Create a new workflow with local validation.

```javascript
create_workflow({
  name: "My Workflow",
  nodes: [
    {
      id: "1",
      name: "Start",
      type: "n8n-nodes-base.manualTrigger",
      typeVersion: 1,
      position: [250, 300]
    },
    {
      id: "2",
      name: "Set Data",
      type: "n8n-nodes-base.set",
      typeVersion: 3,
      position: [450, 300],
      parameters: {
        assignments: {
          assignments: [
            { name: "message", value: "Hello!", type: "string" }
          ]
        }
      }
    }
  ],
  connections: {
    "Start": {
      "main": [[{ "node": "Set Data", "type": "main", "index": 0 }]]
    }
  },
  settings: {}
})
```

**Validation checks:**
- Required fields: name, nodes, connections
- Node structure: id, name, type, position
- Connection references valid nodes
- Expression syntax (balanced `{{ }}`)

---

#### `update_workflow`
Update an existing workflow. Fetches current state, merges updates, saves.

```javascript
update_workflow({
  id: "abc123",
  name: "Updated Name"  // Only changed fields needed
})
```

---

#### `validate_workflow`
Validate workflow JSON without submitting.

```javascript
validate_workflow({
  workflow: { name: "Test", nodes: [...], connections: {...} }
})
```

Returns: `{ valid: true/false, errors: [], warnings: [] }`

---

#### `activate_workflow` / `deactivate_workflow`
Publish or unpublish a workflow.

```javascript
activate_workflow({ id: "abc123" })
deactivate_workflow({ id: "abc123" })
```

---

### Execution Management

#### `list_executions`
List workflow executions with filters.

```javascript
list_executions({
  workflowId: "abc123",
  status: "success",  // "error", "success", "waiting"
  limit: 20
})
```

---

#### `get_execution`
Get execution details including input/output data.

```javascript
get_execution({ id: "1234", includeData: true })
```

---

### Credential Management

#### `list_credentials`
List available credentials (metadata only, not secrets).

```javascript
list_credentials({ limit: 50 })
```

> **Note:** May return 405 on n8n Cloud due to security restrictions.

---

#### `get_credential_schema`
Get the configuration schema for a credential type.

```javascript
get_credential_schema({ credentialType: "slackOAuth2Api" })
```

Common types: `httpBasicAuth`, `httpHeaderAuth`, `oAuth2Api`, `slackOAuth2Api`, `googleSheetsOAuth2Api`, `notionApi`

---

### API Discovery

#### `download_api_spec`
Download latest n8n OpenAPI spec from GitHub and load into database.

```javascript
download_api_spec()
```

Run this first to enable `search_api_endpoints`.

---

#### `search_api_endpoints`
Search the API endpoint database.

```javascript
search_api_endpoints({ query: "workflow", limit: 10 })
```

---

#### `get_api_endpoint_details`
Get detailed endpoint info including parameters and request body schema.

```javascript
get_api_endpoint_details({ path: "/workflows", method: "POST" })
```

---

#### `load_api_spec_from_json`
Load OpenAPI spec from a local JSON file.

```javascript
load_api_spec_from_json({ json_file_path: "/path/to/spec.json" })
```

---

### Core API Tools

#### `execute_api_call`
Execute any n8n API call directly.

```javascript
execute_api_call({
  path: "/workflows",
  method: "GET",
  params: { limit: 5 }
})

execute_api_call({
  path: "/workflows",
  method: "POST",
  data: { name: "New Workflow", nodes: [], connections: {}, settings: {} }
})
```

---

#### `send_raw_api_request`
Execute API using raw request string format.

```javascript
send_raw_api_request({
  raw_request: "GET /workflows?limit=5"
})

send_raw_api_request({
  raw_request: 'POST /tags {"name":"my-tag"}'
})
```

---

#### `natural_language_api_search`
Search for API calls using natural language. Checks Fast Memory first.

```javascript
natural_language_api_search({ query: "list all tags" })
```

---

### Fast Memory Cache

Cache successful API patterns for quick reuse.

#### `save_to_fast_memory`
```javascript
save_to_fast_memory({
  natural_language_query: "list all tags",
  api_path: "/tags",
  api_method: "GET",
  description: "Get all tags in n8n"
})
```

#### `list_fast_memory`
```javascript
list_fast_memory({ search_term: "tags", limit: 10 })
```

#### `delete_from_fast_memory`
```javascript
delete_from_fast_memory({ id: 1 })
```

#### `clear_fast_memory`
```javascript
clear_fast_memory()
```

---

## Common Workflows

### Create and Activate a Workflow

```javascript
// 1. Create the workflow
create_workflow({
  name: "Daily Report",
  nodes: [...],
  connections: {...},
  settings: {}
})
// Returns: { id: "newId123", ... }

// 2. Activate it
activate_workflow({ id: "newId123" })
```

### Check Recent Executions

```javascript
// List recent failures
list_executions({
  workflowId: "abc123",
  status: "error",
  limit: 5
})

// Get details of specific execution
get_execution({ id: "exec456", includeData: true })
```

### Explore Available APIs

```javascript
// First, load the API spec
download_api_spec()

// Search for endpoints
search_api_endpoints({ query: "tags" })

// Get details
get_api_endpoint_details({ path: "/tags", method: "POST" })
```

---

## Tips

1. **Always validate first:** Use `validate_workflow` before `create_workflow` to catch errors early.

2. **Use dedicated tools:** Prefer `list_workflows`, `get_workflow` over raw `execute_api_call` for better error handling.

3. **Load API spec:** Run `download_api_spec` once per session to enable endpoint search.

4. **Check credentials:** Use `get_credential_schema` to understand required fields before referencing credentials in workflows.

5. **Fast Memory:** Save frequently used API patterns with `save_to_fast_memory` for quicker access via natural language.
