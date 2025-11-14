# Infrastructure as Code Repository

This repository contains Terraform configurations for provisioning cloud infrastructure across multiple providers (AWS and Hetzner Cloud) in a modular, scalable, and maintainable way.

## 📋 Table of Contents

- [Overview](#overview)
- [Repository Structure](#repository-structure)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [AWS Infrastructure](#aws-infrastructure)
- [Hetzner Infrastructure](#hetzner-infrastructure)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## 🏗️ Overview

This infrastructure repository follows Infrastructure as Code (IaC) principles using Terraform to manage:

- **AWS Infrastructure**: Multi-project AWS resources with shared modules
- **Hetzner Cloud Infrastructure**: Cost-effective European cloud infrastructure

### Key Features

- ✅ **Modular Architecture**: Reusable modules for common infrastructure patterns
- ✅ **Environment Separation**: Dev, staging, and production configurations
- ✅ **State Management**: Remote state with Terraform Cloud
- ✅ **Security First**: Encrypted storage, secure networking, least-privilege access
- ✅ **Cost Optimized**: Environment-specific sizing and resource allocation
- ✅ **Automated Deployments**: Scripts and Makefiles for common operations

## 📁 Repository Structure

```
infra/
├── aws/                          # AWS infrastructure
│   ├── modules/                  # Reusable AWS modules
│   │   ├── vpc/                 # VPC and networking
│   │   ├── postgresql/           # RDS PostgreSQL
│   │   ├── redis/               # ElastiCache Redis
│   │   ├── security_groups/    # Security groups
│   │   └── monitoring/          # CloudWatch monitoring
│   ├── projects/                # Project-specific configurations
│   │   ├── _template/           # Template for new projects
│   │   └── vent-help/           # Vent.Help project
│   ├── scripts/                 # Deployment scripts
│   ├── Makefile                 # Common operations
│   └── README.md                # AWS-specific documentation
│
├── hetzner/                      # Hetzner Cloud infrastructure
│   ├── modules/                 # Reusable Hetzner modules
│   │   ├── server/             # Basic server module
│   │   ├── networking/         # Networking and firewall
│   │   └── postgres/           # PostgreSQL service
│   ├── environments/            # Environment configurations
│   │   ├── dev/                # Development environment
│   │   └── prod/               # Production environment
│   ├── scripts/                # Deployment scripts
│   ├── main.tf                 # Main configuration
│   ├── locals.tf               # Centralized configuration
│   └── README.md              # Hetzner-specific documentation
│
└── README.md                    # This file
```

## 🔧 Prerequisites

### Required Tools

1. **Terraform** >= 1.0
   ```bash
   # macOS
   brew install terraform
   
   # Linux
   wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
   unzip terraform_1.6.0_linux_amd64.zip
   sudo mv terraform /usr/local/bin/
   ```

2. **AWS CLI** (for AWS infrastructure)
   ```bash
   # macOS
   brew install awscli
   
   # Configure
   aws configure
   ```

3. **Terraform Cloud Account** (for remote state)
   - Sign up at [terraform.io](https://app.terraform.io)
   - Create organization and workspaces

### Required Accounts

- **AWS Account** with appropriate IAM permissions
- **Hetzner Cloud Account** with API token
- **Terraform Cloud Account** for state management

## 🚀 Quick Start

### AWS Infrastructure

```bash
# Navigate to AWS infrastructure
cd infra/aws

# Create a new project
./scripts/create-project.sh my-project

# Deploy to development
cd projects/my-project
terraform init
terraform plan -var-file="environments/dev.tfvars"
terraform apply -var-file="environments/dev.tfvars"
```

### Hetzner Infrastructure

```bash
# Navigate to Hetzner infrastructure
cd infra/hetzner

# Set environment variables
export HCLOUD_TOKEN="your-hetzner-api-token"
export SSH_PUBLIC_KEY="$(cat ~/.ssh/id_ed25519.pub)"

# Initialize with dev environment
terraform init -backend-config=environments/dev/backend-config.hcl

# Deploy
terraform apply -var-file="environments/dev/dev.tfvars" \
  -var="hcloud_token=$HCLOUD_TOKEN" \
  -var="ssh_public_key=$SSH_PUBLIC_KEY"
```

## ☁️ AWS Infrastructure

### Architecture

AWS infrastructure is organized into:

- **Shared Modules**: Reusable components (VPC, RDS, Redis, etc.)
- **Projects**: Application-specific infrastructure configurations
- **Environments**: Dev, staging, and production configurations

### Available Modules

| Module | Description | Use Case |
|--------|-------------|----------|
| `vpc` | VPC with public/private subnets, NAT Gateway | Network isolation |
| `postgresql` | RDS PostgreSQL with encryption, backups | Managed database |
| `redis` | ElastiCache Redis cluster | Caching layer |
| `security_groups` | Network security rules | Access control |
| `monitoring` | CloudWatch dashboards and alarms | Observability |

### Creating a New AWS Project

1. **Use the template:**
   ```bash
   cd infra/aws
   ./scripts/create-project.sh my-new-project
   ```

2. **Customize configuration:**
   - Edit `projects/my-new-project/main.tf`
   - Update `environments/dev.tfvars` and `environments/prod.tfvars`
   - Configure project-specific variables

3. **Deploy:**
   ```bash
   cd projects/my-new-project
   terraform init
   terraform plan -var-file="environments/dev.tfvars"
   terraform apply -var-file="environments/dev.tfvars"
   ```

### Cost Management

- **Development**: ~$60/month (small instances, single AZ)
- **Production**: ~$120-200/month (appropriate sizing, Multi-AZ)

See [AWS README](./aws/README.md) for detailed documentation.

## 🖥️ Hetzner Infrastructure

### Architecture

Hetzner infrastructure uses:

- **Centralized Configuration**: `locals.tf` for environment-specific settings
- **Modular Services**: Reusable modules for servers, networking, databases
- **Environment Isolation**: Separate configurations for dev/prod

### Available Services

| Service | Description | Cost (Dev/Prod) |
|---------|-------------|-----------------|
| PostgreSQL | Managed PostgreSQL 15 server | €9/€16 per month |
| Networking | Floating IPs, firewalls, VPCs | Included |
| Monitoring | Basic logging and status | Included |

### Setting Up Hetzner Infrastructure

1. **Get Hetzner API Token:**
   - Go to [Hetzner Cloud Console](https://console.hetzner.cloud/)
   - Navigate to **Security** → **API Tokens**
   - Generate token with **Read & Write** permissions

2. **Generate SSH Key:**
   ```bash
   ssh-keygen -t ed25519 -C "your-email@example.com" -f ~/.ssh/hetzner_key
   ```

3. **Set Environment Variables:**
   ```bash
   export HCLOUD_TOKEN="your-api-token"
   export SSH_PUBLIC_KEY="$(cat ~/.ssh/hetzner_key.pub)"
   ```

4. **Deploy:**
   ```bash
   cd infra/hetzner
   terraform init -backend-config=environments/dev/backend-config.hcl
   terraform apply -var-file="environments/dev/dev.tfvars" \
     -var="hcloud_token=$HCLOUD_TOKEN" \
     -var="ssh_public_key=$SSH_PUBLIC_KEY"
   ```

### Environment Management

**Development:**
- Backend: `environments/dev/backend-config.hcl`
- Variables: `environments/dev/dev.tfvars`
- Features: pgAdmin enabled, relaxed security
- Cost: ~€9/month

**Production:**
- Backend: `environments/prod/backend-config.hcl`
- Variables: `environments/prod/prod.tfvars`
- Features: Enhanced security, monitoring
- Cost: ~€16/month

See [Hetzner README](./hetzner/README.md) for detailed documentation.

## 🔐 Security Best Practices

### General

1. **Never commit secrets**: Use environment variables or Terraform Cloud variables
2. **Use remote state**: Store state in Terraform Cloud or S3 with encryption
3. **Enable state locking**: Prevent concurrent modifications
4. **Tag resources**: Tag all resources for cost tracking and security
5. **Least privilege**: Grant minimum required permissions

### AWS Specific

- Use IAM roles instead of access keys where possible
- Enable encryption at rest and in transit
- Use VPC endpoints for AWS service access
- Enable CloudTrail for audit logging
- Use AWS Secrets Manager for sensitive data

### Hetzner Specific

- Use SSH key authentication (disable password auth)
- Configure firewall rules restrictively
- Use different SSH keys per environment
- Store passwords in secure location (not in code)
- Enable automated backups

## 💰 Cost Optimization

### Development Environments

- Use smallest instance types (`t3.micro`, `cx21`)
- Disable Multi-AZ deployments
- Reduce backup retention periods
- Use single availability zone
- Disable deletion protection

### Production Environments

- Right-size instances based on actual usage
- Enable Multi-AZ for high availability
- Increase backup retention
- Enable deletion protection
- Use reserved instances for predictable workloads

### Cost Tracking

- Tag all resources with `Project`, `Environment`, `CostCenter`
- Use AWS Cost Explorer / Hetzner billing dashboard
- Set up billing alerts
- Review costs monthly

## 🛠️ Common Operations

### Using Makefile (AWS)

```bash
cd infra/aws

# Format all Terraform files
make fmt

# Validate configurations
make validate

# Security scan
make security-scan

# Deploy to dev
make dev

# Deploy to prod (with extra validation)
make prod
```

### Using Scripts

**AWS:**
```bash
# Create new project
./scripts/create-project.sh my-project

# Deploy project
./scripts/deploy.sh -p my-project -e dev -a apply
```

**Hetzner:**
```bash
# Deploy infrastructure
./scripts/deploy.sh dev

# Setup PostgreSQL
./scripts/postgres-setup.sh
```

## 🔄 Workflow

### Development Workflow

1. Create feature branch: `git checkout -b feature/my-change`
2. Make infrastructure changes
3. Validate: `terraform validate` or `make validate`
4. Plan changes: `terraform plan -var-file="environments/dev.tfvars"`
5. Test in dev: `terraform apply -var-file="environments/dev.tfvars"`
6. Create pull request
7. Review and merge

### Production Deployment

1. Merge approved changes to main branch
2. Deploy to staging (if available)
3. Run security scan: `make security-scan`
4. Review plan output carefully
5. Deploy to production: `make prod`
6. Monitor deployment and verify resources
7. Document any manual steps or gotchas

## 📊 State Management

### Terraform Cloud

Both AWS and Hetzner infrastructure use Terraform Cloud for remote state:

- **State Storage**: Encrypted and versioned
- **State Locking**: Prevents concurrent modifications
- **Workspace Isolation**: Separate workspaces per environment
- **Access Control**: Team-based permissions

### Backend Configuration

**AWS Projects:**
- State stored in S3 (configured per project)
- DynamoDB table for state locking

**Hetzner:**
- State stored in Terraform Cloud
- Backend config in `environments/{env}/backend-config.hcl`

## 🆘 Troubleshooting

### Common Issues

**1. State Lock Errors**
```bash
# Check for locks
terraform force-unlock <LOCK_ID>

# Or wait for lock to be released
```

**2. Module Not Found**
```bash
# Reinitialize Terraform
terraform init -upgrade
```

**3. Authentication Errors**
- AWS: Check `aws configure` and IAM permissions
- Hetzner: Verify `HCLOUD_TOKEN` is set and valid

**4. VPC CIDR Conflicts**
- Change CIDR block in `tfvars` file
- Ensure no overlap with existing VPCs

**5. Resource Already Exists**
- Import existing resource: `terraform import <resource> <id>`
- Or destroy and recreate (if safe)

### Getting Help

- Check provider-specific README files
- Review Terraform documentation
- Check cloud provider service limits
- Monitor cloud provider status pages
- Review Terraform Cloud run logs

## 📈 Monitoring and Maintenance

### Regular Tasks

- **Weekly**: Review infrastructure costs
- **Monthly**: Update Terraform and provider versions
- **Quarterly**: Review and optimize resource sizing
- **Annually**: Security audit and compliance review

### Monitoring

- **AWS**: CloudWatch dashboards and alarms
- **Hetzner**: Server metrics and logs
- **Terraform Cloud**: Run history and state changes

## 🔮 Future Enhancements

- [ ] Multi-region deployments
- [ ] Disaster recovery configurations
- [ ] Infrastructure testing with Terratest
- [ ] CI/CD pipeline integration
- [ ] Automated cost optimization recommendations
- [ ] Infrastructure drift detection
- [ ] Automated security scanning in CI/CD
- [ ] Documentation generation from code

## 📚 Additional Resources

### Documentation

- [AWS Infrastructure README](./aws/README.md)
- [Hetzner Infrastructure README](./hetzner/README.md)
- [Hetzner PostgreSQL Setup](./hetzner/POSTGRES_README.md)
- [Terraform Cloud Setup](./hetzner/TERRAFORM_CLOUD_SETUP.md)

### External Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Hetzner Provider Documentation](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs)
- [Terraform Cloud Documentation](https://www.terraform.io/docs/cloud)

## 📝 Contributing

When adding new infrastructure:

1. Follow existing module patterns
2. Document all variables and outputs
3. Add appropriate tags and labels
4. Test in development first
5. Update relevant README files
6. Add cost estimates if applicable

## 📄 License

This infrastructure code is part of Babalola Opeyemi's personal projects portfolio.

---

**Maintained by**: Babalola Opeyemi  
**Last Updated**: 2024

