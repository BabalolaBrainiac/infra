variable "environment" {
  description = "Environment name"
  type        = string
}

variable "database_identifier" {
  description = "RDS database identifier"
  type        = string
}

variable "redis_cluster_id" {
  description = "ElastiCache Redis cluster identifier"
  type        = string
}

variable "email_notifications" {
  description = "Enable email notifications for alarms"
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