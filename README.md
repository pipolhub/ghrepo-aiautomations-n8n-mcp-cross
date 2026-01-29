# n8n API MCP Controller

Template for managing n8n workflows via the n8n API through MCP (Model Context Protocol).

## Setup

```bash
./install.sh
```

This will:
- Initialize git submodules (MCP server, n8n-mcp database)
- Install sqlite3 if not present
- Build the MCP server
- Download n8n OpenAPI spec
- Configure your n8n instance credentials

## Features

### MCP Server

22 tools for workflow, execution, credential, and API management via `n8n-api-mcp`.

### Claude Skills

| Skill | Description |
|-------|-------------|
| [n8n-workflow-builder](.claude/skills/n8n-workflow-builder/SKILL.md) | Build workflows programmatically via MCP |
| [n8n-nodes-db](.claude/skills/n8n-nodes-db/SKILL.md) | Query 800+ nodes, 2,700+ templates, real-world configs |

### Query the Nodes Database

```bash
search_nodes "gmail"                     # Search nodes
get_node nodes-base.httpRequest          # Node details
list_templates "slack webhook"           # Search templates
query_nodes_db configs nodes-base.code   # Real-world configs
db_stats                                 # Statistics
```

## Structure

```
├── .claude/skills/          # Claude Code skills
│   ├── n8n-workflow-builder/  # Workflow building guide
│   └── n8n-nodes-db/          # Database query tools
├── mcp/                     # MCP server (submodule)
├── n8n-mcp/                 # Nodes database (submodule)
├── workflows/               # Workflow documentation
└── install.sh               # Setup script
```

## Requirements

- Node.js
- sqlite3 (auto-installed by install.sh)
- n8n instance with API access
