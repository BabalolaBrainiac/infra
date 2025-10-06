# PostgreSQL Module Main Configuration

# Generate secure passwords
resource "random_password" "postgres_admin_password" {
  length  = var.password_length
  special = var.password_special_chars
}

resource "random_password" "database_passwords" {
  for_each = { for db in var.databases : db.name => db }
  length  = var.password_length
  special = var.password_special_chars
}

# Store passwords securely
resource "local_file" "postgres_passwords" {
  filename = "${path.module}/.passwords.json"
  content = jsonencode({
    postgres_admin_password = random_password.postgres_admin_password.result
    database_passwords = {
      for db_name, password in random_password.database_passwords : db_name => password.result
    }
    generated_at = timestamp()
    server_name  = var.server_name
  })
  file_permission = "0600"
}

# PostgreSQL Database Server
module "postgres_server" {
  source = "../server"

  server_name     = var.server_name
  image           = "debian-12"  # Debian 12 for PostgreSQL hosting
  server_type     = var.server_type
  location        = var.location
  ssh_public_key  = var.ssh_public_key

  enable_firewall     = true
  enable_web_access   = false  # No web access needed for database server
  allowed_ssh_ips    = var.allowed_ssh_ips
  
  create_volume      = true
  volume_size        = var.volume_size  # Additional storage for databases
  
  # Network configuration
  create_private_network = var.create_private_network
  network_ip_range      = var.network_ip_range
  network_zone          = var.network_zone
  subnet_ip_range       = var.subnet_ip_range
  server_private_ip     = var.server_private_ip
  server_alias_ips      = var.server_alias_ips
  enable_ipv6           = var.enable_ipv6
  
  # Cloud-init script to install and configure PostgreSQL
  user_data = templatefile("${path.module}/scripts/postgres-setup.sh", jsonencode({
    postgres_version = var.postgres_version
    admin_user       = var.postgres_admin_user
    admin_password   = random_password.postgres_admin_password.result
    databases        = [
      for db in var.databases : {
        name     = db.name
        owner    = db.owner
        password = random_password.database_passwords[db.name].result
      }
    ]
    backup_enabled   = var.backup_enabled
  }))
  
  labels = merge(var.labels, {
    Service     = "postgresql"
    PostgreSQL  = var.postgres_version
  })
}