terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.49.1"
    }
  }
}
# Hetzner Cloud Server Module
# Creates a basic server with SSH key, firewall, and optional volumes

resource "hcloud_server" "main" {
  name        = var.server_name
  image       = var.image
  server_type = var.server_type
  location    = var.location
  ssh_keys    = [hcloud_ssh_key.main.id]
  firewall_ids = var.enable_firewall ? [hcloud_firewall.main[0].id] : []
  user_data   = var.user_data
  labels      = var.labels

  # Attach volumes if specified
  dynamic "volume" {
    for_each = var.volumes
    content {
      volume_id = volume.value.id
      automount = volume.value.automount
    }
  }

  depends_on = [hcloud_ssh_key.main]
}

# SSH Key for server access
resource "hcloud_ssh_key" "main" {
  name       = "${var.server_name}-ssh-key"
  public_key = var.ssh_public_key
}

# Firewall rules
resource "hcloud_firewall" "main" {
  count = var.enable_firewall ? 1 : 0
  
  name = "${var.server_name}-firewall"
  
  rule {
    direction  = "in"
    port       = "22"
    protocol   = "tcp"
    source_ips = var.allowed_ssh_ips
  }

  # Allow HTTP and HTTPS if web server
  dynamic "rule" {
    for_each = var.enable_web_access ? [1] : []
    content {
      direction  = "in"
      port       = "80"
      protocol   = "tcp"
      source_ips = ["0.0.0.0/0", "::/0"]
    }
  }

  dynamic "rule" {
    for_each = var.enable_web_access ? [1] : []
    content {
      direction  = "in"
      port       = "443"
      protocol   = "tcp"
      source_ips = ["0.0.0.0/0", "::/0"]
    }
  }

  # Custom rules
  dynamic "rule" {
    for_each = var.custom_firewall_rules
    content {
      direction  = rule.value.direction
      port       = rule.value.port
      protocol   = rule.value.protocol
      source_ips = rule.value.source_ips
    }
  }
}

# Volume for additional storage
resource "hcloud_volume" "main" {
  count = var.create_volume ? 1 : 0
  
  name     = "${var.server_name}-volume"
  size     = var.volume_size
  location = var.location
  labels   = var.labels
}

# Attach volume to server
resource "hcloud_volume_attachment" "main" {
  count = var.create_volume ? 1 : 0
  
  volume_id = hcloud_volume.main[0].id
  server_id = hcloud_server.main.id
  automount = true
}

# Floating IP (optional)
resource "hcloud_primary_ip" "main" {
  count = var.create_floating_ip ? 1 : 0
  
  name          = "${var.server_name}-ip"
  type          = "ipv4"
  datacenter    = var.datacenter
  assignee      = hcloud_server.main.id
  auto_delete   = true
  labels        = var.labels
}
