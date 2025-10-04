# Building Scalable AWS Infrastructure with Terraform: A Complete Guide

*How I built a modular, production-ready infrastructure setup for my projects using Infrastructure as Code*

## Introduction

As a developer working on multiple projects, I needed a scalable and maintainable way to manage my AWS infrastructure. After experimenting with manual setups and various tools, I settled on Terraform as my Infrastructure as Code (IaC) solution. This article walks through how I built a comprehensive, modular infrastructure setup that supports multiple projects with different environments.

## The Challenge

When I started working on my projects (like Vent.Help, a mental health support platform), I faced several infrastructure challenges:

- **Manual Setup**: Creating resources manually was error-prone and time-consuming
- **Environment Consistency**: Keeping dev, staging, and production environments in sync was difficult
- **Cost Management**: Without proper tagging and monitoring, costs were hard to track
- **Security**: Ensuring consistent security configurations across environments
- **Scalability**: Adding new projects required duplicating infrastructure work

## The Solution: Modular Terraform Architecture

I designed a modular infrastructure setup that addresses all these challenges. Here's the high-level architecture:

```
infra/
├── modules/                    # Reusable infrastructure components
│   ├── vpc/                   # VPC and networking
│   ├── postgresql/            # PostgreSQL RDS
│   ├── redis/                 # Redis ElastiCache
│   ├── security_groups/       # Security groups
│   └── monitoring/           # CloudWatch monitoring
├── projects/                   # Project-specific configurations
│   ├── _template/             # Template for new projects
│   ├── vent-help/             # Vent.Help - Mental health platform
│   ├── ai-incident-response/  # AI Incident Response - Web application
│   └── babalola.dev/         # Portfolio website - Next.js application
├── scripts/                    # Utility scripts
└── Makefile                    # Common operations
```

## Core Infrastructure Components

### 1. VPC Module - Network Foundation

The VPC module creates a secure, multi-AZ network foundation:

```hcl
# modules/vpc/main.tf
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
  }
}

resource "aws_subnet" "public" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = var.azs[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.environment}-public-subnet-${count.index + 1}"
    Environment = var.environment
  }
}

resource "aws_subnet" "private" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + length(var.azs))
  availability_zone = var.azs[count.index]

  tags = {
    Name        = "${var.environment}-private-subnet-${count.index + 1}"
    Environment = var.environment
  }
}
```

**Key Features:**
- Multi-AZ deployment for high availability
- Public subnets for load balancers and NAT gateways
- Private subnets for databases and application servers
- Configurable CIDR blocks per environment

### 2. PostgreSQL Module - Secure Database

The PostgreSQL module provides a production-ready database setup:

```hcl
# modules/postgresql/main.tf
resource "aws_db_instance" "database" {
  identifier = "${var.environment}-venthelp-db"

  engine         = "postgres"
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class

  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true
  kms_key_id            = aws_kms_key.database.arn

  db_name  = var.db_name
  username = var.db_username
  password = random_password.database_password.result
  port     = "5432"

  vpc_security_group_ids = [aws_security_group.database.id]
  db_subnet_group_name   = aws_db_subnet_group.database.name
  parameter_group_name   = aws_db_parameter_group.database.name

  backup_retention_period = var.backup_retention
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"
  copy_tags_to_snapshot   = true

  multi_az                  = var.multi_az
  publicly_accessible       = false
  skip_final_snapshot       = var.environment == "dev"
  deletion_protection       = var.deletion_protection

  # Enhanced monitoring
  monitoring_interval = var.environment == "prod" ? 60 : 0
  monitoring_role_arn = var.environment == "prod" ? aws_iam_role.rds_enhanced_monitoring[0].arn : null

  # Performance Insights
  performance_insights_enabled          = var.environment == "prod"
  performance_insights_retention_period = var.environment == "prod" ? 7 : null

  tags = {
    Name        = "${var.environment}-venthelp-db"
    Environment = var.environment
    Backup      = "required"
  }
}
```

**Security Features:**
- Encryption at rest using KMS
- Secrets stored in AWS Secrets Manager
- Network isolation in private subnets
- Security groups with least-privilege access
- Automated backups with configurable retention

### 3. Redis Module - High-Performance Caching

For caching and session storage, I implemented a Redis cluster:

```hcl
# modules/redis/main.tf
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
}
```

**Features:**
- Encryption in transit and at rest
- Automatic failover for high availability
- Configurable backup retention
- Auth token authentication

