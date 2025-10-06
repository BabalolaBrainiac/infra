# PostgreSQL Service Configuration

module "postgres" {
  source = "./modules/postgres"

  # Server Configuration
  server_name     = local.resource_names.postgres_server
  server_type     = local.environment_config.dev.server_type
  location        = local.server_config.location
  ssh_public_key  = var.ssh_public_key
  volume_size     = local.environment_config.dev.volume_size
  create_floating_ip = local.networking_config.create_floating_ip

  # Security Configuration
  allowed_ssh_ips    = local.environment_config.dev.allowed_ssh_ips
  postgres_allowed_ips = local.environment_config.dev.postgres_allowed_ips

  # Labels - merge common labels with service-specific ones
  labels = merge(local.common_labels, {
    Service = "postgresql"
    Database = "postgres"
  })
}