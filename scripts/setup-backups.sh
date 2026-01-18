#!/bin/bash

# Backup Setup Script for MIMAH ERP
# Configures automated daily backups

set -e

echo "========================================="
echo "MIMAH ERP Backup Configuration"
echo "========================================="
echo ""

SITE_NAME="mimah.sohob.co.uk"
BACKUP_DIR="/home/frappe/backups"

echo "This script will set up automated daily backups for: $SITE_NAME"
echo ""

# Create backup directory if it doesn't exist
echo "Creating backup directory..."
mkdir -p "$BACKUP_DIR"

echo "✓ Backup directory created"
echo ""

# Test manual backup
echo "Testing manual backup..."
docker compose -f docker-compose.production.yml exec backend \
  bench --site "$SITE_NAME" backup --with-files

echo ""
echo "✓ Manual backup successful"
echo ""

# Get backup location
echo "Backup files are stored in the 'sites' Docker volume"
echo "Inside container path: /home/frappe/frappe-bench/sites/$SITE_NAME/private/backups/"
echo ""

# Create backup script
cat > /tmp/backup-mimah.sh << 'EOF'
#!/bin/bash
# Daily backup script for MIMAH ERP
set -e

SITE_NAME="mimah.sohob.co.uk"
BACKUP_RETENTION_DAYS=30

echo "[$(date)] Starting backup for $SITE_NAME..."

# Run backup
docker compose -f /home/frappe/frappe_docker/docker-compose.production.yml exec -T backend \
  bench --site "$SITE_NAME" backup --with-files

echo "[$(date)] Backup completed successfully"

# Clean up old backups (older than 30 days)
docker compose -f /home/frappe/frappe_docker/docker-compose.production.yml exec -T backend \
  find /home/frappe/frappe-bench/sites/"$SITE_NAME"/private/backups/ -type f -mtime +$BACKUP_RETENTION_DAYS -delete

echo "[$(date)] Old backups cleaned up"
EOF

echo "Backup script created at: /tmp/backup-mimah.sh"
echo ""

# Provide cron instructions
echo "========================================="
echo "Backup Setup Instructions"
echo "========================================="
echo ""
echo "To enable automated daily backups, add this to your crontab:"
echo ""
echo "# MIMAH ERP Daily Backup at 2 AM"
echo "0 2 * * * /path/to/backup-mimah.sh >> /var/log/mimah-backup.log 2>&1"
echo ""
echo "To edit crontab, run: crontab -e"
echo ""
echo "Manual backup command:"
echo "  docker compose -f docker-compose.production.yml exec backend bench --site $SITE_NAME backup --with-files"
echo ""
echo "List all backups:"
echo "  docker compose -f docker-compose.production.yml exec backend bench --site $SITE_NAME list-backups"
echo ""
echo "Restore from backup:"
echo "  docker compose -f docker-compose.production.yml exec backend bench --site $SITE_NAME restore --with-public-files --with-private-files [backup-file]"
echo ""
echo "Export backups from Docker volume:"
echo "  docker compose -f docker-compose.production.yml cp backend:/home/frappe/frappe-bench/sites/$SITE_NAME/private/backups ./backups/"
echo ""
