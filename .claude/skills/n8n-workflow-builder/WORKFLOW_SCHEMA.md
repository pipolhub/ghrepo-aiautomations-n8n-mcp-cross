# Workflow JSON Schema

Complete reference for n8n workflow JSON structure.

---

## Root Structure

```json
{
  "name": "string (required)",
  "active": "boolean (default: false)",
  "nodes": "array (required)",
  "connections": "object (required)",
  "settings": "object (optional)",
  "staticData": "object (optional)",
  "tags": "array (optional)",
  "versionId": "string (optional)"
}
```

---

## Nodes Array

Each node in the `nodes` array follows this structure:

```json
{
  "id": "string (UUID format, required)",
  "name": "string (display name, required)",
  "type": "string (node type identifier, required)",
  "typeVersion": "number (schema version, required)",
  "position": "[x, y] array (canvas position, required)",
  "parameters": "object (node-specific config, required)",
  "credentials": "object (credential references, optional)",
  "disabled": "boolean (default: false, optional)",
  "notes": "string (optional)",
  "notesInFlow": "boolean (optional)",
  "webhookId": "string (for webhook nodes, optional)",
  "continueOnFail": "boolean (optional)",
  "onError": "string ('continueRegularOutput' | 'continueErrorOutput' | 'stopWorkflow', optional)",
  "retryOnFail": "boolean (optional)",
  "maxTries": "number (optional)",
  "waitBetweenTries": "number (ms, optional)"
}
```

### Node ID

- Must be UUID format
- Must be unique within workflow
- Example: `"8b0c1e5d-4f2a-4b3c-9d8e-7f6a5b4c3d2e"`

### Node Name

- Display name shown in UI
- Used in connections (case-sensitive!)
- Must be unique within workflow
- Example: `"HTTP Request"`, `"Transform Data"`

### Node Type

Two formats exist:

**Standard nodes:**
```
n8n-nodes-base.nodeType
```
Examples:
- `n8n-nodes-base.httpRequest`
- `n8n-nodes-base.webhook`
- `n8n-nodes-base.set`
- `n8n-nodes-base.if`
- `n8n-nodes-base.code`

**LangChain/AI nodes:**
```
@n8n/n8n-nodes-langchain.nodeType
```
Examples:
- `@n8n/n8n-nodes-langchain.agent`
- `@n8n/n8n-nodes-langchain.lmChatOpenAi`
- `@n8n/n8n-nodes-langchain.toolHttpRequest`

### Type Version

Schema version for the node. Use the latest stable version:

| Node | Current Version |
|------|-----------------|
| httpRequest | 4.2 |
| webhook | 2 |
| set | 3.4 |
| if | 2.2 |
| switch | 3.2 |
| code | 2 |
| scheduleTrigger | 1.2 |
| manualTrigger | 1 |

### Position

Canvas coordinates `[x, y]`:
- X: Horizontal position (left to right)
- Y: Vertical position (top to bottom)
- Recommended spacing: ~200px horizontal, ~150px vertical

```json
"position": [240, 300]
```

### Parameters

Node-specific configuration. Structure varies by node type:

**Set Node:**
```json
"parameters": {
  "mode": "manual",
  "fields": {
    "values": [
      {
        "name": "fieldName",
        "stringValue": "value"
      }
    ]
  }
}
```

**HTTP Request Node:**
```json
"parameters": {
  "method": "GET",
  "url": "https://api.example.com/data",
  "authentication": "none",
  "sendQuery": true,
  "queryParameters": {
    "parameters": [
      {"name": "limit", "value": "100"}
    ]
  }
}
```

### Credentials

Reference to configured credentials:

```json
"credentials": {
  "credentialType": {
    "id": "credential-uuid",
    "name": "Credential Display Name"
  }
}
```

Common credential types:
- `slackOAuth2Api`
- `googleSheetsOAuth2Api`
- `openAiApi`
- `httpHeaderAuth`
- `httpBasicAuth`

**Note:** Credentials must exist in n8n instance before workflow import.

---

## Connections Object

Defines data flow between nodes:

```json
"connections": {
  "Source Node Name": {
    "connectionType": [
      [
        {
          "node": "Target Node Name",
          "type": "connectionType",
          "index": 0
        }
      ]
    ]
  }
}
```

### Connection Types

**Main (standard data flow):**
```json
"main": [
  [{"node": "Target", "type": "main", "index": 0}]
]
```

**AI connections:**
```json
"ai_languageModel": [[{"node": "Agent", "type": "ai_languageModel", "index": 0}]]
"ai_tool": [[{"node": "Agent", "type": "ai_tool", "index": 0}]]
"ai_memory": [[{"node": "Agent", "type": "ai_memory", "index": 0}]]
```

### Multi-Output Nodes

Nodes with multiple outputs use nested arrays:

**IF Node (2 outputs):**
```json
"IF": {
  "main": [
    [{"node": "True Handler", "type": "main", "index": 0}],
    [{"node": "False Handler", "type": "main", "index": 0}]
  ]
}
```

