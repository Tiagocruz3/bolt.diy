# Bolt.DIY n8n Workflow - Quick Start Guide

Get the Bolt.DIY n8n workflow running in under 5 minutes!

## Prerequisites

- Docker and Docker Compose installed
- At least one LLM API key (OpenAI or Anthropic recommended)
- 4GB RAM available
- Ports 5678, 8080, 9000, 9001, 6379 available

## Quick Start

### 1. Set Up Environment Variables

```bash
# Copy the example env file
cp .env.n8n.example .env.n8n

# Edit the file and add your API keys
nano .env.n8n
```

**Required variables:**
```bash
N8N_USER=admin
N8N_PASSWORD=your-secure-password
OPENAI_API_KEY=sk-...
# OR
ANTHROPIC_API_KEY=sk-ant-...
```

### 2. Start the Stack

```bash
# Start all services
docker-compose -f docker-compose.n8n.yml --env-file .env.n8n up -d

# Watch the logs
docker-compose -f docker-compose.n8n.yml logs -f
```

### 3. Import the Workflow

**Option A: Via n8n UI**

1. Open http://localhost:5678
2. Login with credentials from `.env.n8n`
3. Click "Workflows" → "Import from File"
4. Select `bolt-diy-n8n-workflow.json`
5. Click "Import"

**Option B: Via CLI**

```bash
# Copy workflow into n8n container
docker cp bolt-diy-n8n-workflow.json bolt-n8n:/tmp/workflow.json

# Import using n8n CLI
docker exec bolt-n8n n8n import:workflow --input=/tmp/workflow.json
```

### 4. Configure Credentials

