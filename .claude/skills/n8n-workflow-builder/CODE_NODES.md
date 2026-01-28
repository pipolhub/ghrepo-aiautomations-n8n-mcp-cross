# Code Nodes Guide

Writing JavaScript and Python code in n8n Code nodes.

---

## Code Node Basics

**Type:** `n8n-nodes-base.code`
**Version:** 2

```json
{
  "type": "n8n-nodes-base.code",
  "typeVersion": 2,
  "parameters": {
    "mode": "runOnceForAllItems",
    "language": "javaScript",
    "jsCode": "// Your code here"
  }
}
```

---

## Mode Selection

### Run Once for All Items (Recommended)

- Executes once with access to all input items
- Best for: aggregation, filtering, batch processing

```javascript
const items = $input.all();

return items.map(item => ({
  json: {
    ...item.json,
    processed: true
  }
}));
```

### Run Once for Each Item

- Executes separately for each input item
- Best for: item-specific logic, independent operations

```javascript
const item = $input.item;

return [{
  json: {
    ...item.json,
    processed: true
  }
}];
```

---

## Data Access

### $input Methods

```javascript
// All items
const allItems = $input.all();

// First item
const first = $input.first();

// Current item (Each Item mode only)
const current = $input.item;
```

### $json - Current Item

```javascript
// Direct access
const value = $json.fieldName;
const nested = $json.user.email;

// Webhook data (CRITICAL!)
const email = $json.body.email;  // NOT $json.email
```

### $node - Other Nodes

```javascript
// Reference other node output
const webhookData = $node["Webhook"].json;
const httpData = $node["HTTP Request"].json;
```

---

## Critical: No Expressions!

Code nodes use **direct JavaScript**, not expressions:

```javascript
// WRONG - expression syntax
const email = '={{ $json.email }}';
const value = '{{ $json.body.name }}';

// CORRECT - direct JavaScript
const email = $json.email;
const value = $json.body.name;
const data = $input.first().json.body;
```

---

## Return Format

**Always return array of objects with `json` property:**

```javascript
// Single result
return [{
  json: {
    field1: value1,
    field2: value2
  }
}];

// Multiple results
return [
  {json: {id: 1, data: 'first'}},
  {json: {id: 2, data: 'second'}}
];

// Transformed array
return items.map(item => ({
  json: {
    ...item.json,
    processed: true
  }
}));

// Empty result
return [];
```

### Wrong Formats

```javascript
// WRONG: No array wrapper
return {json: {field: value}};

// WRONG: No json wrapper
return [{field: value}];

// WRONG: Plain value
return "processed";
```

---

## Common Patterns

### Filter Items

```javascript
const items = $input.all();

const filtered = items.filter(item =>
  item.json.status === 'active'
);

return filtered.map(item => ({json: item.json}));
```

### Transform Data

```javascript
const items = $input.all();

return items.map(item => ({
  json: {
    fullName: `${item.json.firstName} ${item.json.lastName}`,
    email: item.json.email.toLowerCase(),
    timestamp: new Date().toISOString()
  }
}));
```

### Aggregate Data

```javascript
const items = $input.all();

const total = items.reduce(
  (sum, item) => sum + (item.json.amount || 0),
  0
);

return [{
  json: {
    total,
    count: items.length,
    average: total / items.length
  }
}];
```

### Webhook Data Processing

```javascript
// Access webhook body
const body = $json.body;

// Extract fields
const {name, email, message} = body;

return [{
  json: {
    name,
    email,
    message,
    receivedAt: new Date().toISOString()
  }
}];
```

### Conditional Logic

```javascript
const item = $input.first();
const data = item.json.body;

if (!data.email) {
  return [{
    json: {
      error: true,
      message: 'Email is required'
    }
  }];
}

return [{
  json: {
    valid: true,
    email: data.email
  }
}];
```

### Grouping Data

```javascript
const items = $input.all();

const grouped = items.reduce((acc, item) => {
  const key = item.json.category;
  if (!acc[key]) acc[key] = [];
  acc[key].push(item.json);
  return acc;
}, {});

return [{json: {grouped}}];
```

---

## Built-in Helpers

### $helpers.httpRequest()

```javascript
const response = await $helpers.httpRequest({
  method: 'GET',
  url: 'https://api.example.com/data',
  headers: {
    'Authorization': 'Bearer token'
  }
});

return [{json: {data: response}}];
```

### DateTime (Luxon)

```javascript
const now = DateTime.now();
const formatted = now.toFormat('yyyy-MM-dd');
const tomorrow = now.plus({days: 1});

return [{
  json: {
    today: formatted,
    tomorrow: tomorrow.toFormat('yyyy-MM-dd')
  }
}];
```

### $jmespath()

```javascript
const data = $input.first().json;

// Filter array
const adults = $jmespath(data, 'users[?age >= `18`]');

// Extract field
const names = $jmespath(data, 'users[*].name');

return [{json: {adults, names}}];
```

---

## Error Handling

```javascript
try {
  const response = await $helpers.httpRequest({
    url: 'https://api.example.com/data'
  });

  return [{
    json: {
      success: true,
      data: response
    }
  }];
} catch (error) {
  return [{
    json: {
      success: false,
      error: error.message
    }
  }];
}
```

---

## Python Code Node

```json
{
  "type": "n8n-nodes-base.code",
  "typeVersion": 2,
  "parameters": {
    "mode": "runOnceForAllItems",
    "language": "python",
    "pythonCode": "items = _input.all()\n\nreturn [{'json': item.json} for item in items]"
  }
}
```

### Python Data Access

```python
# All items
items = _input.all()

# First item
first = _input.first()

# Item json
data = first.json

# Webhook body
body = data.get('body', {})
```

---

## Node Configuration in Workflow JSON

```json
{
  "id": "code-uuid",
  "name": "Process Data",
  "type": "n8n-nodes-base.code",
  "typeVersion": 2,
  "position": [460, 300],
  "parameters": {
    "mode": "runOnceForAllItems",
    "language": "javaScript",
    "jsCode": "const items = $input.all();\n\nconst filtered = items.filter(item => item.json.status === 'active');\n\nreturn filtered.map(item => ({\n  json: {\n    id: item.json.id,\n    name: item.json.name,\n    processedAt: new Date().toISOString()\n  }\n}));"
  }
}
```

---

## Common Mistakes

### 1. Missing Return

```javascript
// WRONG
const items = $input.all();
items.map(item => ({json: item.json}));

// CORRECT
const items = $input.all();
return items.map(item => ({json: item.json}));
```

### 2. Expression Syntax in Code

```javascript
// WRONG
const email = '={{ $json.email }}';

// CORRECT
const email = $json.email;
```

### 3. Wrong Return Format

```javascript
// WRONG
return {result: 'success'};

// CORRECT
return [{json: {result: 'success'}}];
```

### 4. Forgetting Webhook Body

```javascript
// WRONG (webhook data)
const email = $json.email;

// CORRECT
const email = $json.body.email;
```

### 5. Not Handling Empty Input

```javascript
const items = $input.all();

// Add guard
if (!items || items.length === 0) {
  return [];
}

// Continue processing
return items.map(item => ({json: item.json}));
```

---

## Best Practices

1. **Always validate input** - Check for null/undefined
2. **Use try-catch** - Handle errors gracefully
3. **Keep code simple** - Move complex logic to multiple code nodes
4. **Return correct format** - Array of `{json: {...}}`
5. **No expressions** - Use direct JavaScript
6. **Debug with console.log()** - View output in browser console