### 4. Monitoring Module - Comprehensive Observability

The monitoring module provides comprehensive CloudWatch alarms:

```hcl
# modules/monitoring/main.tf
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
}

# Composite alarms for critical issues
resource "aws_cloudwatch_composite_alarm" "database_health" {
  alarm_name = "${var.environment}-venthelp-db-health"
  
  alarm_rule = "ALARM(${aws_cloudwatch_metric_alarm.database_cpu.alarm_name}) AND ALARM(${aws_cloudwatch_metric_alarm.database_storage.alarm_name})"
  
  alarm_description = "Database is experiencing critical issues (high CPU and low storage)"
  alarm_actions     = [aws_sns_topic.alarms.arn]
  ok_actions        = [aws_sns_topic.alarms.arn]
}
```

**Monitoring Coverage:**
- Database: CPU, connections, storage, IOPS
- Redis: CPU, memory, connections, evictions
- Network: Inbound/outbound traffic
- Composite alarms for critical issues
- Email notifications via SNS

## Project Types and Configurations

My infrastructure supports three different types of projects, each optimized for their specific use case:

### 1. Vent.Help - Full-Stack Web Application

A mental health support platform requiring database, caching, and comprehensive monitoring:

**Infrastructure Components:**
- PostgreSQL RDS for user data and content
- Redis ElastiCache for session management and caching
- VPC with private subnets for database security
- Comprehensive CloudWatch monitoring and alerting

**Environment Configuration:**
```hcl
# Development Environment
db_instance_class    = "db.t3.micro"
redis_node_type      = "cache.t3.micro"
multi_az             = false
backup_retention     = 1

# Production Environment  
db_instance_class    = "db.t3.small"
redis_node_type      = "cache.t3.small"
multi_az             = true
backup_retention     = 30
```

### 2. AI-Incidence-Response - Data-Heavy Application

An AI-powered incident response platform with similar infrastructure to Vent.Help but optimized for data processing:

**Infrastructure Components:**
- PostgreSQL RDS for incident data storage
- Redis ElastiCache for real-time data caching
- Enhanced monitoring for data processing workloads
- Separate VPC CIDR (10.2.0.0/16) for network isolation

**Key Differences:**
- Larger storage allocations for data processing
- More aggressive monitoring thresholds
- Optimized for high-throughput data operations

### 3. babalola.dev - Next.js Portfolio Website

A personal portfolio website built with Next.js, requiring different infrastructure considerations:

**Infrastructure Components:**
- VPC for security groups (minimal usage)
- Could be deployed to Vercel, AWS Amplify, or containerized
- Database integration with Supabase (external service)
- Static asset optimization

**Configuration:**
```hcl
# Next.js specific considerations
# - Static site generation for performance
# - API routes for dynamic functionality
# - Integration with external services (Supabase)
# - CDN optimization for global delivery
```

**Benefits:**
- Modern React/Next.js stack
- Server-side rendering capabilities
- API routes for backend functionality
- Easy deployment options (Vercel, AWS Amplify)

## Project Configuration

### Environment-Specific Settings

Each project has environment-specific configurations:

```hcl
# projects/vent-help/environments/dev.tfvars
environment = "dev"
aws_region  = "us-east-1"

# VPC Configuration
vpc_cidr           = "10.0.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b"]
enable_nat_gateway = true

# Database Configuration
db_name              = "venthelp_dev"
db_username          = "venthelp_admin"
db_instance_class    = "db.t3.micro"
db_allocated_storage = 20
backup_retention     = 1
multi_az             = false
deletion_protection  = false

# Redis Configuration
redis_node_type                = "cache.t3.micro"
redis_num_cache_clusters       = 1
redis_automatic_failover_enabled = false
redis_multi_az_enabled         = false
```

```hcl
# projects/vent-help/environments/prod.tfvars
environment = "prod"
aws_region  = "us-east-1"

# VPC Configuration
vpc_cidr           = "10.1.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
enable_nat_gateway = true

# Database Configuration
db_name              = "venthelp"
db_username          = "venthelp_admin"
db_instance_class    = "db.t3.small"
db_allocated_storage = 100
backup_retention     = 30
multi_az             = true
deletion_protection  = true

# Redis Configuration
redis_node_type                = "cache.t3.small"
redis_num_cache_clusters       = 2
redis_automatic_failover_enabled = true
redis_multi_az_enabled         = true
```

