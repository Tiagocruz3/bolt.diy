#!/bin/bash

# SSL Setup Script for bolt.diy using Let's Encrypt
# Run this AFTER nginx-hostinger-setup.sh and DNS is configured

set -e

echo "=================================="
echo "bolt.diy SSL/HTTPS Setup"
echo "=================================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
   echo "Please run as root (use: sudo bash ssl-setup.sh)"
   exit 1
fi

# Get domain name
read -p "Enter your domain name (e.g., example.com): " DOMAIN_NAME

if [ -z "$DOMAIN_NAME" ]; then
    echo "Error: Domain name is required for SSL setup"
    exit 1
fi

# Get email for Let's Encrypt
read -p "Enter your email address for Let's Encrypt notifications: " EMAIL

if [ -z "$EMAIL" ]; then
    echo "Error: Email address is required"
    exit 1
fi

echo ""
echo "Installing Certbot..."
apt update
apt install -y certbot python3-certbot-nginx

echo ""
echo "Obtaining SSL certificate for $DOMAIN_NAME..."
echo "This will automatically configure Nginx with HTTPS and the required headers."
echo ""

# Run Certbot
certbot --nginx \
    -d "$DOMAIN_NAME" \
    -d "www.$DOMAIN_NAME" \
    --non-interactive \
    --agree-tos \
    --email "$EMAIL" \
    --redirect

# Verify the required headers are still in place after certbot modification
echo ""
echo "Verifying WebContainer headers are configured..."

# Update the SSL config to ensure headers are present
CONFIG_FILE="/etc/nginx/sites-available/bolt-diy"

# Check if headers are in the SSL server block
if ! grep -q "Cross-Origin-Embedder-Policy" "$CONFIG_FILE" | grep -q "443"; then
    echo "Adding required headers to SSL configuration..."

    # Create a backup
    cp "$CONFIG_FILE" "${CONFIG_FILE}.pre-ssl-headers"

    # Add headers to the SSL block if not present
    sed -i '/listen 443 ssl/a \
\
    # Required headers for WebContainer (CrossOriginIsolated)\
    add_header Cross-Origin-Embedder-Policy "require-corp" always;\
    add_header Cross-Origin-Opener-Policy "same-origin" always;\
    add_header Cross-Origin-Resource-Policy "cross-origin" always;\
\
    # Security headers\
    add_header X-Frame-Options "SAMEORIGIN" always;\
    add_header X-Content-Type-Options "nosniff" always;\
    add_header X-XSS-Protection "1; mode=block" always;\
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;' "$CONFIG_FILE"

    # Test and reload Nginx
    nginx -t && systemctl reload nginx
fi

# Set up automatic renewal
echo ""
echo "Setting up automatic SSL renewal..."
systemctl enable certbot.timer
systemctl start certbot.timer

echo ""
echo "=================================="
echo "✓ SSL Setup Complete!"
echo "=================================="
echo ""
echo "Your bolt.diy instance is now available at:"
echo "  https://$DOMAIN_NAME"
echo "  https://www.$DOMAIN_NAME"
echo ""
echo "SSL certificate will auto-renew before expiration."
echo ""
echo "All required headers for WebContainer are configured!"
echo "The SharedArrayBuffer errors should now be resolved."
echo ""
