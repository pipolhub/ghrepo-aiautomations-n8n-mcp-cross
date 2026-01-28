# Node Types Reference

Catalog of common n8n node types for workflow building.

---

## Node Type Format

**Standard nodes:**
```
n8n-nodes-base.<nodeName>
```

**LangChain/AI nodes:**
```
@n8n/n8n-nodes-langchain.<nodeName>
```

---

## Trigger Nodes

Every workflow must have at least one trigger.

### Manual Trigger
**Type:** `n8n-nodes-base.manualTrigger`
**Version:** 1
**Purpose:** Test workflows manually

```json
{
  "type": "n8n-nodes-base.manualTrigger",
  "typeVersion": 1,
  "parameters": {}
}
```

### Webhook Trigger
**Type:** `n8n-nodes-base.webhook`
**Version:** 2
**Purpose:** Receive HTTP requests

```json
{
  "type": "n8n-nodes-base.webhook",
  "typeVersion": 2,
  "parameters": {
    "httpMethod": "POST",
    "path": "my-webhook",
    "responseMode": "onReceived",
    "responseData": "allEntries"
  }
}
```

**Response Modes:**
- `onReceived` - Respond immediately
- `lastNode` - Wait for workflow completion
- `responseNode` - Use Respond to Webhook node

### Schedule Trigger
**Type:** `n8n-nodes-base.scheduleTrigger`
**Version:** 1.2
**Purpose:** Run on schedule (cron)

