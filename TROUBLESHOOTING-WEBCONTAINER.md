# Troubleshooting WebContainer Errors on Hostinger VPS

This guide addresses the common errors you're seeing when running bolt.diy on a VPS.

## Error Overview

You're encountering these critical errors:

### 1. SharedArrayBuffer / crossOriginIsolated Error
```
DataCloneError: SharedArrayBuffer transfer requires self.crossOriginIsolated
```

**Cause:** WebContainer requires specific HTTP headers to enable cross-origin isolation.

**Solution:** Configure Nginx reverse proxy with required headers.

### 2. Cross-Origin-Opener-Policy Warning
```
The Cross-Origin-Opener-Policy header has been ignored, because the URL's origin was untrustworthy
```

**Cause:** Accessing via HTTP instead of HTTPS.

**Solution:** Set up HTTPS with Let's Encrypt.

### 3. LLM API Call 500 Error
```
Failed to load resource: the server responded with a status of 500 (Error)
/api/llmcall:1
```

**Cause:** Missing or invalid API keys, or backend configuration issue.

**Solution:** Verify environment variables are properly set.

---

## Quick Fix Guide

### Step 1: Set Up Nginx Reverse Proxy

This is **REQUIRED** to fix the WebContainer errors.

1. **SSH into your VPS:**
   ```bash
   ssh root@your-vps-ip
   ```

2. **Download the setup script:**
   ```bash
   cd /root
   curl -O https://raw.githubusercontent.com/stackblitz-labs/bolt.diy/main/nginx-hostinger-setup.sh
   chmod +x nginx-hostinger-setup.sh
   ```

   Or manually create the script from the repository files.

3. **Run the setup script:**
   ```bash
   sudo bash nginx-hostinger-setup.sh
   ```

4. **Choose setup type:**
   - **Without domain:** Press Enter when asked for domain (access via IP)
   - **With domain:** Enter your domain name

5. **Update firewall:**
   ```bash
   # Allow HTTP
   sudo ufw allow 80/tcp

   # Allow HTTPS (if using domain)
   sudo ufw allow 443/tcp

   # Block direct access to port 3005 (optional security)
   sudo ufw deny 3005/tcp
   ```

6. **Test access:**
   ```bash
   # Without domain
   curl -I http://your-vps-ip

   # With domain
   curl -I http://your-domain.com
   ```

   You should see these headers in the response:
   ```
   Cross-Origin-Embedder-Policy: require-corp
   Cross-Origin-Opener-Policy: same-origin
   Cross-Origin-Resource-Policy: cross-origin
   ```

### Step 2: Set Up SSL (Recommended for Production)

If you have a domain name:

1. **Point your domain to your VPS:**
   - Go to your domain registrar's DNS settings
   - Add an A record pointing to your VPS IP
   - Wait for DNS propagation (5-30 minutes)

2. **Run SSL setup:**
   ```bash
   sudo bash ssl-setup.sh
   ```

3. **Access via HTTPS:**
   ```
   https://your-domain.com
   ```

### Step 3: Fix API Key Configuration

The 500 error on `/api/llmcall` indicates missing or invalid API keys.

#### Using Hostinger Docker Manager:

1. Go to **Docker Manager** in Hostinger
2. Click on your **bolt** container
3. Click **Edit** or **Visual Editor**
4. Scroll to **Environment variables**
5. Add at least ONE of these:

   ```
   Name: ANTHROPIC_API_KEY
   Value: sk-ant-api03-your-key-here
   ```

   ```
   Name: OPENAI_API_KEY
   Value: sk-your-openai-key-here
   ```

   ```
   Name: GROQ_API_KEY
   Value: gsk_your-groq-key-here
   ```

6. **Save** and **Restart** the container

#### Or via Command Line:

```bash
# Stop the container
docker stop bolt

# Remove it
docker rm bolt

# Run with environment variables
docker run -d \
  --name bolt \
  -p 3005:5173 \
  -e ANTHROPIC_API_KEY="sk-ant-your-key-here" \
  -e OPENAI_API_KEY="sk-your-openai-key-here" \
  -v /srv/bolt/projects:/app/projects \
  -v /srv/bolt/data:/app/data \
  --restart unless-stopped \
  ghcr.io/tiagocruz3/bolt-diy:latest
```

---

## Verification Checklist

After completing the steps above, verify everything works:

### ✅ Nginx Headers Check

```bash
# Check if required headers are present
curl -I http://your-domain-or-ip | grep -i "cross-origin"
```

Expected output:
```
Cross-Origin-Embedder-Policy: require-corp
Cross-Origin-Opener-Policy: same-origin
Cross-Origin-Resource-Policy: cross-origin
```

### ✅ Container Running Check

```bash
docker ps | grep bolt
```

Should show your container running.

### ✅ Container Logs Check

```bash
docker logs bolt --tail 50
```

Should NOT show errors about missing API keys.

### ✅ API Endpoint Check

```bash
# This should return provider information (not 500 error)
curl http://localhost:3005/api/providers
```

### ✅ Browser Console Check

