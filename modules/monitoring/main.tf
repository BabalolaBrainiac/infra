# CloudWatch Alarms for Vent.Help Infrastructure

# SNS Topic for alarm notifications
resource "aws_sns_topic" "alarms" {
  name = "${var.environment}-venthelp-alarms"
  
  tags = {
    Name        = "${var.environment}-venthelp-alarms"
    Environment = var.environment
  }
}

# SNS Topic Subscription (email)
resource "aws_sns_topic_subscription" "email" {
  count     = var.email_notifications ? 1 : 0
  topic_arn = aws_sns_topic.alarms.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

# IAM Role for CloudWatch Alarms
resource "aws_iam_role" "cloudwatch_alarms" {
  name = "${var.environment}-cloudwatch-alarms-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.environment}-cloudwatch-alarms-role"
    Environment = var.environment
  }
}

# IAM Policy for CloudWatch Alarms
resource "aws_iam_role_policy" "cloudwatch_alarms" {
  name = "${var.environment}-cloudwatch-alarms-policy"
  role = aws_iam_role.cloudwatch_alarms.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData",
          "cloudwatch:GetMetricData",
          "cloudwatch:GetMetricStatistics"
        ]
        Resource = "*"
      }
    ]
  })
}

# Database Alarms

# CPU Utilization Alarm
resource "aws_cloudwatch_metric_alarm" "database_cpu" {
  alarm_name          = "${var.environment}-venthelp-db-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.database_cpu_threshold
  alarm_description   = "Database CPU utilization is high"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]

  dimensions = {
    DBInstanceIdentifier = var.database_identifier
  }

  tags = {
    Name        = "${var.environment}-venthelp-db-cpu"
    Environment = var.environment
    Resource    = "database"
  }
}

# Database Connections Alarm
resource "aws_cloudwatch_metric_alarm" "database_connections" {
  alarm_name          = "${var.environment}-venthelp-db-connections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.database_connections_threshold
  alarm_description   = "Database connection count is high"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]

  dimensions = {
    DBInstanceIdentifier = var.database_identifier
  }

  tags = {
    Name        = "${var.environment}-venthelp-db-connections"
    Environment = var.environment
    Resource    = "database"
  }
}

# Free Storage Space Alarm
resource "aws_cloudwatch_metric_alarm" "database_storage" {
  alarm_name          = "${var.environment}-venthelp-db-storage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.database_storage_threshold
  alarm_description   = "Database free storage space is low"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]

  dimensions = {
    DBInstanceIdentifier = var.database_identifier
  }

  tags = {
    Name        = "${var.environment}-venthelp-db-storage"
    Environment = var.environment
    Resource    = "database"
  }
}

# Database Read IOPS Alarm
resource "aws_cloudwatch_metric_alarm" "database_read_iops" {
  alarm_name          = "${var.environment}-venthelp-db-read-iops"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ReadIOPS"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.database_read_iops_threshold
  alarm_description   = "Database read IOPS is high"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]

  dimensions = {
    DBInstanceIdentifier = var.database_identifier
  }

  tags = {
    Name        = "${var.environment}-venthelp-db-read-iops"
    Environment = var.environment
    Resource    = "database"
  }
}

# Database Write IOPS Alarm
resource "aws_cloudwatch_metric_alarm" "database_write_iops" {
  alarm_name          = "${var.environment}-venthelp-db-write-iops"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "WriteIOPS"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.database_write_iops_threshold
  alarm_description   = "Database write IOPS is high"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]

  dimensions = {
    DBInstanceIdentifier = var.database_identifier
  }

  tags = {
    Name        = "${var.environment}-venthelp-db-write-iops"
    Environment = var.environment
    Resource    = "database"
  }
}

# Redis Alarms

# Redis CPU Utilization Alarm
resource "aws_cloudwatch_metric_alarm" "redis_cpu" {
  alarm_name          = "${var.environment}-venthelp-redis-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ElastiCache"
  period              = "300"
  statistic           = "Average"
  threshold           = var.redis_cpu_threshold
  alarm_description   = "Redis CPU utilization is high"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]

  dimensions = {
    CacheClusterId = var.redis_cluster_id
  }

  tags = {
    Name        = "${var.environment}-venthelp-redis-cpu"
    Environment = var.environment
    Resource    = "redis"
  }
}

