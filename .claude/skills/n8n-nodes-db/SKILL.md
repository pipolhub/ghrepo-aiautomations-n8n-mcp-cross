---
name: n8n-nodes-db
description: Query the n8n nodes database containing 800+ nodes, 2,700+ templates, and real-world configurations. Use when searching for n8n nodes, exploring node properties, finding workflow templates, or getting example configurations. Complements n8n-workflow-builder with dynamic database lookups.
---

# n8n Nodes Database Query Skill

Query a comprehensive SQLite database of n8n nodes, workflow templates, and real-world configurations.

---

## Quick Start

```bash
# Search for nodes by keyword
search_nodes "gmail"
search_nodes "http request" 10

# Get detailed node information
get_node n8n-nodes-base.gmail
get_node n8n-nodes-base.httpRequest

# Search workflow templates
list_templates "slack webhook"
list_templates "email automation" 20

# Get real-world node configurations
query_nodes_db configs "n8n-nodes-base.httpRequest" 5

# Database statistics
db_stats
```

---

## Database Contents

| Table | Count | Description |
|-------|-------|-------------|
| `nodes` | 803 | All n8n node types with properties, operations, credentials |
| `templates` | 2,737 | Workflow templates from n8n.io |
| `template_node_configs` | 215 | Pre-extracted real-world configurations |
| `nodes_fts` | - | FTS5 full-text search index |

---

## Available Commands

### search_nodes - Find Nodes

Search nodes using full-text search on name, description, and documentation.

```bash
search_nodes <keyword> [limit]
```

**Examples:**
```bash
search_nodes gmail              # Find Gmail-related nodes
search_nodes "http request" 10  # HTTP nodes, limit 10
search_nodes slack              # Slack integration nodes
search_nodes trigger 20         # Trigger-type nodes
```

**Output columns:** node_type, display_name, category, ai_capable, is_trigger

---

### get_node - Node Details

Get comprehensive information about a specific node.

```bash
get_node <node_type>
```

**Examples:**
```bash
get_node n8n-nodes-base.gmail
get_node n8n-nodes-base.httpRequest
get_node @n8n/n8n-nodes-langchain.agent
```

**Output includes:**
- node_type, display_name, description
- category, package_name
- ai_capable, is_trigger, is_webhook
- version, credentials_required
- AI-generated documentation summary

---

### list_templates - Search Templates

Search workflow templates by keyword. Results sorted by view count.

```bash
list_templates <keyword> [limit]
```

**Examples:**
```bash
list_templates "email automation"
list_templates slack 20
list_templates "google sheets"
```

**Output columns:** id, name, author_name, views, description_preview

Use `get_template <id>` for full details.

---

### query_nodes_db - Main Entry Point

Unified interface for all queries.

```bash
query_nodes_db <command> [args]
```

**Commands:**
| Command | Purpose | Example |
|---------|---------|---------|
| `search` | Search nodes | `query_nodes_db search "gmail"` |
| `node` | Get node details | `query_nodes_db node "n8n-nodes-base.gmail"` |
| `templates` | Search templates | `query_nodes_db templates "slack"` |
| `configs` | Real-world configs | `query_nodes_db configs "n8n-nodes-base.httpRequest"` |
| `config-json` | Get config JSON | `query_nodes_db config-json "n8n-nodes-base.httpRequest" 1` |
| `stats` | Database statistics | `query_nodes_db stats` |
| `categories` | List categories | `query_nodes_db categories` |
| `ai-nodes` | AI-capable nodes | `query_nodes_db ai-nodes 20` |
| `triggers` | Trigger nodes | `query_nodes_db triggers 20` |

---

## Use Cases

### 1. Find the Right Node

When building a workflow and need to find the correct node type:

```bash
# Search by service name
search_nodes "google sheets"
search_nodes "airtable"
search_nodes "notion"

# Search by function
search_nodes "http"
search_nodes "webhook"
search_nodes "email"
```

### 2. Get Node Type String

When you need the exact node type for workflow JSON:

```bash
get_node gmail
# Returns: n8n-nodes-base.gmail

get_node "ai agent"
# Returns: @n8n/n8n-nodes-langchain.agent
```

### 3. Find AI-Capable Nodes

List nodes that work with LangChain/AI agents:

```bash
query_nodes_db ai-nodes 50
```