1. Open bolt.diy in browser
2. Open Developer Tools (F12)
3. Go to **Console** tab
4. **Should NOT see:**
   - `SharedArrayBuffer transfer requires self.crossOriginIsolated`
   - `500 Error on /api/llmcall`

5. **Should see:**
   - Provider registration messages (INFO)
   - No critical errors

---

## Common Issues and Solutions

### Issue: "Connection Refused" when accessing via domain

**Solution:**
```bash
# Check Nginx status
sudo systemctl status nginx

# If not running, start it
sudo systemctl start nginx

# Check Nginx configuration
sudo nginx -t

# Check if port 80/443 is open
sudo netstat -tlnp | grep nginx
```

### Issue: Still getting WebContainer errors after Nginx setup

**Solution:**
```bash
# Verify you're accessing through Nginx (not port 3005 directly)
# Access via: http://your-domain-or-ip
# NOT: http://your-domain-or-ip:3005

# Check headers
curl -I http://your-domain-or-ip | grep Cross-Origin

# If headers missing, check Nginx config
sudo cat /etc/nginx/sites-available/bolt-diy

# Reload Nginx
sudo systemctl reload nginx
```

### Issue: 500 Error persists on /api/llmcall

**Solution:**
```bash
# Check container environment variables
docker exec bolt env | grep API_KEY

# If empty, API keys aren't set
# Recreate container with proper env vars (see Step 3 above)

# Check container logs for specific error
docker logs bolt | grep -i error
```

### Issue: "ERR_SSL_PROTOCOL_ERROR" with HTTPS

**Solution:**
```bash
# Check SSL certificate
sudo certbot certificates

# Renew if needed
sudo certbot renew

# Check Nginx SSL configuration
sudo nginx -t

# Verify port 443 is listening
sudo netstat -tlnp | grep 443
```

---

## Manual Nginx Configuration (If Script Fails)

If the automated script doesn't work, manually configure Nginx:

1. **Create configuration file:**
   ```bash
   sudo nano /etc/nginx/sites-available/bolt-diy
   ```

2. **Add this configuration:**
   ```nginx
   server {
       listen 80;
       server_name your-domain.com www.your-domain.com;  # or use _ for IP-based

       # CRITICAL: Required headers for WebContainer
       add_header Cross-Origin-Embedder-Policy "require-corp" always;
       add_header Cross-Origin-Opener-Policy "same-origin" always;
       add_header Cross-Origin-Resource-Policy "cross-origin" always;

       # Security headers
       add_header X-Frame-Options "SAMEORIGIN" always;
       add_header X-Content-Type-Options "nosniff" always;
       add_header X-XSS-Protection "1; mode=block" always;

       location / {
           proxy_pass http://localhost:3005;
           proxy_http_version 1.1;

           # WebSocket support
           proxy_set_header Upgrade $http_upgrade;
           proxy_set_header Connection 'upgrade';

           # Standard headers
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header X-Forwarded-Proto $scheme;

           proxy_buffering off;
           proxy_cache_bypass $http_upgrade;

           # Timeouts for long requests
           proxy_read_timeout 300s;
           proxy_connect_timeout 75s;
       }

       client_max_body_size 50M;
   }
   ```

3. **Enable the site:**
   ```bash
   sudo ln -sf /etc/nginx/sites-available/bolt-diy /etc/nginx/sites-enabled/
   sudo rm -f /etc/nginx/sites-enabled/default
   ```

4. **Test and restart:**
   ```bash
   sudo nginx -t
   sudo systemctl restart nginx
   ```

---

## Getting API Keys

### Anthropic (Recommended)
1. Go to https://console.anthropic.com/
2. Sign up / Log in
3. Go to API Keys section
4. Create a new key
5. Copy key (starts with `sk-ant-`)

### OpenAI
1. Go to https://platform.openai.com/
2. Sign up / Log in
3. Go to API Keys
4. Create new secret key
5. Copy key (starts with `sk-`)

### Groq (Free Tier Available)
1. Go to https://console.groq.com/
2. Sign up / Log in
3. Go to API Keys
4. Create API key
5. Copy key (starts with `gsk_`)

---

## Architecture After Fix

```
User Browser
    ↓
Nginx (Port 80/443)
    ↓ [Adds required headers]
Docker Container (Port 3005)
    ↓ [Container port 5173]
bolt.diy Application
    ↓
AI Provider APIs
```

**Key Points:**
- Users access via Nginx (not directly to port 3005)
- Nginx adds CrossOriginIsolated headers
- Docker container runs on internal port 3005
- API keys passed as environment variables

---

## Need More Help?

1. **Check container logs:**
   ```bash
   docker logs bolt --tail 100 -f
   ```

2. **Check Nginx logs:**
   ```bash
   sudo tail -f /var/log/nginx/error.log
   sudo tail -f /var/log/nginx/access.log
   ```

3. **Restart everything:**
   ```bash
   docker restart bolt
   sudo systemctl restart nginx
   ```

4. **Community support:**
   - [bolt.diy Community Forum](https://thinktank.ottomator.ai)
   - [GitHub Issues](https://github.com/stackblitz-labs/bolt.diy/issues)
