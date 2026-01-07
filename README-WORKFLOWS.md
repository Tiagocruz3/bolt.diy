# 📦 N8N Workflows - Which One to Use?

You now have **3 complete n8n workflow files** in this repo. Here's what each one does and when to use it.

## 🎯 Quick Answer

**Just want to paste and go?**
→ Use `COMPLETE-WORKFLOW-PASTE-READY.json` + `SETUP.md`

**Want to understand everything first?**
→ Read `ENHANCED_WORKFLOW_GUIDE.md`

**Want to add storage to your existing workflow?**
→ Follow `QUICK_INTEGRATION_GUIDE.md` + `n8n-nodes-to-add.md`

---

## 📁 File Guide

### 1. ⭐ COMPLETE-WORKFLOW-PASTE-READY.json (RECOMMENDED)

**What it is:**
Complete, production-ready workflow combining your Brainiac pipeline with storage/sessions.

**When to use:**
- You want a complete solution
- You want to paste and configure quickly
- You're starting fresh

**What you get:**
- ✅ Full AI pipeline (Router → Planner → Coder → Reviewer)
- ✅ Session management (Redis)
- ✅ File storage (S3/MinIO)
- ✅ Quality control with auto-retry
- ✅ 33 nodes, all connected
- ✅ Ready to configure credentials and activate

**Setup time:** 5 minutes

**Setup guide:** `SETUP.md`

**Node count:** 33 nodes

**What to do:**
1. Import JSON to n8n
2. Configure 3 credentials (Redis, S3, OpenRouter)
3. Replace credential IDs
4. Activate
5. Test with curl

---

### 2. 📚 bolt-diy-enhanced-workflow.json (FULL FEATURED)

**What it is:**
Most comprehensive version with extra features and documentation.

**When to use:**
- You want all possible features
- You need extensive documentation
- You want to understand every detail

**What you get:**
- Everything from COMPLETE-WORKFLOW-PASTE-READY
- Plus: Enhanced error handling
- Plus: More detailed system prompts
- Plus: Additional validation steps
- Plus: Better positioning for visual workflow

**Setup time:** 10 minutes

**Setup guide:** `ENHANCED_WORKFLOW_GUIDE.md` (50+ pages)

**Node count:** 35+ nodes

**What to do:**
1. Read ENHANCED_WORKFLOW_GUIDE.md
2. Import JSON to n8n
3. Configure credentials
4. Customize as needed
5. Activate

---

### 3. 🔧 n8n-nodes-to-add.md (INTEGRATION SNIPPETS)

**What it is:**
Individual node configurations to add to your existing workflow.

**When to use:**
- You already have the Brainiac workflow working
- You want to add storage/sessions without starting over
- You prefer manual integration

**What you get:**
- 8 new node configurations (copy-paste ready)
- Code updates for 3 existing nodes
- Step-by-step connection instructions

**Setup time:** 15 minutes

**Setup guide:** `QUICK_INTEGRATION_GUIDE.md`

**What to do:**
1. Open your existing Brainiac workflow
2. Follow QUICK_INTEGRATION_GUIDE.md
3. Add nodes one by one
4. Update existing nodes
5. Test incrementally

---

### 4. 📖 bolt-diy-n8n-workflow.json (ORIGINAL)

**What it is:**
The original n8n workflow I created first (from webhook approach).

**When to use:**
- You want a simpler HTTP webhook approach
- You don't need the langchain chat interface
- You want to build your own frontend

**What you get:**
- HTTP webhook endpoints
- Basic file storage
- No quality review
- Simpler architecture

**Setup time:** 10 minutes

**Setup guide:** `N8N_WORKFLOW_GUIDE.md`

**Note:** This is the first version - use COMPLETE-WORKFLOW-PASTE-READY instead for better features.

---

## 🎯 Comparison Table

