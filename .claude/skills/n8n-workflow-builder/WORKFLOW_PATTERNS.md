# Workflow Patterns

Common architectural patterns for building n8n workflows.

---

## Pattern Selection Guide

| Pattern | Use When |
|---------|----------|
| Webhook → Process → Respond | Receiving data from external systems |
| Schedule → Fetch → Transform → Store | Periodic data collection |
| AI Agent with Tools | Conversational AI, multi-step reasoning |
| Database Sync | ETL, data synchronization |
| Error Handler | Need separate error handling flow |
| Branching Logic | Different processing based on conditions |
| Parallel Processing | Independent operations, aggregation |
| Batch Processing | Large datasets, rate limiting |
| Loop with Static Data Collector | Process items in isolation, collect results for batch continuation |

---

## Pattern 1: Webhook → Process → Respond

**Use case:** API endpoints, form submissions, webhooks from external services

### Basic Structure

```json
{
  "name": "Webhook Handler",
  "nodes": [
    {
      "id": "webhook-uuid",
      "name": "Webhook",
      "type": "n8n-nodes-base.webhook",
      "typeVersion": 2,
      "position": [240, 300],
      "parameters": {
        "httpMethod": "POST",
        "path": "my-endpoint",
        "responseMode": "lastNode",
        "responseData": "allEntries"
      }
    },
    {
      "id": "process-uuid",
      "name": "Process Data",
      "type": "n8n-nodes-base.set",
      "typeVersion": 3.4,
      "position": [460, 300],
      "parameters": {
        "mode": "manual",
        "fields": {
          "values": [
            {
              "name": "processed",
              "stringValue": "={{ $json.body.message }}"
            }
          ]
        }
      }
    },
    {
      "id": "respond-uuid",
      "name": "Respond",
      "type": "n8n-nodes-base.respondToWebhook",
      "typeVersion": 1.1,
      "position": [680, 300],
      "parameters": {
        "respondWith": "json",
        "responseBody": "={{ {\"success\": true, \"data\": $json} }}"
      }
    }
  ],
  "connections": {
    "Webhook": {
      "main": [[{"node": "Process Data", "type": "main", "index": 0}]]
    },
    "Process Data": {
      "main": [[{"node": "Respond", "type": "main", "index": 0}]]
    }
  },
  "settings": {"executionOrder": "v1"}
}
```

### With Validation

Add IF node for input validation:

```json
{
  "nodes": [
    {"name": "Webhook", "type": "n8n-nodes-base.webhook"},
    {"name": "Validate", "type": "n8n-nodes-base.if"},
    {"name": "Process", "type": "n8n-nodes-base.set"},
    {"name": "Success Response", "type": "n8n-nodes-base.respondToWebhook"},
    {"name": "Error Response", "type": "n8n-nodes-base.respondToWebhook"}
  ],
  "connections": {
    "Webhook": {"main": [[{"node": "Validate"}]]},
    "Validate": {
      "main": [
        [{"node": "Process"}],
        [{"node": "Error Response"}]
      ]
    },
    "Process": {"main": [[{"node": "Success Response"}]]}
  }
}
```

---

## Pattern 2: Schedule → Fetch → Transform → Store

**Use case:** Periodic data collection, reports, synchronization

### Basic Structure

