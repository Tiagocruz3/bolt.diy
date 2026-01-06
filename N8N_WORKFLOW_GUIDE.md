# Bolt.DIY n8n Workflow - Complete Guide

This n8n workflow replicates the core functionality of bolt.diy - an AI-powered web development assistant that can generate, modify, and manage web applications through natural language conversations.

## Overview

The workflow provides three main endpoints:

1. **Chat Endpoint** (`/chat`) - Main interface for AI-powered development
2. **Files Endpoint** (`/files/:sessionId`) - Retrieve project files
3. **Deploy Endpoint** (`/deploy/:platform`) - Deploy to Vercel/Netlify

## Architecture

```
User Request → Chat Webhook → Load Context → LLM Processing →
Parse Actions → Execute Actions → Update State → Return Response
```

### Key Components

#### 1. Session Management (Redis)
- Stores conversation history
- Maintains project file state
- Tracks dev server status
- TTL: 24 hours

#### 2. LLM Integration
- **Supported Providers**: OpenAI, Anthropic (extensible to others)
- **Model Selection**: Per-request model switching
- **Context**: Last 10 messages + file context

#### 3. Action Execution System
Parses AI responses for structured actions:

**File Actions** (`<boltAction type="file">`)
- Creates/updates files in cloud storage (S3)
- Updates session file state
- Supports any file type

**Shell Actions** (`<boltAction type="shell">`)
- Executes commands in isolated Docker containers
- Captures stdout/stderr
- Maintains command history

**Start Actions** (`<boltAction type="start">`)
- Launches dev servers (Vite, Next.js, etc.)
- Runs in background with port mapping
- Tracks preview URLs

**Build Actions** (`<boltAction type="build">`)
- Runs build commands
- Captures build output

#### 4. Storage Layer
- **Primary**: AWS S3 (or compatible: MinIO, Wasabi, etc.)
- **Structure**: `bolt-projects/<sessionId>/<filePath>`
- **Alternatives**: Could use local filesystem, Google Cloud Storage, etc.

## Prerequisites

### Required Services

1. **n8n Instance** (self-hosted or cloud)
   - Version: 1.0+
   - Required nodes: webhook, code, http request, redis, aws.s3

2. **Redis Server**
   - For session state management
   - Any version supporting basic GET/SET operations

3. **Cloud Storage** (choose one)
   - AWS S3 (recommended)
   - MinIO (self-hosted S3 alternative)
   - Google Cloud Storage
   - Any S3-compatible service

4. **Docker** (for code execution)
   - Required for shell and start actions
   - n8n instance must have Docker access

5. **LLM API Keys** (choose one or more)
   - OpenAI API key
   - Anthropic API key
   - Or other providers as needed

## Setup Instructions

### 1. Import Workflow

```bash
# In n8n UI:
# 1. Go to Workflows > Import from File
# 2. Select bolt-diy-n8n-workflow.json
# 3. Click Import
```

### 2. Configure Credentials

#### Redis Credentials
```
Name: Redis Connection
Type: Redis
Host: your-redis-host
Port: 6379
Password: your-redis-password (if applicable)
Database: 0
```

#### AWS S3 Credentials
```
Name: AWS S3
Type: AWS
Access Key ID: your-access-key
Secret Access Key: your-secret-key
Region: us-east-1 (or your region)
```

Or for MinIO:
```
Name: MinIO Storage
Type: AWS (use S3-compatible mode)
Access Key: minioadmin
Secret: minioadmin
Endpoint: http://your-minio-host:9000
```

#### OpenAI Credentials
```
Name: OpenAI API
Type: OpenAI
API Key: sk-...
```

#### Anthropic Credentials
```
Name: Anthropic API
Type: Anthropic
API Key: sk-ant-...
```

#### Vercel/Netlify (Optional)
```
Name: Vercel API Token
Type: Header Auth
Header Name: Authorization
Header Value: Bearer your-vercel-token
```

### 3. Create S3 Bucket

