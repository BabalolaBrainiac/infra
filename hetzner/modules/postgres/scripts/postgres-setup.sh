#!/bin/bash
# PostgreSQL Server Setup Script for Hetzner Cloud
# This script installs and configures PostgreSQL with multiple databases

set -e

# Variables from Terraform
postgres_version=${postgres_version}
admin_user=${admin_user}
admin_password=${admin_password}
backup_enabled=${backup_enabled}

echo "Starting PostgreSQL server setup..."

# Update system packages
apt-get update
apt-get upgrade -y

# Install essential packages
apt-get install -y curl wget git htop vim postgresql-client

# Add PostgreSQL official repository
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list

# Update package list and install PostgreSQL
apt-get update
apt-get install -y postgresql-${postgres_version} postgresql-client-${postgres_version} postgresql-contrib-${postgres_version}

# Start and enable PostgreSQL service
systemctl start postgresql
systemctl enable postgresql

# Configure PostgreSQL
PG_VERSION=$(sudo -u postgres psql -t -c "SELECT version();" | grep -oP '\d+\.\d+' | head -1)
PG_CONFIG_DIR="/etc/postgresql/${postgres_version}/main"
PG_DATA_DIR="/var/lib/postgresql/${postgres_version}/main"

echo "PostgreSQL ${postgres_version} installed successfully"

# Configure PostgreSQL for remote connections
cat >> /etc/postgresql/${postgres_version}/main/postgresql.conf << EOF

# Custom configuration for multi-database server
listen_addresses = '*'
port = 5432
max_connections = 100
shared_buffers = 256MB
effective_cache_size = 1GB
maintenance_work_mem = 64MB
checkpoint_completion_target = 0.9
wal_buffers = 16MB
default_statistics_target = 100
random_page_cost = 1.1
effective_io_concurrency = 200
work_mem = 4MB
min_wal_size = 1GB
max_wal_size = 4GB

# Logging
log_destination = 'stderr'
logging_collector = on
log_directory = 'log'
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
log_rotation_age = 1d
log_rotation_size = 100MB
log_min_duration_statement = 1000
log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h '
log_checkpoints = on
log_connections = on
log_disconnections = on
log_lock_waits = on
log_temp_files = -1
log_autovacuum_min_duration = 0
log_error_verbosity = default
EOF

# Configure pg_hba.conf for remote connections
cat >> /etc/postgresql/${postgres_version}/main/pg_hba.conf << EOF

# Allow connections from any IP (restrict in production!)
host    all             all             0.0.0.0/0               md5
host    all             all             ::/0                    md5
EOF

# Set PostgreSQL admin password
sudo -u postgres psql -c "ALTER USER postgres PASSWORD '${admin_password}';"

# Create databases and users
%{ for db in databases ~}
echo "Creating database: ${db.name}"
sudo -u postgres createdb ${db.name}

echo "Creating user: ${db.owner}"
sudo -u postgres psql -c "CREATE USER ${db.owner} WITH PASSWORD '${db.password}';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE ${db.name} TO ${db.owner};"
sudo -u postgres psql -c "ALTER USER ${db.owner} CREATEDB;"

%{ endfor ~}

# Mount additional volume if it exists
if [ -b /dev/sdb ]; then
    echo "Setting up additional volume..."
    
    # Create filesystem if not already created
    if ! blkid /dev/sdb; then
        mkfs.ext4 /dev/sdb
    fi
    
    # Create mount point
    mkdir -p /var/lib/postgresql/data
    
    # Mount the volume
    mount /dev/sdb /var/lib/postgresql/data
    
    # Add to fstab for persistent mounting
    echo "/dev/sdb /var/lib/postgresql/data ext4 defaults 0 2" >> /etc/fstab
    
    # Set proper ownership
    chown -R postgres:postgres /var/lib/postgresql/data
    chmod 700 /var/lib/postgresql/data
    
    echo "Additional volume mounted at /var/lib/postgresql/data"
fi

# Setup automated backups if enabled
if [ "${backup_enabled}" = "true" ]; then
    echo "Setting up automated backups..."
    
    # Create backup directory
    mkdir -p /var/backups/postgresql
    chown postgres:postgres /var/backups/postgresql
    
    # Create a separate backup script file
    cat > /tmp/backup-script.sh << 'BACKUP_EOF'
#!/bin/bash

# Configuration
BACKUP_DIR="/var/backups/postgresql/$(date +%Y-%m-%d)"
LOG_FILE="/var/log/postgres-backup.log"
KEEP_DAYS=7

# Create log directory if it doesn't exist
mkdir -p "$(dirname "$LOG_FILE")"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting PostgreSQL backup" | tee -a "$LOG_FILE"

# Ensure backup directory exists
mkdir -p "$BACKUP_DIR"
chown postgres:postgres "$BACKUP_DIR"

# Backup globals (roles, tablespaces, etc.)
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Backing up global objects" | tee -a "$LOG_FILE"
if ! sudo -u postgres pg_dumpall --globals-only | gzip > "$BACKUP_DIR/globals.sql.gz"; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: Failed to backup global objects" | tee -a "$LOG_FILE"
fi

# Get list of databases to backup (excluding system databases)
DATABASES=$(sudo -u postgres psql -t -c "SELECT datname FROM pg_database WHERE datistemplate = false AND datname NOT IN ('postgres', 'template0', 'template1');" | grep -v '^$' | awk '{$1=$1};1')

# Backup each database
for DB_TO_BACKUP in $DATABASES; do
    BACKUP_FILE="$BACKUP_DIR/$DB_TO_BACKUP.sql.gz"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Backing up database: $DB_TO_BACKUP" | tee -a "$LOG_FILE"
    
    if ! sudo -u postgres pg_dump "$DB_TO_BACKUP" | gzip > "$BACKUP_FILE"; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: Failed to backup database: $DB_TO_BACKUP" | tee -a "$LOG_FILE"
        continue
    fi
    
    # Set proper permissions
    chmod 600 "$BACKUP_FILE"
    chown postgres:postgres "$BACKUP_FILE"
    
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Successfully backed up: $DB_TO_BACKUP" | tee -a "$LOG_FILE"
done

# Clean up old backups
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Cleaning up backups older than $KEEP_DAYS days" | tee -a "$LOG_FILE"
find "$(dirname "$BACKUP_DIR")" -maxdepth 1 -type d -mtime +$KEEP_DAYS -exec echo "Removing old backup: {}" \; -exec rm -rf {} \; | tee -a "$LOG_FILE"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Backup completed" | tee -a "$LOG_FILE"
BACKUP_EOF

    # Move the script to its final location and set permissions
    mv /tmp/backup-script.sh /usr/local/bin/postgres-backup.sh
    chmod +x /usr/local/bin/postgres-backup.sh
    
    # Add to crontab for daily backups at 2 AM
    (crontab -l 2>/dev/null; echo "0 2 * * * /usr/local/bin/postgres-backup.sh") | crontab -
    
    echo "Automated backups configured"
fi

# Restart PostgreSQL to apply configuration changes
systemctl restart postgresql

# Verify PostgreSQL is running
systemctl status postgresql --no-pager

echo "PostgreSQL server setup completed successfully!"
echo "PostgreSQL version: $(sudo -u postgres psql -t -c 'SELECT version();')"
echo "Available databases:"
sudo -u postgres psql -c "\l"

echo "Server is ready for database connections!"
