#!/bin/bash

# Site Creation Script for MIMAH ERP
# Domain: mimah.sohob.co.uk
# This script creates the ERPNext site with proper configuration

set -e

echo "========================================="
echo "MIMAH ERP Site Creation Script"
echo "========================================="
echo ""

# Configuration
SITE_NAME="mimah.sohob.co.uk"
DB_ROOT_PASSWORD="MmH\$9xR2!vL4pQ7wK@Db2026"
ADMIN_PASSWORD="ErP#Mm8!Hx5aQ9wN@Adm2026"
COMPANY_NAME="MIMAH"

echo "Site Name: $SITE_NAME"
echo "Company: $COMPANY_NAME"
echo ""

# Check if containers are running
echo "Checking if containers are running..."
if ! docker compose -f docker-compose.production.yml ps | grep -q "backend"; then
    echo "ERROR: Backend container is not running!"
    echo "Please start the containers first with:"
    echo "  docker compose -f docker-compose.production.yml up -d"
    exit 1
fi

echo "✓ Containers are running"
echo ""

# Wait for services to be ready
echo "Waiting for services to be ready..."
sleep 10

# Check if site already exists
echo "Checking if site already exists..."
if docker compose -f docker-compose.production.yml exec -T backend bench list-sites | grep -q "$SITE_NAME"; then
    echo "WARNING: Site $SITE_NAME already exists!"
    echo "If you want to recreate it, first drop it with:"
    echo "  docker compose -f docker-compose.production.yml exec backend bench drop-site $SITE_NAME --force"
    exit 1
fi

echo "✓ Site does not exist yet"
echo ""

# Create the site
echo "Creating site: $SITE_NAME"
echo "This may take 5-10 minutes..."
echo ""

docker compose -f docker-compose.production.yml exec backend \
  bench new-site "$SITE_NAME" \
  --mariadb-root-password "$DB_ROOT_PASSWORD" \
  --admin-password "$ADMIN_PASSWORD" \
  --verbose

echo ""
echo "✓ Site created successfully"
echo ""

# Install ERPNext app
echo "Installing ERPNext application..."
docker compose -f docker-compose.production.yml exec backend \
  bench --site "$SITE_NAME" install-app erpnext

echo ""
echo "✓ ERPNext installed successfully"
echo ""

# Set up company
echo "Setting up company: $COMPANY_NAME"
docker compose -f docker-compose.production.yml exec backend \
  bench --site "$SITE_NAME" execute "frappe.db.set_single_value('System Settings', 'country', 'United Kingdom')"

echo ""
echo "✓ Company setup complete"
echo ""

# Enable scheduler
echo "Enabling scheduler..."
docker compose -f docker-compose.production.yml exec backend \
  bench --site "$SITE_NAME" enable-scheduler

echo ""
echo "✓ Scheduler enabled"
echo ""

# Set site as default
echo "Setting site as default..."
docker compose -f docker-compose.production.yml exec backend \
  bench use "$SITE_NAME"

echo ""
echo "========================================="
echo "Site Creation Complete!"
echo "========================================="
echo ""
echo "Site URL: https://$SITE_NAME"
echo "Username: Administrator"
echo "Password: $ADMIN_PASSWORD"
echo ""
echo "IMPORTANT: Please save these credentials securely!"
echo ""
echo "Next steps:"
echo "1. Access your site at https://$SITE_NAME"
echo "2. Log in with the Administrator credentials"
echo "3. Complete the setup wizard"
echo "4. Set up your company details and accounting"
echo ""
echo "For backup configuration, run:"
echo "  ./scripts/setup-backups.sh"
echo ""
