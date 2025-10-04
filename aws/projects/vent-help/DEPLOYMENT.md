# Vent.Help Infrastructure Deployment Guide

This guide explains how to deploy the Vent.Help infrastructure (PostgreSQL and Redis) to AWS using the provided scripts.

## Prerequisites

1. **AWS CLI installed**
   ```bash
   # macOS
   brew install awscli
   
   # Ubuntu/Debian
   sudo apt install awscli
   
   # Or download from: https://aws.amazon.com/cli/
   ```

2. **Terraform installed**
   ```bash
   # macOS
   brew install terraform
   
   # Or download from: https://www.terraform.io/downloads
   ```

3. **AWS credentials** with appropriate permissions for:
   - VPC creation
   - RDS (PostgreSQL) creation
   - ElastiCache (Redis) creation
   - Secrets Manager
   - S3 bucket creation
   - IAM roles and policies

## Quick Start

### 1. Set up AWS Credentials

**Option A: Using the setup script with your credentials**
```bash
./scripts/setup-aws.sh AKIATCKAPLQHID7PUHWR kiIvYsj6JFCSGdEydOjwcnSos8ASfAI7qbZeN5IE
```

**Option B: Using aws configure**
```bash
aws configure
# Enter your Access Key ID, Secret Access Key, and region (us-east-1)
```

**Option C: Set environment variables**
```bash
export AWS_ACCESS_KEY_ID=AKIATCKAPLQHID7PUHWR
export AWS_SECRET_ACCESS_KEY=kiIvYsj6JFCSGdEydOjwcnSos8ASfAI7qbZeN5IE
export AWS_DEFAULT_REGION=us-east-1
```

### 2. Deploy Infrastructure

**Deploy to development environment:**
```bash
./scripts/deploy-infrastructure.sh dev apply
```

**Deploy to production environment:**
```bash
./scripts/deploy-infrastructure.sh prod apply
```

## Deployment Scripts

### Main Deployment Script: `deploy-infrastructure.sh`

This script handles the complete deployment process:

```bash
./scripts/deploy-infrastructure.sh <environment> [action]
```

**Environments:**
- `dev` - Development environment (cost-optimized)
- `prod` - Production environment (high-availability)

**Actions:**
- `setup` - Initial setup (S3 bucket, Terraform init)
- `plan` - Show what will be deployed
- `apply` - Deploy the infrastructure (default)
- `destroy` - Remove all infrastructure

**Examples:**
```bash
# Deploy to development
./scripts/deploy-infrastructure.sh dev apply

# Plan production deployment
./scripts/deploy-infrastructure.sh prod plan

# Destroy development environment
./scripts/deploy-infrastructure.sh dev destroy
```

### AWS Setup Script: `setup-aws.sh`

This script helps configure AWS credentials:

```bash
./scripts/setup-aws.sh [access_key secret_key]
```

**Examples:**
```bash
# Interactive setup
./scripts/setup-aws.sh

# Command line setup
./scripts/setup-aws.sh AKIATCKAPLQHID7PUHWR kiIvYsj6JFCSGdEydOjwcnSos8ASfAI7qbZeN5IE
```

## What Gets Deployed

### Development Environment (`dev`)
- **VPC** with public and private subnets
- **PostgreSQL RDS**: `db.t3.micro` instance (20GB storage)
- **Redis ElastiCache**: `cache.t3.micro` instance (single node)
- **Security Groups** with minimal access
- **S3 Bucket** for Terraform state
- **Secrets Manager** for database and Redis credentials

### Production Environment (`prod`)
- **VPC** with public and private subnets across 3 AZs
- **PostgreSQL RDS**: `db.t3.small` instance (100GB storage, Multi-AZ)
- **Redis ElastiCache**: `cache.t3.small` instance (2 nodes, Multi-AZ)
- **Enhanced monitoring** and backup retention
- **Deletion protection** enabled

## Post-Deployment Steps

After successful deployment, you'll need to:

### 1. Get Connection Details

```bash
# Get database password
aws secretsmanager get-secret-value \
  --secret-id $(terraform output -raw database_secret_arn) \
  --query 'SecretString' \
  --output text | jq -r '.password'

# Get Redis auth token
aws secretsmanager get-secret-value \
  --secret-id $(terraform output -raw redis_auth_token_secret_arn) \
  --query 'SecretString' \
  --output text | jq -r '.auth_token'
```

### 2. Update Application Environment

Create or update your `.env.local` file:

```env
# Database Configuration
DB_HOST=<database_endpoint_from_terraform_output>
DB_PORT=5432
DB_NAME=venthelp_dev  # or venthelp for production
DB_USER=venthelp_admin
DB_PASSWORD=<password_from_secrets_manager>

# Redis Configuration
REDIS_URL=redis://<auth_token_from_secrets_manager>@<redis_endpoint_from_terraform_output>:6379

# Encryption Configuration
ENCRYPTION_KEY=your-32-character-encryption-key-here
```

### 3. Test the Connection

```bash
# Test database connection
psql "postgresql://venthelp_admin:<password>@<database_endpoint>:5432/venthelp_dev"

# Test Redis connection
redis-cli -h <redis_endpoint> -p 6379 -a <auth_token> ping
```

## Cost Estimation

### Development Environment
- **VPC & Networking**: ~$20/month
- **PostgreSQL RDS**: ~$15/month
- **Redis ElastiCache**: ~$15/month
- **S3 & Secrets Manager**: ~$5/month
- **Total**: ~$55/month

### Production Environment
- **VPC & Networking**: ~$30/month
- **PostgreSQL RDS**: ~$60/month (Multi-AZ)
- **Redis ElastiCache**: ~$40/month (Multi-AZ)
- **S3 & Secrets Manager**: ~$10/month
- **Total**: ~$140/month

## Troubleshooting

### Common Issues

**1. AWS Credentials Error**
```bash
# Verify credentials
aws sts get-caller-identity

# Re-run setup
./scripts/setup-aws.sh
```

**2. S3 Bucket Already Exists**
```bash
# The script will handle this automatically
# If manual intervention needed:
aws s3 ls s3://opeyemi-terraform-state
```

**3. Terraform State Lock**
```bash
# If deployment is interrupted, you may need to force unlock
terraform force-unlock <lock-id>
```

**4. Resource Creation Fails**
```bash
# Check AWS console for specific errors
# Common issues: insufficient permissions, quota limits
```

### Monitoring

**Check resource status:**
```bash
# List RDS instances
aws rds describe-db-instances

# List ElastiCache clusters
aws elasticache describe-replication-groups

# Check VPC
aws ec2 describe-vpcs --filters "Name=tag:Project,Values=vent-help"
```

## Security Best Practices

1. **Rotate credentials regularly**
2. **Use IAM roles instead of access keys when possible**
3. **Enable CloudTrail for audit logging**
4. **Set up CloudWatch alarms for monitoring**
5. **Regularly review security groups and access**

## Cleanup

To completely remove the infrastructure:

```bash
./scripts/deploy-infrastructure.sh dev destroy
# or
./scripts/deploy-infrastructure.sh prod destroy
```

⚠️ **Warning**: This will delete all data including the database and Redis cache.

## Support

If you encounter issues:

1. Check the AWS console for resource status
2. Review CloudWatch logs for errors
3. Verify your AWS credentials have sufficient permissions
4. Check the Terraform state: `terraform show`

For additional help, refer to the main project README or create an issue in the repository. 