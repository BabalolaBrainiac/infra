# Vent.Help Infrastructure

This directory contains the Terraform configuration for the Vent.Help project infrastructure.

## Architecture

- **VPC** with public and private subnets
- **PostgreSQL RDS** instance with encryption and automated backups
- **Redis ElastiCache** cluster with encryption and authentication
- **CloudWatch Monitoring** with comprehensive alarms and notifications
- **Security Groups** for secure network access
- **KMS** encryption for database and cache storage
- **Secrets Manager** for secure password and auth token storage

## Quick Start

### 1. Navigate to the project directory
```bash
cd infra/projects/vent-help
```

### 2. Initialize Terraform
```bash
terraform init
```

### 3. Deploy to Development
```bash
# Plan the deployment
terraform plan -var-file="environments/dev.tfvars"

# Apply the configuration
terraform apply -var-file="environments/dev.tfvars"
```

### 4. Deploy to Production
```bash
# Plan the deployment
terraform plan -var-file="environments/prod.tfvars"

# Apply the configuration
terraform apply -var-file="environments/prod.tfvars"
```

## Environment Configurations

- **Development** (`environments/dev.tfvars`): Cost-optimized for development
- **Production** (`environments/prod.tfvars`): High-availability configuration

## Outputs

After deployment, you'll get:
- Database endpoint and connection details
- Redis endpoint and connection details
- CloudWatch alarm ARNs and SNS topic information
- VPC and subnet information
- Security group IDs
- KMS key information

## Connecting to the Database

The database password is stored in AWS Secrets Manager. To retrieve it:

```bash
# Get the secret ARN from outputs
terraform output database_secret_arn

# Retrieve the password
aws secretsmanager get-secret-value --secret-id <secret-arn>
```

## Connecting to Redis

The Redis auth token is stored in AWS Secrets Manager. To retrieve it:

```bash
# Get the secret ARN from outputs
terraform output redis_auth_token_secret_arn

# Retrieve the auth token
aws secretsmanager get-secret-value --secret-id <secret-arn>
```

## Cost Estimation

- **Development**: ~$80/month (VPC + RDS + Redis + NAT Gateway)
- **Production**: ~$160/month (with Multi-AZ, enhanced monitoring, and Redis cluster)

## Security Features

- Database and Redis in private subnets
- Encryption at rest with KMS
- Secrets Manager for password and auth token storage
- Security groups with minimal access
- Enhanced monitoring (production only)
- Redis authentication enabled
- Comprehensive CloudWatch monitoring and alerting

## Maintenance

### Scaling
```bash
# Update instance class in tfvars file
terraform plan -var-file="environments/prod.tfvars"
terraform apply -var-file="environments/prod.tfvars"
```

### Backups
- Automated backups configured
- Manual snapshots can be created via AWS console
- Point-in-time recovery available

## Cleanup

⚠️ **Warning**: This will delete all resources including the database and its data.

```bash
terraform destroy -var-file="environments/dev.tfvars"
``` 