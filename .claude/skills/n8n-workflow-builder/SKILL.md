---
name: n8n-workflow-builder
description: Expert guide for building n8n workflows programmatically. Use when creating workflows, updating workflow structure, configuring nodes, writing expressions, understanding workflow JSON schema, or using the n8n API through MCP. Covers workflow architecture, node configuration, connections, and best practices.
---

# n8n Workflow Builder

Master guide for building n8n workflows using the n8n API via MCP.

---

## Quick Reference

### MCP Tools Available (N8N-api-MCP)

| Tool | Purpose | Use When |
|------|---------|----------|
| `search_api_endpoints` | Find API endpoints | Discovering available operations |
| `get_api_endpoint_details` | Get endpoint specs | Understanding request/response format |
| `execute_api_call` | Call n8n API | Creating/updating workflows |
| `natural_language_api_search` | NL search | Don't know exact endpoint |
| `save_to_fast_memory` | Cache queries | Reusing common API patterns |
| `list_fast_memory` | View cached queries | Finding saved patterns |
| `send_raw_api_request` | Raw API calls | Quick API testing |

### Key API Endpoints for Workflow Building

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/workflows` | GET | List all workflows |
| `/workflows` | POST | Create new workflow |
| `/workflows/{id}` | GET | Get workflow details |
| `/workflows/{id}` | PUT | Update entire workflow |
| `/workflows/{id}` | PATCH | Partial workflow update |
| `/workflows/{id}` | DELETE | Delete workflow |
| `/credentials` | GET | List credentials |
| `/tags` | GET | List tags |

---

## Workflow JSON Structure

Every n8n workflow consists of these core components:

```json
{
  "name": "My Workflow",
  "active": false,
  "nodes": [...],
  "connections": {...},
  "settings": {...},
  "tags": []
}
```

### Detailed Structure

```json
{
  "name": "Example Workflow",
  "active": false,
  "nodes": [
    {
      "id": "uuid-format-id",
      "name": "Node Display Name",
      "type": "n8n-nodes-base.nodeType",
      "typeVersion": 1,
      "position": [250, 300],
      "parameters": {
        // Node-specific configuration
      },
      "credentials": {
        "credentialType": {
          "id": "credential-id",
          "name": "Credential Name"
        }
      }
    }
  ],
  "connections": {
    "Source Node Name": {
      "main": [
        [
          {
            "node": "Target Node Name",
            "type": "main",
            "index": 0
          }
        ]
      ]
    }
  },
  "settings": {
    "executionOrder": "v1"
  },
  "tags": []
}
```

See: [WORKFLOW_SCHEMA.md](WORKFLOW_SCHEMA.md) for complete schema reference

---

## Creating a Workflow via MCP

### Step 1: Search for Endpoint

```javascript
// Using natural language search
natural_language_api_search({
  query: "create new workflow"
})