| Feature | COMPLETE-WORKFLOW | bolt-diy-enhanced | n8n-nodes-to-add | bolt-diy-original |
|---------|-------------------|-------------------|------------------|-------------------|
| **AI Pipeline** | ✅ Full | ✅ Full | ➕ Add to yours | ⚠️ Basic |
| **Quality Review** | ✅ Opus 4.5 | ✅ Opus 4.5 | ➕ Add to yours | ❌ No |
| **Session Memory** | ✅ Redis | ✅ Redis | ➕ Add to yours | ❌ No |
| **File Storage** | ✅ S3 | ✅ S3 | ➕ Add to yours | ✅ S3 |
| **Chat Interface** | ✅ Langchain | ✅ Langchain | ➕ Use existing | ⚠️ HTTP only |
| **Auto-retry** | ✅ Yes | ✅ Yes | ➕ Add to yours | ❌ No |
| **Documentation** | ⭐ Simple | ⭐⭐⭐ Extensive | ⭐⭐ Detailed | ⭐ Basic |
| **Complexity** | 🟢 Medium | 🟡 High | 🟢 Low | 🟢 Low |
| **Setup Time** | 5 min | 10 min | 15 min | 10 min |
| **Best For** | Quick start | Deep dive | Existing setup | Learning |

---

## 📋 Decision Tree

```
Do you have the Brainiac workflow already?
│
├─ YES → Want to keep it and add storage?
│         └─ Use: n8n-nodes-to-add.md + QUICK_INTEGRATION_GUIDE.md
│
└─ NO → Want a complete solution?
          │
          ├─ Need simple setup?
          │   └─ Use: COMPLETE-WORKFLOW-PASTE-READY.json + SETUP.md
          │
          └─ Want all features + docs?
              └─ Use: bolt-diy-enhanced-workflow.json + ENHANCED_WORKFLOW_GUIDE.md
```

---

## 🚀 Recommended Path

### For Most Users (Fastest)

1. **Start here:** `COMPLETE-WORKFLOW-PASTE-READY.json`
2. **Setup guide:** `SETUP.md`
3. **Time:** 5 minutes
4. **Result:** Working workflow with storage + sessions

### For Advanced Users

1. **Start here:** `bolt-diy-enhanced-workflow.json`
2. **Setup guide:** `ENHANCED_WORKFLOW_GUIDE.md`
3. **Time:** 10 minutes
4. **Result:** Full-featured workflow with deep understanding

### For Existing Brainiac Users

1. **Start here:** `QUICK_INTEGRATION_GUIDE.md`
2. **Node configs:** `n8n-nodes-to-add.md`
3. **Time:** 15 minutes
4. **Result:** Your workflow + storage + sessions

---

## 📚 Documentation Files

### SETUP.md
- **For:** COMPLETE-WORKFLOW-PASTE-READY.json
- **Length:** ~300 lines
- **Covers:** Quick 5-minute setup, troubleshooting, testing

### ENHANCED_WORKFLOW_GUIDE.md
- **For:** bolt-diy-enhanced-workflow.json
- **Length:** ~1000 lines (50+ pages)
- **Covers:** Architecture, examples, API usage, production deployment, cost optimization

### QUICK_INTEGRATION_GUIDE.md
- **For:** Adding to existing workflow
- **Length:** ~500 lines
- **Covers:** Step-by-step integration, code blocks, testing

### n8n-nodes-to-add.md
- **For:** Copy-paste node configs
- **Length:** ~350 lines
- **Covers:** Individual node JSON, connection diagram, troubleshooting

### N8N_WORKFLOW_GUIDE.md
- **For:** Original bolt-diy-n8n-workflow.json
- **Length:** ~800 lines
- **Covers:** Original approach, frontend integration, deployment

### N8N_QUICKSTART.md
- **For:** Docker deployment of original
- **Length:** ~400 lines
- **Covers:** Docker compose setup, quick start

---

## ✅ What They All Have in Common

All workflows include:

