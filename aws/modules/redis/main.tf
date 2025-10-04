resource "aws_security_group" "redis" {
  name_prefix = "${var.environment}-redis-sg-"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [var.app_security_group_id]
    description     = "Redis access from application"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-redis-sg"
    Environment = var.environment
  }
}

resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.environment}-redis-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name        = "${var.environment}-redis-subnet-group"
    Environment = var.environment
  }
}

resource "aws_elasticache_parameter_group" "redis" {
  family = "redis7"
  name   = "${var.environment}-redis-parameter-group"

  parameter {
    name  = "maxmemory-policy"
    value = "allkeys-lru"
  }

  parameter {
    name  = "notify-keyspace-events"
    value = "Ex"
  }

  tags = {
    Name        = "${var.environment}-redis-parameter-group"
    Environment = var.environment
  }
}

# Generate random auth token
resource "random_password" "redis_auth_token" {
  length  = 32
  special = false
}

# Store auth token in AWS Secrets Manager
resource "aws_secretsmanager_secret" "redis_auth_token" {
  name                    = "${var.environment}/venthelp/redis/auth-token"
  description             = "Redis auth token for ${var.environment} environment"
  recovery_window_in_days = var.environment == "prod" ? 30 : 0

  tags = {
    Name        = "${var.environment}-redis-auth-token"
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "redis_auth_token" {
  secret_id = aws_secretsmanager_secret.redis_auth_token.id
  secret_string = jsonencode({
    auth_token = random_password.redis_auth_token.result
  })
}

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id          = "${var.environment}-venthelp-redis"
  description                   = "Redis cluster for ${var.environment} environment"
  node_type                     = var.node_type
  port                          = 6379
  parameter_group_name          = aws_elasticache_parameter_group.redis.name
  subnet_group_name             = aws_elasticache_subnet_group.redis.name
  security_group_ids            = [aws_security_group.redis.id]
  auth_token                    = random_password.redis_auth_token.result
  automatic_failover_enabled   = var.automatic_failover_enabled
  multi_az_enabled             = var.multi_az_enabled
  num_cache_clusters            = var.num_cache_clusters
  at_rest_encryption_enabled   = true
  transit_encryption_enabled   = true
  transit_encryption_mode      = "required"

  # Backup configuration
  snapshot_retention_limit = var.snapshot_retention_limit
  snapshot_window          = "03:00-04:00"
  maintenance_window       = "sun:04:00-sun:05:00"

  tags = {
    Name        = "${var.environment}-venthelp-redis"
    Environment = var.environment
  }

  depends_on = [aws_secretsmanager_secret_version.redis_auth_token]
}

# KMS key for encryption
resource "aws_kms_key" "redis" {
  description             = "KMS key for ${var.environment} Redis encryption"
  deletion_window_in_days = var.environment == "prod" ? 30 : 7

  tags = {
    Name        = "${var.environment}-redis-kms-key"
    Environment = var.environment
  }
}

resource "aws_kms_alias" "redis" {
  name          = "alias/${var.environment}-venthelp-redis"
  target_key_id = aws_kms_key.redis.key_id
} 