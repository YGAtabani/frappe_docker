# MIMAH ERP - Coolify Deployment Guide

Complete step-by-step guide for deploying MIMAH's ERPNext instance to Coolify.

## 📋 Pre-Deployment Checklist

Before starting the deployment, ensure you have:

- ✅ Access to your Coolify dashboard
- ✅ Domain configured: `mimah.sohob.co.uk` pointing to your Coolify server
- ✅ This repository forked and accessible from Coolify
- ✅ Passwords saved securely (see `PASSWORDS.md`)

## 🚀 Deployment Steps

### Step 1: Create New Service in Coolify

1. Log in to your Coolify dashboard
2. Navigate to your project
3. Click **"+ New Resource"**
4. Select **"Docker Compose"**

### Step 2: Configure the Service

1. **Service Name**: `mimah-erp`
2. **Git Repository**: Your forked repository URL
   - Example: `https://github.com/YGAtabani/frappe_docker.git`
3. **Branch**: `claude/setup-frappe-coolify-ENAHl`
4. **Docker Compose File Path**: `docker-compose.yaml` (default, auto-detected)

### Step 3: Configure Environment Variables

In Coolify's environment variables section, add the following:

**Copy the entire content from `.env.production`** or manually add:

```env
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
```

### Step 4: Configure Domain

