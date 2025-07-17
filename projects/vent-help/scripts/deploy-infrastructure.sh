#!/bin/bash

# Vent.Help Infrastructure Deployment Script
# This script sets up and deploys PostgreSQL and Redis infrastructure to AWS

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Check if environment is provided
if [ $# -eq 0 ]; then
    print_error "Usage: $0 <environment> [action]"
    echo "Environment: dev, prod"
    echo "Action: setup, plan, apply, destroy (default: apply)"
    exit 1
fi

ENVIRONMENT=$1
ACTION=${2:-apply}

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(dev|prod)$ ]]; then
    print_error "Invalid environment. Use 'dev' or 'prod'"
    exit 1
fi

# Validate action
if [[ ! "$ACTION" =~ ^(setup|plan|apply|destroy)$ ]]; then
    print_error "Invalid action. Use 'setup', 'plan', 'apply', or 'destroy'"
    exit 1
fi

TFVARS_FILE="environments/${ENVIRONMENT}.tfvars"
S3_BUCKET="opeyemi-terraform-state"
REGION="us-east-1"

# Check if tfvars file exists
if [ ! -f "$TFVARS_FILE" ]; then
    print_error "Environment file $TFVARS_FILE not found"
    exit 1
fi

print_status "Deploying Vent.Help infrastructure for environment: $ENVIRONMENT"
print_status "Action: $ACTION"
print_status "Using configuration: $TFVARS_FILE"

# Function to check AWS credentials
check_aws_credentials() {
    print_step "Checking AWS credentials..."
    
    if ! aws sts get-caller-identity &>/dev/null; then
        print_error "AWS credentials not configured or invalid"
        print_error "Please configure your AWS credentials:"
        echo "  aws configure"
        echo "  or set environment variables:"
        echo "  export AWS_ACCESS_KEY_ID=your_access_key"
        echo "  export AWS_SECRET_ACCESS_KEY=your_secret_key"
        echo "  export AWS_DEFAULT_REGION=us-east-1"
        exit 1
    fi
    
    print_status "AWS credentials verified"
}

# Function to setup S3 bucket for Terraform state
setup_s3_bucket() {
    print_step "Setting up S3 bucket for Terraform state..."
    
    if ! aws s3 ls "s3://$S3_BUCKET" &>/dev/null; then
        print_status "Creating S3 bucket: $S3_BUCKET"
        aws s3 mb "s3://$S3_BUCKET" --region "$REGION"
        
        print_status "Enabling versioning on S3 bucket"
        aws s3api put-bucket-versioning \
            --bucket "$S3_BUCKET" \
            --versioning-configuration Status=Enabled
        
        print_status "S3 bucket setup completed"
    else
        print_status "S3 bucket $S3_BUCKET already exists"
    fi
}

# Function to initialize Terraform
init_terraform() {
    print_step "Initializing Terraform..."
    
    if [ ! -d ".terraform" ]; then
        terraform init
        print_status "Terraform initialized successfully"
    else
        print_status "Terraform already initialized"
    fi
}

# Function to validate Terraform configuration
validate_terraform() {
    print_step "Validating Terraform configuration..."
    
    if terraform validate; then
        print_status "Terraform configuration is valid"
    else
        print_error "Terraform configuration validation failed"
        exit 1
    fi
}

# Function to format Terraform files
format_terraform() {
    print_step "Formatting Terraform files..."
    
    if terraform fmt -recursive; then
        print_status "Terraform files formatted"
    else
        print_warning "Some Terraform files could not be formatted"
    fi
}

# Function to plan Terraform deployment
plan_terraform() {
    print_step "Planning Terraform deployment..."
    
    terraform plan -var-file="$TFVARS_FILE" -out=tfplan
    print_status "Plan completed successfully"
    print_warning "Review the plan above before applying"
}

# Function to apply Terraform deployment
apply_terraform() {
    print_step "Applying Terraform deployment..."
    
    if [ -f "tfplan" ]; then
        print_status "Applying from saved plan..."
        terraform apply tfplan
        rm -f tfplan
    else
        print_status "Applying directly..."
        terraform apply -var-file="$TFVARS_FILE"
    fi
    
    print_status "Deployment completed successfully!"
    
    # Show outputs
    print_step "Infrastructure outputs:"
    terraform output
    
    # Show connection details
    print_step "Connection details:"
    echo "Database endpoint: $(terraform output -raw database_endpoint 2>/dev/null || echo 'Not available yet')"
    echo "Redis endpoint: $(terraform output -raw redis_endpoint 2>/dev/null || echo 'Not available yet')"
    
    print_status "Next steps:"
    echo "1. Get database password: aws secretsmanager get-secret-value --secret-id \$(terraform output -raw database_secret_arn)"
    echo "2. Get Redis auth token: aws secretsmanager get-secret-value --secret-id \$(terraform output -raw redis_auth_token_secret_arn)"
    echo "3. Update your application environment variables with the connection details"
}

# Function to destroy infrastructure
destroy_terraform() {
    print_warning "This will destroy all resources including the database and its data!"
    read -p "Are you sure you want to continue? (yes/no): " confirm
    
    if [ "$confirm" = "yes" ]; then
        print_step "Destroying infrastructure..."
        terraform destroy -var-file="$TFVARS_FILE"
        print_status "Infrastructure destroyed successfully!"
    else
        print_status "Destroy cancelled."
    fi
}

# Function to setup complete infrastructure
setup_infrastructure() {
    print_step "Setting up complete infrastructure..."
    
    check_aws_credentials
    setup_s3_bucket
    init_terraform
    format_terraform
    validate_terraform
    
    print_status "Infrastructure setup completed!"
    print_status "You can now run: $0 $ENVIRONMENT plan"
}

# Main execution
case $ACTION in
    "setup")
        setup_infrastructure
        ;;
    "plan")
        check_aws_credentials
        setup_s3_bucket
        init_terraform
        validate_terraform
        plan_terraform
        print_warning "To apply: $0 $ENVIRONMENT apply"
        ;;
    "apply")
        check_aws_credentials
        setup_s3_bucket
        init_terraform
        validate_terraform
        apply_terraform
        ;;
    "destroy")
        check_aws_credentials
        init_terraform
        destroy_terraform
        ;;
esac

print_status "Deployment script completed!" 