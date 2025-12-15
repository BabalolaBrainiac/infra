# Local values for Babalola's Hetzner Infrastructure
# Centralized configuration used across all modules

locals {
  # Default tags applied to all resources
  default_tags = {
    Project     = var.project_name
    Environment = upper(var.environment)
    Owner       = "opeyemi"
    ManagedBy   = "terraform"
    Purpose     = "personal-infrastructure"
    CreatedAt   = timestamp()
  }

  # Common labels for resources
  common_labels = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = "opeyemi"
    Purpose     = "personal-infrastructure"
  }

  # Server configuration defaults
  server_config = {
    type        = "cpx21"     # 3 vCPU, 4GB RAM - good for development
    location    = "nbg1"      # Nuremberg, Germany
    image       = "debian-12" # Debian 12 for better package management
    volume_size = 50          # 50GB additional storage
    datacenter  = "nbg1-dc3"  # Specific datacenter for floating IPs
  }

  # Networking configuration defaults
  networking_config = {
    create_floating_ip   = true
    allowed_ssh_ips      = ["0.0.0.0/0", "::/0"] # Open for development
    postgres_allowed_ips = ["0.0.0.0/0", "::/0"] # Open for development
    redis_allowed_ips    = ["0.0.0.0/0", "::/0"] # Open for development
  }

  # PostgreSQL configuration defaults
  postgres_config = {
    version                = "15"
    admin_user             = "opeyemi"
    enable_pgadmin         = true
    backup_enabled         = true
    password_length        = 32
    password_special_chars = true
    databases = [
      {
        name  = "myapp_dev"
        owner = "myapp_user"
      },
      {
        name  = "test_db"
        owner = "test_user"
      },
      {
        name  = "staging_db"
        owner = "staging_user"
      }
    ]
  }

  # Environment-specific overrides
  environment_config = {
    dev = {
      server_type          = "cpx21"
      volume_size          = 50
      enable_pgadmin       = true
      backup_enabled       = true
      allowed_ssh_ips      = ["0.0.0.0/0", "::/0"] # Open for development
      postgres_allowed_ips = ["0.0.0.0/0", "::/0"] # Open for development
      redis_allowed_ips    = ["0.0.0.0/0", "::/0"] # Open for development
    }
    prod = {
      server_type          = "cpx31"
      volume_size          = 100
      enable_pgadmin       = false
      backup_enabled       = true
      allowed_ssh_ips      = ["YOUR_IP_ADDRESS/32"] # Restrict in production
      postgres_allowed_ips = ["YOUR_IP_ADDRESS/32", "YOUR_APP_SERVER_IP/32"]
      redis_allowed_ips    = ["YOUR_IP_ADDRESS/32", "YOUR_APP_SERVER_IP/32"]
    }
  }

  # Current environment configuration
  current_env_config = local.environment_config[var.environment]

  # Resource naming convention
  resource_names = {
    postgres_server   = "${var.project_name}-postgres-${var.environment}"
    redis_server      = "${var.project_name}-redis-${var.environment}"
    floating_ip       = "${var.project_name}-${var.environment}-ip"
    ssh_firewall      = "${var.project_name}-${var.environment}-ssh-firewall"
    postgres_firewall = "${var.project_name}-${var.environment}-postgres-firewall"
    redis_firewall    = "${var.project_name}-${var.environment}-redis-firewall"
  }
}
