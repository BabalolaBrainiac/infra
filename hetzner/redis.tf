# redis service configuration

module "redis" {
  source = "./modules/redis"

  server_name        = local.resource_names.redis_server
  server_type        = local.current_env_config.server_type
  location           = local.server_config.location
  ssh_key_id         = local.ssh_key_id
  volume_size        = local.current_env_config.volume_size
  create_floating_ip = local.networking_config.create_floating_ip

  allowed_ssh_ips   = local.current_env_config.allowed_ssh_ips
  redis_allowed_ips = local.current_env_config.redis_allowed_ips

  labels = merge(local.common_labels, {
    Service  = "redis"
    Database = "redis"
  })
}


