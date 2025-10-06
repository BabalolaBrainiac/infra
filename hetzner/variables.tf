# Variables for Babalola's Hetzner Infrastructure

# Provider Configuration
variable "hcloud_token" {
  description = "Hetzner Cloud API token"
  type        = string
  sensitive   = true
}

# Environment Configuration
variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "babalolas-infra"
}

variable "ssh_public_key" {
  description = "SSH public key for server access"
  type        = string
}