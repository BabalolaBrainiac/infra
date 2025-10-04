#!/bin/bash
# PostgreSQL Server Setup Script for Hetzner Cloud
# This script installs and configures PostgreSQL with multiple databases

set -e

# Variables from Terraform
POSTGRES_VERSION="${postgres_version}"
ADMIN_USER="${admin_user}"
ADMIN_PASSWORD="${admin_password}"
BACKUP_ENABLED="${backup_enabled}"

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
apt-get install -y postgresql-${POSTGRES_VERSION} postgresql-client-${POSTGRES_VERSION} postgresql-contrib-${POSTGRES_VERSION}

# Start and enable PostgreSQL service
systemctl start postgresql
systemctl enable postgresql

# Configure PostgreSQL
PG_VERSION=$(sudo -u postgres psql -t -c "SELECT version();" | grep -oP '\d+\.\d+' | head -1)
PG_CONFIG_DIR="/etc/postgresql/${POSTGRES_VERSION}/main"
PG_DATA_DIR="/var/lib/postgresql/${POSTGRES_VERSION}/main"

echo "PostgreSQL ${POSTGRES_VERSION} installed successfully"

# Configure PostgreSQL for remote connections
cat >> ${PG_CONFIG_DIR}/postgresql.conf << EOF

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
cat >> ${PG_CONFIG_DIR}/pg_hba.conf << EOF

# Allow connections from any IP (restrict in production!)
host    all             all             0.0.0.0/0               md5
host    all             all             ::/0                    md5
EOF

# Set PostgreSQL admin password
sudo -u postgres psql -c "ALTER USER postgres PASSWORD '${ADMIN_PASSWORD}';"

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
if [ "${BACKUP_ENABLED}" = "true" ]; then
    echo "Setting up automated backups..."
    
    # Create backup directory
    mkdir -p /var/backups/postgresql
    chown postgres:postgres /var/backups/postgresql
    
    # Create backup script
    cat > /usr/local/bin/postgres-backup.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/var/backups/postgresql"
DATE=$(date +%Y%m%d_%H%M%S)

# Create backup for each database
for db in $(sudo -u postgres psql -t -c "SELECT datname FROM pg_database WHERE datistemplate = false;" | grep -v '^$'); do
    echo "Backing up database: $db"
    sudo -u postgres pg_dump $db > ${BACKUP_DIR}/${db}_${DATE}.sql
done

# Compress old backups (keep last 7 days)
find ${BACKUP_DIR} -name "*.sql" -mtime +7 -delete

echo "Backup completed at $(date)"
EOF

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
