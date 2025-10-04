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

# Database variables
variable "db_name" {
  description = "Name of the database to create"
  type        = string
  default     = "venthelp"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]*$", var.db_name))
    error_message = "Database name must start with a letter and contain only alphanumeric characters and underscores."
  }
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "venthelp_admin"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]*$", var.db_username))
    error_message = "Database username must start with a letter and contain only alphanumeric characters and underscores."
  }
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"

  validation {
    condition     = can(regex("^db\\.[a-z0-9]+\\.[a-z0-9]+$", var.db_instance_class))
    error_message = "Database instance class must be a valid RDS instance type (e.g., db.t3.micro)."
  }
}

variable "db_allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20

  validation {
    condition     = var.db_allocated_storage >= 20 && var.db_allocated_storage <= 65536
    error_message = "Allocated storage must be between 20 and 65536 GB."
  }
}

variable "db_engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "15.4"
}

variable "backup_retention" {
  description = "Backup retention period in days"
  type        = number
  default     = 7

  validation {
    condition     = var.backup_retention >= 0 && var.backup_retention <= 35
    error_message = "Backup retention must be between 0 and 35 days."
  }
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = true
}

# Redis variables
variable "redis_node_type" {
  description = "ElastiCache node type"
  type        = string
  default     = "cache.t3.micro"

  validation {
    condition     = can(regex("^cache\\.[a-z0-9]+\\.[a-z0-9]+$", var.redis_node_type))
    error_message = "Redis node type must be a valid ElastiCache instance type (e.g., cache.t3.micro)."
  }
}

variable "redis_num_cache_clusters" {
  description = "Number of cache clusters in the replication group"
  type        = number
  default     = 1

  validation {
    condition     = var.redis_num_cache_clusters >= 1 && var.redis_num_cache_clusters <= 6
    error_message = "Number of cache clusters must be between 1 and 6."
  }
}

variable "redis_automatic_failover_enabled" {
  description = "Enable automatic failover for Redis"
  type        = bool
  default     = false
}

variable "redis_multi_az_enabled" {
  description = "Enable Multi-AZ deployment for Redis"
  type        = bool
  default     = false
}

variable "redis_snapshot_retention_limit" {
  description = "Number of days to retain Redis snapshots"
  type        = number
  default     = 7

  validation {
    condition     = var.redis_snapshot_retention_limit >= 0 && var.redis_snapshot_retention_limit <= 35
    error_message = "Redis snapshot retention must be between 0 and 35 days."
  }
}

# Monitoring and Alarms
variable "enable_email_notifications" {
  description = "Enable email notifications for CloudWatch alarms"
  type        = bool
  default     = false
}

variable "notification_email" {
  description = "Email address for alarm notifications"
  type        = string
  default     = ""
}

# Database Alarm Thresholds
variable "database_cpu_threshold" {
  description = "CPU utilization threshold for database alarms (%)"
  type        = number
  default     = 80
}

variable "database_connections_threshold" {
  description = "Database connections threshold"
  type        = number
  default     = 100
}

variable "database_storage_threshold" {
  description = "Free storage space threshold for database (bytes)"
  type        = number
  default     = 5368709120 # 5GB
}

variable "database_read_iops_threshold" {
  description = "Read IOPS threshold for database"
  type        = number
  default     = 1000
}

variable "database_write_iops_threshold" {
  description = "Write IOPS threshold for database"
  type        = number
  default     = 500
}

# Redis Alarm Thresholds
variable "redis_cpu_threshold" {
  description = "CPU utilization threshold for Redis alarms (%)"
  type        = number
  default     = 80
}

variable "redis_memory_threshold" {
  description = "Memory usage threshold for Redis alarms (%)"
  type        = number
  default     = 85
}

variable "redis_connections_threshold" {
  description = "Connection count threshold for Redis"
  type        = number
  default     = 1000
}

variable "redis_evictions_threshold" {
  description = "Evictions threshold for Redis"
  type        = number
  default     = 10
}

# Network Alarm Thresholds
variable "network_in_threshold" {
  description = "Network inbound traffic threshold (bytes)"
  type        = number
  default     = 104857600 # 100MB
}

variable "network_out_threshold" {
  description = "Network outbound traffic threshold (bytes)"
  type        = number
  default     = 104857600 # 100MB
}

# Tagging
variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "encryption_key" {
  description = "Encryption key for vent content (32 characters)"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.encryption_key) == 32
    error_message = "Encryption key must be exactly 32 characters long."
  }
} 