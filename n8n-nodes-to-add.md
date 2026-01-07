# N8N Nodes to Add - Copy & Paste Ready

These are the exact node configurations to add to your existing Brainiac workflow.

## 🎯 At the Start (After Chat Input)

### Node 1: Init Session
```json
{
  "parameters": {
    "jsCode": "const input = $input.item.json;\nconst sessionId = input.sessionId || crypto.randomUUID();\n\nreturn {\n  json: {\n    ...input,\n    sessionId: sessionId,\n    timestamp: new Date().toISOString()\n  }\n};"
  },
  "type": "n8n-nodes-base.code",
  "typeVersion": 2,
  "position": [300, 300],
  "name": "Init Session"
}
```

### Node 2: Load Session from Redis
```json
{
  "parameters": {
    "operation": "get",
    "key": "={{ $json.sessionId }}"
  },
  "type": "n8n-nodes-base.redis",
  "typeVersion": 1,
  "position": [500, 300],
  "name": "Load Session",
  "credentials": {
    "redis": {
      "name": "Redis"
    }
  }
}
```

### Node 3: Merge Context
```json
{
  "parameters": {
    "jsCode": "const currentData = $input.item.json;\nlet sessionState = {};\n\ntry {\n  const stored = $('Load Session').item.json.value;\n  sessionState = stored ? JSON.parse(stored) : {};\n} catch (e) {\n  sessionState = {};\n}\n\nif (!sessionState.messages) {\n  sessionState = {\n    messages: [],\n    projects: {},\n    files: {}\n  };\n}\n\nsessionState.messages.push({\n  role: 'user',\n  content: currentData.chatInput,\n  timestamp: currentData.timestamp\n});\n\nreturn {\n  json: {\n    ...currentData,\n    sessionState: sessionState\n  }\n};"
  },
  "type": "n8n-nodes-base.code",
  "typeVersion": 2,
  "position": [700, 300],
  "name": "Merge Context"
}
```

**Connection:** Chat Input → Init Session → Load Session → Merge Context → Parse Router1

## 💾 After "Parse + Merge" Node

### Node 4: Split Files
```json
{
  "parameters": {
    "fieldToSplitOut": "files",
    "options": {}
  },
  "type": "n8n-nodes-base.splitOut",
  "typeVersion": 1,
  "position": [400, 500],
  "name": "Split Files"
}
```

### Node 5: Save to S3
```json
{
  "parameters": {
    "operation": "upload",
    "bucketName": "bolt-projects",
    "fileName": "={{ $('Parse + Merge').item.json.sessionId }}/{{ $json.path }}",
    "binaryData": false,
    "fileContent": "={{ $json.content }}",
    "options": {
      "contentType": "text/plain"
    }
  },
  "type": "n8n-nodes-base.aws.s3",
  "typeVersion": 1,
  "position": [600, 500],
  "name": "Save to S3",
  "credentials": {
    "aws": {
      "name": "AWS S3"
    }
  }
}
```

### Node 6: Aggregate Files
```json
{
  "parameters": {},
  "type": "n8n-nodes-base.aggregate",
  "typeVersion": 1,
  "position": [800, 500],
  "name": "Aggregate Files"
}
```

**Connection:** Parse + Merge → Split Files → Save to S3 → Aggregate Files → Prep Review

## 🔄 Before "Prep Deploy" Node

### Node 7: Update Session State
```json
{
  "parameters": {
    "jsCode": "const data = $input.item.json;\nconst sessionState = data.sessionState || { messages: [], projects: {}, files: {} };\n\nconst projectId = data.plan.project_name;\n\nsessionState.messages.push({\n  role: 'assistant',\n  content: `Created project: ${projectId}`,\n  timestamp: new Date().toISOString(),\n  score: data.score\n});\n\nsessionState.projects[projectId] = {\n  name: projectId,\n  description: data.plan.description,\n  stack: data.template.stack,\n  files: data.files.map(f => f.path),\n  score: data.score,\n  created: new Date().toISOString()\n};\n\nreturn {\n  json: {\n    ...data,\n    sessionState: sessionState,\n    sessionStateJson: JSON.stringify(sessionState)\n  }\n};"
  },
  "type": "n8n-nodes-base.code",
  "typeVersion": 2,
  "position": [1200, 600],
  "name": "Update Session State"
}
```

### Node 8: Save Session to Redis
```json
{
  "parameters": {
    "operation": "set",
    "key": "={{ $json.sessionId }}",
    "value": "={{ $json.sessionStateJson }}",
    "options": {
      "ttl": 86400
    }
  },
  "type": "n8n-nodes-base.redis",
  "typeVersion": 1,
  "position": [1400, 600],
  "name": "Save Session",
  "credentials": {
    "redis": {
      "name": "Redis"
    }
  }
}
```