### Project Main Configuration

The main project file orchestrates all modules:

```hcl
# projects/vent-help/main.tf
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
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

  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  app_security_group_id = module.security_groups.app_security_group_id
  node_type             = var.redis_node_type
  num_cache_clusters    = var.redis_num_cache_clusters
  automatic_failover_enabled = var.redis_automatic_failover_enabled
  multi_az_enabled      = var.redis_multi_az_enabled
  snapshot_retention_limit = var.redis_snapshot_retention_limit
}

# CloudWatch Monitoring and Alarms
module "monitoring" {
  source = "../../modules/monitoring"

  environment = var.environment
  database_identifier = module.postgresql.database_identifier
  redis_cluster_id = module.redis.redis_replication_group_id
  
  # Notification settings
  email_notifications = var.enable_email_notifications
  notification_email = var.notification_email
  
  # Alarm thresholds
  database_cpu_threshold = var.database_cpu_threshold
  database_connections_threshold = var.database_connections_threshold
  database_storage_threshold = var.database_storage_threshold
  redis_cpu_threshold = var.redis_cpu_threshold
  redis_memory_threshold = var.redis_memory_threshold
}
```

## Automation and Scripts

### Project Creation Script

I created a script to quickly spin up new projects:

```bash
#!/bin/bash
# scripts/create-project.sh

PROJECT_NAME="$1"
TEMPLATE_DIR="projects/_template"
PROJECT_DIR="projects/$PROJECT_NAME"

# Validate project name
if [[ ! $PROJECT_NAME =~ ^[a-z0-9-]+$ ]]; then
    echo "Project name must contain only lowercase letters, numbers, and hyphens"
    exit 1
fi

# Copy template to new project
cp -r "$TEMPLATE_DIR" "$PROJECT_DIR"

# Replace PROJECT_NAME placeholder in files
replace_project_name() {
    local file="$1"
    if [ -f "$file" ]; then
        sed -i "s/PROJECT_NAME/$PROJECT_NAME/g" "$file"
    fi
}

# Update main.tf
replace_project_name "$PROJECT_DIR/main.tf"

# Update environments/dev.tfvars
replace_project_name "$PROJECT_DIR/environments/dev.tfvars"

# Create production environment file
cp "$PROJECT_DIR/environments/dev.tfvars" "$PROJECT_DIR/environments/prod.tfvars"

# Update production-specific values
sed -i 's/environment = "dev"/environment = "prod"/' "$PROJECT_DIR/environments/prod.tfvars"
sed -i 's/vpc_cidr = "10.0.0.0\/16"/vpc_cidr = "10.1.0.0\/16"/' "$PROJECT_DIR/environments/prod.tfvars"
sed -i 's/CostCenter = "development"/CostCenter = "production"/' "$PROJECT_DIR/environments/prod.tfvars"

echo "Project created successfully!"
echo "Next steps:"
echo "1. cd $PROJECT_DIR"
echo "2. Review and customize the configuration files"
echo "3. terraform init"
echo "4. terraform plan -var-file=\"environments/dev.tfvars\""
echo "5. terraform apply -var-file=\"environments/dev.tfvars\""
```

### Deployment Script

A comprehensive deployment script handles the entire deployment process:

```bash
#!/bin/bash
# projects/vent-help/scripts/deploy-infrastructure.sh

ENVIRONMENT=$1
ACTION=${2:-apply}
TFVARS_FILE="environments/${ENVIRONMENT}.tfvars"

# Function to check AWS credentials
check_aws_credentials() {
    if ! aws sts get-caller-identity &>/dev/null; then
        echo "AWS credentials not configured or invalid"
        echo "Please configure your AWS credentials:"
        echo "  aws configure"
        exit 1
    fi
}

# Function to setup S3 bucket for Terraform state
setup_s3_bucket() {
    S3_BUCKET="opeyemi-terraform-state"
    if ! aws s3 ls "s3://$S3_BUCKET" &>/dev/null; then
        echo "Creating S3 bucket: $S3_BUCKET"
        aws s3 mb "s3://$S3_BUCKET" --region "us-east-1"
        
        echo "Enabling versioning on S3 bucket"
        aws s3api put-bucket-versioning \
            --bucket "$S3_BUCKET" \
            --versioning-configuration Status=Enabled
    fi
}

# Function to apply Terraform deployment
apply_terraform() {
    echo "Applying Terraform deployment..."
    terraform apply -var-file="$TFVARS_FILE"
    
    echo "Deployment completed successfully!"
    
    # Show outputs
    echo "Infrastructure outputs:"
    terraform output
    
    # Show connection details
    echo "Connection details:"
    echo "Database endpoint: $(terraform output -raw database_endpoint)"
    echo "Redis endpoint: $(terraform output -raw redis_endpoint)"
}

# Main execution
case $ACTION in
    "apply")
        check_aws_credentials
        setup_s3_bucket
        terraform init
        terraform validate
        apply_terraform
        ;;
esac
```

