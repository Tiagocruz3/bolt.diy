# Installing Docker on Hostinger VPS and Deploying bolt.diy

This guide will walk you through installing Docker on your Hostinger VPS and deploying bolt.diy.

## Prerequisites

- A Hostinger VPS with Ubuntu 20.04+ or Debian 11+ (most common)
- SSH access to your VPS
- Root or sudo privileges

## Step 1: Connect to Your VPS

```bash
ssh root@your-vps-ip-address
# OR if using a non-root user:
ssh your-username@your-vps-ip-address
```

## Step 2: Update System Packages

```bash
sudo apt update
sudo apt upgrade -y
```

## Step 3: Install Docker

### Method 1: Using Docker's Official Script (Recommended)

This is the fastest and easiest method:

```bash
# Download and run Docker's official installation script
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add your user to the docker group (optional, allows running docker without sudo)
sudo usermod -aG docker $USER

# Start and enable Docker service
sudo systemctl start docker
sudo systemctl enable docker
```

### Method 2: Manual Installation (Alternative)

If you prefer manual installation:

```bash
# Remove old versions (if any)
sudo apt remove docker docker-engine docker.io containerd runc

# Install dependencies
sudo apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up the repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

## Step 4: Verify Docker Installation

```bash
# Check Docker version
docker --version

# Test Docker with hello-world
sudo docker run hello-world

# Check Docker service status
sudo systemctl status docker
```

## Step 5: Install Docker Compose

Docker Compose is now included as a plugin with Docker, but you can also install standalone:

```bash
# Check if docker compose is installed (should work with modern Docker)
docker compose version

# If not available, install standalone version
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
```

## Step 6: Clone and Set Up bolt.diy

```bash
# Install git if not already installed
sudo apt install -y git

# Clone the repository
git clone https://github.com/stackblitz-labs/bolt.diy.git
cd bolt.diy

# Create environment files
cp .env.example .env
cp .env.example .env.local
```

## Step 7: Configure Environment Variables

Edit your `.env.local` file to add your API keys:

```bash
# Use nano or vim to edit
nano .env.local
```

Add your API keys (at least one provider):

```bash
# Example providers
OPENAI_API_KEY=sk-your-openai-key-here
ANTHROPIC_API_KEY=sk-ant-your-anthropic-key-here
GOOGLE_GENERATIVE_AI_API_KEY=your-google-key-here

# Optional: Custom base URLs for local providers
OLLAMA_BASE_URL=http://127.0.0.1:11434
LMSTUDIO_BASE_URL=http://127.0.0.1:1234
```

Save and exit (Ctrl+X, then Y, then Enter in nano).

## Step 8: Build and Run with Docker

### Option A: Using Docker Compose (Recommended)

```bash
# Build and run in production mode
docker compose --profile production up -d

# Or for development mode with hot reload
docker compose --profile development up -d
```

### Option B: Using Docker Commands Directly

```bash
# Build the production image
docker build -t bolt-ai:production --target bolt-ai-production .

# Run the container
docker run -d \
  --name bolt-ai \
  -p 5173:5173 \
  --env-file .env.local \
  --restart unless-stopped \
  bolt-ai:production
```

## Step 9: Configure Firewall

```bash
# Allow port 5173 (or your custom port)
sudo ufw allow 5173/tcp

# Allow SSH (if not already allowed)
sudo ufw allow 22/tcp

# Enable firewall
sudo ufw enable

# Check firewall status
sudo ufw status
```

## Step 10: Access Your Application

Open your browser and navigate to:
```
http://your-vps-ip-address:5173
```

## Additional Configuration

### Setting Up a Domain Name (Optional but Recommended)

If you have a domain, you can set up a reverse proxy with Nginx:

```bash
# Install Nginx
sudo apt install -y nginx

