# redis module outputs

output "server_id" {
  description = "id of the redis server"
  value       = module.redis_server.server_id
}

output "server_name" {
  description = "name of the redis server"
  value       = module.redis_server.server_name
}

output "server_ipv4" {
  description = "ipv4 address of the redis server"
  value       = module.redis_server.server_ipv4
}

output "server_ipv6" {
  description = "ipv6 address of the redis server"
  value       = module.redis_server.server_ipv6
}

output "floating_ip" {
  description = "floating ip address of the redis server"
  value       = module.redis_server.floating_ip_address
}

output "redis_port" {
  description = "redis port"
  value       = var.redis_port
}

output "redis_connection_info" {
  description = "redis connection info"
  value = {
    host = module.redis_server.floating_ip_address != null ? module.redis_server.floating_ip_address : module.redis_server.server_ipv4
    port = var.redis_port
  }
}

output "redis_password" {
  description = "redis password"
  value       = random_password.redis_password.result
  sensitive   = true
}

output "redis_uri" {
  description = "redis uri"
  value       = "redis://:${random_password.redis_password.result}@${module.redis_server.floating_ip_address != null ? module.redis_server.floating_ip_address : module.redis_server.server_ipv4}:${var.redis_port}/0"
  sensitive   = true
}

output "ssh_connection_command" {
  description = "ssh connection command"
  value       = "ssh root@${module.redis_server.floating_ip_address != null ? module.redis_server.floating_ip_address : module.redis_server.server_ipv4}"
}


