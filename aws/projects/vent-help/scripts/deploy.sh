#!/bin/bash

# Vent.Help Infrastructure Deployment Script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if environment is provided
if [ $# -eq 0 ]; then
    print_error "Usage: $0 <environment> [action]"
    echo "Environment: dev, prod"
    echo "Action: plan, apply, destroy (default: plan)"
    exit 1
fi

ENVIRONMENT=$1
ACTION=${2:-plan}

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(dev|prod)$ ]]; then
    print_error "Invalid environment. Use 'dev' or 'prod'"
    exit 1
fi

# Validate action
if [[ ! "$ACTION" =~ ^(plan|apply|destroy)$ ]]; then
    print_error "Invalid action. Use 'plan', 'apply', or 'destroy'"
    exit 1
fi

TFVARS_FILE="environments/${ENVIRONMENT}.tfvars"

# Check if tfvars file exists
if [ ! -f "$TFVARS_FILE" ]; then
    print_error "Environment file $TFVARS_FILE not found"
    exit 1
fi

print_status "Deploying Vent.Help infrastructure for environment: $ENVIRONMENT"
print_status "Action: $ACTION"
print_status "Using configuration: $TFVARS_FILE"

# Initialize Terraform if needed
if [ ! -d ".terraform" ]; then
    print_status "Initializing Terraform..."
    terraform init
fi

# Execute the specified action
case $ACTION in
    "plan")
        print_status "Planning deployment..."
        terraform plan -var-file="$TFVARS_FILE" -out=tfplan
        print_status "Plan completed. Review the plan above."
        print_warning "To apply: $0 $ENVIRONMENT apply"
        ;;
    "apply")
        if [ -f "tfplan" ]; then
            print_status "Applying deployment from plan..."
            terraform apply tfplan
            rm -f tfplan
        else
            print_status "Applying deployment..."
            terraform apply -var-file="$TFVARS_FILE"
        fi
        
        print_status "Deployment completed!"
        print_status "Retrieving outputs..."
        terraform output
        
        print_status "Next steps:"
        echo "1. Get database password: aws secretsmanager get-secret-value --secret-id \$(terraform output -raw database_secret_arn)"
        echo "2. Get Redis auth token: aws secretsmanager get-secret-value --secret-id \$(terraform output -raw redis_auth_token_secret_arn)"
        echo "3. Update your application environment variables with the connection details"
        ;;
    "destroy")
        print_warning "This will destroy all resources including the database and its data!"
        read -p "Are you sure you want to continue? (yes/no): " confirm
        if [ "$confirm" = "yes" ]; then
            print_status "Destroying infrastructure..."
            terraform destroy -var-file="$TFVARS_FILE"
            print_status "Infrastructure destroyed!"
        else
            print_status "Destroy cancelled."
        fi
        ;;
esac 