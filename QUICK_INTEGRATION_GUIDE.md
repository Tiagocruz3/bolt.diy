# Quick Integration Guide - Add Storage to Your Workflow

Your Brainiac workflow is excellent! Here's how to add persistent storage and session management in 5 simple steps.

## 🎯 What You're Adding

1. **Session Management** (Redis) - Remember conversations
2. **File Storage** (S3) - Save generated code permanently
3. **Project Tracking** - Link files to projects

## 📋 Step-by-Step Integration

### Step 1: Add Session Management (Start)

**Add these 3 nodes at the beginning (after Chat Input):**

#### Node 1: Init Session
```
Type: Code
Name: Init Session
Position: Right after "Chat Input"

Code:
const input = $input.item.json;
const sessionId = input.sessionId || crypto.randomUUID();

return {
  json: {
    ...input,
    sessionId: sessionId,
    timestamp: new Date().toISOString()
  }
};
```

#### Node 2: Load from Redis
```
Type: Redis
Name: Load Session
Operation: Get
Key: ={{ $json.sessionId }}

Connect your Redis credentials
```

#### Node 3: Merge Context
```
Type: Code
Name: Merge Context

Code:
const currentData = $input.item.json;
let sessionState = {};

try {
  const stored = $('Load Session').item.json.value;
  sessionState = stored ? JSON.parse(stored) : {};
} catch (e) {
  sessionState = {};
}

if (!sessionState.messages) {
  sessionState = {
    messages: [],
    projects: {},
    files: {}
  };
}

sessionState.messages.push({
  role: 'user',
  content: currentData.chatInput,
  timestamp: currentData.timestamp
});

return {
  json: {
    ...currentData,
    sessionState: sessionState
  }
};
```

**Connect:** Chat Input → Init Session → Load Session → Merge Context → (Your existing "Parse Router1" node)

### Step 2: Pass Session Through Pipeline

**Update "Parse Router1" node:**

```javascript
// ADD at the end:
parsed.sessionId = $input.item.json.sessionId;
parsed.sessionState = $input.item.json.sessionState;

return { json: parsed };
```

**Update "Parse Plan1" node:**

```javascript
// ADD at the end:
return {
  json: {
    ...plan,
    sessionId: router.sessionId,
    sessionState: router.sessionState
  }
};
```

**Update "Parse + Merge" node:**

```javascript
// ADD at the end:
return {
  json: {
    ...existing fields...,
    sessionId: data.sessionId,
    sessionState: data.sessionState
  }
};
```

### Step 3: Add File Storage (After "Parse + Merge")

**Add these nodes after your "Parse + Merge" node:**

#### Node A: Split Files
```
Type: Split Out
Name: Split Files
Field to Split: files
```

#### Node B: Save to S3
```
Type: AWS S3
Name: Save Files
Operation: Upload
Bucket: bolt-projects
File Name: ={{ $('Parse + Merge').item.json.sessionId }}/{{ $json.path }}
Binary Data: No
File Content: ={{ $json.content }}

Connect your S3 credentials
```

#### Node C: Aggregate
```
Type: Aggregate
Name: Aggregate Files
```

**Connect:** Parse + Merge → Split Files → Save to S3 → Aggregate → (Your existing "Prep Review" node)

### Step 4: Add Session Update (Before Final Output)

**Add these 2 nodes before "Final Output1":**

#### Node 1: Update Session State
```
Type: Code
Name: Update Session

Code:
const data = $input.item.json;
const sessionState = data.sessionState || { messages: [], projects: {}, files: {} };

const projectId = data.plan.project_name;

// Add AI response
sessionState.messages.push({
  role: 'assistant',
  content: `Created: ${projectId}`,
  timestamp: new Date().toISOString(),
  score: data.score
});

// Store project
sessionState.projects[projectId] = {
  name: projectId,
  stack: data.template.stack,
  files: data.files.map(f => f.path),
  score: data.score,
  created: new Date().toISOString()
};

return {
  json: {
    ...data,
    sessionState: sessionState,
    sessionStateJson: JSON.stringify(sessionState)
  }
};
```

#### Node 2: Save to Redis
```
Type: Redis
Name: Save Session
Operation: Set
Key: ={{ $json.sessionId }}
Value: ={{ $json.sessionStateJson }}
TTL: 86400

Connect your Redis credentials
```

**Connect:** (After "Passed?1" FALSE path) → Update Session → Save to Redis → Prep Deploy

### Step 5: Update Final Output

**Modify "Final Output1" node:**

```javascript
const data = $input.item.json;

const msg = `🎉 **Project Complete!**

📁 **Repo**: https://github.com/Tiagocruz3/${data.repo_name}
🌐 **Live**: ${data.deployment_url || 'Deploying...'}
⭐ **Score**: ${data.review_score}/100
📊 **Session**: ${data.sessionId}

**Files**: ${data.files?.length || 0} | **Stack**: ${data.framework}

💾 Files saved to S3
🔄 Session saved to Redis
`;

return { json: { output: msg, sessionId: data.sessionId } };
```

## 🎨 Visual Connection Diagram

```
[Chat Input]
     ↓
[Init Session] ← NEW
     ↓
[Load Session] ← NEW (Redis)
     ↓
[Merge Context] ← NEW
     ↓
[Parse Router1] ← UPDATED (pass sessionId)
     ↓
... your existing pipeline ...
     ↓
[Parse + Merge] ← UPDATED (include sessionId)
     ↓
[Split Files] ← NEW
     ↓
[Save to S3] ← NEW (S3)
     ↓
[Aggregate] ← NEW
     ↓
[Prep Review]
     ↓
... your existing review ...
     ↓
[Passed?1]
     ↓
[Update Session] ← NEW
     ↓
[Save to Redis] ← NEW (Redis)
     ↓
[Prep Deploy]
     ↓
... rest of pipeline ...
```

