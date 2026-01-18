#!/bin/bash

# Manual Deployment Script for MIMAH ERP
# Use this if Coolify UI is giving issues

set -e

echo "========================================="
echo "MIMAH ERP - Manual Deployment Script"
echo "========================================="
echo ""

# Configuration
DEPLOY_DIR="/opt/mimah-erp"
REPO_URL="https://github.com/YGAtabani/frappe_docker.git"
BRANCH="claude/setup-frappe-coolify-ENAHl"

echo "This script will deploy MIMAH ERP manually"
echo "Deploy directory: $DEPLOY_DIR"
echo ""

# Check if running as root or with sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please run with sudo:"
    echo "  sudo bash deploy-manual.sh"
    exit 1
fi

# Clone or update repository
if [ -d "$DEPLOY_DIR" ]; then
    echo "Directory exists, pulling latest changes..."
    cd "$DEPLOY_DIR"
    git pull origin "$BRANCH"
else
    echo "Cloning repository..."
    git clone -b "$BRANCH" "$REPO_URL" "$DEPLOY_DIR"
    cd "$DEPLOY_DIR"
fi

echo "✓ Repository ready"
echo ""

# Create .env file
echo "Creating .env file..."
cat > .env << 'EOF'
ERPNEXT_VERSION=v15.94.3
DB_PASSWORD=MmH$9xR2!vL4pQ7wK@Db2026
DB_HOST=mariadb
DB_PORT=3306
REDIS_CACHE=redis-cache:6379
REDIS_QUEUE=redis-queue:6379
LETSENCRYPT_EMAIL=admin@sohob.co.uk
FRAPPE_SITE_NAME_HEADER=mimah.sohob.co.uk
SITES=`mimah.sohob.co.uk`
HTTP_PUBLISH_PORT=8080
PROXY_READ_TIMEOUT=300
CLIENT_MAX_BODY_SIZE=100m
UPSTREAM_REAL_IP_ADDRESS=172.17.0.0/16
UPSTREAM_REAL_IP_HEADER=X-Forwarded-For
UPSTREAM_REAL_IP_RECURSIVE=on
CUSTOM_IMAGE=frappe/erpnext
CUSTOM_TAG=v15.94.3
PULL_POLICY=always
RESTART_POLICY=unless-stopped
EOF

echo "✓ Environment file created"
echo ""

# Deploy with Docker Compose
echo "Starting Docker Compose deployment..."
echo "This will download ~2GB of images (5-10 minutes)..."
echo ""

docker compose -f docker-compose.yaml up -d

echo ""
echo "✓ Deployment started"
echo ""

# Wait for services
echo "Waiting for services to be healthy (30 seconds)..."
sleep 30

# Check status
echo ""
echo "Container Status:"
docker compose -f docker-compose.yaml ps

echo ""
echo "========================================="
echo "Deployment Complete!"
echo "========================================="
echo ""
echo "Next steps:"
echo "1. Verify all containers are running above"
echo "2. Set up nginx reverse proxy (see instructions below)"
echo "3. Create the ERPNext site:"
echo "   cd $DEPLOY_DIR"
echo "   ./scripts/create-mimah-site.sh"
echo ""
echo "To view logs:"
echo "   docker compose -f $DEPLOY_DIR/docker-compose.yaml logs -f"
echo ""
