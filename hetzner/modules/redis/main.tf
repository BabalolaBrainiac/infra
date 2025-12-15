# redis module main configuration

resource "random_password" "redis_password" {
  length  = 48
  special = true
}

module "redis_server" {
  source = "../server"

  server_name = var.server_name
  image       = "debian-12"
  server_type = var.server_type
  location    = var.location
  ssh_key_id  = var.ssh_key_id

  enable_firewall   = true
  enable_web_access = false
  allowed_ssh_ips   = var.allowed_ssh_ips

  custom_firewall_rules = [
    {
      direction  = "in"
      port       = tostring(var.redis_port)
      protocol   = "tcp"
      source_ips = var.redis_allowed_ips
    }
  ]

  create_volume = var.enable_persistence
  volume_size   = var.volume_size

  create_floating_ip = var.create_floating_ip

  create_private_network = var.create_private_network
  network_ip_range       = var.network_ip_range
  network_zone           = var.network_zone
  subnet_ip_range        = var.subnet_ip_range
  server_private_ip      = var.server_private_ip
  server_alias_ips       = var.server_alias_ips
  enable_ipv6            = var.enable_ipv6

  user_data = templatefile("${path.module}/scripts/redis-setup.sh", {
    redis_password         = random_password.redis_password.result
    redis_port             = var.redis_port
    redis_maxmemory_mb     = var.redis_maxmemory_mb
    redis_maxmemory_policy = var.redis_maxmemory_policy
    enable_persistence     = var.enable_persistence
  })

  labels = merge(var.labels, {
    Service = "redis"
    Port    = tostring(var.redis_port)
  })
}