### Makefile for Common Operations

A Makefile provides convenient commands for common operations:

```makefile
# Makefile
.PHONY: help init plan apply destroy dev staging prod clean validate fmt security-scan

help:
	@echo "Available commands:"
	@echo "  init         - Initialize Terraform"
	@echo "  validate     - Validate Terraform configuration"
	@echo "  fmt          - Format Terraform files"
	@echo "  security-scan - Run security scan with tfsec"
	@echo "  plan         - Plan Terraform changes"
	@echo "  apply        - Apply Terraform changes"
	@echo "  destroy      - Destroy all resources"
	@echo "  dev          - Deploy to development environment"
	@echo "  staging      - Deploy to staging environment"
	@echo "  prod         - Deploy to production environment"

# Initialize Terraform
init:
	terraform init

# Validate configuration
validate: init
	terraform validate

# Format Terraform files
fmt:
	terraform fmt -recursive

# Security scan (requires tfsec)
security-scan:
	@if command -v tfsec >/dev/null 2>&1; then \
		tfsec .; \
	else \
		echo "tfsec not installed. Install with: brew install tfsec"; \
	fi

# Development environment
dev: validate
	terraform plan -var-file="environments/dev.tfvars"
	@read -p "Apply changes to DEV environment? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		terraform apply -var-file="environments/dev.tfvars"; \
	fi

# Production environment
prod: validate security-scan
	@echo "PRODUCTION DEPLOYMENT - Extra validation required"
	terraform plan -var-file="environments/prod.tfvars"
	@read -p "Apply changes to PRODUCTION environment? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		terraform apply -var-file="environments/prod.tfvars"; \
	fi
```

## Security Best Practices

### 1. Secrets Management

All sensitive data is stored in AWS Secrets Manager:

```hcl
# Generate random password
resource "random_password" "database_password" {
  length  = 32
  special = true
}

# Store password in AWS Secrets Manager
resource "aws_secretsmanager_secret" "database_password" {
  name                    = "${var.environment}/venthelp/database/password"
  description             = "Database password for ${var.environment} environment"
  recovery_window_in_days = var.environment == "prod" ? 30 : 0
}

resource "aws_secretsmanager_secret_version" "database_password" {
  secret_id = aws_secretsmanager_secret.database_password.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.database_password.result
  })
}
```

### 2. Encryption

All data is encrypted at rest and in transit:

```hcl
# KMS key for encryption
resource "aws_kms_key" "database" {
  description             = "KMS key for ${var.environment} database encryption"
  deletion_window_in_days = var.environment == "prod" ? 30 : 7
}

resource "aws_kms_alias" "database" {
  name          = "alias/${var.environment}-venthelp-db"
  target_key_id = aws_kms_key.database.key_id
}
```

### 3. Network Security

Security groups implement least-privilege access:

