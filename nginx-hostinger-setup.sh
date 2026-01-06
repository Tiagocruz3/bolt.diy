#!/bin/bash

# Nginx Setup Script for bolt.diy on Hostinger VPS
# This script configures Nginx as a reverse proxy with the required headers for WebContainer

set -e

echo "==================================="
echo "bolt.diy Nginx Setup for Hostinger"
echo "==================================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
   echo "Please run as root (use: sudo bash nginx-hostinger-setup.sh)"
   exit 1
fi

# Get domain name from user
read -p "Enter your domain name (or press Enter to skip SSL setup): " DOMAIN_NAME

# Install Nginx if not installed
echo "Installing Nginx..."
apt update
apt install -y nginx

# Stop nginx to configure
systemctl stop nginx

# Backup existing default config
if [ -f /etc/nginx/sites-available/default ]; then
    cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.backup
fi

# Create Nginx configuration for bolt.diy
echo "Creating Nginx configuration..."

if [ -z "$DOMAIN_NAME" ]; then
    # No domain - use IP address configuration
    cat > /etc/nginx/sites-available/bolt-diy << 'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    server_name _;

    # Required headers for WebContainer (CrossOriginIsolated)
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

        # Standard proxy headers
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # Disable buffering for streaming responses
        proxy_buffering off;
        proxy_cache_bypass $http_upgrade;

        # Timeout settings for long-running requests
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }

    # Increase body size limit for file uploads
    client_max_body_size 50M;
}
EOF
else
    # With domain - create config for SSL setup
    cat > /etc/nginx/sites-available/bolt-diy << EOF
server {
    listen 80;
    listen [::]:80;

    server_name $DOMAIN_NAME www.$DOMAIN_NAME;

    # Required headers for WebContainer (CrossOriginIsolated)
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
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';

        # Standard proxy headers
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;

        # Disable buffering for streaming responses
        proxy_buffering off;
        proxy_cache_bypass \$http_upgrade;

        # Timeout settings for long-running requests
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }

    # Increase body size limit for file uploads
    client_max_body_size 50M;
}
EOF
fi

# Remove default site and enable bolt-diy
rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/bolt-diy /etc/nginx/sites-enabled/

# Test Nginx configuration
echo "Testing Nginx configuration..."
nginx -t

if [ $? -eq 0 ]; then
    echo "✓ Nginx configuration is valid"

    # Start Nginx
    systemctl start nginx
    systemctl enable nginx

    echo ""
    echo "✓ Nginx has been configured and started successfully!"
    echo ""

    if [ -z "$DOMAIN_NAME" ]; then
        echo "Access your bolt.diy instance at: http://YOUR_VPS_IP"
        echo ""
        echo "IMPORTANT: The required headers are now set!"
    else
        echo "✓ Nginx is configured for domain: $DOMAIN_NAME"
        echo ""
        echo "Next steps for SSL:"
        echo "1. Make sure your domain DNS points to this server's IP"
        echo "2. Run the SSL setup:"
        echo "   sudo bash ssl-setup.sh"
        echo ""
        echo "Access your bolt.diy instance at: http://$DOMAIN_NAME"
    fi

    echo ""
    echo "Container should be accessible through Nginx now."
    echo "The WebContainer errors should be resolved!"

else
    echo "✗ Nginx configuration test failed"
    exit 1
fi