# Create Nginx configuration
sudo nano /etc/nginx/sites-available/bolt-diy
```

Add this configuration:

```nginx
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;

    location / {
        proxy_pass http://localhost:5173;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Enable the site:

```bash
sudo ln -s /etc/nginx/sites-available/bolt-diy /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### Setting Up SSL with Let's Encrypt (Recommended)

```bash
# Install Certbot
sudo apt install -y certbot python3-certbot-nginx

# Obtain SSL certificate
sudo certbot --nginx -d your-domain.com -d www.your-domain.com

# Auto-renewal is set up automatically
sudo certbot renew --dry-run
```

## Managing Your Docker Container

### Useful Docker Commands

```bash
# View running containers
docker ps

# View all containers (including stopped)
docker ps -a

# View logs
docker logs bolt-ai
docker logs -f bolt-ai  # Follow logs in real-time

# Stop the container
docker stop bolt-ai

# Start the container
docker start bolt-ai

# Restart the container
docker restart bolt-ai

# Remove the container
docker stop bolt-ai
docker rm bolt-ai

# View Docker images
docker images

# Remove an image
docker rmi bolt-ai:production
```

### Using Docker Compose Commands

```bash
# View running services
docker compose ps

# View logs
docker compose logs
docker compose logs -f  # Follow logs

# Stop services
docker compose --profile production down

# Restart services
docker compose --profile production restart

# Rebuild and restart
docker compose --profile production up -d --build
```

## Updating bolt.diy

To update to the latest version:

```bash
# Navigate to the project directory
cd /path/to/bolt.diy

# Stop the container
docker compose --profile production down
# OR: docker stop bolt-ai

# Pull latest changes
git pull origin main

# Rebuild the image
docker compose --profile production up -d --build
# OR: docker build -t bolt-ai:production --target bolt-ai-production .
#     docker run -d --name bolt-ai -p 5173:5173 --env-file .env.local bolt-ai:production
```

## Troubleshooting

### Check if Docker is running
```bash
sudo systemctl status docker
```

### Container won't start
```bash
# Check logs for errors
docker logs bolt-ai

# Check if port 5173 is already in use
sudo lsof -i :5173
```

### Permission denied errors
```bash
# Make sure you're in the docker group
sudo usermod -aG docker $USER

# Log out and back in for changes to take effect
```

### Container keeps restarting
```bash
# Check logs
docker logs bolt-ai

# Common issues:
# - Missing or invalid API keys in .env.local
# - Port already in use
# - Insufficient memory
```

### Free up disk space
```bash
# Remove unused images and containers
docker system prune -a

# Remove specific old images
docker images
docker rmi <image-id>
```

## Security Best Practices

1. **Never expose sensitive API keys** in your Dockerfile
2. **Use `.env.local`** for all API keys and secrets
3. **Keep Docker updated**: `sudo apt update && sudo apt upgrade docker-ce`
4. **Use a firewall** (ufw) to restrict access to necessary ports only
5. **Set up automatic security updates**:
   ```bash
   sudo apt install unattended-upgrades
   sudo dpkg-reconfigure --priority=low unattended-upgrades
   ```
6. **Use strong passwords** and consider SSH key authentication
7. **Regular backups** of your configuration and data
8. **Monitor logs** regularly for suspicious activity

## Resource Management

### Check system resources
```bash
# CPU and memory usage
htop

# Docker resource usage
docker stats

# Disk usage
df -h
docker system df
```

### Limit container resources (optional)
```bash
docker run -d \
  --name bolt-ai \
  -p 5173:5173 \
  --env-file .env.local \
  --memory="2g" \
  --cpus="1.5" \
  --restart unless-stopped \
  bolt-ai:production
```

## Support

If you encounter issues:

1. Check the [bolt.diy documentation](https://stackblitz-labs.github.io/bolt.diy/)
2. Visit the [GitHub issues](https://github.com/stackblitz-labs/bolt.diy/issues)
3. Join the [community forum](https://thinktank.ottomator.ai)

## Quick Reference

```bash
# Start bolt.diy
docker compose --profile production up -d

# Stop bolt.diy
docker compose --profile production down

# View logs
docker compose logs -f

# Restart
docker compose --profile production restart

# Update
git pull && docker compose --profile production up -d --build
```

---

**Congratulations!** You now have bolt.diy running on your Hostinger VPS with Docker! 🎉