**Connection:** Passed?1 (FALSE path) → Update Session State → Save Session → Prep Deploy

## ✏️ Code Updates for Existing Nodes

### Update "Parse Router1" (add at end)
```javascript
// ADD THESE LINES:
parsed.sessionId = $input.item.json.sessionId;
parsed.sessionState = $input.item.json.sessionState;

return { json: parsed };
```

### Update "Parse Plan1" (add at end)
```javascript
// ADD THESE LINES:
return {
  json: {
    original_request: router.original_request,
    type: router.type,
    features: router.features,
    plan: plan,
    sessionId: router.sessionId,  // ADD THIS
    sessionState: router.sessionState  // ADD THIS
  }
};
```

### Update "Parse + Merge" (add at end)
```javascript
// ADD THESE LINES:
return {
  json: {
    success: true,
    files: allFiles,
    file_count: allFiles.length,
    generated_count: generatedFiles.length,
    config_count: configFiles.length,
    plan: data.plan,
    template: data.template,
    original_request: data.original_request,
    sessionId: data.sessionId,  // ADD THIS
    sessionState: data.sessionState  // ADD THIS
  }
};
```

### Update "Final Output1" (modify entire function)
```javascript
const data = $input.item.json;

const msg = `🎉 **Project Complete!**

📁 **Repo**: https://github.com/Tiagocruz3/${data.repo_name}
🌐 **Live**: ${data.deployment_url || 'Deploying...'}
⭐ **Score**: ${data.review_score}/100
💾 **Session**: ${data.sessionId || 'N/A'}

**Files**: ${data.files?.length || 0} | **Stack**: ${data.framework}

✅ Files saved to S3
✅ Session saved to Redis (24h)
`;

return {
  json: {
    output: msg,
    sessionId: data.sessionId,
    projectId: data.repo_name
  }
};
```

## 🚀 Quick Import Method

**Method 1: Import via UI**
1. Copy each node JSON above
2. In n8n, click the canvas
3. Press Ctrl+V to paste
4. Connect as described

**Method 2: Import Full Workflow**
1. Save your current workflow (backup!)
2. Open `bolt-diy-enhanced-workflow.json` in a text editor
3. Copy the entire JSON
4. In n8n: Workflows → Import from File → Paste JSON
5. Click Import
6. Update all credential references

**Method 3: Manual Creation (Recommended for first time)**
1. Create each node manually using the n8n UI
2. Set the node type
3. Copy-paste the JavaScript code from above
4. Configure credentials
5. Connect nodes as shown

## 🔗 Connection Summary

```
Chat Input
    ↓
Init Session (NEW)
    ↓
Load Session (NEW - Redis)
    ↓
Merge Context (NEW)
    ↓
Parse Router1 (UPDATED)
    ↓
[your existing pipeline...]
    ↓
Parse + Merge (UPDATED)
    ↓
Split Files (NEW)
    ↓
Save to S3 (NEW - S3)
    ↓
Aggregate Files (NEW)
    ↓
Prep Review
    ↓
5. Reviewer
    ↓
Parse Review1
    ↓
Passed?1
    ├─ TRUE → Prep Deploy → ...
    └─ FALSE → Prep Fixes → 4. Coder (retry)
                ↓
         Update Session State (NEW)
                ↓
         Save Session (NEW - Redis)
                ↓
            Prep Deploy
                ↓
            → GitHub
                ↓
            → Vercel
                ↓
            Final Output1 (UPDATED)
```

## ✅ Verification Checklist

After adding nodes:

- [ ] All 8 new nodes created
- [ ] 3 existing nodes updated
- [ ] Redis credential configured
- [ ] S3/AWS credential configured
- [ ] All connections made
- [ ] No red error indicators
- [ ] Workflow can be saved

## 🧪 Test Command

```bash
curl -X POST http://localhost:5678/webhook-test/brainiac-v2 \
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

Check S3:
```bash
aws s3 ls s3://bolt-projects/test-123/
```

## 💡 Troubleshooting

**"Cannot read property 'value' of undefined"**
- Redis node not connected properly
- Add try-catch in "Merge Context" (already included above)

**"Bucket does not exist"**
- Create bucket: `aws s3 mb s3://bolt-projects`
- Or change bucket name in "Save to S3" node

**"Invalid credentials"**
- Re-enter Redis credentials in n8n
- Test connection in credential modal

**"Split Files not working"**
- Ensure "Parse + Merge" outputs `files` array
- Check field name is exactly "files"

## 📞 Need Help?

If pasting isn't working:
1. Make sure you're in edit mode (not execution)
2. Try creating nodes manually and copy-pasting just the code
3. Check n8n version (needs 1.0+)
4. Verify all required node types are available

The QUICK_INTEGRATION_GUIDE.md has full step-by-step instructions!
