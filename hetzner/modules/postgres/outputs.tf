# PostgreSQL Module Outputs

# Server Information
output "server_id" {
  description = "ID of the PostgreSQL server"
  value       = module.postgres_server.server_id
}

output "server_name" {
  description = "Name of the PostgreSQL server"
  value       = module.postgres_server.server_name
}

output "server_ipv4" {
  description = "IPv4 address of the PostgreSQL server"
  value       = module.postgres_server.server_ipv4
}

output "server_ipv6" {
  description = "IPv6 address of the PostgreSQL server"
  value       = module.postgres_server.server_ipv6
}

output "floating_ip" {
  description = "Floating IP address of the PostgreSQL server"
  value       = module.postgres_server.floating_ip_address
}

# Storage Information
output "volume_id" {
  description = "ID of the attached volume"
  value       = module.postgres_server.volume_id
}

output "volume_device" {
  description = "Device path of the attached volume"
  value       = module.postgres_server.volume_id
}

# Connection Information
output "postgres_connection_info" {
  description = "PostgreSQL connection information"
  value = {
    host     = module.postgres_server.floating_ip_address != null ? module.postgres_server.floating_ip_address : module.postgres_server.server_ipv4
    port     = 5432
    database = "postgres"
    username = var.postgres_admin_user
  }
  sensitive = true
}

output "database_connection_strings" {
  description = "Complete connection strings for each database"
  value = {
    for db in var.databases : db.name => "postgresql://${db.owner}:${random_password.database_passwords[db.name].result}@${module.postgres_server.floating_ip_address != null ? module.postgres_server.floating_ip_address : module.postgres_server.server_ipv4}:5432/${db.name}"
  }
  sensitive = true
}

output "admin_connection_string" {
  description = "Admin connection string"
  value       = "postgresql://${var.postgres_admin_user}:${random_password.postgres_admin_password.result}@${module.postgres_server.floating_ip_address != null ? module.postgres_server.floating_ip_address : module.postgres_server.server_ipv4}:5432/postgres"
  sensitive   = true
}

# Access Information
output "ssh_connection_command" {
  description = "SSH connection command"
  value       = "ssh root@${module.postgres_server.floating_ip_address != null ? module.postgres_server.floating_ip_address : module.postgres_server.server_ipv4}"
}

output "pgadmin_url" {
  description = "pgAdmin web interface URL (if enabled)"
  value       = var.enable_pgadmin ? "http://${module.postgres_server.floating_ip_address != null ? module.postgres_server.floating_ip_address : module.postgres_server.server_ipv4}:5050" : null
}

# # Security Information
# output "firewall_id" {
#   description = "ID of the PostgreSQL firewall"
#   value       = hcloud_firewall.postgres.id
# }

# Password Management
output "password_file_location" {
  description = "Location of the password file"
  value       = local_file.postgres_passwords.filename
}

output "password_retrieval_command" {
  description = "Command to retrieve passwords"
  value       = "cat ${local_file.postgres_passwords.filename} | jq"
}