# Redis Memory Usage Alarm
resource "aws_cloudwatch_metric_alarm" "redis_memory" {
  alarm_name          = "${var.environment}-venthelp-redis-memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "DatabaseMemoryUsagePercentage"
  namespace           = "AWS/ElastiCache"
  period              = "300"
  statistic           = "Average"
  threshold           = var.redis_memory_threshold
  alarm_description   = "Redis memory usage is high"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]

  dimensions = {
    CacheClusterId = var.redis_cluster_id
  }

  tags = {
    Name        = "${var.environment}-venthelp-redis-memory"
    Environment = var.environment
    Resource    = "redis"
  }
}

# Redis Connections Alarm
resource "aws_cloudwatch_metric_alarm" "redis_connections" {
  alarm_name          = "${var.environment}-venthelp-redis-connections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CurrConnections"
  namespace           = "AWS/ElastiCache"
  period              = "300"
  statistic           = "Average"
  threshold           = var.redis_connections_threshold
  alarm_description   = "Redis connection count is high"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]

  dimensions = {
    CacheClusterId = var.redis_cluster_id
  }

  tags = {
    Name        = "${var.environment}-venthelp-redis-connections"
    Environment = var.environment
    Resource    = "redis"
  }
}

# Redis Evictions Alarm
resource "aws_cloudwatch_metric_alarm" "redis_evictions" {
  alarm_name          = "${var.environment}-venthelp-redis-evictions"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Evictions"
  namespace           = "AWS/ElastiCache"
  period              = "300"
  statistic           = "Sum"
  threshold           = var.redis_evictions_threshold
  alarm_description   = "Redis evictions are occurring"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]

  dimensions = {
    CacheClusterId = var.redis_cluster_id
  }

  tags = {
    Name        = "${var.environment}-venthelp-redis-evictions"
    Environment = var.environment
    Resource    = "redis"
  }
}

# Network Alarms

# Network In Alarm
resource "aws_cloudwatch_metric_alarm" "network_in" {
  alarm_name          = "${var.environment}-venthelp-network-in"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "NetworkIn"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.network_in_threshold
  alarm_description   = "Network inbound traffic is high"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]

  dimensions = {
    DBInstanceIdentifier = var.database_identifier
  }

  tags = {
    Name        = "${var.environment}-venthelp-network-in"
    Environment = var.environment
    Resource    = "network"
  }
}

# Network Out Alarm
resource "aws_cloudwatch_metric_alarm" "network_out" {
  alarm_name          = "${var.environment}-venthelp-network-out"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "NetworkOut"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.network_out_threshold
  alarm_description   = "Network outbound traffic is high"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]

  dimensions = {
    DBInstanceIdentifier = var.database_identifier
  }

  tags = {
    Name        = "${var.environment}-venthelp-network-out"
    Environment = var.environment
    Resource    = "network"
  }
}

# Composite Alarms for Critical Issues

# Database Health Composite Alarm
resource "aws_cloudwatch_composite_alarm" "database_health" {
  alarm_name = "${var.environment}-venthelp-db-health"
  
  alarm_rule = "ALARM(${aws_cloudwatch_metric_alarm.database_cpu.alarm_name}) AND ALARM(${aws_cloudwatch_metric_alarm.database_storage.alarm_name})"
  
  alarm_description = "Database is experiencing critical issues (high CPU and low storage)"
  alarm_actions     = [aws_sns_topic.alarms.arn]
  ok_actions        = [aws_sns_topic.alarms.arn]

  tags = {
    Name        = "${var.environment}-venthelp-db-health"
    Environment = var.environment
    Resource    = "database"
    Type        = "composite"
  }
}

# Redis Health Composite Alarm
resource "aws_cloudwatch_composite_alarm" "redis_health" {
  alarm_name = "${var.environment}-venthelp-redis-health"
  
  alarm_rule = "ALARM(${aws_cloudwatch_metric_alarm.redis_cpu.alarm_name}) AND ALARM(${aws_cloudwatch_metric_alarm.redis_memory.alarm_name})"
  
  alarm_description = "Redis is experiencing critical issues (high CPU and memory usage)"
  alarm_actions     = [aws_sns_topic.alarms.arn]
  ok_actions        = [aws_sns_topic.alarms.arn]

  tags = {
    Name        = "${var.environment}-venthelp-redis-health"
    Environment = var.environment
    Resource    = "redis"
    Type        = "composite"
  }
} 