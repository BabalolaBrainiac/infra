terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket = "opeyemi-terraform-state"
    key    = "vent-help/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = merge({
      Project     = "vent-help"
      Environment = var.environment
      ManagedBy   = "terraform"
      Owner       = "opeyemi"
    }, var.additional_tags)
  }
}

# VPC and networking
module "vpc" {
  source = "../../modules/vpc"

  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  azs                = var.availability_zones
  enable_nat_gateway = var.enable_nat_gateway
}

# Security groups
module "security_groups" {
  source = "../../modules/security_groups"

  vpc_id      = module.vpc.vpc_id
  environment = var.environment
  vpc_cidr    = var.vpc_cidr
}

# PostgreSQL RDS instance
module "postgresql" {
  source = "../../modules/postgresql"

  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  app_security_group_id = module.security_groups.app_security_group_id
  db_name               = var.db_name
  db_username           = var.db_username
  db_password           = var.db_password
  db_instance_class     = var.db_instance_class
  db_allocated_storage  = var.db_allocated_storage
  db_engine_version     = var.db_engine_version
  backup_retention      = var.backup_retention
  multi_az              = var.multi_az
  deletion_protection   = var.deletion_protection
}

# Redis ElastiCache cluster
module "redis" {
  source = "../../modules/redis"

  environment                = var.environment
  vpc_id                     = module.vpc.vpc_id
  private_subnet_ids         = module.vpc.private_subnet_ids
  app_security_group_id      = module.security_groups.app_security_group_id
  node_type                  = var.redis_node_type
  num_cache_clusters         = var.redis_num_cache_clusters
  automatic_failover_enabled = var.redis_automatic_failover_enabled
  multi_az_enabled           = var.redis_multi_az_enabled
  snapshot_retention_limit   = var.redis_snapshot_retention_limit
}

# CloudWatch Monitoring and Alarms
module "monitoring" {
  source = "../../modules/monitoring"

  environment         = var.environment
  database_identifier = module.postgresql.database_identifier
  redis_cluster_id    = module.redis.redis_replication_group_id

  # Notification settings
  email_notifications = var.enable_email_notifications
  notification_email  = var.notification_email

  # Database alarm thresholds
  database_cpu_threshold         = var.database_cpu_threshold
  database_connections_threshold = var.database_connections_threshold
  database_storage_threshold     = var.database_storage_threshold
  database_read_iops_threshold   = var.database_read_iops_threshold
  database_write_iops_threshold  = var.database_write_iops_threshold

  # Redis alarm thresholds
  redis_cpu_threshold         = var.redis_cpu_threshold
  redis_memory_threshold      = var.redis_memory_threshold
  redis_connections_threshold = var.redis_connections_threshold
  redis_evictions_threshold   = var.redis_evictions_threshold

  # Network alarm thresholds
  network_in_threshold  = var.network_in_threshold
  network_out_threshold = var.network_out_threshold
} 