In n8n UI (http://localhost:5678), set up these credentials:

#### Redis
- **Name**: Redis Connection
- **Type**: Redis
- **Host**: redis
- **Port**: 6379
- **Database**: 0

#### MinIO (S3)
- **Name**: AWS S3
- **Type**: AWS
- **Access Key ID**: minioadmin (or from .env.n8n)
- **Secret Access Key**: minioadmin (or from .env.n8n)
- **Region**: us-east-1
- **Custom Endpoint**: http://minio:9000
- **Force Path Style**: Yes

#### OpenAI
- **Name**: OpenAI API
- **Type**: OpenAI
- **API Key**: (from your .env.n8n)

#### Anthropic
- **Name**: Anthropic API
- **Type**: Anthropic
- **API Key**: (from your .env.n8n)

### 5. Update Workflow Nodes

Replace credential placeholders in these nodes:
1. Load Session Context → Select "Redis Connection"
2. Save Session Context → Select "Redis Connection"
3. Save File (S3/Storage) → Select "AWS S3"
4. List Session Files → Select "AWS S3"
5. OpenAI → Select "OpenAI API"
6. Anthropic → Select "Anthropic API"

### 6. Activate Workflow

Click the "Active" toggle switch in the workflow editor.

### 7. Open Frontend

Navigate to: **http://localhost:8080**

## Test It!

Try these example prompts:

```
Create a React counter app with increment and decrement buttons
```

```
Build a landing page with a hero section and gradient background
```

```
Create a Node.js Express API with a /health endpoint
```

## Service URLs

| Service | URL | Credentials |
|---------|-----|-------------|
| **Frontend** | http://localhost:8080 | None |
| **n8n** | http://localhost:5678 | From .env.n8n |
| **MinIO Console** | http://localhost:9001 | From .env.n8n |
| **Redis** | localhost:6379 | None |

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│  Frontend (http://localhost:8080)                       │
│  - HTML/JS interface for chat                           │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────┐
│  n8n (http://localhost:5678)                            │
│  - Workflow automation                                  │
│  - LLM integration                                      │
│  - Action execution                                     │
└────────┬──────────────────────────┬─────────────────────┘
         │                          │
         ▼                          ▼
┌─────────────────┐      ┌─────────────────────┐
│  Redis          │      │  MinIO (S3)         │
│  - Sessions     │      │  - File storage     │
│  - State        │      │  - Project files    │
└─────────────────┘      └─────────────────────┘
```

## Common Issues

### Port Already in Use

```bash
# Check what's using the port
lsof -i :5678

# Change the port in docker-compose.n8n.yml
ports:
  - "5679:5678"  # Use 5679 instead
```

### Can't Connect to Docker

```bash
# Ensure Docker socket is accessible
ls -l /var/run/docker.sock

# Add your user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

### MinIO Bucket Not Created

```bash
# Manually create the bucket
docker exec bolt-minio-init /bin/sh -c "
  mc config host add myminio http://minio:9000 minioadmin minioadmin;
  mc mb myminio/bolt-projects --ignore-existing;
"
```

### n8n Can't Access LLM APIs

Check your API keys:
```bash
# View environment variables
docker exec bolt-n8n env | grep API

# Update credentials in n8n UI
# Settings → Credentials → Edit credential
```

## Stopping and Cleanup

```bash
# Stop all services
docker-compose -f docker-compose.n8n.yml down

# Stop and remove volumes (WARNING: deletes all data)
docker-compose -f docker-compose.n8n.yml down -v

# View logs
docker-compose -f docker-compose.n8n.yml logs -f [service-name]
```

## Monitoring

### View Redis Data

```bash
# Connect to Redis CLI
docker exec -it bolt-redis redis-cli

# List all keys
KEYS *

# Get session data
GET <sessionId>_context
```

### View MinIO Files

1. Open http://localhost:9001
2. Login with credentials
3. Browse `bolt-projects` bucket

### View n8n Executions

1. Open http://localhost:5678
2. Go to "Executions"
3. Click on any execution to see details

## Production Deployment

### Security Checklist

- [ ] Change default passwords in `.env.n8n`
- [ ] Use HTTPS (add Caddy or Nginx proxy)
- [ ] Set up firewall rules
- [ ] Enable n8n authentication
- [ ] Use strong API keys
- [ ] Regular backups of volumes
- [ ] Monitor resource usage
- [ ] Set up logging/alerting
- [ ] Rate limit webhooks
- [ ] Use secrets management

### Recommended Changes for Production

1. **Use PostgreSQL instead of SQLite**

```yaml
services:
  postgres:
    image: postgres:15-alpine
    environment:
      - POSTGRES_DB=n8n
      - POSTGRES_USER=n8n
      - POSTGRES_PASSWORD=secure-password
    volumes:
      - postgres_data:/var/lib/postgresql/data

  n8n:
    environment:
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_DATABASE=n8n
      - DB_POSTGRESDB_USER=n8n
      - DB_POSTGRESDB_PASSWORD=secure-password
```

2. **Add HTTPS with Caddy**

```yaml
services:
  caddy:
    image: caddy:2-alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - caddy_data:/data
      - caddy_config:/config
```

Caddyfile:
```
yourdomain.com {
  reverse_proxy n8n:5678
}
```

3. **Use AWS S3 instead of MinIO**

Update workflow to use real AWS S3:
- Create S3 bucket
- Create IAM user with S3 permissions
- Update credentials in n8n

4. **Add Redis persistence**

```yaml
redis:
  command: redis-server --appendonly yes --appendfsync everysec
  volumes:
    - redis_data:/data
```

5. **Set resource limits**

```yaml
services:
  n8n:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4G
        reservations:
          cpus: '1'
          memory: 2G
```

## Backup and Restore

### Backup

```bash
# Create backup directory
mkdir -p backups

# Backup n8n data
docker run --rm -v bolt-diy_n8n_data:/data -v $(pwd)/backups:/backup alpine tar czf /backup/n8n-backup-$(date +%Y%m%d).tar.gz /data

# Backup Redis data
docker run --rm -v bolt-diy_redis_data:/data -v $(pwd)/backups:/backup alpine tar czf /backup/redis-backup-$(date +%Y%m%d).tar.gz /data

# Backup MinIO data
docker run --rm -v bolt-diy_minio_data:/data -v $(pwd)/backups:/backup alpine tar czf /backup/minio-backup-$(date +%Y%m%d).tar.gz /data
```

### Restore

```bash
# Restore n8n data
docker run --rm -v bolt-diy_n8n_data:/data -v $(pwd)/backups:/backup alpine sh -c "cd /data && tar xzf /backup/n8n-backup-YYYYMMDD.tar.gz --strip 1"

# Restart services
docker-compose -f docker-compose.n8n.yml restart
```

## Scaling

### Horizontal Scaling

```yaml
services:
  n8n-worker:
    image: n8nio/n8n:latest
    command: worker
    environment:
      - EXECUTIONS_MODE=queue
      - QUEUE_BULL_REDIS_HOST=redis
    deploy:
      replicas: 3
```

### Load Balancing

```yaml
services:
  nginx:
    image: nginx:alpine
    volumes:
      - ./nginx-lb.conf:/etc/nginx/nginx.conf
    ports:
      - "80:80"
    depends_on:
      - n8n
```

## Performance Tuning

### Redis

```bash
# Increase max memory
redis:
  command: redis-server --maxmemory 512mb --maxmemory-policy allkeys-lru
```

### n8n

```yaml
n8n:
  environment:
    - EXECUTIONS_PROCESS=main
    - EXECUTIONS_TIMEOUT=300
    - EXECUTIONS_TIMEOUT_MAX=600
    - EXECUTIONS_DATA_PRUNE=true
    - EXECUTIONS_DATA_MAX_AGE=168  # 7 days
```

## Next Steps

1. ✅ Test the chat interface
2. ✅ Try different LLM providers
3. ✅ Create your first project
4. ✅ Explore the file tree
5. ✅ Deploy to Vercel (add credentials)
6. ✅ Customize the system prompt
7. ✅ Add more action types
8. ✅ Build your own frontend

## Support

- n8n Documentation: https://docs.n8n.io
- n8n Community: https://community.n8n.io
- Bolt.DIY GitHub: https://github.com/stackblitz-labs/bolt.diy

## License

MIT License - See LICENSE file for details
