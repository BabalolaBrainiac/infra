output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "database_endpoint" {
  description = "The connection endpoint for the RDS instance"
  value       = module.postgresql.database_endpoint
}

output "database_name" {
  description = "The name of the database"
  value       = module.postgresql.database_name
}

output "database_username" {
  description = "The master username for the database"
  value       = module.postgresql.database_username
  sensitive   = true
}

output "database_port" {
  description = "The port on which the database accepts connections"
  value       = module.postgresql.database_port
}

output "database_secret_arn" {
  description = "ARN of the database password secret in AWS Secrets Manager"
  value       = module.postgresql.database_secret_arn
  sensitive   = true
}

output "database_kms_key_id" {
  description = "KMS key ID used for database encryption"
  value       = module.postgresql.database_kms_key_id
}

output "database_security_group_id" {
  description = "The security group ID for the database"
  value       = module.postgresql.database_security_group_id
}

output "connection_string" {
  description = "PostgreSQL connection string (without password)"
  value       = "postgresql://${module.postgresql.database_username}:<password>@${module.postgresql.database_endpoint}:${module.postgresql.database_port}/${module.postgresql.database_name}"
  sensitive   = true
}

# Redis outputs
output "redis_endpoint" {
  description = "Redis primary endpoint"
  value       = module.redis.redis_endpoint
}

output "redis_port" {
  description = "Redis port"
  value       = module.redis.redis_port
}

output "redis_auth_token_secret_arn" {
  description = "ARN of the Redis auth token secret"
  value       = module.redis.redis_auth_token_secret_arn
  sensitive   = true
}

output "redis_security_group_id" {
  description = "Security group ID for Redis"
  value       = module.redis.redis_security_group_id
}

output "redis_connection_string" {
  description = "Redis connection string (without auth token)"
  value       = "redis://<auth_token>@${module.redis.redis_endpoint}:${module.redis.redis_port}"
  sensitive   = true
}

# Monitoring outputs
output "sns_topic_arn" {
  description = "ARN of the SNS topic for alarm notifications"
  value       = module.monitoring.sns_topic_arn
}

output "database_health_alarm_arn" {
  description = "ARN of the database health composite alarm"
  value       = module.monitoring.database_health_alarm_arn
}

output "redis_health_alarm_arn" {
  description = "ARN of the Redis health composite alarm"
  value       = module.monitoring.redis_health_alarm_arn
} 