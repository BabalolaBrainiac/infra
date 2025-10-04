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
  description = "ID of the SSH key"
  value       = hcloud_ssh_key.main.id
}

output "ssh_key_name" {
  description = "Name of the SSH key"
  value       = hcloud_ssh_key.main.name
}

output "firewall_id" {
  description = "ID of the firewall (if created)"
  value       = var.enable_firewall ? hcloud_firewall.main[0].id : null
}

output "volume_id" {
  description = "ID of the volume (if created)"
  value       = var.create_volume ? hcloud_volume.main[0].id : null
}

output "volume_device" {
  description = "Device path of the attached volume"
  value       = var.create_volume ? hcloud_volume_attachment.main[0].device : null
}

output "floating_ip" {
  description = "Floating IP address (if created)"
  value       = var.create_floating_ip ? hcloud_primary_ip.main[0].ip_address : null
}

output "floating_ip_id" {
  description = "ID of the floating IP (if created)"
  value       = var.create_floating_ip ? hcloud_primary_ip.main[0].id : null
}

output "connection_command" {
  description = "SSH connection command"
  value       = "ssh root@${hcloud_server.main.ipv4_address}"
}

output "floating_ip_connection_command" {
  description = "SSH connection command using floating IP"
  value       = var.create_floating_ip ? "ssh root@${hcloud_primary_ip.main[0].ip_address}" : null
}
