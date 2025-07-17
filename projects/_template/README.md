# PROJECT_NAME Infrastructure

This directory contains the Terraform configuration for the PROJECT_NAME project infrastructure.

## Quick Start

### 1. Copy this template
```bash
cp -r infra/projects/_template infra/projects/YOUR_PROJECT_NAME
cd infra/projects/YOUR_PROJECT_NAME
```

### 2. Update project-specific files
- Replace `PROJECT_NAME` with your actual project name in:
  - `main.tf` (backend key and project tag)
  - `environments/dev.tfvars` (Purpose tag)
  - `README.md` (this file)

### 3. Customize the configuration
- Uncomment and configure modules in `main.tf`
- Add project-specific variables in `variables.tf`
- Add project-specific outputs in `outputs.tf`
- Update environment configurations in `environments/`

### 4. Initialize and deploy
```bash
terraform init
terraform plan -var-file="environments/dev.tfvars"
terraform apply -var-file="environments/dev.tfvars"
```

## Available Modules

### Core Infrastructure
- **VPC** (`../../modules/vpc`): VPC with public and private subnets
- **Security Groups** (`../../modules/security_groups`): Network security rules

### Database
- **PostgreSQL** (`../../modules/postgresql`): RDS PostgreSQL with encryption

### Compute (Coming Soon)
- **ECS** (`../../modules/ecs`): ECS cluster for containerized applications
- **EC2** (`../../modules/ec2`): EC2 instances for traditional applications

### Networking (Coming Soon)
- **ALB** (`../../modules/alb`): Application Load Balancer
- **CloudFront** (`../../modules/cloudfront`): CDN for static content

### Storage (Coming Soon)
- **S3** (`../../modules/s3`): S3 buckets for file storage
- **EFS** (`../../modules/efs`): Elastic File System for shared storage

## Environment Configurations

- **Development** (`environments/dev.tfvars`): Cost-optimized for development
- **Production** (`environments/prod.tfvars`): High-availability configuration

## Best Practices

1. **Use environment-specific configurations** to avoid conflicts
2. **Tag all resources** for cost tracking and management
3. **Use private subnets** for sensitive resources
4. **Enable encryption** for all data at rest
5. **Use Secrets Manager** for sensitive configuration
6. **Enable monitoring** in production environments

## Cost Optimization

- Use appropriate instance sizes for each environment
- Disable Multi-AZ in development
- Use spot instances where possible
- Enable auto-scaling for variable workloads
- Monitor and optimize storage usage

## Security

- All resources are tagged with environment and project
- Database passwords are stored in Secrets Manager
- Security groups follow least-privilege principle
- Encryption is enabled by default
- VPC flow logs can be enabled for audit trails 