```json
{
  "name": "Scheduled Data Collector",
  "nodes": [
    {
      "id": "schedule-uuid",
      "name": "Schedule",
      "type": "n8n-nodes-base.scheduleTrigger",
      "typeVersion": 1.2,
      "position": [240, 300],
      "parameters": {
        "rule": {
          "interval": [{"field": "hours", "hoursInterval": 1}]
        }
      }
    },
    {
      "id": "fetch-uuid",
      "name": "Fetch Data",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [460, 300],
      "parameters": {
        "method": "GET",
        "url": "https://api.example.com/data",
        "authentication": "predefinedCredentialType",
        "nodeCredentialType": "httpHeaderAuth"
      }
    },
    {
      "id": "transform-uuid",
      "name": "Transform",
      "type": "n8n-nodes-base.set",
      "typeVersion": 3.4,
      "position": [680, 300],
      "parameters": {
        "mode": "manual",
        "fields": {
          "values": [
            {"name": "timestamp", "stringValue": "={{ $now.toISO() }}"},
            {"name": "data", "stringValue": "={{ $json.results }}"}
          ]
        }
      }
    },
    {
      "id": "store-uuid",
      "name": "Store",
      "type": "n8n-nodes-base.googleSheets",
      "typeVersion": 4.5,
      "position": [900, 300],
      "parameters": {
        "operation": "append",
        "documentId": {"mode": "id", "value": "sheet-id"},
        "sheetName": {"mode": "name", "value": "Data"}
      }
    }
  ],
  "connections": {
    "Schedule": {"main": [[{"node": "Fetch Data"}]]},
    "Fetch Data": {"main": [[{"node": "Transform"}]]},
    "Transform": {"main": [[{"node": "Store"}]]}
  },
  "settings": {"executionOrder": "v1"}
}
```

### With Error Handling

```json
{
  "nodes": [
    {"name": "Schedule", "type": "n8n-nodes-base.scheduleTrigger"},
    {"name": "Fetch Data", "type": "n8n-nodes-base.httpRequest"},
    {"name": "Transform", "type": "n8n-nodes-base.set"},
    {"name": "Store", "type": "n8n-nodes-base.googleSheets"},
    {"name": "Error Trigger", "type": "n8n-nodes-base.errorTrigger"},
    {"name": "Send Error Alert", "type": "n8n-nodes-base.slack"}
  ],
  "connections": {
    "Schedule": {"main": [[{"node": "Fetch Data"}]]},
    "Fetch Data": {"main": [[{"node": "Transform"}]]},
    "Transform": {"main": [[{"node": "Store"}]]},
    "Error Trigger": {"main": [[{"node": "Send Error Alert"}]]}
  }
}
```

---

## Pattern 3: AI Agent with Tools

**Use case:** Chatbots, intelligent assistants, RAG systems

### Basic Agent

```json
{
  "name": "AI Assistant",
  "nodes": [
    {
      "id": "input-uuid",
      "name": "Chat Input",
      "type": "n8n-nodes-base.webhook",
      "typeVersion": 2,
      "position": [240, 300],
      "parameters": {
        "httpMethod": "POST",
        "path": "chat",
        "responseMode": "lastNode"
      }
    },
    {
      "id": "agent-uuid",
      "name": "AI Agent",
      "type": "@n8n/n8n-nodes-langchain.agent",
      "typeVersion": 1.7,
      "position": [460, 300],
      "parameters": {
        "promptType": "define",
        "text": "={{ $json.body.message }}",
        "options": {
          "systemMessage": "You are a helpful assistant."
        }
      }
    },
    {
      "id": "llm-uuid",
      "name": "OpenAI",
      "type": "@n8n/n8n-nodes-langchain.lmChatOpenAi",
      "typeVersion": 1.2,
      "position": [460, 100],
      "parameters": {
        "model": "gpt-4",
        "options": {"temperature": 0.7}
      }
    },
    {
      "id": "response-uuid",
      "name": "Response",
      "type": "n8n-nodes-base.respondToWebhook",
      "typeVersion": 1.1,
      "position": [680, 300],
      "parameters": {
        "respondWith": "json",
        "responseBody": "={{ {\"response\": $json.output} }}"
      }
    }
  ],
  "connections": {
    "Chat Input": {
      "main": [[{"node": "AI Agent", "type": "main", "index": 0}]]
    },
    "OpenAI": {
      "ai_languageModel": [[{"node": "AI Agent", "type": "ai_languageModel", "index": 0}]]
    },
    "AI Agent": {
      "main": [[{"node": "Response", "type": "main", "index": 0}]]
    }
  },
  "settings": {"executionOrder": "v1"}
}
```

### Agent with Tools

Add HTTP tool and memory:

```json
{
  "nodes": [
    {"name": "Chat Input", "type": "n8n-nodes-base.webhook"},
    {"name": "AI Agent", "type": "@n8n/n8n-nodes-langchain.agent"},
    {"name": "OpenAI", "type": "@n8n/n8n-nodes-langchain.lmChatOpenAi"},
    {"name": "Search Tool", "type": "@n8n/n8n-nodes-langchain.toolHttpRequest"},
    {"name": "Memory", "type": "@n8n/n8n-nodes-langchain.memoryBufferWindow"},
    {"name": "Response", "type": "n8n-nodes-base.respondToWebhook"}
  ],
  "connections": {
    "Chat Input": {"main": [[{"node": "AI Agent"}]]},
    "OpenAI": {"ai_languageModel": [[{"node": "AI Agent"}]]},
    "Search Tool": {"ai_tool": [[{"node": "AI Agent"}]]},
    "Memory": {"ai_memory": [[{"node": "AI Agent"}]]},
    "AI Agent": {"main": [[{"node": "Response"}]]}
  }
}
```

---

## Pattern 4: Database Sync

**Use case:** ETL, data migration, synchronization

### Basic Sync

```json
{
  "name": "Database Sync",
  "nodes": [
    {
      "name": "Schedule",
      "type": "n8n-nodes-base.scheduleTrigger",
      "parameters": {
        "rule": {"interval": [{"field": "minutes", "minutesInterval": 15}]}
      }
    },
    {
      "name": "Read Source",
      "type": "n8n-nodes-base.postgres",
      "parameters": {
        "operation": "executeQuery",
        "query": "SELECT * FROM users WHERE updated_at > $1",
        "options": {"queryParams": "={{ [$json.lastSync] }}"}
      }
    },
    {
      "name": "Check Records",
      "type": "n8n-nodes-base.if",
      "parameters": {
        "conditions": {
          "conditions": [{
            "leftValue": "={{ $json.length }}",
            "rightValue": "0",
            "operator": {"type": "number", "operation": "gt"}
          }]
        }
      }
    },
    {
      "name": "Write Target",
      "type": "n8n-nodes-base.mySql",
      "parameters": {
        "operation": "upsert",
        "table": "users"
      }
    },
    {
      "name": "Update Sync Time",
      "type": "n8n-nodes-base.postgres",
      "parameters": {
        "operation": "executeQuery",
        "query": "UPDATE sync_state SET last_sync = NOW()"
      }
    }
  ],
  "connections": {
    "Schedule": {"main": [[{"node": "Read Source"}]]},
    "Read Source": {"main": [[{"node": "Check Records"}]]},
    "Check Records": {
      "main": [
        [{"node": "Write Target"}],
        []
      ]
    },
    "Write Target": {"main": [[{"node": "Update Sync Time"}]]}
  }
}
```

---

## Pattern 5: Branching Logic

**Use case:** Different processing based on conditions

### IF Branch

```json
{
  "nodes": [
    {"name": "Trigger", "type": "n8n-nodes-base.webhook"},
    {
      "name": "Check Type",
      "type": "n8n-nodes-base.if",
      "parameters": {
        "conditions": {
          "conditions": [{
            "leftValue": "={{ $json.body.type }}",
            "rightValue": "order",
            "operator": {"type": "string", "operation": "equals"}
          }]
        }
      }
    },
    {"name": "Process Order", "type": "n8n-nodes-base.set"},
    {"name": "Process Other", "type": "n8n-nodes-base.set"},
    {"name": "Send Response", "type": "n8n-nodes-base.respondToWebhook"}
  ],
  "connections": {
    "Trigger": {"main": [[{"node": "Check Type"}]]},
    "Check Type": {
      "main": [
        [{"node": "Process Order"}],
        [{"node": "Process Other"}]
      ]
    },
    "Process Order": {"main": [[{"node": "Send Response"}]]},
    "Process Other": {"main": [[{"node": "Send Response"}]]}
  }
}
```

### Switch (Multiple Branches)