**Switch Node (N outputs):**
```json
"Switch": {
  "main": [
    [{"node": "Case 0 Handler", "type": "main", "index": 0}],
    [{"node": "Case 1 Handler", "type": "main", "index": 0}],
    [{"node": "Default Handler", "type": "main", "index": 0}]
  ]
}
```

### Multiple Targets from Same Output

One output to multiple nodes:

```json
"Trigger": {
  "main": [
    [
      {"node": "Branch A", "type": "main", "index": 0},
      {"node": "Branch B", "type": "main", "index": 0}
    ]
  ]
}
```

---

## Settings Object

Workflow execution settings:

```json
"settings": {
  "executionOrder": "v1",
  "saveManualExecutions": true,
  "callerPolicy": "workflowsFromSameOwner",
  "errorWorkflow": "workflow-id-for-errors",
  "timezone": "America/New_York",
  "executionTimeout": 300
}
```

### Execution Order

- `"v0"` - Legacy top-to-bottom (deprecated)
- `"v1"` - Connection-based (recommended)

Always use `"v1"` for new workflows.

---

## Tags Array

Workflow categorization:

```json
"tags": [
  {
    "id": "tag-uuid",
    "name": "automation"
  }
]
```

Tags must exist in n8n instance before referencing.

---

## Complete Example

```json
{
  "name": "Contact Form Handler",
  "active": false,
  "nodes": [
    {
      "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "name": "Webhook",
      "type": "n8n-nodes-base.webhook",
      "typeVersion": 2,
      "position": [240, 300],
      "parameters": {
        "httpMethod": "POST",
        "path": "contact-form",
        "responseMode": "lastNode",
        "responseData": "allEntries"
      }
    },
    {
      "id": "b2c3d4e5-f6a7-8901-bcde-f23456789012",
      "name": "Validate Input",
      "type": "n8n-nodes-base.if",
      "typeVersion": 2.2,
      "position": [460, 300],
      "parameters": {
        "conditions": {
          "options": {
            "caseSensitive": true,
            "leftValue": "",
            "typeValidation": "strict"
          },
          "conditions": [
            {
              "id": "condition-uuid",
              "leftValue": "={{ $json.body.email }}",
              "rightValue": "",
              "operator": {
                "type": "string",
                "operation": "isNotEmpty"
              }
            }
          ],
          "combinator": "and"
        }
      }
    },
    {
      "id": "c3d4e5f6-a7b8-9012-cdef-345678901234",
      "name": "Send Notification",
      "type": "n8n-nodes-base.slack",
      "typeVersion": 2.3,
      "position": [680, 200],
      "parameters": {
        "resource": "message",
        "operation": "post",
        "channel": "#notifications",
        "text": "=New contact: {{ $json.body.name }} ({{ $json.body.email }})"
      },
      "credentials": {
        "slackOAuth2Api": {
          "id": "slack-cred-id",
          "name": "Slack OAuth2"
        }
      }
    },
    {
      "id": "d4e5f6a7-b8c9-0123-defa-456789012345",
      "name": "Send Error Response",
      "type": "n8n-nodes-base.respondToWebhook",
      "typeVersion": 1.1,
      "position": [680, 400],
      "parameters": {
        "respondWith": "json",
        "responseBody": "={{ {\"error\": \"Email is required\"} }}"
      }
    },
    {
      "id": "e5f6a7b8-c9d0-1234-efab-567890123456",
      "name": "Send Success Response",
      "type": "n8n-nodes-base.respondToWebhook",
      "typeVersion": 1.1,
      "position": [900, 200],
      "parameters": {
        "respondWith": "json",
        "responseBody": "={{ {\"success\": true, \"message\": \"Thank you!\"} }}"
      }
    }
  ],
  "connections": {
    "Webhook": {
      "main": [
        [
          {"node": "Validate Input", "type": "main", "index": 0}
        ]
      ]
    },
    "Validate Input": {
      "main": [
        [
          {"node": "Send Notification", "type": "main", "index": 0}
        ],
        [
          {"node": "Send Error Response", "type": "main", "index": 0}
        ]
      ]
    },
    "Send Notification": {
      "main": [
        [
          {"node": "Send Success Response", "type": "main", "index": 0}
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

---

## Validation Checklist

Before submitting workflow JSON:

- [ ] All nodes have unique `id` (UUID format)
- [ ] All nodes have unique `name`
- [ ] `type` matches valid n8n node type
- [ ] `position` is `[x, y]` array
- [ ] At least one trigger node exists
- [ ] All connection node names match exactly
- [ ] Connection types are valid (`main`, `ai_*`)
- [ ] Settings include `executionOrder: "v1"`
- [ ] Credentials reference existing credentials

---

## Common Errors

**"Node not found in connections"**
- Node name in connection doesn't match node's `name` property
- Check case sensitivity

**"Invalid node type"**
- Node type doesn't exist in n8n instance
- Check spelling and version

**"Workflow has no trigger"**
- Add a trigger node (webhook, schedule, manual, etc.)

**"Circular dependency"**
- Connection creates a loop
- Restructure workflow flow