```bash
# AWS CLI
aws s3 mb s3://bolt-projects

# Or MinIO client
mc mb myminio/bolt-projects
```

### 4. Update Node Configurations

Replace placeholder credential IDs in these nodes:
- `Load Session Context` → Redis credentials
- `Save Session Context` → Redis credentials
- `Save File (S3/Storage)` → AWS credentials
- `List Session Files` → AWS credentials
- `OpenAI` → OpenAI credentials
- `Anthropic` → Anthropic credentials
- `Deploy to Vercel` → Vercel credentials (optional)
- `Deploy to Netlify` → Netlify credentials (optional)

### 5. Activate Workflow

Click the "Active" toggle in the n8n UI.

## API Usage

### Chat Endpoint

**Request:**
```bash
curl -X POST http://your-n8n-instance/webhook/chat \
  -H "Content-Type: application/json" \
  -d '{
    "sessionId": "unique-session-id",
    "message": "Create a React app with a counter component",
    "provider": "openai",
    "model": "gpt-4"
  }'
```

**Response:**
```json
{
  "message": "I'll create a React app with a counter component...",
  "actions": [
    {
      "type": "file",
      "filePath": "package.json",
      "success": true
    },
    {
      "type": "file",
      "filePath": "src/App.jsx",
      "success": true
    },
    {
      "type": "shell",
      "success": true,
      "output": "Dependencies installed"
    },
    {
      "type": "start",
      "success": true
    }
  ],
  "files": ["package.json", "src/App.jsx", "src/Counter.jsx"],
  "devServer": {
    "running": true,
    "port": 5173,
    "url": "http://localhost:5173"
  },
  "timestamp": "2026-01-06T10:30:00.000Z"
}
```

**Parameters:**
- `sessionId` (required): Unique identifier for the session
- `message` (required): User's natural language request
- `provider` (optional): AI provider (default: "openai")
- `model` (optional): Model name (default: "gpt-4")
- `files` (optional): Array of file attachments

### Get Files Endpoint

**Request:**
```bash
curl http://your-n8n-instance/webhook/files/unique-session-id
```

**Response:**
```json
{
  "files": [
    {
      "key": "unique-session-id/package.json",
      "size": 423,
      "lastModified": "2026-01-06T10:30:00.000Z"
    },
    {
      "key": "unique-session-id/src/App.jsx",
      "size": 1024,
      "lastModified": "2026-01-06T10:30:00.000Z"
    }
  ]
}
```

### Deploy Endpoint

**Request:**
```bash
curl -X POST http://your-n8n-instance/webhook/deploy/vercel \
  -H "Content-Type: application/json" \
  -d '{
    "sessionId": "unique-session-id",
    "projectName": "my-bolt-app",
    "files": [...file objects...]
  }'
```

**Response:**
```json
{
  "deploymentUrl": "https://my-bolt-app.vercel.app",
  "status": "success"
}
```

## System Prompt

The workflow uses the following system prompt structure:

```
You are Bolt, an expert AI assistant and full-stack developer.

You can create and modify web applications. When responding, follow this format:

<boltArtifact id="unique-id" title="Project Title">
  <boltAction type="file" filePath="path/to/file.ext">
Full file content here
  </boltAction>
  <boltAction type="shell">
command to run
  </boltAction>
  <boltAction type="start">
command to start dev server
  </boltAction>
</boltArtifact>

Supported action types:
- file: Create or update a file (include full content)
- shell: Run a shell command
- start: Start the development server
- build: Build the project

Constraints:
- Use modern web technologies (React, Vue, Vite, etc.)
- Provide complete, working code
- No placeholders or TODOs
- Use npm for package management
- Write clean, production-ready code
```

## Example Conversations

### Example 1: Create React App

**User:** "Create a simple React todo app with local storage"