```json
{
  "type": "n8n-nodes-base.scheduleTrigger",
  "typeVersion": 1.2,
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

**Interval Options:**
- `seconds`, `minutes`, `hours`, `days`, `weeks`, `months`
- Or use `cronExpression` for complex schedules

### n8n Trigger
**Type:** `n8n-nodes-base.n8nTrigger`
**Version:** 1
**Purpose:** React to n8n events

```json
{
  "type": "n8n-nodes-base.n8nTrigger",
  "typeVersion": 1,
  "parameters": {
    "events": ["workflow:activated", "workflow:updated"]
  }
}
```

---

## Data Transformation Nodes

### Set Node
**Type:** `n8n-nodes-base.set`
**Version:** 3.4
**Purpose:** Set/transform field values

```json
{
  "type": "n8n-nodes-base.set",
  "typeVersion": 3.4,
  "parameters": {
    "mode": "manual",
    "fields": {
      "values": [
        {
          "name": "outputField",
          "stringValue": "={{ $json.body.inputField }}"
        }
      ]
    },
    "include": "none"
  }
}
```

**Modes:**
- `manual` - Define fields manually
- `raw` - JSON mode

**Include options:**
- `none` - Only set fields
- `selected` - Include selected input fields
- `all` - Include all input fields
- `except` - Include all except selected

### Code Node
**Type:** `n8n-nodes-base.code`
**Version:** 2
**Purpose:** Custom JavaScript/Python logic

```json
{
  "type": "n8n-nodes-base.code",
  "typeVersion": 2,
  "parameters": {
    "mode": "runOnceForAllItems",
    "language": "javaScript",
    "jsCode": "const items = $input.all();\n\nreturn items.map(item => ({\n  json: {\n    ...item.json,\n    processed: true\n  }\n}));"
  }
}
```

**Modes:**
- `runOnceForAllItems` - Process all items once (recommended)
- `runOnceForEachItem` - Process each item separately

### Merge Node
**Type:** `n8n-nodes-base.merge`
**Version:** 3
**Purpose:** Combine data from multiple branches

```json
{
  "type": "n8n-nodes-base.merge",
  "typeVersion": 3,
  "parameters": {
    "mode": "combine",
    "combineBy": "combineByPosition",
    "options": {}
  }
}
```

**Modes:**
- `append` - Add items from input 2 after input 1
- `combine` - Merge matching items
- `chooseBranch` - Select which branch to output

### Split In Batches
**Type:** `n8n-nodes-base.splitInBatches`
**Version:** 3
**Purpose:** Process items in batches

```json
{
  "type": "n8n-nodes-base.splitInBatches",
  "typeVersion": 3,
  "parameters": {
    "batchSize": 100,
    "options": {}
  }
}
```

---

## Conditional Logic Nodes

### IF Node
**Type:** `n8n-nodes-base.if`
**Version:** 2.2
**Purpose:** Branch based on conditions

```json
{
  "type": "n8n-nodes-base.if",
  "typeVersion": 2.2,
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
          "leftValue": "={{ $json.status }}",
          "rightValue": "active",
          "operator": {
            "type": "string",
            "operation": "equals"
          }
        }
      ],
      "combinator": "and"
    }
  }
}
```

**Operators:**
- String: `equals`, `notEquals`, `contains`, `notContains`, `startsWith`, `endsWith`, `isEmpty`, `isNotEmpty`, `regex`
- Number: `equals`, `notEquals`, `gt`, `gte`, `lt`, `lte`
- Boolean: `true`, `false`

**Outputs:**
- Index 0: True branch
- Index 1: False branch

### Switch Node
**Type:** `n8n-nodes-base.switch`
**Version:** 3.2
**Purpose:** Route to multiple outputs

```json
{
  "type": "n8n-nodes-base.switch",
  "typeVersion": 3.2,
  "parameters": {
    "rules": {
      "values": [
        {
          "outputKey": "case1",
          "conditions": {
            "conditions": [
              {
                "leftValue": "={{ $json.type }}",
                "rightValue": "order",
                "operator": {"type": "string", "operation": "equals"}
              }
            ]
          }
        },
        {
          "outputKey": "case2",
          "conditions": {
            "conditions": [
              {
                "leftValue": "={{ $json.type }}",
                "rightValue": "refund",
                "operator": {"type": "string", "operation": "equals"}
              }
            ]
          }
        }
      ]
    },
    "options": {
      "fallbackOutput": "extra"
    }
  }
}
```

---

## HTTP Nodes

### HTTP Request
**Type:** `n8n-nodes-base.httpRequest`
**Version:** 4.2
**Purpose:** Make HTTP requests

```json
{
  "type": "n8n-nodes-base.httpRequest",
  "typeVersion": 4.2,
  "parameters": {
    "method": "POST",
    "url": "https://api.example.com/endpoint",
    "authentication": "predefinedCredentialType",
    "nodeCredentialType": "httpHeaderAuth",
    "sendBody": true,
    "bodyParameters": {
      "parameters": [
        {"name": "key", "value": "={{ $json.value }}"}
      ]
    },
    "options": {
      "response": {
        "response": {
          "responseFormat": "json"
        }
      }
    }
  }
}
```

**Authentication Options:**
- `none`
- `predefinedCredentialType` - Use n8n credentials
- `genericCredentialType` - Custom auth

### Respond to Webhook
**Type:** `n8n-nodes-base.respondToWebhook`
**Version:** 1.1
**Purpose:** Send webhook response

```json
{
  "type": "n8n-nodes-base.respondToWebhook",
  "typeVersion": 1.1,
  "parameters": {
    "respondWith": "json",
    "responseBody": "={{ {\"success\": true, \"data\": $json} }}"
  }
}
```

---

## Database Nodes

### Postgres
**Type:** `n8n-nodes-base.postgres`
**Version:** 2.5
**Purpose:** PostgreSQL operations

```json
{
  "type": "n8n-nodes-base.postgres",
  "typeVersion": 2.5,
  "parameters": {
    "operation": "executeQuery",
    "query": "SELECT * FROM users WHERE status = $1",
    "options": {
      "queryParams": "={{ [$json.status] }}"
    }
  }
}
```

**Operations:**
- `executeQuery` - Run custom SQL
- `insert` - Insert rows
- `update` - Update rows
- `upsert` - Insert or update
- `deleteTable` - Delete rows

### MySQL
**Type:** `n8n-nodes-base.mySql`
**Version:** 2.4

### MongoDB
**Type:** `n8n-nodes-base.mongoDb`
**Version:** 1.2

---

## Communication Nodes

### Slack
**Type:** `n8n-nodes-base.slack`
**Version:** 2.3
**Purpose:** Slack messaging

```json
{
  "type": "n8n-nodes-base.slack",
  "typeVersion": 2.3,
  "parameters": {
    "resource": "message",
    "operation": "post",
    "channel": "#general",
    "text": "={{ $json.message }}"
  }
}
```

### Gmail
**Type:** `n8n-nodes-base.gmail`
**Version:** 2.1
**Purpose:** Send/manage emails

```json
{
  "type": "n8n-nodes-base.gmail",
  "typeVersion": 2.1,
  "parameters": {
    "resource": "message",
    "operation": "send",
    "sendTo": "={{ $json.email }}",
    "subject": "Notification",
    "message": "={{ $json.body }}"
  }
}
```

---

## Google Nodes

### Google Sheets
**Type:** `n8n-nodes-base.googleSheets`
**Version:** 4.5
**Purpose:** Read/write spreadsheets

```json
{
  "type": "n8n-nodes-base.googleSheets",
  "typeVersion": 4.5,
  "parameters": {
    "operation": "append",
    "documentId": {"mode": "id", "value": "spreadsheet-id"},
    "sheetName": {"mode": "name", "value": "Sheet1"},
    "columns": {
      "mappingMode": "autoMapInputData",
      "value": {}
    }
  }
}
```

### Google Drive
**Type:** `n8n-nodes-base.googleDrive`
**Version:** 3

### Google BigQuery
**Type:** `n8n-nodes-base.googleBigQuery`
**Version:** 2

---

## AI/LangChain Nodes

### AI Agent
**Type:** `@n8n/n8n-nodes-langchain.agent`
**Version:** 1.7
**Purpose:** Conversational AI agent

```json
{
  "type": "@n8n/n8n-nodes-langchain.agent",
  "typeVersion": 1.7,
  "parameters": {
    "promptType": "define",
    "text": "={{ $json.body.message }}",
    "options": {
      "systemMessage": "You are a helpful assistant."
    }
  }
}
```

**Required connections:**
- `ai_languageModel` - LLM connection

**Optional connections:**
- `ai_tool` - Tool connections
- `ai_memory` - Memory connection

### OpenAI Chat Model
**Type:** `@n8n/n8n-nodes-langchain.lmChatOpenAi`
**Version:** 1.2

```json
{
  "type": "@n8n/n8n-nodes-langchain.lmChatOpenAi",
  "typeVersion": 1.2,
  "parameters": {
    "model": "gpt-4",
    "options": {
      "temperature": 0.7
    }
  }
}
```

### HTTP Request Tool
**Type:** `@n8n/n8n-nodes-langchain.toolHttpRequest`
**Version:** 1.1

```json
{
  "type": "@n8n/n8n-nodes-langchain.toolHttpRequest",
  "typeVersion": 1.1,
  "parameters": {
    "name": "search_api",
    "description": "Search for information",
    "method": "GET",
    "url": "https://api.example.com/search",
    "sendQuery": true,
    "parametersQuery": {
      "values": [
        {"name": "q", "valueProvider": "modelRequired"}
      ]
    }
  }
}
```

### Window Buffer Memory
**Type:** `@n8n/n8n-nodes-langchain.memoryBufferWindow`
**Version:** 1.3

```json
{
  "type": "@n8n/n8n-nodes-langchain.memoryBufferWindow",
  "typeVersion": 1.3,
  "parameters": {
    "sessionIdType": "fromInput",
    "sessionKey": "={{ $json.sessionId }}",
    "contextWindowLength": 10
  }
}
```

---

## Error Handling Nodes

### Error Trigger
**Type:** `n8n-nodes-base.errorTrigger`
**Version:** 1
**Purpose:** Catch workflow errors

```json
{
  "type": "n8n-nodes-base.errorTrigger",
  "typeVersion": 1,
  "parameters": {}
}
```

### Stop and Error
**Type:** `n8n-nodes-base.stopAndError`
**Version:** 1
**Purpose:** Stop workflow with error

```json
{
  "type": "n8n-nodes-base.stopAndError",
  "typeVersion": 1,
  "parameters": {
    "errorMessage": "Validation failed: missing required field"
  }
}
```

---

## Utility Nodes

### No Operation (NoOp)
**Type:** `n8n-nodes-base.noOp`
**Version:** 1
**Purpose:** Pass through data unchanged

### Wait
**Type:** `n8n-nodes-base.wait`
**Version:** 1.1
**Purpose:** Pause execution

```json
{
  "type": "n8n-nodes-base.wait",
  "typeVersion": 1.1,
  "parameters": {
    "amount": 5,
    "unit": "seconds"
  }
}
```

### Execute Workflow
**Type:** `n8n-nodes-base.executeWorkflow`
**Version:** 1.2
**Purpose:** Call another workflow

```json
{
  "type": "n8n-nodes-base.executeWorkflow",
  "typeVersion": 1.2,
  "parameters": {
    "source": "database",
    "workflowId": "workflow-id-to-call",
    "options": {}
  }
}
```

---

## Finding Node Types

### Using MCP

```javascript
// Search for nodes
search_api_endpoints({
  query: "node types"
})

// Get available integrations
execute_api_call({
  path: "/workflows",
  method: "GET"
})
// Examine existing workflows for node types
```

### From n8n Documentation

- Core Nodes: https://docs.n8n.io/integrations/builtin/core-nodes/
- Trigger Nodes: https://docs.n8n.io/integrations/builtin/trigger-nodes/
- All Integrations: https://docs.n8n.io/integrations/

---

## Version Compatibility

When creating workflows:
1. Check your n8n instance version
2. Use compatible node versions
3. New workflows from v1.0+ may not work in older instances

**Note:** The MCP cannot directly query available node types. Use the n8n UI or API to discover available nodes in your instance.
