# Networking Module Main Configuration

# Floating IP for the infrastructure
resource "hcloud_primary_ip" "main" {
  count = var.create_floating_ip ? 1 : 0
  
  name          = "${var.project_name}-${var.environment}-ip"
  type          = "ipv4"
  datacenter    = var.datacenter
  auto_delete   = true
  labels        = merge(var.labels, {
    Service = "networking"
  })
}

# General firewall for SSH access
resource "hcloud_firewall" "ssh" {
  name = "${var.project_name}-${var.environment}-ssh-firewall"
  
  # SSH access
  rule {
    direction  = "in"
    port       = "22"
    protocol   = "tcp"
    source_ips = var.allowed_ssh_ips
  }
  
  labels = merge(var.labels, {
    Service = "networking"
    Purpose = "ssh-access"
  })
}

# PostgreSQL firewall
resource "hcloud_firewall" "postgres" {
  name = "${var.project_name}-${var.environment}-postgres-firewall"
  
  # SSH access
  rule {
    direction  = "in"
    port       = "22"
    protocol   = "tcp"
    source_ips = var.allowed_ssh_ips
  }

  # PostgreSQL access
  rule {
    direction  = "in"
    port       = "5432"
    protocol   = "tcp"
    source_ips = var.postgres_allowed_ips
  }
  
  labels = merge(var.labels, {
    Service = "networking"
    Purpose = "postgres-access"
  })
}