**AI Response:**
```xml
<boltArtifact id="react-todo-app" title="React Todo App">
  <boltAction type="file" filePath="package.json">
{
  "name": "react-todo-app",
  "version": "1.0.0",
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  },
  "devDependencies": {
    "vite": "^5.0.0",
    "@vitejs/plugin-react": "^4.2.0"
  },
  "scripts": {
    "dev": "vite",
    "build": "vite build"
  }
}
  </boltAction>

  <boltAction type="file" filePath="src/App.jsx">
import { useState, useEffect } from 'react';
import './App.css';

function App() {
  const [todos, setTodos] = useState(() => {
    const saved = localStorage.getItem('todos');
    return saved ? JSON.parse(saved) : [];
  });

  // ... rest of component code ...
}

export default App;
  </boltAction>

  <boltAction type="shell">
npm install
  </boltAction>

  <boltAction type="start">
npm run dev
  </boltAction>
</boltArtifact>
```

**Workflow Actions:**
1. Creates `package.json` in S3
2. Creates `src/App.jsx` in S3
3. Runs `npm install` in Docker container
4. Starts Vite dev server on port 5173

### Example 2: Modify Existing Code

**User:** "Add dark mode toggle to the todo app"

**AI Response:**
```xml
<boltArtifact id="add-dark-mode" title="Add Dark Mode">
  <boltAction type="file" filePath="src/App.jsx">
import { useState, useEffect } from 'react';
import './App.css';

function App() {
  const [darkMode, setDarkMode] = useState(false);
  const [todos, setTodos] = useState(() => {
    const saved = localStorage.getItem('todos');
    return saved ? JSON.parse(saved) : [];
  });

  // ... component with dark mode implementation ...
}

export default App;
  </boltAction>

  <boltAction type="file" filePath="src/App.css">
.app {
  transition: background-color 0.3s, color 0.3s;
}

.app.dark-mode {
  background-color: #1a1a1a;
  color: #ffffff;
}

/* ... rest of styles ... */
  </boltAction>
</boltArtifact>
```

**Workflow Actions:**
1. Updates `src/App.jsx` in S3
2. Updates `src/App.css` in S3
3. Dev server automatically reloads (if using Vite HMR)

## Key Differences from bolt.diy

### What's the Same
✅ AI-powered code generation
✅ Multi-turn conversations with context
✅ File creation and management
✅ Command execution
✅ Dev server launching
✅ Deployment to Vercel/Netlify
✅ Session-based state management

### What's Different

| Feature | bolt.diy | n8n Workflow |
|---------|----------|--------------|
| **Runtime** | WebContainer (browser) | Docker containers (server) |
| **Storage** | In-memory (browser) | S3/Cloud storage (persistent) |
| **Preview** | Embedded iframe | External URL |
| **File Editor** | CodeMirror in browser | External editor required |
| **Terminal** | XTerm.js in browser | Docker exec |
| **State** | Browser localStorage | Redis |
| **UI** | Full React app | API-only (bring your own UI) |
| **Git** | isomorphic-git | Real git in Docker |

### Limitations

❌ **No in-browser preview** - Dev servers run on server, not in browser
❌ **No visual editor** - API-only, requires separate frontend
❌ **No terminal UI** - Commands execute but no interactive terminal
❌ **No WebContainer magic** - Can't run everything client-side
❌ **Requires Docker** - More infrastructure than browser-only solution
❌ **No real-time streaming** - Responses are batch, not streamed

### Advantages

✅ **Persistent storage** - Files survive browser refresh
✅ **Server-side execution** - More powerful than browser sandbox
✅ **Multi-user ready** - Sessions are isolated
✅ **Scalable** - Can run multiple sessions in parallel
✅ **Full Docker access** - Can run databases, services, etc.
✅ **API-first** - Integrate with any frontend or service

## Enhancements & Extensions

### Add More LLM Providers

```javascript
// In "Route by Provider" node, add new outputs:
{
  "conditions": [
    { "leftValue": "={{ $json.provider }}", "rightValue": "google", "operator": "equals" }
  ]
}

// Add new node for Google
{
  "name": "Google Gemini",
  "type": "@n8n/n8n-nodes-langchain.lmChatGoogleGemini",
  "credentials": { "googleGeminiApi": "..." }
}
```

