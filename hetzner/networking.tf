# Networking Configuration

module "networking" {
  source = "./modules/networking"

  project_name = var.project_name
  environment  = var.environment

  create_floating_ip   = local.networking_config.create_floating_ip
  allowed_ssh_ips      = local.current_env_config.allowed_ssh_ips
  postgres_allowed_ips = local.current_env_config.postgres_allowed_ips

  labels = merge(local.common_labels, {
    Service   = "networking"
    Component = "firewall"
  })
}
