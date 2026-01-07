# Bolt.DIY Enhanced Workflow - Complete Guide

This workflow combines the sophisticated code generation pipeline from your Brainiac workflow with persistent storage, session management, and execution capabilities.

## 🎯 What's New

### From Your Workflow (Kept & Enhanced)
✅ **Router Agent** - Smart request classification
✅ **Planner Agent** - Detailed project architecture
✅ **Template Manager** - Pre-built stack templates
✅ **Coder Agent** - Production code generation (Claude Sonnet 4.5)
✅ **Reviewer Agent** - Quality control (Claude Opus 4.5)
✅ **Fix Loop** - Automatic code improvements

### New Additions
🆕 **Session Management** - Persistent conversation history via Redis
🆕 **File Storage** - S3/MinIO for permanent file storage
🆕 **Project State** - Track multiple projects per session
🆕 **Conversation Context** - Multi-turn conversations with memory
🆕 **Enhanced Templates** - More stacks and design presets

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  Chat Input (Webhook)                                       │
│  - User message + sessionId                                 │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│  Session Layer (NEW)                                        │
│  ┌──────────────┐  ┌──────────────┐  ┌─────────────────┐  │
│  │ Init Session │→ │ Load  Redis  │→ │ Merge  Context  │  │
│  └──────────────┘  └──────────────┘  └─────────────────┘  │
│  - Create or resume session                                 │
│  - Load conversation history                                │
│  - Maintain project state                                   │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│  AI Pipeline (Your Workflow - Enhanced)                     │
│                                                               │
│  1️⃣  Router (Haiku)                                         │
│      ├─ Classify request type                               │
│      ├─ Detect stack and complexity                         │
│      └─ Check if clarification needed                       │
│                                                               │
│  2️⃣  Planner (GPT-4)                                        │
│      ├─ Design system specification                         │
│      ├─ File tree structure                                 │
│      ├─ Component architecture                              │
│      └─ Build order                                          │
│                                                               │
│  3️⃣  Template Manager (Code)                                │
│      ├─ Select stack templates                              │
│      ├─ Apply color presets                                 │
│      ├─ Detect page type                                    │
│      └─ Generate config files                               │
│                                                               │
│  4️⃣  Coder (Sonnet 4.5)                                     │
│      ├─ Generate production code                            │
│      ├─ Follow design system                                │
│      ├─ Real content (no Lorem)                             │
│      └─ Full interactivity                                  │
│                                                               │
│  5️⃣  Reviewer (Opus 4.5)                                    │
│      ├─ Check for critical issues                           │
│      ├─ Validate responsiveness                             │
│      ├─ Score code quality                                  │
│      └─ Generate fix recommendations                        │
│                                                               │
│  🔁  Fix Loop (max 2 retries)                               │
│      └─ If score < 70: Return to Coder with fixes          │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│  Storage Layer (NEW)                                        │
│  ┌──────────────┐  ┌──────────────┐  ┌─────────────────┐  │
│  │  Split Files │→ │ Save to S3   │→ │ Update Session  │  │
│  └──────────────┘  └──────────────┘  └─────────────────┘  │
│  - Store each file in S3                                    │
│  - Update project metadata                                  │
│  - Save conversation state                                  │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│  Deployment (Your Sub-Workflows)                            │
│  ┌──────────────┐  ┌──────────────┐  ┌─────────────────┐  │
│  │ Prep Deploy  │→ │ → GitHub     │→ │ → Vercel        │  │
│  └──────────────┘  └──────────────┘  └─────────────────┘  │
│  - Create GitHub repo                                       │
│  - Push code                                                │
│  - Deploy to Vercel                                         │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│  Final Output                                               │
│  - Project summary                                          │
│  - GitHub URL                                               │
│  - Live deployment URL                                      │
│  - Quality score                                            │
└─────────────────────────────────────────────────────────────┘
```

## 🔄 Session State Structure

```json
{
  "messages": [
    {
      "role": "user|assistant",
      "content": "Message text",
      "timestamp": "2026-01-07T10:30:00Z",
      "project": "my-project",
      "score": 85,
      "files": 12
    }
  ],
  "projects": {
    "my-landing-page": {
      "name": "my-landing-page",
      "description": "Modern landing page",
      "stack": "react-vite",
      "created": "2026-01-07T10:30:00Z",
      "files": ["package.json", "src/App.jsx", ...],
      "score": 85,
      "review": {...}
    }
  },
  "files": {
    "my-landing-page/package.json": {
      "content": "{...}",
      "size": 423,
      "type": "config",
      "updated": "2026-01-07T10:30:00Z"
    }
  },
  "currentProject": "my-landing-page"
}
```

## 🎨 Enhanced Template System

### Supported Stacks

**react-vite** (Default)
- Vite + React 18
- TailwindCSS + PostCSS
- Framer Motion
- Lucide React icons
- Fast HMR

**html-tailwind**
- Standalone HTML
- Tailwind CDN
- No build step
- Perfect for simple sites

**nextjs**
- Next.js 14
- App Router
- Server Components
- Built-in optimization

### Design Presets

**dark-blue** (Default)
```js
{
  primary: '#3b82f6',
  secondary: '#60a5fa',
  gradient: 'from-blue-400 to-violet-400'
}
```

**dark-purple**
```js
{
  primary: '#8b5cf6',
  secondary: '#a78bfa',
  gradient: 'from-purple-400 to-pink-400'
}
```

**dark-emerald**
```js
{
  primary: '#10b981',
  secondary: '#34d399',
  gradient: 'from-emerald-400 to-cyan-400'
}
```

**dark-amber**
```js
{
  primary: '#f59e0b',
  secondary: '#fbbf24',
  gradient: 'from-amber-400 to-orange-400'
}
```

### Page Types

**landing** - Marketing/product pages
- Navbar, Hero, Features, Testimonials, Pricing, CTA, Footer

**dashboard** - Admin/analytics interfaces
- Sidebar, Header, Stats, Charts, Tables
- Includes: recharts library

**portfolio** - Personal/professional sites
- Projects showcase, Skills, Experience, Contact

**saas** - SaaS product pages
- Features, Integrations, How It Works, FAQ

**blog** - Content/publication sites
- Article list, Categories, Newsletter

**ecommerce** - Online stores
- Product grid, Categories, Reviews
- Includes: @headlessui/react

## 📝 Example Usage

### Example 1: New Landing Page

**Input:**
```
Create a modern SaaS landing page with purple theme
```

**Router Output:**
```json
{
  "type": "new_project",
  "complexity": "medium",
  "stack": "react-vite",
  "features": ["dark-mode", "animations"],
  "summary": "Modern SaaS landing page with purple theme"
}
```

**Plan Output:**
```json
{
  "project_name": "saas-landing-purple",
  "tech_stack": {
    "framework": "react-vite",
    "styling": "tailwind"
  },
  "design_system": {
    "theme": "dark",
    "primary_color": "#8b5cf6",
    "style": "glassmorphism"
  }
}
```

**Template Manager:**
- Detects: `pageType = "saas"`, `preset = "dark-purple"`
- Generates: package.json, vite.config.js, tailwind.config.js
- Sections: Navbar, Hero, Features, Integrations, Pricing, FAQ, CTA

**Coder Output:**
```
===FILE: src/components/Hero.jsx===
import { motion } from 'framer-motion';
import { ArrowRight, Sparkles } from 'lucide-react';

