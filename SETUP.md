# Complete Workflow - Setup Guide

This is your complete, production-ready workflow combining the best of your Brainiac pipeline with persistent storage and session management.

## 🚀 Quick Start (5 Minutes)

### Step 1: Start Infrastructure

```bash
# 1. Redis (Session Storage)
docker run -d --name bolt-redis -p 6379:6379 redis:7-alpine

# 2. MinIO (File Storage - S3 Compatible)
docker run -d --name bolt-minio \
  -p 9000:9000 -p 9001:9001 \
  -e "MINIO_ROOT_USER=minioadmin" \
  -e "MINIO_ROOT_PASSWORD=minioadmin" \
  minio/minio server /data --console-address ":9001"

# 3. Create MinIO Bucket
docker run --rm --network host \
  minio/mc alias set myminio http://localhost:9000 minioadmin minioadmin && \
  minio/mc mb myminio/bolt-projects
```

**Verify:**
- Redis: `docker exec bolt-redis redis-cli ping` → Should return "PONG"
- MinIO: Open http://localhost:9001 → Login with minioadmin/minioadmin

### Step 2: Import Workflow to n8n

**Method 1: Import via UI (Recommended)**

1. Open n8n
2. Click "Workflows" → "Import from File"
3. Select `COMPLETE-WORKFLOW-PASTE-READY.json`
4. Click "Import"

**Method 2: Copy-Paste**

1. Open `COMPLETE-WORKFLOW-PASTE-READY.json` in text editor
2. Copy entire contents (Ctrl+A, Ctrl+C)
3. In n8n: Workflows → Import from URL
4. Paste JSON and click Import

### Step 3: Configure Credentials

The workflow needs 3 credentials:

#### A. Redis Credential

1. In n8n: Settings → Credentials → Add Credential
2. Search for "Redis"
3. Fill in:
   - **Host**: `localhost` (or `redis` if n8n is in Docker)
   - **Port**: `6379`
   - **Password**: (leave empty)
   - **Database**: `0`
