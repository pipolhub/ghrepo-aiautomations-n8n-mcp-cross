#!/bin/bash
# Install script for n8n-api-mcp-controller
# Sets up the MCP server submodule and downloads n8n API spec

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== n8n-api-mcp-controller Install Script ==="

# Check and install sqlite3 if not present
echo ""
echo "=== Checking Dependencies ==="

if ! command -v sqlite3 &> /dev/null; then
    echo "sqlite3 not found. Installing..."

    # Detect OS and install
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y sqlite3
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y sqlite
        elif command -v yum &> /dev/null; then
            sudo yum install -y sqlite
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm sqlite
        elif command -v apk &> /dev/null; then
            sudo apk add sqlite
        else
            echo "ERROR: Could not detect package manager. Please install sqlite3 manually."
            exit 1
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &> /dev/null; then
            brew install sqlite3
        else
            echo "ERROR: Homebrew not found. Please install sqlite3 manually: brew install sqlite3"
            exit 1
        fi
    else
        echo "ERROR: Unsupported OS. Please install sqlite3 manually."
        exit 1
    fi

    echo "sqlite3 installed successfully."
else
    echo "sqlite3 found: $(sqlite3 --version)"
fi

# Initialize and update submodules
echo ""
echo "=== Initializing Submodules ==="
git submodule update --init --recursive

# Pin n8n-mcp to specific commit for reproducibility
echo ""
echo "=== Pinning n8n-mcp Submodule ==="
N8N_MCP_COMMIT="c8c76e435d80953cdbde3fc8b86675285c555b30"
cd n8n-mcp
git checkout "$N8N_MCP_COMMIT"
cd ..
echo "n8n-mcp pinned to commit: $N8N_MCP_COMMIT"

# Make n8n-nodes-db query scripts executable
echo ""
echo "=== Setting up n8n-nodes-db Skill ==="
chmod +x .claude/skills/n8n-nodes-db/bin/*
echo "n8n-nodes-db query scripts ready"

# Verify database exists
if [ -f "n8n-mcp/data/nodes.db" ]; then
    echo "Database found: n8n-mcp/data/nodes.db"
else
    echo "WARNING: Database not found at n8n-mcp/data/nodes.db"
fi

# Install MCP dependencies and build
echo ""
echo "=== Installing MCP Server ==="
cd mcp
npm install
npm run build
cd ..

# Download and setup n8n OpenAPI spec
echo ""
echo "=== Downloading n8n OpenAPI Spec ==="
OPENAPI_URL="https://raw.githubusercontent.com/n8n-io/n8n-docs/main/docs/api/v1/openapi.yml"
OPENAPI_YML="mcp/n8n-openapi.yml"
OPENAPI_JSON="mcp/n8n-openapi.json"

if curl -sL "$OPENAPI_URL" -o "$OPENAPI_YML"; then
    echo "Downloaded OpenAPI spec from n8n-docs"

    # Convert YAML to JSON
    cd mcp
    node -e "
        const yaml = require('yaml');
        const fs = require('fs');
        const spec = yaml.parse(fs.readFileSync('n8n-openapi.yml', 'utf8'));
        fs.writeFileSync('n8n-openapi.json', JSON.stringify(spec, null, 2));
        console.log('Converted to JSON. Endpoints:', Object.keys(spec.paths).length);
    "
    cd ..
    echo "OpenAPI spec ready at $OPENAPI_JSON"
else
    echo "WARNING: Failed to download OpenAPI spec. You can load it later with the download_api_spec tool."
fi

# Setup .mcp.json if it doesn't exist
if [ ! -f ".mcp.json" ]; then
    echo ""
    echo "=== MCP Configuration Setup ==="
    echo "No .mcp.json found. Let's create one."
    echo ""

    read -p "Enter your n8n instance URL (e.g., https://your-instance.app.n8n.cloud): " N8N_URL
    read -p "Enter your n8n API key: " N8N_API_KEY

    cat > .mcp.json << MCPEOF
{
  "mcpServers": {
    "n8n-api-mcp": {
      "command": "node",
      "args": [
        "./mcp/build/index.js"
      ],
      "env": {
        "N8N_URL": "${N8N_URL}",
        "N8N_API_KEY": "${N8N_API_KEY}"
      }
    }
  }
}
MCPEOF

    echo ".mcp.json created successfully."
else
    echo ".mcp.json already exists, skipping configuration."
fi

echo ""
echo "=== Installation complete ==="
echo ""
echo "Next steps:"
echo "1. Start Claude Code in this directory"
echo "2. The MCP server will auto-start"
echo "3. Use 'download_api_spec' tool to load the API endpoint database"
echo "   (or 'load_api_spec_from_json' with path: $SCRIPT_DIR/$OPENAPI_JSON)"
echo ""
echo "Available resources:"
echo "  - MCP tools: 22 (workflow, execution, credential, and API management)"
echo "  - n8n-nodes-db: Query 800+ nodes, 2,700+ templates via bash scripts"
echo ""
echo "Query nodes database:"
echo "  search_nodes \"gmail\"              # Search nodes"
echo "  get_node n8n-nodes-base.gmail      # Get node details"
echo "  list_templates \"slack webhook\"    # Search templates"
echo "  db_stats                           # Database statistics"
