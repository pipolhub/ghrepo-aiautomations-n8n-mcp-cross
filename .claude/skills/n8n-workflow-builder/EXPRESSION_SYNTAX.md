# Expression Syntax Guide

Complete reference for n8n expressions in workflow JSON.

---

## Expression Format

In workflow JSON parameters, use expressions with the `=` prefix:

```json
{
  "parameters": {
    "text": "={{ $json.message }}",
    "value": "={{ $json.body.email }}"
  }
}
```

**Format:** `"={{ expression }}"`

---

## Core Variables

### $json - Current Item Data

Access data from the current item:

```javascript
={{ $json.fieldName }}
={{ $json.nested.property }}
={{ $json['field with spaces'] }}
={{ $json.items[0].name }}
```

### $json.body - Webhook Data

**Critical:** Webhook payload is always under `.body`:

```javascript
// WRONG
={{ $json.email }}

// CORRECT
={{ $json.body.email }}
={{ $json.body.name }}
={{ $json.body.data.items }}
```

### $node - Reference Other Nodes

Access data from any previous node:

```javascript
={{ $node["Node Name"].json.field }}
={{ $node["HTTP Request"].json.data }}
={{ $node["Webhook"].json.body.email }}
```

**Rules:**
- Node names must be in quotes
- Case-sensitive
- Must match exact node name

### $now - Current Timestamp

Luxon DateTime object:

```javascript
={{ $now }}
={{ $now.toISO() }}
={{ $now.toFormat('yyyy-MM-dd') }}
={{ $now.toFormat('HH:mm:ss') }}
={{ $now.plus({days: 7}).toFormat('yyyy-MM-dd') }}
```

### $env - Environment Variables

```javascript
={{ $env.API_KEY }}
={{ $env.BASE_URL }}
```

---

## Data Types

### Strings

```javascript
// Direct access
={{ $json.message }}

// String methods
={{ $json.name.toLowerCase() }}
={{ $json.text.trim() }}
={{ $json.email.split('@')[0] }}
```

### Numbers

```javascript
// Direct access
={{ $json.price }}

// Math operations
={{ $json.price * 1.1 }}
={{ $json.quantity + 5 }}
={{ Math.round($json.value) }}
```

### Arrays

```javascript
// Access by index
={{ $json.items[0] }}
={{ $json.users[0].email }}

// Array length
={{ $json.items.length }}

// Last item
={{ $json.items[$json.items.length - 1] }}
```

### Objects

```javascript
// Dot notation
={{ $json.user.email }}

// Bracket notation (for spaces or dynamic keys)
={{ $json['user data'].email }}
={{ $json[dynamicKey] }}
```

### Booleans

```javascript
={{ $json.isActive }}
={{ $json.status === 'active' }}
={{ !$json.disabled }}
```

---

## Common Patterns

### Conditional Values (Ternary)

```javascript
={{ $json.status === 'active' ? 'Active User' : 'Inactive' }}
={{ $json.count > 0 ? $json.items : [] }}
```

### Default Values

```javascript
={{ $json.email || 'no-email@example.com' }}
={{ $json.name ?? 'Unknown' }}
```

### String Concatenation

```javascript
={{ 'Hello ' + $json.name + '!' }}
={{ `Hello ${$json.name}!` }}
```

### Object Construction

```javascript
={{ { "name": $json.body.name, "email": $json.body.email } }}
={{ { ...$json, processed: true } }}
```

### Array Operations

```javascript
// Filter
={{ $json.items.filter(item => item.status === 'active') }}

// Map
={{ $json.users.map(u => u.email) }}

// Find
={{ $json.items.find(item => item.id === $json.targetId) }}

// Join
={{ $json.tags.join(', ') }}
```

---

## Date/Time Operations

Using Luxon DateTime:

### Current Time

```javascript
={{ $now }}
={{ $now.toISO() }}
={{ DateTime.now() }}
```

### Formatting

| Format | Output Example |
|--------|----------------|
| `yyyy-MM-dd` | 2025-10-20 |
| `dd/MM/yyyy` | 20/10/2025 |
| `HH:mm:ss` | 14:30:45 |
| `MMMM dd, yyyy` | October 20, 2025 |
| `yyyy-MM-dd HH:mm` | 2025-10-20 14:30 |

```javascript
={{ $now.toFormat('yyyy-MM-dd') }}
={{ $now.toFormat('MMMM dd, yyyy') }}
```

### Date Arithmetic