1. In Coolify, go to the **Domains** tab
2. Add domain: `mimah.sohob.co.uk`
3. Enable **SSL/TLS** (Let's Encrypt automatic)
4. Set the port to: `8080` (this matches the frontend service)

### Step 5: Configure Persistent Storage

Coolify should automatically detect the volumes from docker-compose.yaml:
- `sites` - ERPNext site data
- `mariadb-data` - Database
- `redis-cache-data` - Redis cache
- `redis-queue-data` - Redis queue

Ensure these are configured as **persistent volumes** in Coolify.

### Step 6: Deploy

1. Click **"Deploy"**
2. Monitor the deployment logs
3. Wait for all services to start (approximately 5-10 minutes)
4. Look for: `✓ configurator exited successfully`

### Step 7: Create the ERPNext Site

Once all containers are running, execute the site creation script:

**Option A: Via Coolify Terminal**
1. Open Coolify terminal for the `backend` service
2. Run:
```bash
cd /workspace
./scripts/create-mimah-site.sh
```

**Option B: Via SSH to Coolify Server**
```bash
# SSH to your Coolify server
ssh user@your-coolify-server

# Navigate to the project directory
cd /path/to/coolify/mimah-erp

# Run the script
./scripts/create-mimah-site.sh
```

**Option C: Manual Site Creation**
```bash
docker compose -f docker-compose.yaml exec backend \
  bench new-site mimah.sohob.co.uk \
  --mariadb-root-password "MmH\$9xR2!vL4pQ7wK@Db2026" \
  --admin-password "ErP#Mm8!Hx5aQ9wN@Adm2026" \
  --install-app erpnext
```

### Step 8: Access Your ERP

1. Open browser and navigate to: `https://mimah.sohob.co.uk`
2. Log in with:
   - **Username**: `Administrator`
   - **Password**: See `PASSWORDS.md`

### Step 9: Complete Setup Wizard

1. **Language**: English (United Kingdom)
2. **Country**: United Kingdom
3. **Timezone**: Europe/London
4. **Currency**: GBP (£)
5. **Company Name**: MIMAH
6. **Company Abbreviation**: MIMAH
7. **Domain**: Services or select appropriate industry

## 📊 Post-Deployment Configuration

### Set Up Chart of Accounts

1. Go to **Accounting** → **Chart of Accounts**
2. Select **United Kingdom - Chart of Accounts**
3. Customize as needed for your business

### Configure Company Details

1. Go to **Setup** → **Company**
2. Fill in:
   - Company Name: MIMAH
   - Default Currency: GBP
   - Country: United Kingdom
   - Company Address
   - Tax ID (if applicable)

### Enable Required Modules

For accounting focus, ensure these are enabled:
- ✅ Accounting
- ✅ Buying
- ✅ Selling
- ✅ Stock (for inventory if needed)
- ✅ CRM (for customer management)

### Set Up Users

1. Go to **Setup** → **User**
2. Create users for your team members
3. Assign appropriate roles:
   - Accounts Manager
   - Accounts User
   - Sales Manager
   - etc.

## 🔒 Security Recommendations

### 1. Change Default Password
After first login, change the Administrator password:
- Go to **Administrator** profile → **Change Password**

### 2. Enable Two-Factor Authentication
- Go to **User** → **Enable Two Factor Authentication**

### 3. Set Up Email
Configure email for notifications:
1. Go to **Settings** → **Email Domain**
2. Add your email domain
3. Configure SMTP settings

### 4. Regular Backups
Set up automated backups (see Backup section below)

## 💾 Backup Strategy

### Automated Daily Backups

Run the backup setup script:
```bash
./scripts/setup-backups.sh
```

This will:
- Test backup functionality
- Create backup script
- Provide cron configuration instructions

### Manual Backup

To create a manual backup:
```bash
docker compose -f docker-compose.yaml exec backend \
  bench --site mimah.sohob.co.uk backup --with-files
```

### Download Backups

To download backups to your local machine:
```bash
docker compose -f docker-compose.yaml cp \
  backend:/home/frappe/frappe-bench/sites/mimah.sohob.co.uk/private/backups \
  ./local-backups/
```

### Restore from Backup

```bash
# 1. List available backups
docker compose -f docker-compose.yaml exec backend \
  bench --site mimah.sohob.co.uk list-backups

# 2. Restore from specific backup
docker compose -f docker-compose.yaml exec backend \
  bench --site mimah.sohob.co.uk restore \
  --with-public-files \
  --with-private-files \
  [backup-file-name]
```

## 🔧 Maintenance

### View Logs

**All services:**
```bash
docker compose -f docker-compose.yaml logs -f
```

**Specific service:**
```bash
docker compose -f docker-compose.yaml logs -f backend
```

### Restart Services

**All services:**
```bash
docker compose -f docker-compose.yaml restart
```

**Specific service:**
```bash
docker compose -f docker-compose.yaml restart backend
```

### Update ERPNext

To update to a newer version:

1. Update `.env.production`:
```env
ERPNEXT_VERSION=v15.XX.X  # New version
CUSTOM_TAG=v15.XX.X
```

2. Pull new images and restart:
```bash
docker compose -f docker-compose.yaml pull
docker compose -f docker-compose.yaml up -d
```

3. Run migrations:
```bash
docker compose -f docker-compose.yaml exec backend \
  bench --site mimah.sohob.co.uk migrate
```

### Monitor Resources

Check container resource usage:
```bash
docker stats
```

## 🐛 Troubleshooting

### Site Not Loading

1. Check all containers are running:
```bash
docker compose -f docker-compose.yaml ps
```

2. Check frontend logs:
```bash
docker compose -f docker-compose.yaml logs frontend
```

3. Verify site exists:
```bash
docker compose -f docker-compose.yaml exec backend bench list-sites
```

### Database Connection Issues

1. Check MariaDB health:
```bash
docker compose -f docker-compose.yaml exec mariadb mysqladmin ping -p
```

2. Verify database password in `.env.production`

3. Restart configurator:
```bash
docker compose -f docker-compose.yaml restart configurator
```

### Slow Performance

1. Check resource usage:
```bash
docker stats
```

2. Increase MariaDB buffer pool (in docker-compose.yaml):
```yaml
--innodb-buffer-pool-size=2G  # Increase if you have RAM
```

3. Scale worker containers:
```bash
docker compose -f docker-compose.yaml up -d --scale queue-short=2 --scale queue-long=2
```

### Cannot Access via Domain

1. Verify DNS is pointing to Coolify server:
```bash
dig mimah.sohob.co.uk
```

2. Check Coolify proxy configuration
3. Verify SSL certificate was issued:
```bash
docker compose -f docker-compose.yaml logs frontend | grep -i ssl
```

## 📚 Useful Commands

### Bench Commands (Inside Backend Container)

```bash
# Enter backend container
docker compose -f docker-compose.yaml exec backend bash

# List all sites
bench list-sites

# Access database console
bench --site mimah.sohob.co.uk mariadb

# Access Python console
bench --site mimah.sohob.co.uk console

# Clear cache
bench --site mimah.sohob.co.uk clear-cache

# Rebuild assets
bench build

# Enable/Disable maintenance mode
bench --site mimah.sohob.co.uk set-maintenance-mode on
bench --site mimah.sohob.co.uk set-maintenance-mode off
```

## 📞 Support and Resources

### Documentation
- [ERPNext User Manual](https://docs.erpnext.com/)
- [Frappe Framework Docs](https://frappeframework.com/docs)
- [Frappe Docker Docs](https://github.com/frappe/frappe_docker/tree/main/docs)

### Community
- [Frappe Forum](https://discuss.frappe.io/)
- [ERPNext Community](https://discuss.erpnext.com/)

### Accounting Resources
- [ERPNext Accounting Guide](https://docs.erpnext.com/docs/user/manual/en/accounts)
- [UK Accounting Setup](https://docs.erpnext.com/docs/user/manual/en/regional/united-kingdom)

## ✅ Deployment Checklist

- [ ] Coolify service created and deployed
- [ ] All containers running (check `docker compose ps`)
- [ ] Site created via creation script
- [ ] Accessed site at https://mimah.sohob.co.uk
- [ ] Completed setup wizard
- [ ] Changed Administrator password
- [ ] Configured company details
- [ ] Set up Chart of Accounts (UK)
- [ ] Created team user accounts
- [ ] Configured email settings
- [ ] Tested backup creation
- [ ] Set up automated backups
- [ ] Documented custom configurations

## 🎉 Success!

Your MIMAH ERP system is now deployed and ready to use!

Start with:
1. Setting up your Chart of Accounts
2. Creating customer/supplier records
3. Recording your first invoices
4. Exploring accounting reports

For specific accounting workflows, refer to the [ERPNext Accounting Manual](https://docs.erpnext.com/docs/user/manual/en/accounts).
