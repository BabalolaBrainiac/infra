# Outputs for Hetzner Cloud Server Module

output "server_id" {
  description = "ID of the created server"
  value       = hcloud_server.main.id
}

output "server_name" {
  description = "Name of the created server"
  value       = hcloud_server.main.name
}

output "server_ipv4" {
  description = "IPv4 address of the server"
  value       = hcloud_server.main.ipv4_address
}

output "server_ipv6" {
  description = "IPv6 address of the server"
  value       = hcloud_server.main.ipv6_address
}

output "server_status" {
  description = "Status of the server"
  value       = hcloud_server.main.status
}

output "ssh_key_id" {
  description = "ssh key id (or name) attached to the server"
  value       = var.ssh_key_id
}

output "firewall_id" {
  description = "ID of the firewall (if created)"
  value       = var.enable_firewall ? hcloud_firewall.main[0].id : null
}

output "volume_id" {
  description = "ID of the volume (if created)"
  value       = var.create_volume ? hcloud_volume.main[0].id : null
}

output "floating_ip_id" {
  description = "ID of the floating IP (if created)"
  value       = var.create_floating_ip ? hcloud_primary_ip.main[0].id : null
}

output "floating_ip_address" {
  description = "Floating IP address (if created)"
  value       = var.create_floating_ip ? hcloud_primary_ip.main[0].ip_address : null
}

# Network Outputs
output "network_id" {
  description = "ID of the private network (if created)"
  value       = var.create_private_network ? hcloud_network.main[0].id : null
}

output "network_name" {
  description = "Name of the private network (if created)"
  value       = var.create_private_network ? hcloud_network.main[0].name : null
}

output "subnet_id" {
  description = "ID of the subnet (if created)"
  value       = var.create_private_network ? hcloud_network_subnet.main[0].id : null
}

output "server_private_ip" {
  description = "Private IP address of the server"
  value       = var.create_private_network ? var.server_private_ip : null
}

output "connection_command" {
  description = "SSH connection command"
  value       = "ssh root@${hcloud_server.main.ipv4_address}"
}