```json
{
  "nodes": [
    {"name": "Trigger", "type": "n8n-nodes-base.webhook"},
    {
      "name": "Route by Type",
      "type": "n8n-nodes-base.switch",
      "parameters": {
        "rules": {
          "values": [
            {
              "outputKey": "orders",
              "conditions": {"conditions": [{
                "leftValue": "={{ $json.body.type }}",
                "rightValue": "order",
                "operator": {"type": "string", "operation": "equals"}
              }]}
            },
            {
              "outputKey": "refunds",
              "conditions": {"conditions": [{
                "leftValue": "={{ $json.body.type }}",
                "rightValue": "refund",
                "operator": {"type": "string", "operation": "equals"}
              }]}
            }
          ]
        },
        "options": {"fallbackOutput": "extra"}
      }
    },
    {"name": "Handle Order", "type": "n8n-nodes-base.set"},
    {"name": "Handle Refund", "type": "n8n-nodes-base.set"},
    {"name": "Handle Default", "type": "n8n-nodes-base.set"}
  ],
  "connections": {
    "Trigger": {"main": [[{"node": "Route by Type"}]]},
    "Route by Type": {
      "main": [
        [{"node": "Handle Order"}],
        [{"node": "Handle Refund"}],
        [{"node": "Handle Default"}]
      ]
    }
  }
}
```

---

## Pattern 6: Parallel Processing

**Use case:** Independent operations, aggregation

```json
{
  "nodes": [
    {"name": "Trigger", "type": "n8n-nodes-base.webhook"},
    {"name": "Fetch API 1", "type": "n8n-nodes-base.httpRequest"},
    {"name": "Fetch API 2", "type": "n8n-nodes-base.httpRequest"},
    {"name": "Merge Results", "type": "n8n-nodes-base.merge"},
    {"name": "Response", "type": "n8n-nodes-base.respondToWebhook"}
  ],
  "connections": {
    "Trigger": {
      "main": [[
        {"node": "Fetch API 1"},
        {"node": "Fetch API 2"}
      ]]
    },
    "Fetch API 1": {"main": [[{"node": "Merge Results", "index": 0}]]},
    "Fetch API 2": {"main": [[{"node": "Merge Results", "index": 1}]]},
    "Merge Results": {"main": [[{"node": "Response"}]]}
  }
}
```

---

## Pattern 7: Batch Processing

**Use case:** Large datasets, rate limiting

```json
{
  "nodes": [
    {"name": "Trigger", "type": "n8n-nodes-base.scheduleTrigger"},
    {"name": "Fetch All", "type": "n8n-nodes-base.httpRequest"},
    {
      "name": "Split Batches",
      "type": "n8n-nodes-base.splitInBatches",
      "parameters": {"batchSize": 50}
    },
    {"name": "Process Batch", "type": "n8n-nodes-base.httpRequest"},
    {"name": "Wait", "type": "n8n-nodes-base.wait", "parameters": {"amount": 1, "unit": "seconds"}}
  ],
  "connections": {
    "Trigger": {"main": [[{"node": "Fetch All"}]]},
    "Fetch All": {"main": [[{"node": "Split Batches"}]]},
    "Split Batches": {
      "main": [
        [{"node": "Process Batch"}],
        []
      ]
    },
    "Process Batch": {"main": [[{"node": "Wait"}]]},
    "Wait": {"main": [[{"node": "Split Batches"}]]}
  }
}
```

---

## Pattern 8: Loop with Static Data Collector

**Use case:** Process items in isolation, collect results, then continue with batched data

**Problem:** When multiple items flow through a workflow:
- Nodes process all items together by default
- Some operations need each item processed independently (e.g., folder creation, API calls with dependencies)
- After independent processing, you need all results together for the next stage

**Solution:** Use `splitInBatches` with workflow static data to accumulate results across iterations.

### Flow Structure

```
Input (N items) → Loop Over Items ──[loop branch]──→ Process → Collect ─┐
                       ↑                                                 │
                       └─────────────────────────────────────────────────┘
                       │
                 [done branch]
                       ↓
                Get All Results (N items) → Continue...
```

