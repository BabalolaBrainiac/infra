# Infrastructure as Code Repository

This repository contains Terraform configurations for provisioning AWS infrastructure across multiple projects in a modular, scalable way.

## 🏗️ Architecture Overview

The infrastructure is organized into:

- **Shared Modules** (`modules/`): Reusable infrastructure components
- **Project Configurations** (`projects/`): Project-specific infrastructure
- **Templates** (`projects/_template/`): Template for creating new projects

## 📁 Repository Structure

```
infra/
├── modules/                    # Shared infrastructure modules
│   ├── vpc/                   # VPC and networking
│   ├── postgresql/            # PostgreSQL RDS
│   ├── security_groups/       # Security groups
│   └── ...                    # Additional modules
├── projects/                   # Project-specific configurations
│   ├── _template/             # Template for new projects
│   ├── vent-help/             # Vent.Help project
│   └── ...                    # Additional projects
├── scripts/                    # Utility scripts
├── README.md                   # This file
└── Makefile                    # Common operations
```

## 🚀 Getting Started

### Prerequisites

1. **AWS CLI** configured with appropriate credentials
2. **Terraform** >= 1.0 installed
3. **AWS S3 bucket** for Terraform state storage

### Quick Start

1. **Navigate to a project:**
   ```bash
   cd infra/projects/vent-help
   ```

2. **Initialize Terraform:**
   ```bash
   terraform init
   ```

3. **Deploy to development:**
   ```bash
   terraform plan -var-file="environments/dev.tfvars"
   terraform apply -var-file="environments/dev.tfvars"
   ```

## 📋 Available Projects

### Vent.Help
- **Location**: `projects/vent-help/`
- **Description**: Mental health support platform
- **Components**: VPC, PostgreSQL RDS, Security Groups
- **Cost**: ~$60/month (dev), ~$120/month (prod)

### Adding New Projects

1. **Copy the template:**
   ```bash
   ./scripts/create-project.sh my-new-project
   ```

2. **Customize the configuration:**
   - Update project name in `main.tf`
   - Add project-specific variables
   - Configure environment settings

3. **Deploy:**
   ```bash
   cd projects/my-new-project
   terraform init
   terraform apply -var-file="environments/dev.tfvars"
   ```

## 🔧 Available Modules

### Core Infrastructure
- **VPC** (`modules/vpc/`): VPC with public/private subnets, NAT Gateway
- **Security Groups** (`modules/security_groups/`): Network security rules

### Database
- **PostgreSQL** (`modules/postgresql/`): RDS with encryption, backups, monitoring

### Coming Soon
- **ECS** (`modules/ecs/`): Container orchestration
- **ALB** (`modules/alb/`): Load balancing
- **S3** (`modules/s3/`): Object storage
- **CloudFront** (`modules/cloudfront/`): CDN

## 🛠️ Management Commands

### Using Makefile
```bash
# From the infra directory
make help                    # Show available commands
make validate                # Validate all configurations
make fmt                     # Format Terraform files
make security-scan           # Run security scan
```

### Using Scripts
```bash
# Create a new project
./scripts/create-project.sh my-project

# Deploy a project
./scripts/deploy.sh -p my-project -e dev -a apply

# Update application configuration
./scripts/update-app-config.sh my-project
```

## 🔐 Security Features

- **Encryption**: All data encrypted at rest and in transit
- **Secrets Management**: Passwords stored in AWS Secrets Manager
- **Network Security**: Private subnets, security groups, least-privilege access
- **Monitoring**: Enhanced monitoring for production environments
- **Backups**: Automated backups with point-in-time recovery

## 💰 Cost Management

### Development Environments
- Use smaller instance types (`db.t3.micro`)
- Disable Multi-AZ deployment
- Reduce backup retention
- Disable deletion protection

### Production Environments
- Use appropriate instance sizes
- Enable Multi-AZ for high availability
- Increase backup retention
- Enable deletion protection
- Enable enhanced monitoring

### Cost Tracking
- All resources tagged with project and environment
- Use AWS Cost Explorer to track by tags
- Set up billing alerts for each project

## 🔄 Workflow

### Development
1. Create feature branch
2. Make changes to project configuration
3. Test with `terraform plan`
4. Deploy to dev environment
5. Create pull request

### Production
1. Merge approved changes to main
2. Deploy to staging environment
3. Run security scan
4. Deploy to production environment
5. Monitor deployment

## 🚨 Best Practices

1. **Environment Isolation**: Use separate VPCs and configurations
2. **State Management**: Use S3 backend with state locking
3. **Tagging**: Tag all resources for cost tracking
4. **Security**: Follow least-privilege principle
5. **Monitoring**: Enable monitoring in production
6. **Backups**: Configure appropriate backup strategies
7. **Documentation**: Keep README files updated

## 🆘 Troubleshooting

### Common Issues

1. **State Lock**: Wait for state lock to be released or force unlock
2. **VPC CIDR Conflicts**: Change VPC CIDR in tfvars file
3. **Permission Errors**: Check AWS credentials and IAM permissions
4. **Module Not Found**: Run `terraform init` to download modules

### Getting Help

- Check project-specific README files
- Review Terraform documentation
- Check AWS service limits and quotas
- Monitor CloudWatch logs for errors

## 📈 Scaling

### Horizontal Scaling
- Use Auto Scaling Groups for compute
- Implement read replicas for databases
- Use load balancers for traffic distribution

### Vertical Scaling
- Increase instance sizes as needed
- Add more storage to databases
- Upgrade to larger instance classes

## 🔮 Future Enhancements

- **Multi-region deployments**
- **Disaster recovery configurations**
- **Advanced monitoring and alerting**
- **Infrastructure testing with Terratest**
- **CI/CD pipeline integration**
- **Cost optimization recommendations**

## 📄 License

This infrastructure code is part of the personal projects portfolio. # infra