// Or direct search
search_api_endpoints({
  query: "workflows POST"
})
```

### Step 2: Get Endpoint Details

```javascript
get_api_endpoint_details({
  path: "/workflows",
  method: "POST"
})
```

### Step 3: Execute the API Call

```javascript
execute_api_call({
  path: "/workflows",
  method: "POST",
  data: {
    "name": "My New Workflow",
    "nodes": [
      {
        "id": "start-node-uuid",
        "name": "When clicking Test workflow",
        "type": "n8n-nodes-base.manualTrigger",
        "typeVersion": 1,
        "position": [240, 300],
        "parameters": {}
      },
      {
        "id": "set-node-uuid",
        "name": "Set Data",
        "type": "n8n-nodes-base.set",
        "typeVersion": 3.4,
        "position": [460, 300],
        "parameters": {
          "mode": "manual",
          "fields": {
            "values": [
              {
                "name": "message",
                "stringValue": "Hello from API!"
              }
            ]
          }
        }
      }
    ],
    "connections": {
      "When clicking Test workflow": {
        "main": [
          [
            {
              "node": "Set Data",
              "type": "main",
              "index": 0
            }
          ]
        ]
      }
    },
    "settings": {
      "executionOrder": "v1"
    }
  }
})
```

### Step 4: Save Pattern to Fast Memory

```javascript
save_to_fast_memory({
  natural_language_query: "create a basic workflow with manual trigger",
  api_path: "/workflows",
  api_method: "POST",
  api_data: { /* your workflow JSON */ },
  description: "Creates workflow with manual trigger and set node"
})
```

---

## Node Configuration Patterns

### Trigger Nodes (Must have one!)

Every workflow needs at least one trigger node. Common types:

**Manual Trigger** (for testing):
```json
{
  "id": "manual-trigger-uuid",
  "name": "When clicking Test workflow",
  "type": "n8n-nodes-base.manualTrigger",
  "typeVersion": 1,
  "position": [240, 300],
  "parameters": {}
}
```

**Webhook Trigger** (receive HTTP requests):
```json
{
  "id": "webhook-uuid",
  "name": "Webhook",
  "type": "n8n-nodes-base.webhook",
  "typeVersion": 2,
  "position": [240, 300],
  "parameters": {
    "httpMethod": "POST",
    "path": "my-webhook-path",
    "responseMode": "onReceived",
    "responseData": "allEntries"
  }
}
```

**Schedule Trigger** (cron/interval):
```json
{
  "id": "schedule-uuid",
  "name": "Schedule Trigger",
  "type": "n8n-nodes-base.scheduleTrigger",
  "typeVersion": 1.2,
  "position": [240, 300],
  "parameters": {
    "rule": {
      "interval": [
        {
          "field": "hours",
          "hoursInterval": 1
        }
      ]
    }
  }
}
```

See: [NODE_TYPES.md](NODE_TYPES.md) for complete node catalog

---

## Connection Types

### Main Connections (Standard Data Flow)

```json
"connections": {
  "Source Node": {
    "main": [
      [
        {"node": "Target Node", "type": "main", "index": 0}
      ]
    ]
  }
}
```

### Multi-Output Nodes (IF, Switch)

```json
"connections": {
  "IF": {
    "main": [
      [{"node": "True Branch Handler", "type": "main", "index": 0}],
      [{"node": "False Branch Handler", "type": "main", "index": 0}]
    ]
  }
}
```

**Output indices:**
- IF node: `0` = true branch, `1` = false branch
- Switch node: indices correspond to case numbers

### AI Connections (LangChain Nodes)

| Connection Type | Purpose | Example |
|-----------------|---------|---------|
| `ai_languageModel` | Connect LLM to agent | OpenAI → Agent |
| `ai_memory` | Connect memory to agent | Buffer Memory → Agent |
| `ai_tool` | Connect tools to agent | HTTP Tool → Agent |
| `ai_outputParser` | Connect parser | Structured Parser → Chain |
| `ai_retriever` | Connect retriever | Vector Store → Chain |
| `ai_document` | Connect documents | Document Loader → Splitter |
| `ai_embedding` | Connect embeddings | OpenAI Embeddings → Vector Store |
| `ai_vectorStore` | Connect vector store | Pinecone → Retriever |

---

## Expression Syntax

### In Workflow JSON (Parameter Values)

Use `=` prefix for expressions:

```json
{
  "parameters": {
    "text": "={{$json.body.message}}",
    "email": "={{$json.body.email}}",
    "timestamp": "={{$now.toFormat('yyyy-MM-dd')}}"
  }
}
```

### Common Expression Patterns

| Expression | Purpose | Example Output |
|------------|---------|----------------|
| `={{$json.field}}` | Current node data | Value of field |
| `={{$json.body.field}}` | Webhook body data | POST body field |
| `={{$node["Node Name"].json.field}}` | Other node data | Referenced value |
| `={{$now}}` | Current timestamp | ISO datetime |
| `={{$now.toFormat('yyyy-MM-dd')}}` | Formatted date | 2025-10-20 |
| `={{$env.VAR_NAME}}` | Environment variable | Variable value |

### Critical: Webhook Data Structure

Webhook data is nested under `.body`:

```javascript
// WRONG
{{$json.email}}

