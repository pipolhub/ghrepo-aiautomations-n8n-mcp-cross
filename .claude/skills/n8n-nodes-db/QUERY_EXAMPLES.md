# Query Examples

Advanced query patterns for the n8n nodes database.

---

## Using the CLI Scripts

### Basic Searches

```bash
# Find Gmail nodes
search_nodes gmail

# Find HTTP-related nodes
search_nodes "http request"

# Find all trigger nodes
query_nodes_db triggers 50

# Find AI-capable nodes
query_nodes_db ai-nodes 100
```

### Getting Node Details

```bash
# Official node
get_node n8n-nodes-base.gmail

# LangChain node
get_node @n8n/n8n-nodes-langchain.agent

# Partial match (fuzzy search)
get_node slack
```

### Finding Templates

```bash
# Search by use case
list_templates "email automation"
list_templates "data sync"
list_templates "webhook handler"

# Get full template details
get_template 1234
```

### Real-World Configurations

```bash
# See top configurations for HTTP Request node
query_nodes_db configs "n8n-nodes-base.httpRequest" 5

# Get the actual JSON parameters
query_nodes_db config-json "n8n-nodes-base.httpRequest" 1
```

---

## Direct SQLite Queries

For advanced queries, use sqlite3 directly:

```bash
DB_PATH=".claude/skills/n8n-nodes-db/../../../n8n-mcp/data/nodes.db"
sqlite3 "$DB_PATH" "YOUR QUERY HERE"
```

### Node Queries

**Find nodes by category:**
```sql
SELECT node_type, display_name
FROM nodes
WHERE category = 'trigger'
ORDER BY display_name;
```

**Find nodes with specific credentials:**
```sql
SELECT node_type, display_name, credentials_required
FROM nodes
WHERE credentials_required LIKE '%OAuth%'
LIMIT 20;
```

**Find nodes by package:**
```sql
SELECT node_type, display_name
FROM nodes
WHERE package_name = '@n8n/n8n-nodes-langchain'
ORDER BY display_name;
```

**Search with multiple terms:**
```sql
SELECT node_type, display_name
FROM nodes
WHERE node_type IN (
  SELECT node_type FROM nodes_fts
  WHERE nodes_fts MATCH 'google AND sheets'
);
```

**Find tool variants:**
```sql
SELECT
  n1.node_type as base_node,
  n2.node_type as tool_variant
FROM nodes n1
JOIN nodes n2 ON n1.node_type = n2.tool_variant_of
WHERE n1.has_tool_variant = 1
LIMIT 20;
```

### Template Queries

**Most popular templates:**
```sql
SELECT id, name, views, author_name
FROM templates
ORDER BY views DESC
LIMIT 20;
```

**Templates using specific node:**
```sql
SELECT id, name, views
FROM templates
WHERE nodes_used LIKE '%n8n-nodes-base.slack%'
ORDER BY views DESC
LIMIT 10;
```

**Templates by author:**
```sql
SELECT id, name, views
FROM templates
WHERE author_verified = 1
ORDER BY views DESC
LIMIT 20;
```

### Configuration Queries

**Simple configurations (no expressions):**
```sql
SELECT template_name, parameters_json
FROM template_node_configs
WHERE node_type = 'n8n-nodes-base.httpRequest'
  AND has_expressions = 0
  AND complexity = 'simple'
ORDER BY rank ASC
LIMIT 5;
```

**Configurations with authentication:**
```sql
SELECT template_name, parameters_json, credentials_json
FROM template_node_configs
WHERE node_type = 'n8n-nodes-base.httpRequest'
  AND has_credentials = 1
ORDER BY rank ASC
LIMIT 5;
```

---

## Common Patterns

### Find Node Type for Service

```bash
# Search for the service
search_nodes "notion"

# Get exact type string
get_node n8n-nodes-base.notion
```

### Explore Node Capabilities

```bash
# Get node info including operations
get_node n8n-nodes-base.gmail

# For detailed operations, query directly:
sqlite3 "$DB_PATH" "SELECT operations FROM nodes WHERE node_type='n8n-nodes-base.gmail';" | jq
```

### Find Template Inspiration

```bash
# Search templates
list_templates "AI chatbot"

# Get template details
get_template 1234

# See what nodes it uses
sqlite3 "$DB_PATH" "SELECT nodes_used FROM templates WHERE id=1234;" | jq
```

### Get Example Parameters

```bash
# Find best configs
query_nodes_db configs "n8n-nodes-base.code" 3

# Get JSON for top-ranked
query_nodes_db config-json "n8n-nodes-base.code" 1 | jq
```

---

## Output Formatting

### Table Format (default)

```bash
sqlite3 -header -column "$DB_PATH" "SELECT node_type, display_name FROM nodes LIMIT 5;"
```

### Line Format

```bash
sqlite3 "$DB_PATH" ".mode line" "SELECT * FROM nodes WHERE node_type='n8n-nodes-base.gmail';"
```

### JSON Output

```bash
sqlite3 -json "$DB_PATH" "SELECT node_type, display_name FROM nodes LIMIT 5;"
```

### CSV Output

```bash
sqlite3 -csv -header "$DB_PATH" "SELECT node_type, display_name FROM nodes LIMIT 5;"
```

---

## Performance Tips

1. **Use FTS for text search** - Always use `nodes_fts` or `templates_fts` for keyword searches
2. **Limit results** - Add `LIMIT` to prevent large result sets
3. **Use indexes** - Query on indexed columns (node_type, category, is_ai_tool, etc.)
4. **Avoid LIKE with leading wildcard** - `LIKE '%term%'` is slow; use FTS instead
