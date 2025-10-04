# Networking Module Outputs

output "floating_ip" {
  description = "Floating IP address"
  value       = var.create_floating_ip ? hcloud_primary_ip.main[0].ip_address : null
}

output "floating_ip_id" {
  description = "ID of the floating IP"
  value       = var.create_floating_ip ? hcloud_primary_ip.main[0].id : null
}

output "ssh_firewall_id" {
  description = "ID of the SSH firewall"
  value       = hcloud_firewall.ssh.id
}

output "postgres_firewall_id" {
  description = "ID of the PostgreSQL firewall"
  value       = hcloud_firewall.postgres.id
}