```javascript
// Add time
={{ $now.plus({days: 7}).toFormat('yyyy-MM-dd') }}
={{ $now.plus({hours: 24}).toISO() }}
={{ $now.plus({months: 1}).toFormat('yyyy-MM-dd') }}

// Subtract time
={{ $now.minus({days: 30}).toFormat('yyyy-MM-dd') }}
={{ $now.minus({weeks: 2}).toISO() }}
```

### Parse Dates

```javascript
={{ DateTime.fromISO($json.dateString).toFormat('MMM dd') }}
={{ DateTime.fromFormat($json.date, 'dd/MM/yyyy').toISO() }}
```

---

## JSON Operations

### Stringify

```javascript
={{ JSON.stringify($json.data) }}
={{ JSON.stringify($json, null, 2) }}
```

### Parse

```javascript
={{ JSON.parse($json.jsonString) }}
```

### Keys/Values

```javascript
={{ Object.keys($json.data) }}
={{ Object.values($json.data) }}
```

---

## Special Use Cases

### Webhook with Multiple Fields

```json
{
  "parameters": {
    "name": "={{ $json.body.firstName }} {{ $json.body.lastName }}",
    "email": "={{ $json.body.email }}",
    "subject": "=New submission from {{ $json.body.firstName }}"
  }
}
```

### Referencing Multiple Nodes

```json
{
  "parameters": {
    "message": "=User: {{ $node['Get User'].json.name }}, Order: {{ $node['Get Order'].json.id }}"
  }
}
```

### Complex Conditions

```json
{
  "parameters": {
    "conditions": {
      "conditions": [
        {
          "leftValue": "={{ $json.body.amount }}",
          "rightValue": "100",
          "operator": {"type": "number", "operation": "gte"}
        }
      ]
    }
  }
}
```

### Building URLs

```json
{
  "parameters": {
    "url": "=https://api.example.com/users/{{ $json.body.userId }}/orders"
  }
}
```

---

## Expression in Different Contexts

### Set Node Fields

```json
{
  "type": "n8n-nodes-base.set",
  "parameters": {
    "fields": {
      "values": [
        {
          "name": "fullName",
          "stringValue": "={{ $json.body.firstName }} {{ $json.body.lastName }}"
        },
        {
          "name": "timestamp",
          "stringValue": "={{ $now.toISO() }}"
        }
      ]
    }
  }
}
```

### HTTP Request Body

```json
{
  "type": "n8n-nodes-base.httpRequest",
  "parameters": {
    "method": "POST",
    "url": "https://api.example.com/endpoint",
    "sendBody": true,
    "bodyParameters": {
      "parameters": [
        {
          "name": "userId",
          "value": "={{ $json.body.id }}"
        },
        {
          "name": "timestamp",
          "value": "={{ $now.toISO() }}"
        }
      ]
    }
  }
}
```

### IF Node Conditions

```json
{
  "type": "n8n-nodes-base.if",
  "parameters": {
    "conditions": {
      "conditions": [
        {
          "leftValue": "={{ $json.body.email }}",
          "rightValue": "",
          "operator": {
            "type": "string",
            "operation": "isNotEmpty"
          }
        }
      ]
    }
  }
}
```

---

## Code Nodes - No Expressions!

**Critical:** Code nodes use direct JavaScript, NOT expressions:

```javascript
// WRONG in Code node
const email = '={{ $json.email }}';

// CORRECT in Code node
const email = $json.email;
const email = $input.first().json.email;
const allItems = $input.all();
```

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| `{{ $json.field }}` in JSON | Use `={{ $json.field }}` |
| `$json.email` (webhook) | Use `$json.body.email` |
| `$node.HTTP Request` | Use `$node["HTTP Request"]` |
| `{{ }}` in Code node | Use direct JS: `$json.field` |
| Missing `=` prefix | Add `=` before `{{ }}` |

---

## Debugging Tips

1. **Check data structure** - Use Set node to log `={{ $json }}`
2. **Verify node names** - Case-sensitive, must match exactly
3. **Test expressions** - Use expression editor in n8n UI
4. **Webhook data** - Always check `.body` first

---

## Quick Reference

```javascript
// Current data
={{ $json.field }}
={{ $json.body.field }}  // Webhook

// Other nodes
={{ $node["Name"].json.field }}

// Timestamps
={{ $now.toFormat('yyyy-MM-dd') }}

// Conditionals
={{ $json.x ? 'yes' : 'no' }}

// Defaults
={{ $json.x || 'default' }}

// Environment
={{ $env.VAR_NAME }}
```
