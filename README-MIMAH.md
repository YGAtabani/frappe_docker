# MIMAH ERP System

Production-ready ERPNext deployment for MIMAH, optimized for Coolify.

## 🎯 Quick Start

This repository is configured for deploying MIMAH's ERPNext system to Coolify with:
- Domain: `mimah.sohob.co.uk`
- Focus: Accounting and financial management
- Version: ERPNext v15 (latest stable)

## 📁 Important Files

| File | Description |
|------|-------------|
| `docker-compose.yml` | Production docker compose configuration |
| `.env.production` | Environment variables (NOT in git - contains passwords) |
| `.env.production.example` | Template for environment variables |
| `DEPLOYMENT.md` | Complete deployment guide for Coolify |
| `PASSWORDS.md` | System credentials (NOT in git - keep secure!) |
| `scripts/create-mimah-site.sh` | Automated site creation script |
| `scripts/setup-backups.sh` | Backup configuration script |

## 🚀 Deployment

See **[DEPLOYMENT.md](DEPLOYMENT.md)** for complete step-by-step instructions.

### Quick Deploy to Coolify

1. **In Coolify Dashboard:**
   - Create new Docker Compose service
   - Point to this repository
   - Use `docker-compose.yml`
   - Set domain: `mimah.sohob.co.uk`
   - Configure environment variables from `.env.production`

2. **After Deployment:**
   ```bash
   # Create the ERPNext site
   ./scripts/create-mimah-site.sh
   ```

3. **Access:**
   - URL: https://mimah.sohob.co.uk
   - Username: Administrator
   - Password: See `PASSWORDS.md`

## 🔐 Security

**Important Files NOT in Git** (see `.gitignore`):
- `.env.production` - Contains database passwords
- `PASSWORDS.md` - Contains all system credentials

These files are on the server but not committed to version control for security.

## 📦 What's Included

### Services
- **ERPNext v15** - Latest stable version
- **MariaDB 11.8** - Database
- **Redis** - Caching and queues
- **Nginx** - Web server
- **Gunicorn** - Application server
- **Background Workers** - Job processing
- **Scheduler** - Automated tasks

### Features
- ✅ UK-specific accounting
- ✅ Multi-currency support
- ✅ VAT/Tax management
- ✅ Financial reporting
- ✅ Automated backups
- ✅ SSL/TLS encryption
- ✅ Production-ready configuration

## 💾 Backups

Automated daily backups configured. See `scripts/setup-backups.sh` for details.

**Manual backup:**
```bash
docker compose -f docker-compose.yml exec backend \
  bench --site mimah.sohob.co.uk backup --with-files
```

## 🔧 Common Operations

### View Logs
```bash
docker compose -f docker-compose.yml logs -f
```

### Restart Services
```bash
docker compose -f docker-compose.yml restart
```

### Access Backend Shell
```bash
docker compose -f docker-compose.yml exec backend bash
```

### Clear Cache
```bash
docker compose -f docker-compose.yml exec backend \
  bench --site mimah.sohob.co.uk clear-cache
```

## 📚 Documentation

- [Full Deployment Guide](DEPLOYMENT.md)
- [ERPNext User Manual](https://docs.erpnext.com/)
- [Accounting Guide](https://docs.erpnext.com/docs/user/manual/en/accounts)
- [Frappe Framework Docs](https://frappeframework.com/docs)

## 🆘 Support

- **Documentation Issues**: Check `DEPLOYMENT.md`
- **ERPNext Community**: https://discuss.erpnext.com/
- **Technical Questions**: admin@sohob.co.uk

## 📝 System Information

- **Company**: MIMAH
- **Domain**: mimah.sohob.co.uk
- **Email**: admin@sohob.co.uk
- **Deployment**: Coolify
- **Version**: ERPNext v15.94.3
- **Database**: MariaDB 11.8
- **Focus**: Accounting & Finance

## 🔄 Updating

To update ERPNext to a newer version:

1. Update version in `.env.production`
2. Pull new images: `docker compose -f docker-compose.yml pull`
3. Restart services: `docker compose -f docker-compose.yml up -d`
4. Run migrations: `docker compose -f docker-compose.yml exec backend bench --site mimah.sohob.co.uk migrate`

## ⚠️ Important Notes

1. **Never commit passwords** - `.env.production` and `PASSWORDS.md` are git-ignored
2. **Regular backups** - Set up automated backups (see `scripts/setup-backups.sh`)
3. **Change default passwords** - After first login, change the Administrator password
4. **Enable 2FA** - Set up two-factor authentication for security
5. **Keep updated** - Regularly update ERPNext for security patches

## 📞 Contact

For questions about this deployment:
- Email: admin@sohob.co.uk
- Company: MIMAH

---

**Setup Date**: 2026-01-18
**Last Updated**: 2026-01-18