// CORRECT
{{$json.body.email}}
```

See: [EXPRESSION_SYNTAX.md](EXPRESSION_SYNTAX.md) for complete guide

---

## Updating Workflows

### Full Update (PUT)

Replaces entire workflow:

```javascript
execute_api_call({
  path: "/workflows/workflow-id",
  method: "PUT",
  data: {
    // Complete workflow JSON
    "name": "Updated Workflow",
    "nodes": [...],
    "connections": {...},
    "settings": {...}
  }
})
```

### Partial Update (PATCH)

Updates specific fields only:

```javascript
execute_api_call({
  path: "/workflows/workflow-id",
  method: "PATCH",
  data: {
    "name": "Renamed Workflow"
  }
})
```

**Note:** When updating an active workflow via PUT, n8n automatically reactivates it with the new definition.

---

## Best Practices

### Workflow Architecture

1. **Keep workflows focused** - 5-10 nodes per workflow
2. **Use sub-workflows** - Break complex logic into reusable workflows
3. **Modular design** - Each workflow handles a single responsibility
4. **Clear naming** - Use descriptive node names

### Node Configuration

1. **Start minimal** - Add only required fields first
2. **Validate incrementally** - Test after adding each node
3. **Use credentials properly** - Reference credentials by type, not inline
4. **Handle errors** - Add error handling nodes

### Connections

1. **Check output indices** - IF/Switch have multiple outputs
2. **Verify node names** - Connections use exact node names (case-sensitive)
3. **Test connections** - Ensure data flows correctly

### Expressions

1. **Always use `={{}}`** in JSON parameters
2. **Webhook data** is under `.body`
3. **Quote node names** with spaces: `$node["Node Name"]`
4. **No expressions in Code nodes** - Use direct JavaScript

---

## Common Workflow Patterns

### Pattern 1: Webhook → Process → Respond

```json
{
  "nodes": [
    {"type": "n8n-nodes-base.webhook", "name": "Webhook"},
    {"type": "n8n-nodes-base.set", "name": "Process Data"},
    {"type": "n8n-nodes-base.respondToWebhook", "name": "Respond"}
  ],
  "connections": {
    "Webhook": {"main": [[{"node": "Process Data"}]]},
    "Process Data": {"main": [[{"node": "Respond"}]]}
  }
}
```

### Pattern 2: Schedule → Fetch → Transform → Store

```json
{
  "nodes": [
    {"type": "n8n-nodes-base.scheduleTrigger", "name": "Schedule"},
    {"type": "n8n-nodes-base.httpRequest", "name": "Fetch Data"},
    {"type": "n8n-nodes-base.set", "name": "Transform"},
    {"type": "n8n-nodes-base.googleSheets", "name": "Store"}
  ],
  "connections": {
    "Schedule": {"main": [[{"node": "Fetch Data"}]]},
    "Fetch Data": {"main": [[{"node": "Transform"}]]},
    "Transform": {"main": [[{"node": "Store"}]]}
  }
}
```

### Pattern 3: AI Agent with Tools

```json
{
  "nodes": [
    {"type": "n8n-nodes-base.webhook", "name": "Chat Input"},
    {"type": "@n8n/n8n-nodes-langchain.agent", "name": "AI Agent"},
    {"type": "@n8n/n8n-nodes-langchain.lmChatOpenAi", "name": "OpenAI"},
    {"type": "@n8n/n8n-nodes-langchain.toolHttpRequest", "name": "HTTP Tool"},
    {"type": "n8n-nodes-base.respondToWebhook", "name": "Response"}
  ],
  "connections": {
    "Chat Input": {"main": [[{"node": "AI Agent"}]]},
    "AI Agent": {"main": [[{"node": "Response"}]]},
    "OpenAI": {"ai_languageModel": [[{"node": "AI Agent"}]]},
    "HTTP Tool": {"ai_tool": [[{"node": "AI Agent"}]]}
  }
}
```

See: [WORKFLOW_PATTERNS.md](WORKFLOW_PATTERNS.md) for more patterns

---

## MCP Limitations & Workarounds

The N8N-api-MCP provides basic API access. Some features require direct API calls or UI:

**See:** [MCP_GAPS.md](MCP_GAPS.md) for complete analysis of:
- API features not fully supported by MCP
- Recommended additions for MCP fork
- Workarounds using raw API calls

---

## Detailed Guides

| Guide | Purpose |
|-------|---------|
| [WORKFLOW_SCHEMA.md](WORKFLOW_SCHEMA.md) | Complete workflow JSON schema |
| [NODE_TYPES.md](NODE_TYPES.md) | Node type catalog and configuration |
| [EXPRESSION_SYNTAX.md](EXPRESSION_SYNTAX.md) | Expression writing guide |
| [WORKFLOW_PATTERNS.md](WORKFLOW_PATTERNS.md) | Common architectural patterns |
| [CODE_NODES.md](CODE_NODES.md) | JavaScript/Python code nodes |
| [MCP_GAPS.md](MCP_GAPS.md) | MCP limitations and recommendations |
| [API_REFERENCE.md](API_REFERENCE.md) | n8n API endpoint reference |

---

## Summary

**Building Workflows via MCP:**
1. Search endpoints with `search_api_endpoints` or `natural_language_api_search`
2. Get details with `get_api_endpoint_details`
3. Execute with `execute_api_call`
4. Cache patterns with `save_to_fast_memory`

**Workflow Structure:**
- `nodes[]` - Array of node configurations
- `connections{}` - Data flow between nodes
- `settings{}` - Workflow execution settings
- At least one trigger node required

**Key Rules:**
- Node type format: `n8n-nodes-base.nodeType`
- Expressions use `={{}}` syntax
- Webhook data under `.body`
- Connections use exact node names

**Best Practices:**
- Keep workflows focused (5-10 nodes)
- Use modular sub-workflows
- Validate incrementally
- Handle errors properly

---

## Sources

- [n8n Public REST API](https://docs.n8n.io/api/)
- [n8n API Reference](https://docs.n8n.io/api/api-reference/)
- [n8n Node Types](https://docs.n8n.io/integrations/builtin/node-types/)
- [n8n Core Nodes](https://docs.n8n.io/integrations/builtin/core-nodes/)
- [n8n Best Practices](https://blog.n8n.io/ai-workflow-builder-best-practices/)
- [n8n Workflow JSON Guide](https://latenode.com/blog/low-code-no-code-platforms/n8n-setup-workflows-self-hosting-templates/n8n-import-workflow-json-complete-guide-file-format-examples-2025)
