terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.49.1"
    }
  }
}
# Networking Module Main Configuration

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


## Network Configuration

resource "hcloud_network" "network" {
  name     = "network"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "network-subnet" {
  type         = "cloud"
  network_id   = hcloud_network.network.id
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}