4. Click "Save"
5. **Copy the credential ID** (you'll need it)

#### B. AWS S3 Credential (MinIO)

1. Settings → Credentials → Add Credential
2. Search for "AWS"
3. Fill in:
   - **Access Key ID**: `minioadmin`
   - **Secret Access Key**: `minioadmin`
   - **Region**: `us-east-1`
   - **Custom S3 Endpoint**: `http://localhost:9000`
   - **Force Path Style**: `true`
4. Click "Save"
5. **Copy the credential ID**

#### C. OpenRouter Credential

1. Settings → Credentials → Add Credential
2. Search for "OpenRouter"
3. Fill in:
   - **API Key**: Your OpenRouter API key
   - Get one free at: https://openrouter.ai
4. Click "Save"
5. **Copy the credential ID**

### Step 4: Update Credential References

In the workflow, find and replace these placeholder IDs:

**Find these nodes and update:**

1. **Load Session** node
   - Replace: `"id": "YOUR_REDIS_CREDENTIAL_ID"`
   - With: Your Redis credential ID

2. **Save Session** node
   - Replace: `"id": "YOUR_REDIS_CREDENTIAL_ID"`
   - With: Your Redis credential ID

3. **Save to S3** node
   - Replace: `"id": "YOUR_AWS_S3_CREDENTIAL_ID"`
   - With: Your AWS/MinIO credential ID

4. **Router Model** node
   - Replace: `"id": "YOUR_OPENROUTER_CREDENTIAL_ID"`
   - With: Your OpenRouter credential ID

5. **Planner Model** node
   - Replace: `"id": "YOUR_OPENROUTER_CREDENTIAL_ID"`
   - With: Your OpenRouter credential ID

6. **Coder Model** node
   - Replace: `"id": "YOUR_OPENROUTER_CREDENTIAL_ID"`
   - With: Your OpenRouter credential ID

7. **Reviewer Model** node
   - Replace: `"id": "YOUR_OPENROUTER_CREDENTIAL_ID"`
   - With: Your OpenRouter credential ID

**Quick Replace:**
- In n8n UI, use the search function (Ctrl+F)
- Search for: `YOUR_REDIS_CREDENTIAL_ID`
- Replace all with your Redis credential ID
- Repeat for `YOUR_AWS_S3_CREDENTIAL_ID` and `YOUR_OPENROUTER_CREDENTIAL_ID`

### Step 5: Connect Your Deploy Workflows

Replace these NoOp nodes with your actual deployment workflows:

**→ GitHub** node:
```json
{
  "type": "n8n-nodes-base.executeWorkflow",
  "parameters": {
    "workflowId": "YOUR_GITHUB_WORKFLOW_ID"
  }
}
```

**→ Vercel** node:
```json
{
  "type": "n8n-nodes-base.executeWorkflow",
  "parameters": {
    "workflowId": "YOUR_VERCEL_WORKFLOW_ID"
  }
}
```

Or leave them as NoOp if you don't have deployment workflows yet.

### Step 6: Activate Workflow

1. Click the "Active" toggle in the top-right
2. Should turn green ✅

## 🧪 Test It!

### Test 1: Basic Project Generation

```bash
curl -X POST http://localhost:5678/webhook-test/bolt-enhanced \
  -H "Content-Type: application/json" \
  -d '{
    "chatInput": "Create a modern landing page with blue theme",
    "sessionId": "test-alice"
  }'
```

**Expected Response:**
```
🎉 **Project Complete!**

📁 **Repo**: https://github.com/Tiagocruz3/modern-landing-blue
🌐 **Live**: Deploying...
⭐ **Score**: 85/100
💾 **Session**: test-alice

**Files**: 12 | **Stack**: vite

✅ Files saved to S3
✅ Session saved to Redis
```

### Test 2: Session Continuity

```bash
curl -X POST http://localhost:5678/webhook-test/bolt-enhanced \
  -H "Content-Type: application/json" \
  -d '{
    "chatInput": "Add a pricing section with 3 tiers",
    "sessionId": "test-alice"
  }'
```

Should remember the previous project!

### Test 3: Verify Storage

**Redis (Session Data):**
```bash
docker exec bolt-redis redis-cli GET test-alice
```

Should show JSON with messages and projects.

**S3 (Files):**
```bash
# Using MinIO client
docker run --rm --network host \
  minio/mc ls myminio/bolt-projects/test-alice/
```

Should list all generated files!

## ✅ Verification Checklist

- [ ] Redis running and accessible
- [ ] MinIO running and bucket created
- [ ] Workflow imported to n8n
- [ ] All 3 credentials configured
- [ ] All credential IDs updated in workflow
- [ ] Workflow activated (green toggle)
- [ ] Test request successful
- [ ] Files visible in MinIO
- [ ] Session data in Redis

## 🎯 What This Workflow Does

### 1. Session Management
- ✅ Remembers conversation history (24h)
- ✅ Tracks multiple projects per user
- ✅ Enables follow-up requests ("add a feature")

### 2. AI Pipeline
- ✅ Router: Classifies request (Haiku)
- ✅ Planner: Creates architecture (GPT-4)
- ✅ Template Manager: Applies presets
- ✅ Coder: Generates production code (Sonnet 4.5)
- ✅ Reviewer: Quality control (Opus 4.5)

### 3. File Storage
- ✅ Saves all files to S3/MinIO
- ✅ Persistent (survives workflow restarts)
- ✅ Retrievable via S3 API

### 4. Quality Control
- ✅ Automatic review (score 0-100)
- ✅ Fix loop (max 2 retries)
- ✅ Critical issue detection

## 📊 Cost Estimate

**LLM API (per project):**
- Router (Haiku): ~$0.001
- Planner (GPT-4 mini): ~$0.02
- Coder (Sonnet 4.5): ~$0.20
- Reviewer (Opus 4.5): ~$0.15
- **Total**: ~$0.37 per project

**Infrastructure (self-hosted):**
- Redis: Free (Docker)
- MinIO: Free (Docker)
- n8n: Free (self-hosted)

**Or Cloud:**
- Redis Cloud: Free tier (50MB)
- AWS S3: ~$0.02/GB/month
- n8n Cloud: $20/month

## 🔧 Troubleshooting

### Workflow won't import
- **Issue**: JSON parse error
- **Fix**: Make sure you copied the entire file
- **Fix**: Try importing as file instead of paste

### Can't connect to Redis
- **Issue**: "ECONNREFUSED 127.0.0.1:6379"
- **Fix**: Check Redis is running: `docker ps | grep redis`
- **Fix**: If n8n is in Docker, use host: `redis` or `host.docker.internal`

### S3 upload fails
- **Issue**: "Access Denied" or "Bucket not found"
- **Fix**: Create bucket: `mc mb myminio/bolt-projects`
- **Fix**: Check MinIO is running: `docker ps | grep minio`
- **Fix**: Verify credentials are correct

### No response from LLM
- **Issue**: OpenRouter API error
- **Fix**: Check API key is valid
- **Fix**: Check you have credits: https://openrouter.ai/credits
- **Fix**: Try a different model (cheaper alternative)

### Session not persisting
- **Issue**: Workflow doesn't remember previous conversation
- **Fix**: Verify Redis credential is attached to both Load and Save nodes
- **Fix**: Check TTL is set to 86400 (24h)
- **Fix**: Verify sessionId is being passed through all nodes

### Files not in S3
- **Issue**: Upload succeeds but files not visible
- **Fix**: Check correct bucket: `bolt-projects`
- **Fix**: Check path format: `{sessionId}/{filename}`
- **Fix**: Verify in MinIO console: http://localhost:9001

## 🚀 Production Deployment

For production use:

1. **Use Real AWS S3** instead of MinIO
2. **Use Redis Cloud** or managed Redis
3. **Use n8n Cloud** or properly secured n8n instance
4. **Add authentication** to webhook endpoint
5. **Set up monitoring** (n8n execution logs)
6. **Configure backups** for Redis and S3
7. **Add rate limiting** to prevent abuse
8. **Use environment variables** for credentials

## 📚 What's Next?

Once this is working:

1. **Add Streaming** - Real-time code generation updates
2. **Add Preview** - Docker-based live preview
3. **Add Export** - ZIP download endpoint
4. **Add Analytics** - Track usage and costs
5. **Add Templates** - More stacks and presets

## 💡 Pro Tips

### Reduce LLM Costs

```
Router: anthropic/claude-3-haiku (keep)
Planner: openai/gpt-4o-mini (instead of gpt-4o)
Coder: anthropic/claude-3-5-sonnet (instead of sonnet-4-5)
Reviewer: Skip or use Sonnet instead of Opus
```

### Speed Up Generation

- Cache template outputs in Redis
- Skip review for simple projects
- Use parallel LLM calls where possible

### Improve Quality

- Add more examples to Coder system prompt
- Increase maxTokens for complex projects
- Add project-specific templates

## 📞 Need Help?

1. Check n8n Execution logs
2. Check Redis data: `redis-cli GET <sessionId>`
3. Check S3 files: MinIO console
4. Review ENHANCED_WORKFLOW_GUIDE.md for details
5. Check QUICK_INTEGRATION_GUIDE.md for integration tips

All documentation is in the repo!
