# Networking Module Variables

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "create_floating_ip" {
  description = "Create a floating IP for the server"
  type        = bool
  default     = true
}

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

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default     = {}
}

variable "datacenter" {
  description = "Datacenter for floating IP"
  type        = string
  default     = "nbg1-dc3"
}
