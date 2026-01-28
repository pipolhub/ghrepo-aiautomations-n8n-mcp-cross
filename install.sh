#!/bin/bash
# Install script for n8n-api-mcp-controller
# Sets up the MCP server submodule and downloads n8n API spec

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== n8n-api-mcp-controller Install Script ==="

# Initialize and update submodule
echo ""
echo "=== Initializing MCP Submodule ==="
git submodule update --init --recursive

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
echo "Available tools: 22 (workflow, execution, credential, and API management)"
