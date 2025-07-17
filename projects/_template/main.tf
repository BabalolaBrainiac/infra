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
    key    = "PROJECT_NAME/terraform.tfstate" # Update PROJECT_NAME
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = merge({
      Project     = "PROJECT_NAME" # Update PROJECT_NAME
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

# Add your project-specific modules here
# Example: PostgreSQL database
# module "postgresql" {
#   source = "../../modules/postgresql"
#   
#   environment           = var.environment
#   vpc_id               = module.vpc.vpc_id
#   private_subnet_ids   = module.vpc.private_subnet_ids
#   app_security_group_id = module.security_groups.app_security_group_id
#   db_name              = var.db_name
#   db_username          = var.db_username
#   db_instance_class    = var.db_instance_class
#   db_allocated_storage = var.db_allocated_storage
#   db_engine_version    = var.db_engine_version
#   backup_retention     = var.backup_retention
#   multi_az             = var.multi_az
#   deletion_protection  = var.deletion_protection
# }

# Example: Application Load Balancer
# module "alb" {
#   source = "../../modules/alb"
#   
#   environment = var.environment
#   vpc_id      = module.vpc.vpc_id
#   public_subnet_ids = module.vpc.public_subnet_ids
#   security_group_id = module.security_groups.app_security_group_id
# }

# Example: ECS Cluster
# module "ecs" {
#   source = "../../modules/ecs"
#   
#   environment = var.environment
#   vpc_id      = module.vpc.vpc_id
#   private_subnet_ids = module.vpc.private_subnet_ids
#   security_group_id = module.security_groups.app_security_group_id
# } 