### Add Streaming Support

Replace HTTP webhook with WebSocket node:

```javascript
// Streaming implementation
const stream = streamText({
  model: openai('gpt-4'),
  messages: llmMessages
});

for await (const chunk of stream) {
  websocket.send(JSON.stringify({
    type: 'chunk',
    content: chunk.text
  }));
}
```

### Add GitHub Integration

```javascript
// New action type: git
{
  "type": "git",
  "operation": "commit",
  "message": "Update components"
}

// Handler node
{
  "name": "Git Operations",
  "type": "n8n-nodes-base.executeCommand",
  "parameters": {
    "command": "git add . && git commit -m '{{ $json.message }}' && git push"
  }
}
```

### Add Database Support (Supabase)

```javascript
// New action type: supabase
{
  "type": "supabase",
  "operation": "query",
  "sql": "SELECT * FROM users"
}

// Handler node
{
  "name": "Supabase Query",
  "type": "n8n-nodes-base.postgres",
  "parameters": {
    "query": "={{ $json.sql }}"
  }
}
```

### Add MCP (Model Context Protocol)

```javascript
// Extend system prompt with MCP tools
const mcpTools = [
  {
    name: "read_database",
    description: "Read from database",
    parameters: {...}
  }
];

// Add tool execution node
{
  "name": "MCP Tool Executor",
  "type": "n8n-nodes-base.code",
  "parameters": {
    "jsCode": "// Execute MCP tool based on AI request"
  }
}
```

### Add File Upload Support

```javascript
// Extend Chat Webhook to accept multipart/form-data
{
  "parameters": {
    "httpMethod": "POST",
    "path": "chat",
    "options": {
      "rawBody": true
    }
  }
}

// Parse uploaded files
const formData = await parseMultipart($input.item.binary);
// Save to S3 and include in context
```

## Deployment

### Docker Compose

```yaml
version: '3.8'

services:
  n8n:
    image: n8nio/n8n:latest
    ports:
      - "5678:5678"
    environment:
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=admin
      - N8N_BASIC_AUTH_PASSWORD=password
      - N8N_HOST=0.0.0.0
    volumes:
      - n8n_data:/home/node/.n8n
      - /var/run/docker.sock:/var/run/docker.sock
    depends_on:
      - redis
      - minio

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

  minio:
    image: minio/minio:latest
    ports:
      - "9000:9000"
      - "9001:9001"
    environment:
      - MINIO_ROOT_USER=minioadmin
      - MINIO_ROOT_PASSWORD=minioadmin
    command: server /data --console-address ":9001"
    volumes:
      - minio_data:/data

volumes:
  n8n_data:
  redis_data:
  minio_data:
```

Run:
```bash
docker-compose up -d
```

### Environment Variables

```bash
# .env file
N8N_HOST=0.0.0.0
N8N_PORT=5678
N8N_PROTOCOL=https
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=your-secure-password

# Redis
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=

# Storage
AWS_ACCESS_KEY_ID=your-key
AWS_SECRET_ACCESS_KEY=your-secret
AWS_S3_BUCKET=bolt-projects
AWS_REGION=us-east-1

# LLM APIs
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...
```

## Frontend Integration Example

### React Frontend

