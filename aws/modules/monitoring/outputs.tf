output "sns_topic_arn" {
  description = "ARN of the SNS topic for alarm notifications"
  value       = aws_sns_topic.alarms.arn
}

output "sns_topic_name" {
  description = "Name of the SNS topic for alarm notifications"
  value       = aws_sns_topic.alarms.name
}

# Database Alarms
output "database_cpu_alarm_arn" {
  description = "ARN of the database CPU utilization alarm"
  value       = aws_cloudwatch_metric_alarm.database_cpu.arn
}

output "database_connections_alarm_arn" {
  description = "ARN of the database connections alarm"
  value       = aws_cloudwatch_metric_alarm.database_connections.arn
}

output "database_storage_alarm_arn" {
  description = "ARN of the database storage alarm"
  value       = aws_cloudwatch_metric_alarm.database_storage.arn
}

output "database_read_iops_alarm_arn" {
  description = "ARN of the database read IOPS alarm"
  value       = aws_cloudwatch_metric_alarm.database_read_iops.arn
}

output "database_write_iops_alarm_arn" {
  description = "ARN of the database write IOPS alarm"
  value       = aws_cloudwatch_metric_alarm.database_write_iops.arn
}

# Redis Alarms
output "redis_cpu_alarm_arn" {
  description = "ARN of the Redis CPU utilization alarm"
  value       = aws_cloudwatch_metric_alarm.redis_cpu.arn
}

output "redis_memory_alarm_arn" {
  description = "ARN of the Redis memory usage alarm"
  value       = aws_cloudwatch_metric_alarm.redis_memory.arn
}

output "redis_connections_alarm_arn" {
  description = "ARN of the Redis connections alarm"
  value       = aws_cloudwatch_metric_alarm.redis_connections.arn
}

output "redis_evictions_alarm_arn" {
  description = "ARN of the Redis evictions alarm"
  value       = aws_cloudwatch_metric_alarm.redis_evictions.arn
}

# Network Alarms
output "network_in_alarm_arn" {
  description = "ARN of the network inbound traffic alarm"
  value       = aws_cloudwatch_metric_alarm.network_in.arn
}

output "network_out_alarm_arn" {
  description = "ARN of the network outbound traffic alarm"
  value       = aws_cloudwatch_metric_alarm.network_out.arn
}

# Composite Alarms
output "database_health_alarm_arn" {
  description = "ARN of the database health composite alarm"
  value       = aws_cloudwatch_composite_alarm.database_health.arn
}

output "redis_health_alarm_arn" {
  description = "ARN of the Redis health composite alarm"
  value       = aws_cloudwatch_composite_alarm.redis_health.arn
}

# IAM Role
output "cloudwatch_alarms_role_arn" {
  description = "ARN of the IAM role for CloudWatch alarms"
  value       = aws_iam_role.cloudwatch_alarms.arn
} 