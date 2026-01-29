# Database Schema Reference

Complete schema documentation for the n8n nodes database.

---

## Overview

| Table | Records | Purpose |
|-------|---------|---------|
| `nodes` | 803 | Node type definitions |
| `templates` | 2,737 | Workflow templates |
| `template_node_configs` | 215 | Extracted configurations |
| `node_versions` | - | Version history |
| `nodes_fts` | - | Full-text search (FTS5) |
| `templates_fts` | - | Template search (FTS5) |

---

## nodes Table

Primary table containing all n8n node definitions.

```sql
CREATE TABLE nodes (
  node_type TEXT PRIMARY KEY,          -- e.g., "n8n-nodes-base.gmail"
  package_name TEXT NOT NULL,          -- e.g., "n8n-nodes-base"
  display_name TEXT NOT NULL,          -- e.g., "Gmail"
  description TEXT,                    -- Node description
  category TEXT,                       -- transform, input, output, trigger, organization

  -- Node characteristics
  development_style TEXT,              -- 'declarative' or 'programmatic'
  is_ai_tool INTEGER DEFAULT 0,        -- Works with AI agents
  is_trigger INTEGER DEFAULT 0,        -- Can start workflows
  is_webhook INTEGER DEFAULT 0,        -- Receives HTTP requests
  is_versioned INTEGER DEFAULT 0,      -- Has multiple versions
  version TEXT,                        -- Current version

  -- Documentation
  documentation TEXT,                  -- Full documentation
  ai_documentation_summary TEXT,       -- AI-generated summary

  -- Configuration schemas
  properties_schema TEXT,              -- JSON schema for properties
  operations TEXT,                     -- Available operations (JSON)
  credentials_required TEXT,           -- Required credential types
  outputs TEXT,                        -- Output definitions (JSON)
  output_names TEXT,                   -- Output names (JSON)

  -- Tool variants (for AI)
  is_tool_variant INTEGER DEFAULT 0,   -- Is a tool version of base node
  has_tool_variant INTEGER DEFAULT 0,  -- Has a tool variant available
  base_node_type TEXT,                 -- Base node if tool variant
  tool_variant_of TEXT,                -- Tool variant node type

  -- Community nodes
  is_community INTEGER DEFAULT 0,      -- Community-contributed
  is_verified INTEGER DEFAULT 0,       -- Verified by n8n
  author_name TEXT,
  author_github_url TEXT,
  npm_package_name TEXT,
  npm_version TEXT,
  npm_downloads INTEGER DEFAULT 0,
  npm_readme TEXT,

  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

### Key Indexes

```sql
CREATE INDEX idx_package ON nodes(package_name);
CREATE INDEX idx_ai_tool ON nodes(is_ai_tool);
CREATE INDEX idx_category ON nodes(category);
CREATE INDEX idx_tool_variant ON nodes(is_tool_variant);
CREATE INDEX idx_community ON nodes(is_community);
```

### Categories

| Category | Count | Description |
|----------|-------|-------------|
| transform | 332 | Data manipulation nodes |
| input | 189 | Data source nodes |
| output | 169 | Data destination nodes |
| trigger | 107 | Workflow starters |
| organization | 6 | Control flow nodes |

---

## templates Table

Workflow templates from n8n.io template library.

```sql
CREATE TABLE templates (
  id INTEGER PRIMARY KEY,
  workflow_id INTEGER UNIQUE NOT NULL,  -- n8n.io workflow ID
  name TEXT NOT NULL,
  description TEXT,

  -- Author info
  author_name TEXT,
  author_username TEXT,
  author_verified INTEGER DEFAULT 0,

  -- Content
  nodes_used TEXT,                      -- JSON array of node types
  workflow_json TEXT,                   -- Full workflow (deprecated)
  workflow_json_compressed TEXT,        -- Compressed workflow (base64 gzip)
  categories TEXT,                      -- JSON array of categories

  -- Metrics
  views INTEGER DEFAULT 0,
  url TEXT,

  -- Metadata
  metadata_json TEXT,                   -- Structured metadata (JSON)
  metadata_generated_at DATETIME,
  created_at DATETIME,
  updated_at DATETIME,
  scraped_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

### Key Indexes

```sql
CREATE INDEX idx_template_nodes ON templates(nodes_used);
CREATE INDEX idx_template_updated ON templates(updated_at);
CREATE INDEX idx_template_name ON templates(name);
```

---

## template_node_configs Table

Pre-extracted node configurations from templates, ranked by quality.

```sql
CREATE TABLE template_node_configs (
  id INTEGER PRIMARY KEY,
  node_type TEXT NOT NULL,              -- Node type (FK to nodes)
  template_id INTEGER NOT NULL,         -- Source template (FK)
  template_name TEXT NOT NULL,
  template_views INTEGER DEFAULT 0,

  -- Configuration
  node_name TEXT,                       -- Node name in workflow
  parameters_json TEXT NOT NULL,        -- Node parameters (JSON)
  credentials_json TEXT,                -- Credential config (JSON)

  -- Metadata
  has_credentials INTEGER DEFAULT 0,
  has_expressions INTEGER DEFAULT 0,    -- Contains expressions
  complexity TEXT,                      -- 'simple', 'medium', 'complex'
  use_cases TEXT,                       -- JSON array

  -- Quality ranking (1 = best)
  rank INTEGER DEFAULT 0,

  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (template_id) REFERENCES templates(id) ON DELETE CASCADE
);
```

### Key Indexes

```sql
CREATE INDEX idx_config_node_type_rank ON template_node_configs(node_type, rank);
CREATE INDEX idx_config_complexity ON template_node_configs(node_type, complexity, rank);
CREATE INDEX idx_config_auth ON template_node_configs(node_type, has_credentials, rank);
```

---

## Full-Text Search Tables

### nodes_fts (FTS5)

Virtual table for full-text search on nodes.

```sql
CREATE VIRTUAL TABLE nodes_fts USING fts5(
  node_type,
  display_name,
  description,
  documentation,
  operations,
  content='nodes',
  content_rowid='rowid'
);
```

**Search example:**
```sql
SELECT node_type FROM nodes_fts WHERE nodes_fts MATCH 'gmail';
```

### templates_fts (FTS5)

Virtual table for full-text search on templates.

```sql
CREATE VIRTUAL TABLE templates_fts USING fts5(
  name,
  description,
  content='templates',
  content_rowid='id'
);
```

**Search example:**
```sql
SELECT rowid FROM templates_fts WHERE templates_fts MATCH 'slack webhook';
```

---

## Common Queries

### Find nodes by keyword

```sql
SELECT node_type, display_name, category
FROM nodes
WHERE node_type IN (
  SELECT node_type FROM nodes_fts WHERE nodes_fts MATCH 'gmail'
)
LIMIT 20;
```

### Get node details

```sql
SELECT * FROM nodes WHERE node_type = 'n8n-nodes-base.gmail';
```

### Find AI-capable nodes

```sql
SELECT node_type, display_name
FROM nodes
WHERE is_ai_tool = 1
ORDER BY display_name;
```

### Find trigger nodes

```sql
SELECT node_type, display_name
FROM nodes
WHERE is_trigger = 1
ORDER BY display_name;
```

### Search templates

```sql
SELECT id, name, views
FROM templates
WHERE id IN (
  SELECT rowid FROM templates_fts WHERE templates_fts MATCH 'slack'
)
ORDER BY views DESC
LIMIT 10;
```

### Get best configurations for a node

```sql
SELECT template_name, parameters_json, complexity, rank
FROM template_node_configs
WHERE node_type = 'n8n-nodes-base.httpRequest'
ORDER BY rank ASC
LIMIT 5;
```

---

## Data Relationships

```
nodes (1) ←──────── (N) template_node_configs
                           │
                           │
templates (1) ←────────────┘
```

- Each node can have multiple configurations from different templates
- Configurations are ranked by template popularity and complexity
- FTS tables mirror main tables for search
