# PostgreSQL Server on Hetzner Cloud

This configuration creates a dedicated PostgreSQL server on Hetzner Cloud using Debian 12, configured for hosting multiple databases for your projects.

## 🏗️ Architecture

- **Server**: Debian 12 on Hetzner Cloud
- **PostgreSQL**: Version 15 with optimized configuration
- **Storage**: Additional volume for database data
- **Security**: Firewall rules for PostgreSQL and SSH access
- **Backups**: Automated daily backups (optional)
- **Monitoring**: Basic logging and status monitoring

## 🚀 Quick Start

### Prerequisites

1. **Hetzner Cloud API Token**
   - Go to [Hetzner Cloud Console](https://console.hetzner.cloud/)
   - Create a new project
   - Generate an API token with read/write permissions

2. **SSH Key Pair**
   ```bash
   ssh-keygen -t ed25519 -C "your-email@example.com"
   ```

### Deployment

1. **Set environment variables:**
   ```bash
   export HCLOUD_TOKEN="your-api-token"
   export SSH_PUBLIC_KEY="$(cat ~/.ssh/id_ed25519.pub)"
   ```

2. **Deploy using the script:**
   ```bash
   cd infra/hetzner
   ./deploy.sh dev
   ```

3. **Or deploy manually:**
   ```bash
   terraform init
   terraform apply -var-file="environments/dev.tfvars" \
     -var="hcloud_token=$HCLOUD_TOKEN" \
     -var="ssh_public_key=$SSH_PUBLIC_KEY"
   ```

## 📋 Configuration

### Server Types

- **cx21** (Dev): 2 vCPU, 8GB RAM, 40GB SSD - €5.83/month
- **cx31** (Prod): 2 vCPU, 8GB RAM, 80GB SSD - €10.70/month
- **cx41** (High Load): 4 vCPU, 16GB RAM, 160GB SSD - €16.90/month

### Database Configuration

The server automatically creates databases based on the `databases` variable in your environment file:

```hcl
databases = [
  {
    name     = "myapp_dev"
    owner    = "myapp_user"
    password = "dev_password_123"
  },
  {
    name     = "myapp_prod"
    owner    = "myapp_user"
    password = "prod_password_123"
  }
]
```

## 🔐 Security Features

- **SSH Key Authentication**: No password-based SSH access
- **Firewall Rules**: Configurable network access controls
- **PostgreSQL Access Control**: IP-based connection restrictions
- **Encrypted Storage**: All volumes encrypted at rest
- **Secure Passwords**: Separate passwords for each database

## 💰 Cost Estimation

### Development Environment
- **Server (cx21)**: €5.83/month
- **Floating IP**: €1.19/month
- **Volume (50GB)**: €2.00/month
- **Total**: ~€9/month

### Production Environment
- **Server (cx31)**: €10.70/month
- **Floating IP**: €1.19/month
- **Volume (100GB)**: €4.00/month
- **Total**: ~€16/month

## 🔧 Management Commands

### Connect to Server
```bash
ssh root@$(terraform output -raw server_ipv4)
```

### Connect to PostgreSQL
```bash
# As admin
sudo -u postgres psql

# As specific user
psql -h $(terraform output -raw server_ipv4) -U myapp_user -d myapp_dev
```

### Check PostgreSQL Status
```bash
sudo systemctl status postgresql
sudo systemctl restart postgresql
```

### View Logs
```bash
sudo tail -f /var/log/postgresql/postgresql-15-main.log
```

### Backup Databases
```bash
# Manual backup
sudo -u postgres pg_dump myapp_dev > backup.sql

# Automated backups (if enabled)
ls /var/backups/postgresql/
```

## 📊 Monitoring

### Check Database Status
```bash
sudo -u postgres psql -c "SELECT datname, numbackends, xact_commit, xact_rollback FROM pg_stat_database;"
```

### Check Connections
```bash
sudo -u postgres psql -c "SELECT count(*) FROM pg_stat_activity;"
```

### Check Disk Usage
```bash
df -h
du -sh /var/lib/postgresql/
```

## 🔄 Environment Management

### Development Environment
- **Purpose**: Testing and development
- **Security**: Relaxed (allows connections from anywhere)
- **Features**: pgAdmin enabled, automated backups
- **Cost**: Optimized for development

### Production Environment
- **Purpose**: Live applications
- **Security**: Strict (IP restrictions)
- **Features**: pgAdmin disabled, enhanced monitoring
- **Cost**: Optimized for performance and reliability

## 🛠️ Customization

### Add New Database
1. Edit `environments/dev.tfvars` or `environments/prod.tfvars`
2. Add new database to the `databases` list
3. Run `terraform apply` to update

### Change Server Type
1. Update `server_type` in environment file
2. Run `terraform apply` to resize server

### Modify PostgreSQL Configuration
1. Edit `scripts/postgres-setup.sh`
2. Re-run deployment or manually update server

## 🆘 Troubleshooting

### Common Issues

1. **Connection Refused**
   - Check firewall rules
   - Verify PostgreSQL is running: `sudo systemctl status postgresql`
   - Check PostgreSQL logs: `sudo tail -f /var/log/postgresql/postgresql-15-main.log`

2. **Authentication Failed**
   - Verify database credentials in environment file
   - Check pg_hba.conf: `sudo cat /etc/postgresql/15/main/pg_hba.conf`

3. **Disk Space Issues**
   - Check disk usage: `df -h`
   - Clean old backups: `sudo find /var/backups/postgresql -name "*.sql" -mtime +7 -delete`

### Getting Help

- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Hetzner Cloud Documentation](https://docs.hetzner.com/cloud/)
- Check server logs: `sudo journalctl -u postgresql`

## 🔮 Future Enhancements

- **High Availability**: Master-slave replication
- **Load Balancing**: Multiple read replicas
- **Monitoring**: Prometheus + Grafana setup
- **Automated Scaling**: Auto-scaling based on load
- **Disaster Recovery**: Cross-region backups
