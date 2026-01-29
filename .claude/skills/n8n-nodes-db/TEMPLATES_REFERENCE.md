# Templates Reference

Guide to searching and using workflow templates from the database.

---

## Template Overview

The database contains 2,737 workflow templates from n8n.io's template library, including:

- Complete workflow JSON
- Node configurations used
- View counts and popularity metrics
- Author information
- Category tags

---

## Searching Templates

### By Keyword

```bash
list_templates "email automation" 10
list_templates "slack webhook"
list_templates "data sync"
```

### By Use Case

```bash
# Communication
list_templates "notification"
list_templates "alert"
list_templates "message"

# Data processing
list_templates "transform"
list_templates "sync"
list_templates "backup"

# Integration
list_templates "google sheets"
list_templates "airtable"
list_templates "notion"

# AI/Automation
list_templates "AI agent"
list_templates "chatbot"
list_templates "openai"
```

---

## Template Information

### Basic Info (list_templates)

| Field | Description |
|-------|-------------|
| `id` | Template ID (use with get_template) |
| `name` | Template name |
| `author_name` | Creator |
| `views` | Popularity metric |
| `description_preview` | First 80 chars of description |

### Full Info (get_template)

| Field | Description |
|-------|-------------|
| `id` | Template ID |
| `workflow_id` | n8n.io workflow ID |
| `name` | Full template name |
| `description` | Complete description |
| `author_name` | Creator name |
| `author_username` | n8n.io username |
| `author_verified` | Verified author (Yes/No) |
| `views` | View count |
| `nodes_used` | JSON array of node types |
| `categories` | JSON array of categories |
| `url` | n8n.io template URL |
| `created_at` | Creation date |
| `updated_at` | Last update |

---

## Using Templates

### Step 1: Search

```bash
list_templates "your use case"
```

### Step 2: Get Details

```bash
get_template <id>
```

### Step 3: See Nodes Used

The `nodes_used` field shows all node types in the template.

### Step 4: Extract Configurations

```bash
# Find configs for a specific node from this template
query_nodes_db configs "<node_type>"
```

---

## Finding Templates by Node

Find templates that use a specific node:

```bash
# Direct SQLite query
sqlite3 -column -header n8n-mcp/data/nodes.db \
  "SELECT id, name, views FROM templates
   WHERE nodes_used LIKE '%n8n-nodes-base.slack%'
   ORDER BY views DESC LIMIT 10;"
```

---

## Popular Template Categories

### By Views

```bash
# Most popular overall
sqlite3 -column -header n8n-mcp/data/nodes.db \
  "SELECT id, name, views FROM templates ORDER BY views DESC LIMIT 20;"
```

### By Author Type

```bash
# Verified authors only
sqlite3 -column -header n8n-mcp/data/nodes.db \
  "SELECT id, name, views, author_name FROM templates
   WHERE author_verified=1 ORDER BY views DESC LIMIT 20;"
```

---

## Template Node Configurations

The `template_node_configs` table extracts node configurations from templates:

```bash
# See configurations for HTTP Request from popular templates
query_nodes_db configs "n8n-nodes-base.httpRequest" 10

# Get actual JSON parameters
query_nodes_db config-json "n8n-nodes-base.httpRequest" 1
```

### Configuration Ranking

Configurations are ranked by:
1. Template popularity (views)
2. Configuration quality
3. Complexity level

Rank 1 = best example for that node type.

### Configuration Metadata

| Field | Description |
|-------|-------------|
| `rank` | Quality ranking (1 = best) |
| `template_name` | Source template |
| `template_views` | Template popularity |
| `complexity` | simple/medium/complex |
| `has_auth` | Uses credentials |
| `has_expr` | Uses expressions |

---

## Example Workflows

### Find Webhook + Slack Template

```bash
# Search
list_templates "webhook slack"

# Get details
get_template <id>

# See node configs
query_nodes_db configs "n8n-nodes-base.webhook"
query_nodes_db configs "n8n-nodes-base.slack"
```

### Find AI Agent Template

```bash
# Search
list_templates "AI agent"

# Get details
get_template <id>

# See agent config
query_nodes_db configs "@n8n/n8n-nodes-langchain.agent"
```

### Find Data Sync Template

```bash
# Search
list_templates "google sheets sync"

# Get details
get_template <id>

# See sheet configs
query_nodes_db configs "n8n-nodes-base.googleSheets"
```

---

## Advanced Queries

### Templates with Multiple Specific Nodes

```bash
sqlite3 -column -header n8n-mcp/data/nodes.db \
  "SELECT id, name, views FROM templates
   WHERE nodes_used LIKE '%webhook%'
     AND nodes_used LIKE '%slack%'
   ORDER BY views DESC LIMIT 10;"
```

### Recently Updated Templates

```bash
sqlite3 -column -header n8n-mcp/data/nodes.db \
  "SELECT id, name, views, updated_at FROM templates
   ORDER BY updated_at DESC LIMIT 20;"
```

### Templates by Node Count

```bash
sqlite3 -column -header n8n-mcp/data/nodes.db \
  "SELECT id, name, views,
          (LENGTH(nodes_used) - LENGTH(REPLACE(nodes_used, ',', ''))) + 1 as node_count
   FROM templates
   ORDER BY node_count DESC LIMIT 20;"
```