```hcl
resource "aws_security_group" "database" {
  name_prefix = "${var.environment}-db-sg-"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.app_security_group_id]
    description     = "PostgreSQL access from application"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

## Cost Management

### Environment-Specific Sizing

Different environments use different resource sizes:

**Development:**
- `db.t3.micro` for PostgreSQL
- `cache.t3.micro` for Redis
- Single AZ deployment
- Minimal backup retention

**Production:**
- `db.t3.small` for PostgreSQL
- `cache.t3.small` for Redis
- Multi-AZ deployment
- Extended backup retention

### Resource Tagging

All resources are tagged for cost tracking:

```hcl
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
```

## Getting Started

### Prerequisites

1. **AWS CLI** configured with appropriate credentials
2. **Terraform** >= 1.0 installed
3. **AWS S3 bucket** for Terraform state storage

### Quick Start

1. **Clone the repository:**
   ```bash
   git clone <your-repo-url>
   cd infra
   ```

2. **Create a new project:**
   ```bash
   ./scripts/create-project.sh my-awesome-app
   ```

3. **Navigate to the project:**
   ```bash
   cd projects/my-awesome-app
   ```

4. **Deploy to development:**
   ```bash
   make dev
   ```

5. **Deploy to production:**
   ```bash
   make prod
   ```

## Benefits Achieved

### 1. **Multi-Project Support**
- **Vent.Help**: Full-stack application with database and caching (~$60-120/month)
- **AI-Incidence-Response**: Data-heavy application with enhanced monitoring (~$80-150/month)
- **babalola.dev**: Next.js portfolio with flexible deployment options (~$0-20/month)
- Each project optimized for its specific requirements

### 2. **Consistency**
- Identical infrastructure patterns across projects
- Standardized security configurations
- Consistent monitoring and alerting
- Shared modules reduce duplication

### 3. **Scalability**
- Easy to add new projects using the template
- Modular design allows for easy component updates
- Environment-specific configurations
- Support for different project types (web apps, data processing, static sites)

### 4. **Security**
- Encryption at rest and in transit
- Secrets managed through AWS Secrets Manager
- Network isolation with separate VPC CIDRs
- Least-privilege access controls

### 5. **Cost Optimization**
- Environment-specific resource sizing
- Comprehensive tagging for cost tracking
- Automated backup management
- Right-sized infrastructure for each project type

### 6. **Operational Excellence**
- Comprehensive monitoring and alerting
- Automated deployment scripts
- Infrastructure as Code best practices
- Easy project creation and management

## Lessons Learned

### 1. **Start Simple, Iterate**
I began with basic VPC and database modules, then gradually added complexity. This approach made debugging easier and allowed me to understand each component deeply.

### 2. **Environment Parity**
Keeping dev and prod environments as similar as possible (except for sizing) reduces deployment surprises and makes troubleshooting easier.

### 3. **Automation is Key**
The deployment scripts and Makefile save significant time and reduce human error. Investing in automation upfront pays dividends.

### 4. **Security First**
Implementing security best practices from the beginning is much easier than retrofitting them later.

### 5. **Documentation Matters**
Well-documented modules and clear README files make the infrastructure maintainable and help team members understand the setup.

## Future Enhancements

### Planned Improvements

1. **CI/CD Integration**: Automated testing and deployment pipelines
2. **Multi-Region Support**: Disaster recovery configurations
3. **Advanced Monitoring**: Custom dashboards and more sophisticated alerting
4. **Infrastructure Testing**: Terratest for automated testing
5. **Cost Optimization**: Automated rightsizing recommendations

### Additional Modules

- **ECS Module**: Container orchestration
- **ALB Module**: Application load balancing
- **S3 Module**: Object storage with lifecycle policies
- **CloudFront Module**: CDN for static assets

## Conclusion

Building this modular infrastructure setup has transformed how I approach project deployment and management. The combination of Terraform's declarative syntax, modular architecture, and comprehensive automation has created a robust foundation that scales with my diverse project needs.

### What I've Achieved

**Three Distinct Project Types:**
- **Vent.Help**: A full-stack mental health platform with PostgreSQL, Redis, and comprehensive monitoring
- **AI-Incidence-Response**: A data-heavy AI application optimized for processing and analysis
- **babalola.dev**: A modern Next.js portfolio website with flexible deployment options

**Unified Management:**
- Single repository for all infrastructure
- Consistent deployment patterns across projects
- Shared modules reduce duplication and maintenance overhead
- Environment-specific configurations for dev/prod

**Cost Efficiency:**
- Right-sized infrastructure for each project type
- Next.js portfolio can leverage free hosting options (Vercel) or minimal AWS costs
- Comprehensive tagging enables detailed cost tracking
- Automated resource management reduces waste

The key to success was starting simple, iterating based on real-world usage, and always prioritizing security and maintainability. This setup now supports multiple projects with different requirements while maintaining consistency and operational excellence.

Whether you're a solo developer managing multiple projects or part of a larger team, investing in Infrastructure as Code pays off quickly. The initial setup time is more than compensated by the time saved in deployments, debugging, and maintenance. The modular approach allows you to start with one project type and gradually expand to support more complex architectures as your needs grow.

## Resources

- [Terraform Documentation](https://www.terraform.io/docs/)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

---

*This infrastructure setup is part of my personal projects portfolio. You can find the complete code and documentation in my [infrastructure repository](https://github.com/yourusername/infra).*