export default function Hero() {
  return (
    <section className="relative min-h-screen flex items-center justify-center overflow-hidden">
      {/* Gradient Background */}
      <div className="absolute inset-0 bg-[radial-gradient(ellipse_at_top,rgba(139,92,246,0.15),transparent_50%)]" />

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="text-center"
        >
          <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-purple-500/10 border border-purple-500/20 mb-6">
            <Sparkles className="w-4 h-4 text-purple-400" />
            <span className="text-sm text-purple-300">New Feature Released</span>
          </div>

          <h1 className="text-5xl md:text-6xl lg:text-7xl font-bold tracking-tight mb-6">
            Build Something
            <span className="bg-gradient-to-r from-purple-400 to-pink-400 bg-clip-text text-transparent"> Extraordinary</span>
          </h1>

          <p className="text-xl text-zinc-400 mb-8 max-w-2xl mx-auto">
            The modern platform for building exceptional SaaS products. Ship faster, scale better, delight users.
          </p>

          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <motion.button
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
              className="px-8 py-4 bg-purple-600 hover:bg-purple-500 text-white font-medium rounded-xl transition-all flex items-center justify-center gap-2"
            >
              Start Free Trial
              <ArrowRight className="w-5 h-5" />
            </motion.button>

            <button className="px-8 py-4 bg-zinc-900 hover:bg-zinc-800 border border-zinc-800 hover:border-zinc-700 text-white font-medium rounded-xl transition-all">
              Watch Demo
            </button>
          </div>
        </motion.div>
      </div>
    </section>
  );
}
===END FILE===
```

**Review Output:**
```json
{
  "verdict": "PASS",
  "score": 92,
  "summary": "Excellent implementation with proper animations, responsive design, and clean code structure.",
  "critical_issues": [],
  "major_issues": [],
  "strengths": [
    "Beautiful gradient effects",
    "Smooth Framer Motion animations",
    "Fully responsive layout",
    "Excellent use of design tokens"
  ]
}
```

**Final Output:**
```
## 🎉 Project Complete!