### 4. Find Trigger Nodes

List all available triggers for starting workflows:

```bash
query_nodes_db triggers 30
```

### 5. Get Example Configurations

Find real-world configurations from popular templates:

```bash
query_nodes_db configs "n8n-nodes-base.httpRequest" 5
# Shows: rank, template_name, views, complexity, has_auth, has_expr

query_nodes_db config-json "n8n-nodes-base.httpRequest" 1
# Returns actual parameters JSON from top-ranked template
```

### 6. Find Workflow Inspiration

Search templates for specific use cases:

```bash
list_templates "slack notification"
list_templates "data sync"
list_templates "AI agent"
```

---

## Data Authority & Documentation Workflow

**The database is the leading source** - query it first for node discovery and examples.
**Official n8n documentation is authoritative** - it takes precedence in case of conflicts (more likely to reflect latest versions).

### Recommended Workflow

1. **Query the database first** - Find node types, capabilities, and real-world configurations
2. **Fetch official docs for details** - Get accurate parameter documentation for the latest version
3. **If conflicts exist, trust official docs** - The database may lag behind n8n releases

```bash
# Step 1: Find the node in database
get_node n8n-nodes-base.httpRequest

# Step 2: Fetch official docs for current parameter details:
# https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.httpRequest/
```

**Official documentation URL pattern:**
- Core nodes: `https://docs.n8n.io/integrations/builtin/core-nodes/<node_type>/`
- Trigger nodes: `https://docs.n8n.io/integrations/builtin/trigger-nodes/<node_type>/`
- App nodes: `https://docs.n8n.io/integrations/builtin/app-nodes/<node_type>/`

**Summary:**
| Source | Use For | Priority |
|--------|---------|----------|
| Database | Node discovery, search, examples, real-world configs | Leading (check first) |
| Official docs | Parameter details, latest version info, edge cases | Authoritative (trust in conflicts) |

---

## Integration with n8n-workflow-builder

This skill complements [n8n-workflow-builder](../n8n-workflow-builder/SKILL.md) by providing dynamic database lookups:

| Need | n8n-workflow-builder | n8n-nodes-db |
|------|---------------------|--------------|
| Node type format | Static examples | Search database |
| Type versions | Hardcoded (may be outdated) | From database |
| Available nodes | Limited catalog | 800+ nodes |
| Example configs | Manual examples | Real-world from templates |
| Trigger nodes | Listed subset | Complete list |
| AI-capable nodes | Some listed | Full indexed list |

**Workflow for building workflows:**
1. Use `search_nodes` to find the right node type
2. Use `get_node` to get exact type string and capabilities
3. Use `query_nodes_db configs` to see real-world configurations
4. Use n8n-workflow-builder patterns to structure the workflow JSON
5. Use MCP to deploy via n8n API

---

## Database Schema

See [DATABASE_SCHEMA.md](DATABASE_SCHEMA.md) for complete schema documentation.

**Key tables:**
- `nodes` - Node metadata, properties, credentials
- `templates` - Workflow templates with metadata
- `template_node_configs` - Extracted configurations ranked by quality
- `nodes_fts` - Full-text search virtual table

---

## Technical Details

**Database location:** `n8n-mcp/data/nodes.db` (git submodule)

**Scripts location:** `.claude/skills/n8n-nodes-db/bin/`

**Requirements:** `sqlite3` (standard on most systems)

### Node Type Format

The database stores node types without the `n8n-` prefix:

| Database Format | Workflow JSON Format |
|-----------------|---------------------|
| `nodes-base.gmail` | `n8n-nodes-base.gmail` |
| `nodes-base.httpRequest` | `n8n-nodes-base.httpRequest` |
| `nodes-langchain.agent` | `@n8n/n8n-nodes-langchain.agent` |

The `get_node` script handles both formats automatically and shows the correct workflow JSON format.

**Update database:**
```bash
cd n8n-mcp && git pull origin main
```

---

## Additional References

- [DATABASE_SCHEMA.md](DATABASE_SCHEMA.md) - Complete database schema
- [QUERY_EXAMPLES.md](QUERY_EXAMPLES.md) - Advanced query patterns
- [NODES_REFERENCE.md](NODES_REFERENCE.md) - Node categories guide
- [TEMPLATES_REFERENCE.md](TEMPLATES_REFERENCE.md) - Template search guide
