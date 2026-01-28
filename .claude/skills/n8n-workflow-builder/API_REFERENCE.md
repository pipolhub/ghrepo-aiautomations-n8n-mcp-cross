# n8n API Reference

Quick reference for n8n public REST API endpoints used in workflow building.

---

## API Base

```
{N8N_URL}/api/v1
```

## Authentication

All requests require Bearer token:

```
Authorization: Bearer {N8N_API_KEY}
```

---

## Workflow Endpoints

### List Workflows

```
GET /workflows
```

**Parameters:**
| Name | Type | Description |
|------|------|-------------|
| `cursor` | string | Pagination cursor |
| `limit` | number | Results per page (default: 10, max: 250) |
| `active` | boolean | Filter by active status |
| `tags` | string | Filter by tag IDs (comma-separated) |

**MCP Usage:**
```javascript
execute_api_call({
  path: "/workflows",
  method: "GET",
  params: { limit: 50 }
})
```

### Get Workflow

```
GET /workflows/{id}
```

**MCP Usage:**
```javascript
execute_api_call({
  path: "/workflows/workflow-id",
  method: "GET"
})
```

### Create Workflow

```
POST /workflows
```

**Request Body:**
```json
{
  "name": "Workflow Name",
  "nodes": [...],
  "connections": {...},
  "settings": {...},
  "staticData": {...},
  "tags": [...]
}
```

**MCP Usage:**
```javascript
execute_api_call({
  path: "/workflows",
  method: "POST",
  data: {
    name: "My Workflow",
    nodes: [...],
    connections: {...},
    settings: { executionOrder: "v1" }
  }
})
```

### Update Workflow (Full)

```
PUT /workflows/{id}
```

Replaces entire workflow. If workflow is active, it's automatically reactivated with new definition.

**MCP Usage:**
```javascript
execute_api_call({
  path: "/workflows/workflow-id",
  method: "PUT",
  data: {
    // Complete workflow JSON
  }
})
```

### Update Workflow (Partial)

```
PATCH /workflows/{id}
```

Updates only specified fields.

**MCP Usage:**
```javascript
execute_api_call({
  path: "/workflows/workflow-id",
  method: "PATCH",
  data: {
    name: "New Name"
  }
})
```

### Delete Workflow

```
DELETE /workflows/{id}
```

**MCP Usage:**
```javascript
execute_api_call({
  path: "/workflows/workflow-id",
  method: "DELETE"
})
```

### Activate Workflow

```
POST /workflows/{id}/activate
```

**MCP Usage:**
```javascript
execute_api_call({
  path: "/workflows/workflow-id/activate",
  method: "POST"
})
```

### Deactivate Workflow

```
POST /workflows/{id}/deactivate
```

**MCP Usage:**
```javascript
execute_api_call({
  path: "/workflows/workflow-id/deactivate",
  method: "POST"
})
```

---

## Execution Endpoints

### List Executions

```
GET /executions
```

**Parameters:**
| Name | Type | Description |
|------|------|-------------|
| `cursor` | string | Pagination cursor |
| `limit` | number | Results per page |
| `status` | string | Filter: `waiting`, `running`, `success`, `error` |
| `workflowId` | string | Filter by workflow |

**MCP Usage:**
```javascript
execute_api_call({
  path: "/executions",
  method: "GET",
  params: {
    workflowId: "workflow-id",
    status: "error",
    limit: 10
  }
})
```

### Get Execution

```
GET /executions/{id}
```

Returns execution details including input/output data.

### Delete Execution

```
DELETE /executions/{id}
```

---

## Credential Endpoints

### List Credentials

```
GET /credentials
```

**MCP Usage:**
```javascript
execute_api_call({
  path: "/credentials",
  method: "GET"
})
```

### Get Credential Schema

```
GET /credentials/schema/{credentialTypeName}
```

Returns the schema for a credential type.

**MCP Usage:**
```javascript
execute_api_call({
  path: "/credentials/schema/slackOAuth2Api",
  method: "GET"
})
```

### Create Credential

```
POST /credentials
```

**Request Body:**
```json
{
  "name": "My API Key",
  "type": "httpHeaderAuth",
  "data": {
    "name": "Authorization",
    "value": "Bearer xxx"
  }
}
```

### Delete Credential

```
DELETE /credentials/{id}
```

---

## Tag Endpoints

### List Tags

```
GET /tags
```

**MCP Usage:**
```javascript
execute_api_call({
  path: "/tags",
  method: "GET"
})
```

### Create Tag

```
POST /tags
```

**Request Body:**
```json
{
  "name": "production"
}
```

### Update Tag

```
PUT /tags/{id}
```

### Delete Tag

```
DELETE /tags/{id}
```

---

## User Endpoints

### Get Current User

```
GET /users/me
```

### List Users

```
GET /users
```

### Get User

```
GET /users/{id}
```

---

## Project Endpoints (Enterprise)

### List Projects

```
GET /projects
```

### Create Project

```
POST /projects
```

### Transfer Workflow

```
PUT /workflows/{id}/transfer
```

**Request Body:**
```json
{
  "destinationProjectId": "project-id"
}
```

---

## Variable Endpoints (Enterprise)

### List Variables

```
GET /variables
```

### Create Variable

```
POST /variables
```

**Request Body:**
```json
{
  "key": "API_URL",
  "value": "https://api.example.com"
}
```

### Delete Variable

```
DELETE /variables/{id}
```

---

## Source Control Endpoints (Enterprise)

### Pull from Remote

```
POST /source-control/pull
```

### Push to Remote

```
POST /source-control/push
```

### Get Status

```
GET /source-control/status
```

---

## Response Formats

### Success Response

```json
{
  "data": {...}
}
```

### Paginated Response

```json
{
  "data": [...],
  "nextCursor": "cursor-string"
}
```

### Error Response

```json
{
  "code": 400,
  "message": "Error description",
  "hint": "Suggestion to fix"
}
```

---

## Common Error Codes

| Code | Meaning |
|------|---------|
| 400 | Bad Request - Invalid input |
| 401 | Unauthorized - Invalid/missing API key |
| 403 | Forbidden - No permission |
| 404 | Not Found - Resource doesn't exist |
| 409 | Conflict - Resource already exists |
| 500 | Internal Error - Server error |

---

## Rate Limits

n8n Cloud instances may have rate limits. Check response headers:

```
X-RateLimit-Limit: requests per window
X-RateLimit-Remaining: requests left
X-RateLimit-Reset: window reset time
```

---

## MCP Quick Reference

```javascript
// Search endpoints
search_api_endpoints({ query: "workflows" })

// Get endpoint details
get_api_endpoint_details({ path: "/workflows", method: "POST" })

// Execute API call
execute_api_call({
  path: "/workflows",
  method: "POST",
  params: {},  // Query parameters
  data: {}     // Request body
})

// Raw API request
send_raw_api_request({
  raw_request: "GET /workflows?limit=10"
})

// Natural language search
natural_language_api_search({
  query: "create new workflow"
})
```

---

## Further Reading

- [n8n API Documentation](https://docs.n8n.io/api/)
- [n8n API Reference](https://docs.n8n.io/api/api-reference/)
- [Using API Playground](https://docs.n8n.io/api/using-api-playground/)
