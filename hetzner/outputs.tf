# Outputs for Babalola's Hetzner Infrastructure

# PostgreSQL Service Outputs
output "postgres_server_id" {
  description = "ID of the PostgreSQL server"
  value       = module.postgres.server_id
}

output "postgres_server_name" {
  description = "Name of the PostgreSQL server"
  value       = module.postgres.server_name
}

output "postgres_server_ipv4" {
  description = "IPv4 address of the PostgreSQL server"
  value       = module.postgres.server_ipv4
}

output "postgres_server_ipv6" {
  description = "IPv6 address of the PostgreSQL server"
  value       = module.postgres.server_ipv6
}

output "postgres_floating_ip" {
  description = "Floating IP address of the PostgreSQL server"
  value       = module.postgres.floating_ip
}

output "postgres_volume_id" {
  description = "ID of the attached volume"
  value       = module.postgres.volume_id
}

output "postgres_volume_device" {
  description = "Device path of the attached volume"
  value       = module.postgres.volume_device
}

output "postgres_connection_info" {
  description = "PostgreSQL connection information"
  value       = module.postgres.postgres_connection_info
  sensitive   = true
}

output "postgres_database_connection_strings" {
  description = "Complete connection strings for each database"
  value       = module.postgres.database_connection_strings
  sensitive   = true
}

output "postgres_admin_connection_string" {
  description = "Admin connection string"
  value       = module.postgres.admin_connection_string
  sensitive   = true
}

output "postgres_ssh_connection_command" {
  description = "SSH connection command for PostgreSQL server"
  value       = local.connection_info.ssh_command
}

output "postgres_pgadmin_url" {
  description = "pgAdmin web interface URL (if enabled)"
  value       = local.connection_info.pgadmin_url
}

output "postgres_firewall_id" {
  description = "ID of the PostgreSQL firewall"
  value       = module.postgres.firewall_id
}

output "postgres_password_file_location" {
  description = "Location of the PostgreSQL password file"
  value       = module.postgres.password_file_location
}

output "postgres_password_retrieval_command" {
  description = "Command to retrieve PostgreSQL passwords"
  value       = module.postgres.password_retrieval_command
}