## 🔧 Configuration Checklist

### Redis Setup

1. Start Redis:
```bash
docker run -d --name bolt-redis -p 6379:6379 redis:7-alpine
```

2. In n8n:
   - Credentials → Add Credential → Redis
   - Host: `localhost` (or `redis` if in Docker network)
   - Port: `6379`
   - Save as "Redis"

### S3 Setup

1. Create bucket:
```bash
aws s3 mb s3://bolt-projects
```

2. In n8n:
   - Credentials → Add Credential → AWS
   - Access Key ID: your-key
   - Secret Access Key: your-secret
   - Region: us-east-1
   - Save as "AWS S3"

Or use MinIO for local development:
```bash
docker run -d \
  -p 9000:9000 \
  -p 9001:9001 \
  -e "MINIO_ROOT_USER=minioadmin" \
  -e "MINIO_ROOT_PASSWORD=minioadmin" \
  minio/minio server /data --console-address ":9001"
```

## 🧪 Test It

### Test 1: Basic Session
```bash
curl -X POST http://your-n8n/webhook/brainiac-v2 \
  -H "Content-Type: application/json" \
  -d '{
    "chatInput": "Create a simple landing page",
    "sessionId": "test-123"
  }'
```

Check Redis:
```bash
docker exec bolt-redis redis-cli GET test-123
```

### Test 2: Continuation
```bash
curl -X POST http://your-n8n/webhook/brainiac-v2 \
  -H "Content-Type: application/json" \
  -d '{
    "chatInput": "Add a contact form",
    "sessionId": "test-123"
  }'
```

Should remember the previous project!

### Test 3: File Storage
```bash
aws s3 ls s3://bolt-projects/test-123/
```

Should show all generated files!

## 📊 Session Data Structure

After integration, Redis will store:

```json
{
  "messages": [
    {
      "role": "user",
      "content": "Create a landing page",
      "timestamp": "2026-01-07T10:00:00Z"
    },
    {
      "role": "assistant",
      "content": "Created: my-landing-page",
      "timestamp": "2026-01-07T10:00:15Z",
      "score": 92
    }
  ],
  "projects": {
    "my-landing-page": {
      "name": "my-landing-page",
      "stack": "react-vite",
      "files": ["package.json", "src/App.jsx", ...],
      "score": 92,
      "created": "2026-01-07T10:00:15Z"
    }
  },
  "files": {}
}
```

## 🔍 Debugging

### Session not loading?

```javascript
// Add to "Merge Context" node at the start:
console.log('Session loaded:', sessionState);
console.log('Messages count:', sessionState.messages?.length || 0);
```

### Files not saving?

```javascript
// Add to "Save to S3" node error handler:
console.error('S3 Error:', $json);
```

### Check what's stored:

```bash
# Redis
docker exec bolt-redis redis-cli KEYS "*"
docker exec bolt-redis redis-cli GET <sessionId>

# S3
aws s3 ls s3://bolt-projects/ --recursive
```

## 💡 Pro Tips

### 1. Expire Old Sessions

```javascript
// In "Save to Redis" node
TTL: 86400  // 24 hours
// OR
TTL: 604800 // 7 days
```

### 2. Compress Session Data

```javascript
// In "Update Session" node
const compressed = JSON.stringify(sessionState, null, 0); // No whitespace
return { sessionStateJson: compressed };
```

### 3. File Deduplication

```javascript
// In "Save to S3" node, add:
const hash = require('crypto').createHash('md5').update($json.content).digest('hex');
fileName: `={{ $json.sessionId }}/${hash}-{{ $json.path }}`
```

### 4. Partial File Updates

```javascript
// Only save changed files
if (sessionState.files[$json.path]?.content !== $json.content) {
  // Save to S3
}
```

## 🚀 Next Steps

Once this is working:

1. **Add Caching** - Cache template outputs
2. **Add Streaming** - Real-time code generation updates
3. **Add Preview** - Docker-based live preview
4. **Add Export** - ZIP download endpoint
5. **Add Sharing** - Public project URLs

## 📝 Minimal Code Blocks to Copy

### Init Session
```javascript
const input = $input.item.json;
return { json: { ...input, sessionId: input.sessionId || crypto.randomUUID(), timestamp: new Date().toISOString() } };
```

### Merge Context
```javascript
const data = $input.item.json;
let state = {};
try { state = JSON.parse($('Load Session').item.json.value) || {}; } catch {}
if (!state.messages) state = { messages: [], projects: {}, files: {} };
state.messages.push({ role: 'user', content: data.chatInput, timestamp: data.timestamp });
return { json: { ...data, sessionState: state } };
```

### Update Session
```javascript
const data = $input.item.json;
const state = data.sessionState || { messages: [], projects: {}, files: {} };
const pid = data.plan.project_name;
state.messages.push({ role: 'assistant', content: `Created: ${pid}`, score: data.score });
state.projects[pid] = { name: pid, stack: data.template.stack, files: data.files.map(f => f.path), score: data.score };
return { json: { ...data, sessionStateJson: JSON.stringify(state) } };
```

That's it! Your workflow now has persistent storage and session memory while keeping all your great code generation logic intact! 🎉