```typescript
import { useState } from 'react';

const WORKFLOW_URL = 'https://your-n8n-instance.com/webhook';

function BoltChat() {
  const [messages, setMessages] = useState([]);
  const [input, setInput] = useState('');
  const [sessionId] = useState(() => crypto.randomUUID());

  const sendMessage = async () => {
    const userMessage = { role: 'user', content: input };
    setMessages(prev => [...prev, userMessage]);

    const response = await fetch(`${WORKFLOW_URL}/chat`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        sessionId,
        message: input,
        provider: 'openai',
        model: 'gpt-4'
      })
    });

    const data = await response.json();

    setMessages(prev => [...prev, {
      role: 'assistant',
      content: data.message,
      actions: data.actions,
      devServer: data.devServer
    }]);

    setInput('');
  };

  return (
    <div className="chat-container">
      <div className="messages">
        {messages.map((msg, i) => (
          <div key={i} className={`message ${msg.role}`}>
            <div className="content">{msg.content}</div>
            {msg.actions && (
              <div className="actions">
                {msg.actions.map((action, j) => (
                  <div key={j} className="action">
                    {action.type}: {action.filePath || action.command}
                  </div>
                ))}
              </div>
            )}
            {msg.devServer?.running && (
              <div className="preview">
                <a href={msg.devServer.url} target="_blank">
                  Open Preview
                </a>
              </div>
            )}
          </div>
        ))}
      </div>
      <input
        value={input}
        onChange={e => setInput(e.target.value)}
        onKeyPress={e => e.key === 'Enter' && sendMessage()}
        placeholder="Ask me to build something..."
      />
    </div>
  );
}
```

## Monitoring & Debugging

### Enable Debug Logging

In n8n workflow settings:
- Enable "Save Execution Progress"
- Enable "Save Manual Executions"

### View Logs

```bash
# Docker logs
docker logs n8n -f

# Redis monitoring
redis-cli MONITOR

# S3 file listing
aws s3 ls s3://bolt-projects --recursive
```

### Common Issues

**Issue: Actions not executing**
- Check Docker is running and accessible
- Verify volume mounts in Docker nodes
- Check S3 credentials and bucket permissions

**Issue: Session state lost**
- Verify Redis connection
- Check TTL settings (default 24h)
- Ensure sessionId is consistent

**Issue: LLM not responding**
- Verify API keys are correct
- Check model names match provider
- Review rate limits and quotas

## Performance Optimization

### Redis Caching
- Cache frequently accessed files
- Store compiled bundles
- Cache LLM responses for repeated queries

### Parallel Execution
- Execute independent actions in parallel
- Use n8n's "Split In Batches" for large file sets
- Batch S3 operations

### Resource Limits
```yaml
# Docker resource limits
services:
  n8n:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4G
```

## Security Considerations

1. **API Key Management**
   - Store in n8n credentials (encrypted)
   - Never expose in responses
   - Rotate regularly

2. **Session Isolation**
   - Use UUIDs for session IDs
   - Implement session timeout
   - Validate sessionId format

3. **Docker Security**
   - Run containers as non-root
   - Limit network access
   - Use resource constraints
   - Scan images for vulnerabilities

4. **Input Validation**
   - Sanitize file paths (prevent path traversal)
   - Validate commands (whitelist allowed commands)
   - Limit file sizes
   - Rate limit requests

5. **Storage Security**
   - Use presigned URLs for file access
   - Implement bucket policies
   - Enable encryption at rest
   - Regular backups

## Cost Estimation

### Monthly Costs (example)

**LLM API Usage** (1000 requests/day)
- OpenAI GPT-4: ~$300-500
- Anthropic Claude: ~$200-400

**Infrastructure**
- n8n Cloud (Starter): $20
- Redis Cloud (30MB): $0 (free tier)
- AWS S3 (10GB): ~$0.30
- Docker/Compute: ~$50-100

**Total**: ~$270-920/month depending on usage

### Cost Optimization
- Use cheaper models (GPT-3.5, Claude Haiku) for simple tasks
- Implement response caching
- Compress stored files
- Use spot instances for compute

## Contributing

To extend this workflow:

1. Fork the workflow in n8n
2. Add new nodes for features
3. Update system prompt if needed
4. Test thoroughly
5. Export and share JSON

## License

This workflow is provided as-is under MIT license. Use at your own risk.

## Support

For issues and questions:
- n8n Forum: https://community.n8n.io
- bolt.diy GitHub: https://github.com/stackblitz-labs/bolt.diy

## Changelog

### Version 1.0.0 (2026-01-06)
- Initial workflow release
- Support for OpenAI and Anthropic
- File management via S3
- Shell and start actions via Docker
- Session management via Redis
- Deployment to Vercel/Netlify
