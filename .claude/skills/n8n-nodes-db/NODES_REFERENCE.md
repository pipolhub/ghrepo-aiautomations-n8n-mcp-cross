# Nodes Reference

Guide to searching and understanding n8n nodes in the database.

---

## Node Type Format

### Official Nodes

```
n8n-nodes-base.<nodeName>
```

Examples:
- `n8n-nodes-base.gmail`
- `n8n-nodes-base.httpRequest`
- `n8n-nodes-base.webhook`
- `n8n-nodes-base.slack`

### LangChain/AI Nodes

```
@n8n/n8n-nodes-langchain.<nodeName>
```

Examples:
- `@n8n/n8n-nodes-langchain.agent`
- `@n8n/n8n-nodes-langchain.lmChatOpenAi`
- `@n8n/n8n-nodes-langchain.toolHttpRequest`

### Community Nodes

```
n8n-nodes-<package>.<nodeName>
```

Usually from npm packages.

---

## Node Categories

| Category | Count | Description | Example Nodes |
|----------|-------|-------------|---------------|
| **transform** | 332 | Data manipulation | Set, Code, Merge, IF, Switch |
| **input** | 189 | Data sources | HTTP Request, Database reads |
| **output** | 169 | Data destinations | Email, API calls, Database writes |
| **trigger** | 107 | Workflow starters | Webhook, Schedule, App triggers |
| **organization** | 6 | Control flow | NoOp, StickyNote |

### Find by Category

```bash
# List all nodes in a category
sqlite3 -column -header n8n-mcp/data/nodes.db \
  "SELECT node_type, display_name FROM nodes WHERE category='trigger' ORDER BY display_name;"
```

---

## Node Characteristics

### AI-Capable Nodes

Nodes that work with LangChain AI agents (534 nodes):

```bash
query_nodes_db ai-nodes 50
```

These nodes can be connected to AI agents as tools.

### Trigger Nodes

Nodes that can start workflows (107 nodes):

```bash
query_nodes_db triggers 50
```

Every workflow needs at least one trigger.

### Webhook Nodes

Nodes that receive HTTP requests (85 nodes):

```bash
sqlite3 -column -header n8n-mcp/data/nodes.db \
  "SELECT node_type, display_name FROM nodes WHERE is_webhook=1 LIMIT 20;"
```

---

## Common Node Searches

### By Service

```bash
# Google services
search_nodes google

# AWS services
search_nodes aws

# Messaging
search_nodes slack
search_nodes discord
search_nodes telegram
```

### By Function

```bash
# HTTP/API
search_nodes "http request"
search_nodes "api"

# Email
search_nodes email
search_nodes gmail

# Database
search_nodes postgres
search_nodes mysql
search_nodes mongodb

# File operations
search_nodes file
search_nodes "google drive"
search_nodes dropbox
```

### By Capability

```bash
# All triggers
query_nodes_db triggers

# AI-capable
query_nodes_db ai-nodes

# Webhooks
sqlite3 n8n-mcp/data/nodes.db \
  "SELECT node_type, display_name FROM nodes WHERE is_webhook=1;"
```

---

## Node Information Fields

When using `get_node`, you get:

| Field | Description |
|-------|-------------|
| `node_type` | Full type string for workflow JSON |
| `display_name` | Human-readable name |
| `description` | What the node does |
| `category` | transform/input/output/trigger/organization |
| `package_name` | NPM package containing the node |
| `ai_capable` | Works with AI agents (Yes/No) |
| `is_trigger` | Can start workflows (Yes/No) |
| `is_webhook` | Receives HTTP (Yes/No) |
| `is_community` | Community-contributed (Yes/No) |
| `version` | Current version |
| `credentials_required` | Required credential types |
| `ai_documentation_summary` | AI-generated summary |

---

## Essential Nodes

### Workflow Control

| Node | Type | Purpose |
|------|------|---------|
| Manual Trigger | `n8n-nodes-base.manualTrigger` | Test workflows |
| Webhook | `n8n-nodes-base.webhook` | Receive HTTP |
| Schedule Trigger | `n8n-nodes-base.scheduleTrigger` | Cron/interval |
| IF | `n8n-nodes-base.if` | Conditional branching |
| Switch | `n8n-nodes-base.switch` | Multi-way branching |
| Merge | `n8n-nodes-base.merge` | Combine branches |
| Code | `n8n-nodes-base.code` | Custom JavaScript |
| Set | `n8n-nodes-base.set` | Transform data |

### Common Integrations

| Node | Type | Purpose |
|------|------|---------|
| HTTP Request | `n8n-nodes-base.httpRequest` | API calls |
| Gmail | `n8n-nodes-base.gmail` | Email |
| Slack | `n8n-nodes-base.slack` | Messaging |
| Google Sheets | `n8n-nodes-base.googleSheets` | Spreadsheets |
| Postgres | `n8n-nodes-base.postgres` | Database |
| OpenAI | `@n8n/n8n-nodes-langchain.lmChatOpenAi` | AI/LLM |

### AI/LangChain

| Node | Type | Purpose |
|------|------|---------|
| AI Agent | `@n8n/n8n-nodes-langchain.agent` | Conversational AI |
| OpenAI Chat | `@n8n/n8n-nodes-langchain.lmChatOpenAi` | LLM |
| HTTP Tool | `@n8n/n8n-nodes-langchain.toolHttpRequest` | Agent tool |
| Buffer Memory | `@n8n/n8n-nodes-langchain.memoryBufferWindow` | Conversation memory |

---

## Finding the Right Node

### Step 1: Search

```bash
search_nodes "your service or function"
```

### Step 2: Get Details

```bash
get_node <node_type_from_search>
```

### Step 3: Find Examples

```bash
query_nodes_db configs "<node_type>" 5
```

### Step 4: Get Config JSON

```bash
query_nodes_db config-json "<node_type>" 1
```