**saas-landing-purple**
Modern SaaS landing page with purple theme

### 📊 Stats
- **Score**: 92/100
- **Files**: 14
- **Stack**: react-vite

### 🔗 Links
- **GitHub**: https://github.com/Tiagocruz3/saas-landing-purple
- **Live**: https://saas-landing-purple.vercel.app

### ✨ Strengths
- Beautiful gradient effects
- Smooth Framer Motion animations
- Fully responsive layout
```

### Example 2: Modify Existing Project

**Input:**
```
Add a pricing section with 3 tiers
```

**Router Output:**
```json
{
  "type": "modify_existing",
  "modifies_existing": true,
  "target_files": ["src/App.jsx"],
  "features": ["pricing"]
}
```

**Session Context:**
- Loads current project: `saas-landing-purple`
- Retrieves existing files from session state
- Understands project structure

**Coder Output:**
```
===FILE: src/components/Pricing.jsx===
[New pricing component with 3 tiers]
===END FILE===

===FILE: src/App.jsx===
[Updated App.jsx with Pricing import]
===END FILE===
```

## 🔧 Setup Instructions

### 1. Prerequisites

```bash
# Required services
- n8n (1.0+)
- Redis
- AWS S3 or MinIO
- OpenRouter API key (or direct LLM API keys)
```

### 2. Configure Credentials

**Redis**
```
Host: redis
Port: 6379
Database: 0
```

**AWS S3**
```
Access Key: your-access-key
Secret Key: your-secret-key
Region: us-east-1
Bucket: bolt-projects
```

**OpenRouter**
```
API Key: your-openrouter-key
```

### 3. Import Workflow

```bash
# In n8n UI
1. Workflows → Import from File
2. Select: bolt-diy-enhanced-workflow.json
3. Click Import
```

### 4. Update Node Credentials

Replace placeholder IDs:
- All Redis nodes → Your Redis credential
- All S3 nodes → Your S3 credential
- All OpenRouter nodes → Your OpenRouter credential

### 5. Connect Sub-Workflows

Replace these NoOp nodes with your existing workflows:

**→ GitHub Deploy**
```
Type: Execute Workflow
Workflow: Your GitHub deployment workflow
Pass: repo_name, files, commit_message
```

**→ Vercel Deploy**
```
Type: Execute Workflow
Workflow: Your Vercel deployment workflow
Pass: repo_name, framework, build_command
```

### 6. Activate Workflow

Toggle "Active" switch

## 🚀 API Usage

### Chat Endpoint

```bash
curl -X POST http://your-n8n/webhook/bolt-enhanced \
  -H "Content-Type: application/json" \
  -d '{
    "chatInput": "Create a portfolio website with dark theme",
    "sessionId": "user-123"
  }'
