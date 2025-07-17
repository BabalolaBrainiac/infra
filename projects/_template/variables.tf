# Common variables for all projects
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.aws_region))
    error_message = "AWS region must be in the format: us-east-1, eu-west-1, etc."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "availability_zones" {
  description = "Availability zones to use"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least 2 availability zones must be specified for high availability."
  }
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

# Tagging
variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Add your project-specific variables here
# Example: Database variables
# variable "db_name" {
#   description = "Name of the database to create"
#   type        = string
#   default     = "myapp"
#   
#   validation {
#     condition = can(regex("^[a-zA-Z][a-zA-Z0-9_]*$", var.db_name))
#     error_message = "Database name must start with a letter and contain only alphanumeric characters and underscores."
#   }
# }

# Example: Application variables
# variable "app_name" {
#   description = "Name of the application"
#   type        = string
#   default     = "myapp"
# }

# variable "app_port" {
#   description = "Port the application runs on"
#   type        = number
#   default     = 3000
# } 