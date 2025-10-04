#!/bin/bash
# PostgreSQL Server Deployment Script for Hetzner Cloud

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required environment variables are set
if [ -z "$HCLOUD_TOKEN" ]; then
    print_error "HCLOUD_TOKEN environment variable is not set"
    print_status "Please set your Hetzner Cloud API token:"
    print_status "export HCLOUD_TOKEN='your-api-token'"
    exit 1
fi

if [ -z "$SSH_PUBLIC_KEY" ]; then
    print_error "SSH_PUBLIC_KEY environment variable is not set"
    print_status "Please set your SSH public key:"
    print_status "export SSH_PUBLIC_KEY='\$(cat ~/.ssh/id_ed25519.pub)'"
    exit 1
fi

# Default environment
ENVIRONMENT=${1:-dev}

print_status "Deploying PostgreSQL server for environment: $ENVIRONMENT"

# Check if environment file exists
if [ ! -f "environments/${ENVIRONMENT}.tfvars" ]; then
    print_error "Environment file environments/${ENVIRONMENT}.tfvars not found"
    print_status "Available environments:"
    ls environments/*.tfvars | sed 's/environments\///g' | sed 's/.tfvars//g'
    exit 1
fi

# Initialize Terraform
print_status "Initializing Terraform..."
terraform init

# Plan deployment
print_status "Planning deployment..."
terraform plan \
    -var-file="environments/${ENVIRONMENT}.tfvars" \
    -var="hcloud_token=$HCLOUD_TOKEN" \
    -var="ssh_public_key=$SSH_PUBLIC_KEY"

# Ask for confirmation
echo
read -p "Do you want to proceed with the deployment? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_warning "Deployment cancelled"
    exit 0
fi

# Apply deployment
print_status "Deploying PostgreSQL server..."
terraform apply \
    -var-file="environments/${ENVIRONMENT}.tfvars" \
    -var="hcloud_token=$HCLOUD_TOKEN" \
    -var="ssh_public_key=$SSH_PUBLIC_KEY" \
    -auto-approve

# Get connection information
print_success "PostgreSQL server deployed successfully!"
echo
print_status "Connection Information:"
echo "=========================="

SERVER_IP=$(terraform output -raw server_ipv4)
FLOATING_IP=$(terraform output -raw floating_ip)
CONNECTION_IP=${FLOATING_IP:-$SERVER_IP}

echo "Server IP: $CONNECTION_IP"
echo "SSH Command: ssh root@$CONNECTION_IP"
echo

print_status "PostgreSQL Connection Info:"
echo "Host: $CONNECTION_IP"
echo "Port: 5432"
echo "Admin User: postgres"
echo "Admin Password: [Check your tfvars file]"
echo

print_status "Available Databases:"
terraform output -json database_connection_strings | jq -r 'keys[]' | while read db; do
    echo "- $db"
done

echo
print_status "Next Steps:"
echo "1. SSH into the server: ssh root@$CONNECTION_IP"
echo "2. Check PostgreSQL status: sudo systemctl status postgresql"
echo "3. Connect to PostgreSQL: sudo -u postgres psql"
echo "4. List databases: sudo -u postgres psql -c '\l'"

if [ "$ENVIRONMENT" = "dev" ] && terraform output -raw pgadmin_url > /dev/null 2>&1; then
    PGADMIN_URL=$(terraform output -raw pgadmin_url)
    echo "5. Access pgAdmin: $PGADMIN_URL"
fi

echo
print_success "Deployment completed!"