```

**Response:**
```json
{
  "output": "## 🎉 Project Complete!\n\n**portfolio-dark**...",
  "sessionId": "user-123",
  "projectId": "portfolio-dark"
}
```

### Session Continuity

```bash
# First message
curl ... -d '{"chatInput": "Create a landing page", "sessionId": "user-123"}'

# Follow-up (same session)
curl ... -d '{"chatInput": "Add a contact form", "sessionId": "user-123"}'
```

The workflow remembers:
- Previous projects
- Conversation history
- Project files
- Design decisions

## 📊 Quality Control

### Review Scoring

**Base: 100 points**

**Deductions:**
- Critical issue: Auto-FAIL (missing imports, runtime errors)
- Major issue: -15 points (no hover states, not responsive)
- Minor issue: -5 points (design inconsistency, missing ARIA)
- Warning: -2 points (unused imports, TODOs)

**Bonuses:**
- Exceptional quality: +5
- Extra features: +3
- Perfect a11y: +2

### Verdict Logic

| Score | Verdict | Action |
|-------|---------|--------|
| 80+ | PASS | Deploy immediately |
| 70-79 | PASS_WITH_WARNINGS | Deploy with notes |
| <70 or Critical | FAIL | Retry with fixes (max 2x) |

### Fix Loop

```
Generate Code → Review → Score < 70?
                           │
                           ├─ Yes → Prep Fixes → Regenerate (retry++)
                           │
                           └─ No → Continue to Deploy
```

Max retries: 2
After 2 failures: Deploy anyway with warnings

## 🎯 Best Practices

### For Users

**Be Specific:**
```
❌ "Create a website"
✅ "Create a SaaS landing page with purple theme, pricing section, and testimonials"
```

**Provide Context:**
```
❌ "Add authentication"
✅ "Add authentication using the existing design system with glass cards"
```

**Use Sessions:**
```
// Reuse sessionId for related work
const sessionId = "project-abc-123";
```

### For Developers

**Credential Security:**
- Use n8n's encrypted credential storage
- Never expose API keys in responses
- Rotate keys regularly

**Error Handling:**
- All critical nodes have error fallbacks
- Review parser has try-catch with defaults
- S3 upload failures are logged

**Performance:**
- Redis TTL: 24 hours (adjust as needed)
- S3 objects use standard storage class
- Large files (>10MB) should be chunked

## 🔍 Monitoring

### Redis Inspection

```bash
# Connect to Redis
docker exec -it bolt-redis redis-cli

# View session
GET user-123

# List all sessions
KEYS *

# Check TTL
TTL user-123
```

### S3 File Inspection

```bash
# List files for session
aws s3 ls s3://bolt-projects/user-123/

