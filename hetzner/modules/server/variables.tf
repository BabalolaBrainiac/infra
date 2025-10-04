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
  default     = "cx21"  # Better default for development
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

variable "ssh_public_key" {
  description = "SSH public key for server access"
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
  default     = 50  # Better default for development
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
