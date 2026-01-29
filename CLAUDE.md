# n8n API MCP Controller

**First time setup:** Run `./install.sh` to initialize submodules and install dependencies.

This repository provides a template for managing n8n workflows via the n8n API through MCP.

## Skills

- **[n8n-workflow-builder](.claude/skills/n8n-workflow-builder/SKILL.md)** - Build workflows programmatically via MCP
- **[n8n-nodes-db](.claude/skills/n8n-nodes-db/SKILL.md)** - Query 800+ nodes, 2,700+ templates, and real-world configurations

## MCP Server

The `mcp/` directory contains an MCP server for n8n API access. MCP is already installed and available as `n8n-api-mcp`.

## Workflows

- **[INDEX.md](INDEX.md)** - Complete index of all workflows
- **`workflows/`** - Individual workflow documentation files

## Keep Documentation in Sync

For every workflow change:
1. **Existing:** Update the corresponding `.md` file in `workflows/`
2. **New:** Create a `.md` file in `workflows/` and add to `INDEX.md`
3. **Deleted:** Remove the `.md` file and its `INDEX.md` entry
4. **Renamed:** Update both the filename and `INDEX.md` entry

## n8n Instance

Configure your n8n instance URL and API key during `./install.sh` setup.