# Download project
aws s3 sync s3://bolt-projects/user-123/my-project ./my-project
```

### Workflow Execution

In n8n UI:
1. Go to "Executions"
2. Filter by workflow
3. Click execution to see:
   - Input/output of each node
   - Execution time
   - Errors/warnings

## 🆚 Comparison: Original vs Enhanced

| Feature | Original Bolt Workflow | Your Workflow | Enhanced Workflow |
|---------|----------------------|---------------|-------------------|
| **Code Generation** | Basic | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Quality Control** | None | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Session Memory** | None | None | ⭐⭐⭐⭐⭐ |
| **File Storage** | Temporary | None | ⭐⭐⭐⭐⭐ |
| **Templates** | Basic | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Conversation** | Single-turn | Single-turn | Multi-turn |
| **Project Tracking** | No | No | Yes |
| **Fix Loop** | No | Yes | Yes |
| **Deployment** | Manual | Automated | Automated |
| **Cost** | Low | Medium | Medium |

## 💰 Cost Estimation

### LLM API Costs (per project)

**Router** (Haiku): ~$0.001
**Planner** (GPT-4): ~$0.05
**Coder** (Sonnet 4.5): ~$0.20
**Reviewer** (Opus 4.5): ~$0.15
**Fixes** (if needed): ~$0.20

**Average per project**: $0.40-$0.60

### Infrastructure (monthly)

**Redis Cloud** (100MB): Free
**AWS S3** (10GB): ~$0.30
**n8n Cloud** (Starter): $20

**Total**: ~$20-25/month + LLM costs

### Optimization Tips

1. **Use cheaper models for simple tasks:**
   ```
   Router: claude-haiku ✓
   Planner: gpt-4o-mini (instead of gpt-4)
   Coder: claude-sonnet-3.5 (instead of 4.5)
   ```

2. **Cache common responses:**
   - Store template outputs in Redis
   - Reuse component library

3. **Limit context size:**
   - Review only first 15 files
   - Truncate file content to 2000 chars

## 🐛 Troubleshooting

### Session Not Loading

**Symptom:** Workflow doesn't remember previous conversation

**Fix:**
```bash
# Check Redis connection
docker exec bolt-redis redis-cli ping
# Should return: PONG

# Verify key exists
redis-cli GET <sessionId>
```

### Files Not Saving to S3

**Symptom:** S3 node fails with 403

**Fix:**
1. Verify S3 credentials in n8n
2. Check bucket policy allows PutObject
3. Ensure bucket name matches

### Review Fails to Parse

**Symptom:** Review always returns default score

**Fix:**
- Check Reviewer system prompt
- Increase maxTokens if output is truncated
- Add error logging to parse node

### Code Quality Low

**Symptom:** Projects consistently score < 70

**Fix:**
1. Enhance Coder system prompt with more examples
2. Increase temperature slightly (0.2 → 0.3)
3. Add more specific design system rules
4. Review template quality

## 🚀 Advanced Features

### Custom Templates

Add your own stack:

```javascript
// In Template Manager node
TEMPLATES.stacks['vue-vite'] = {
  'package.json': (vars) => JSON.stringify({
    dependencies: {
      'vue': '^3.3.0',
      ...
    }
  }),
  'vite.config.js': `...`,
  ...
};
```

### Deployment Platforms

Add Netlify, Cloudflare Pages:

```javascript
// After Vercel Deploy node
{
  "name": "→ Netlify Deploy",
  "type": "n8n-nodes-base.executeWorkflow",
  "parameters": {
    "workflowId": "netlify-deploy-workflow"
  }
}
```

### Custom Review Criteria

Modify reviewer scoring:

```javascript
// In Reviewer system prompt
"Custom Rules:
- Must use TypeScript: -20 if not
- Must have tests: -10 if missing
- Must have README: -5 if missing"
```

## 📚 Resources

- [n8n Documentation](https://docs.n8n.io)
- [OpenRouter Models](https://openrouter.ai/models)
- [Tailwind CSS](https://tailwindcss.com)
- [Framer Motion](https://www.framer.com/motion)
- [Lucide Icons](https://lucide.dev)

## 🤝 Contributing

Improvements welcome! Key areas:
- [ ] More stack templates (Vue, Svelte, Angular)
- [ ] Additional page types (docs, blog, ecommerce)
- [ ] Better error recovery
- [ ] Streaming responses
- [ ] Real-time preview
- [ ] GitHub/GitLab integration
- [ ] Database schema generation
- [ ] API endpoint generation

## 📄 License

MIT License - Free to use and modify