- ✅ Your excellent Brainiac AI pipeline
- ✅ Router (classify requests)
- ✅ Planner (architecture design)
- ✅ Template Manager (presets)
- ✅ Coder (Sonnet 4.5 code generation)
- ✅ Reviewer (Opus 4.5 quality control)
- ✅ Fix loop (auto-retry on low scores)

The main differences are:

- Session management (Redis)
- File storage implementation
- Chat vs HTTP interface
- Documentation depth
- Setup complexity

---

## 💡 My Recommendation

**Start with:** `COMPLETE-WORKFLOW-PASTE-READY.json`

**Why:**
1. ✅ Fastest setup (5 minutes)
2. ✅ All core features included
3. ✅ Copy-paste ready
4. ✅ Good documentation
5. ✅ Easy to test
6. ✅ Production-ready

**Then:**
- If you want more details → Read ENHANCED_WORKFLOW_GUIDE.md
- If you want to customize → Modify and experiment
- If you want to integrate → Use QUICK_INTEGRATION_GUIDE.md concepts

---

## 🎯 Example Usage

### Scenario 1: "I just want it working"

```bash
# 1. Start infrastructure
docker run -d --name bolt-redis -p 6379:6379 redis:7-alpine
docker run -d --name bolt-minio -p 9000:9000 -p 9001:9001 \
  -e MINIO_ROOT_USER=minioadmin -e MINIO_ROOT_PASSWORD=minioadmin \
  minio/minio server /data --console-address ":9001"

# 2. Import COMPLETE-WORKFLOW-PASTE-READY.json to n8n

# 3. Configure credentials

# 4. Test
curl -X POST http://localhost:5678/webhook-test/bolt-enhanced \
  -d '{"chatInput":"Create a landing page","sessionId":"test-1"}'
```

### Scenario 2: "I want to understand everything"

1. Read: ENHANCED_WORKFLOW_GUIDE.md (full architecture)
2. Import: bolt-diy-enhanced-workflow.json
3. Configure credentials
4. Explore each node
5. Customize system prompts
6. Test thoroughly

### Scenario 3: "I have Brainiac working already"

1. Read: QUICK_INTEGRATION_GUIDE.md
2. Open your workflow
3. Add nodes from: n8n-nodes-to-add.md
4. Update 3 existing nodes
5. Test incrementally

---

## 🔍 File Sizes

```
COMPLETE-WORKFLOW-PASTE-READY.json    ~45 KB   (33 nodes)
bolt-diy-enhanced-workflow.json       ~52 KB   (35+ nodes)
n8n-nodes-to-add.md                   ~15 KB   (8 node configs)
bolt-diy-n8n-workflow.json            ~38 KB   (30 nodes)
SETUP.md                              ~25 KB   (Simple guide)
ENHANCED_WORKFLOW_GUIDE.md            ~85 KB   (Comprehensive)
QUICK_INTEGRATION_GUIDE.md            ~45 KB   (Step-by-step)
```

---

## 🤝 Support

**Getting stuck?**

1. Check SETUP.md troubleshooting section
2. Check ENHANCED_WORKFLOW_GUIDE.md for detailed explanations
3. Review n8n execution logs
4. Check Redis/S3 connectivity
5. Verify credential IDs are correct

**All good?**

- Start generating projects!
- Experiment with different prompts
- Customize system prompts
- Add your own templates
- Share your results

---

## 🎉 Summary

**TL;DR:**

- **Want quick setup?** → COMPLETE-WORKFLOW-PASTE-READY.json + SETUP.md
- **Want deep dive?** → bolt-diy-enhanced-workflow.json + ENHANCED_WORKFLOW_GUIDE.md
- **Have existing workflow?** → QUICK_INTEGRATION_GUIDE.md + n8n-nodes-to-add.md

All workflows are production-ready and include your excellent code generation pipeline!

Pick one, set it up, and start building! 🚀
