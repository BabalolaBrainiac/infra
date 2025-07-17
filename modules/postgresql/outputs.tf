output "database_endpoint" {
  description = "The connection endpoint for the RDS instance"
  value       = aws_db_instance.database.endpoint
}

output "database_name" {
  description = "The name of the database"
  value       = aws_db_instance.database.db_name
}

output "database_username" {
  description = "The master username for the database"
  value       = aws_db_instance.database.username
}

output "database_port" {
  description = "The port on which the database accepts connections"
  value       = aws_db_instance.database.port
}

output "database_security_group_id" {
  description = "The security group ID for the database"
  value       = aws_security_group.database.id
}

output "database_subnet_group_name" {
  description = "The name of the database subnet group"
  value       = aws_db_subnet_group.database.name
}

output "database_parameter_group_name" {
  description = "The name of the database parameter group"
  value       = aws_db_parameter_group.database.name
}

output "read_replica_endpoint" {
  description = "The connection endpoint for the read replica"
  value       = null
}

output "database_arn" {
  description = "The ARN of the database"
  value       = aws_db_instance.database.arn
}

output "database_identifier" {
  description = "The identifier of the database instance"
  value       = aws_db_instance.database.id
}

output "database_secret_arn" {
  description = "ARN of the database password secret in AWS Secrets Manager"
  value       = aws_secretsmanager_secret.database_password.arn
}

output "database_kms_key_id" {
  description = "KMS key ID used for database encryption"
  value       = aws_kms_key.database.key_id
} 