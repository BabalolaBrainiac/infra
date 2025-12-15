# PostgreSQL Module Variables

# Server Configuration
variable "server_name" {
  description = "Name of the PostgreSQL server"
  type        = string
}

variable "server_type" {
  description = "Server type (cx21, cx31, cx41 recommended)"
  type        = string
  default     = "cpx21"
}

variable "location" {
  description = "Hetzner location (nbg1, fsn1, hel1, ash, hil)"
  type        = string
  default     = "nbg1"
}

variable "ssh_key_id" {
  description = "hetzner ssh key id (or name) to attach to the server"
  type        = string
}

variable "volume_size" {
  description = "Size of the volume in GB for storage"
  type        = number
  default     = 50
}

variable "create_floating_ip" {
  description = "Create a floating IP for the server"
  type        = bool
  default     = true
}

# Security Configuration
variable "allowed_ssh_ips" {
  description = "List of IP addresses allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0", "::/0"]
}

variable "postgres_allowed_ips" {
  description = "List of IP addresses allowed to connect to PostgreSQL"
  type        = list(string)
  default     = ["0.0.0.0/0", "::/0"]
}

# PostgreSQL Configuration
variable "postgres_version" {
  description = "PostgreSQL version to install"
  type        = string
  default     = "15"
}

variable "postgres_admin_user" {
  description = "PostgreSQL admin username"
  type        = string
  default     = "postgres"
}

# Database Configuration
variable "databases" {
  description = "List of databases to create (passwords will be auto-generated)"
  type = list(object({
    name  = string
    owner = string
  }))
  default = [
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

# Optional Features
variable "enable_pgadmin" {
  description = "Enable pgAdmin web interface"
  type        = bool
  default     = true # Enable by default for development
}

variable "pgadmin_allowed_ips" {
  description = "List of IP addresses allowed to access pgAdmin"
  type        = list(string)
  default     = ["0.0.0.0/0", "::/0"]
}

variable "backup_enabled" {
  description = "Enable automated backups"
  type        = bool
  default     = true
}

# Password Management
variable "password_length" {
  description = "Length of auto-generated passwords"
  type        = number
  default     = 32
}

variable "password_special_chars" {
  description = "Include special characters in passwords"
  type        = bool
  default     = true
}

# Labels
variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default     = {}
}

# Firewall Configuration
variable "firewall_id" {
  description = "ID of the firewall to attach to the server"
  type        = string
  default     = null
}

# Network Configuration Variables
variable "create_private_network" {
  description = "Create a private network for the server"
  type        = bool
  default     = true
}

variable "network_ip_range" {
  description = "IP range for the private network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "network_zone" {
  description = "Network zone for the subnet"
  type        = string
  default     = "eu-central"
}

variable "subnet_ip_range" {
  description = "IP range for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "server_private_ip" {
  description = "Private IP address for the server"
  type        = string
  default     = "10.0.1.5"
}

variable "server_alias_ips" {
  description = "Additional alias IPs for the server"
  type        = list(string)
  default     = []
}

variable "enable_ipv6" {
  description = "Enable IPv6 for the server"
  type        = bool
  default     = true
}
