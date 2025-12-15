# Variables for Hetzner Cloud Server Module

variable "server_name" {
  description = "Name of the server"
  type        = string
}

variable "image" {
  description = "Image to use for the server (e.g., ubuntu-22.04)"
  type        = string
  default     = "ubuntu-22.04"
}

variable "server_type" {
  description = "Server type (e.g., cx11, cx21, cx31)"
  type        = string
  default     = "cpx21"
}

variable "location" {
  description = "Location for the server (e.g., nbg1, fsn1, hel1)"
  type        = string
  default     = "nbg1"
}

variable "datacenter" {
  description = "Datacenter for floating IP (optional)"
  type        = string
  default     = "nbg1-dc3"
}

variable "ssh_key_id" {
  description = "hetzner ssh key id (or name) to attach to the server"
  type        = string
}

variable "enable_firewall" {
  description = "Enable firewall for the server"
  type        = bool
  default     = true
}

variable "enable_web_access" {
  description = "Enable HTTP/HTTPS access"
  type        = bool
  default     = false
}

variable "allowed_ssh_ips" {
  description = "List of IP addresses allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0", "::/0"]
}

variable "custom_firewall_rules" {
  description = "Custom firewall rules"
  type = list(object({
    direction  = string
    port       = string
    protocol   = string
    source_ips = list(string)
  }))
  default = []
}

variable "user_data" {
  description = "Cloud-init user data script"
  type        = string
  default     = ""
}

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default     = {}
}

variable "create_volume" {
  description = "Create and attach a volume to the server"
  type        = bool
  default     = false
}

variable "volume_size" {
  description = "Size of the volume in GB"
  type        = number
  default     = 50 # Better default for development
}

variable "volumes" {
  description = "List of existing volumes to attach"
  type = list(object({
    id        = string
    automount = bool
  }))
  default = []
}

variable "create_floating_ip" {
  description = "Create a floating IP for the server"
  type        = bool
  default     = false
}

# Network Configuration Variables
variable "create_private_network" {
  description = "Create a private network for the server"
  type        = bool
  default     = false
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