### Implementation

```json
{
  "name": "Loop with Collector",
  "nodes": [
    {
      "name": "Loop Over Items",
      "type": "n8n-nodes-base.splitInBatches",
      "typeVersion": 3,
      "position": [400, 300],
      "parameters": {"options": {}}
    },
    {
      "name": "Process Item",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [620, 400],
      "parameters": {
        "method": "POST",
        "url": "https://api.example.com/process",
        "sendBody": true,
        "bodyParameters": {
          "parameters": [{"name": "id", "value": "={{ $json.id }}"}]
        }
      }
    },
    {
      "name": "Collect Result",
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [840, 400],
      "parameters": {
        "jsCode": "// Accumulate results in workflow static data\nconst staticData = $getWorkflowStaticData('global');\nstaticData.results = staticData.results || [];\n\nconst result = $input.first().json;\nstaticData.results.push({\n  id: result.id,\n  status: result.status,\n  processedAt: new Date().toISOString()\n});\n\nreturn $input.all();"
      }
    },
    {
      "name": "Get All Results",
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [620, 200],
      "parameters": {
        "jsCode": "// Retrieve all collected results\nconst staticData = $getWorkflowStaticData('global');\nconst results = staticData.results || [];\n\n// CRITICAL: Clear for next execution\nstaticData.results = [];\n\n// Return as n8n items\nreturn results.map(item => ({ json: item }));"
      }
    },
    {
      "name": "Send Summary",
      "type": "n8n-nodes-base.slack",
      "typeVersion": 2.1,
      "position": [840, 200],
      "parameters": {
        "channel": "#notifications",
        "text": "=Processed {{ $json.length }} items"
      }
    }
  ],
  "connections": {
    "Loop Over Items": {
      "main": [
        [{"node": "Get All Results", "type": "main", "index": 0}],
        [{"node": "Process Item", "type": "main", "index": 0}]
      ]
    },
    "Process Item": {
      "main": [[{"node": "Collect Result", "type": "main", "index": 0}]]
    },
    "Collect Result": {
      "main": [[{"node": "Loop Over Items", "type": "main", "index": 0}]]
    },
    "Get All Results": {
      "main": [[{"node": "Send Summary", "type": "main", "index": 0}]]
    }
  }
}
```

### Key Points

| Aspect | Detail |
|--------|--------|
| **splitInBatches outputs** | Output 0 = "done" (fires once when complete), Output 1 = "loop" (fires for each item) |
| **Static data scope** | `$getWorkflowStaticData('global')` persists across loop iterations within the same execution |
| **Always clear data** | Clear static data after retrieval to prevent leakage between workflow executions |
| **Avoids sub-workflows** | This pattern preserves execution quota while achieving isolated processing |

### When to Use

- **File organization:** Creating folder structures where each folder depends on the previous
- **Sequential API calls:** Operations that must complete before the next can determine its target
- **Data aggregation:** Building a summary from individually processed items
- **Resource creation:** Creating resources (folders, records) then collecting their IDs/URLs

### vs. Pattern 7 (Batch Processing)

| Pattern 7 (Batch) | Pattern 8 (Loop + Collector) |
|-------------------|------------------------------|
| Splits large datasets into smaller chunks | Processes items one-by-one |
| For rate limiting parallel operations | For sequential dependent operations |
| Results flow naturally | Results must be explicitly collected |
| Simple loop back to batch node | Loop back + collector + retriever nodes |

---

## Best Practices

### 1. Keep Workflows Focused
- 5-10 nodes per workflow
- Single responsibility
- Use sub-workflows for complex logic

### 2. Always Handle Errors
- Add Error Trigger node
- Use IF for validation
- Send alerts on failures

### 3. Use Descriptive Names
- Clear node names
- Indicate purpose in workflow name
- Add notes for complex logic

### 4. Plan Data Flow
- Understand input structure
- Transform early
- Validate before actions

### 5. Test Incrementally
- Use Manual Trigger for testing
- Validate each step
- Check with real data
