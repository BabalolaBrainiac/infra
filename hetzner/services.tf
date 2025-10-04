# Example: Redis Service Configuration
# This shows how to add more services with service-specific labels
#
# module "redis" {
#   source = "./modules/redis"
#
#   # Server Configuration
#   server_name     = local.resource_names.redis_server
#   server_type     = local.current_env_config.server_type
#   location        = local.server_config.location
#   ssh_public_key  = var.ssh_public_key
#   volume_size     = local.current_env_config.volume_size
#   create_floating_ip = local.networking_config.create_floating_ip
#
#   # Security Configuration
#   allowed_ssh_ips    = local.current_env_config.allowed_ssh_ips
#   redis_allowed_ips  = local.current_env_config.redis_allowed_ips
#
#   # Firewall Configuration
#   firewall_id = module.networking.redis_firewall_id
#
#   # Labels - merge common labels with service-specific ones
#   labels = merge(local.common_labels, {
#     Service = "redis"
#     Database = "redis"
#     Port = "6379"
#   })
# }
#
# Example: Web Service Configuration
# module "web" {
#   source = "./modules/web"
#
#   # Server Configuration
#   server_name     = local.resource_names.web_server
#   server_type     = local.current_env_config.server_type
#   location        = local.server_config.location
#   ssh_public_key  = var.ssh_public_key
#   volume_size     = local.current_env_config.volume_size
#   create_floating_ip = local.networking_config.create_floating_ip
#
#   # Security Configuration
#   allowed_ssh_ips    = local.current_env_config.allowed_ssh_ips
#   web_allowed_ips    = local.current_env_config.web_allowed_ips
#
#   # Firewall Configuration
#   firewall_id = module.networking.web_firewall_id
#
#   # Labels - merge common labels with service-specific ones
#   labels = merge(local.common_labels, {
#     Service = "web"
#     Application = "nginx"
#     Port = "80,443"
#   })
# }
