# Babalola's Hetzner Infrastructure

This repository contains Terraform configurations for provisioning Hetzner Cloud infrastructure in a modular, scalable way.

## 🏗️ Architecture Overview

The infrastructure is organized into:

- **Shared Modules** (`modules/`): Reusable infrastructure components
- **Service Configurations** (`*.tf`): Service-specific infrastructure
- **Centralized Configuration** (`locals.tf`): Common settings and environment overrides

## 📁 Repository Structure

```
infra/hetzner/
├── modules/                    # Shared infrastructure modules
│   ├── server/                # Basic server module
│   ├── networking/            # Networking and firewall module
│   └── postgres/              # PostgreSQL service module
├── environments/              # Environment-specific configurations
│   ├── dev.tfvars            # Development environment
│   └── prod.tfvars           # Production environment
├── locals.tf                  # Centralized configuration
├── networking.tf              # Networking service
├── postgres.tf                # PostgreSQL service
├── services.tf                # Example additional services
├── main.tf                    # Provider configuration
├── variables.tf               # Input variables
├── outputs.tf                 # Output values
└── backend.tf                 # Remote state configuration
```

## 🚀 Getting Started

### Prerequisites

1. **Terraform** >= 1.0 installed
2. **Hetzner Cloud Account** with API token
3. **SSH Key Pair** generated for server access

### Setup Instructions

1. **Get your Hetzner Cloud API token:**
   - Go to [Hetzner Cloud Console](https://console.hetzner.cloud/)
   - Navigate to your project → **Security** → **API Tokens**
   - Click **Generate API Token** with **Read & Write** permissions
   - Copy the token (it won't be shown again)

2. **Generate SSH key pair:**
   ```bash
   ssh-keygen -t ed25519 -C "your-email@example.com"
   ```

3. **Set up Terraform Cloud workspace:**
   - Create a workspace named `babalolas-hetzner-infra`
   - Use CLI-driven workflow

4. **Configure environment variables:**
   ```bash
   export HCLOUD_TOKEN="your-api-token"
   export SSH_PUBLIC_KEY="$(cat ~/.ssh/id_ed25519.pub)"
   ```

5. **Initialize Terraform with environment-specific backend:**
   ```bash
   cd infra/hetzner
   terraform init -backend-config=environments/dev/backend-config.hcl
   ```

6. **Deploy the infrastructure:**
   ```bash
   terraform apply -var-file="environments/dev/dev.tfvars" \
     -var="hcloud_token=$HCLOUD_TOKEN" \
     -var="ssh_public_key=$SSH_PUBLIC_KEY"
   ```

## 🔧 Available Services

### PostgreSQL Database Server
- **Server**: Debian 12 with PostgreSQL 15
- **Storage**: Additional volume for database data
- **Security**: Firewall rules and SSH key authentication
- **Backups**: Automated daily backups
- **Monitoring**: Basic logging and status monitoring

### Networking
- **Floating IP**: Static IP address for consistent access
- **Firewalls**: SSH and PostgreSQL access controls
- **Security**: IP-based access restrictions

## 💰 Cost Estimation

### Development Environment
- **Server (cx21)**: €5.83/month
- **Floating IP**: €1.19/month
- **Volume (50GB)**: €2.00/month
- **Total**: ~€9/month

### Production Environment
- **Server (cx31)**: €10.70/month
- **Floating IP**: €1.19/month
- **Volume (100GB)**: €4.00/month
- **Total**: ~€16/month

## 🔐 Security Features

- **SSH Key Authentication**: No password-based SSH access
- **Firewall Rules**: Configurable network access controls
- **Environment Separation**: Different security settings for dev/prod
- **Encrypted Storage**: All volumes encrypted at rest
- **Secure Passwords**: Auto-generated passwords with secure storage

## 📊 Management Commands

### Connect to Server
```bash
terraform output postgres_ssh_connection_command
```

### Retrieve Database Passwords
```bash
terraform output postgres_password_retrieval_command
```

### Access pgAdmin (Development)
```bash
terraform output postgres_pgadmin_url
```

### Check Infrastructure Status
```bash
terraform show
```

## 🔄 Environment Management

### Development Environment
- **Backend**: `environments/dev/backend-config.hcl`
- **Variables**: `environments/dev/dev.tfvars`
- **Workspace**: `babalolas-hetzner-infra-dev`
- **Purpose**: Testing and development
- **Security**: Relaxed (allows connections from anywhere)
- **Features**: pgAdmin enabled, automated backups
- **Cost**: Optimized for development

### Production Environment
- **Backend**: `environments/prod/backend-config.hcl`
- **Variables**: `environments/prod/prod.tfvars`
- **Workspace**: `babalolas-hetzner-infra-prod`
- **Purpose**: Live applications
- **Security**: Strict (IP restrictions)
- **Features**: pgAdmin disabled, enhanced monitoring
- **Cost**: Optimized for performance and reliability

### Switching Between Environments

**Initialize Development:**
```bash
terraform init -backend-config=environments/dev/backend-config.hcl
terraform apply -var-file="environments/dev/dev.tfvars" \
  -var="hcloud_token=$HCLOUD_TOKEN" \
  -var="ssh_public_key=$SSH_PUBLIC_KEY"
```

**Initialize Production:**
```bash
terraform init -backend-config=environments/prod/backend-config.hcl
terraform apply -var-file="environments/prod/prod.tfvars" \
  -var="hcloud_token=$HCLOUD_TOKEN" \
  -var="ssh_public_key=$SSH_PUBLIC_KEY"
```

## 🛠️ Adding New Services

1. **Create service module:**
   ```bash
   mkdir -p modules/my-service
   # Add main.tf, variables.tf, outputs.tf
   ```

2. **Add service configuration:**
   ```hcl
   # services.tf
   module "my_service" {
     source = "./modules/my-service"
     
     # Configuration...
     
     labels = merge(local.common_labels, {
       Service = "my-service"
     })
   }
   ```

3. **Update locals.tf:**
   ```hcl
   # Add service-specific configuration
   my_service_config = {
     # Service settings...
   }
   ```

## 🆘 Troubleshooting

### Common Issues

1. **API Token Issues**
   - Verify token has correct permissions
   - Check token is not expired

2. **SSH Connection Issues**
   - Verify SSH key is correctly formatted
   - Check firewall rules

3. **PostgreSQL Connection Issues**
   - Check firewall rules for port 5432
   - Verify database credentials

### Getting Help

- [Hetzner Cloud Documentation](https://docs.hetzner.com/cloud/)
- [Terraform Hetzner Provider](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs)
- Check server logs: `ssh root@$(terraform output -raw postgres_floating_ip)`

## 🔮 Future Enhancements

- **High Availability**: Master-slave replication
- **Load Balancing**: Multiple read replicas
- **Monitoring**: Prometheus + Grafana setup
- **Automated Scaling**: Auto-scaling based on load
- **Disaster Recovery**: Cross-region backups

## 📄 License

This infrastructure code is part of Babalola's personal projects portfolio.