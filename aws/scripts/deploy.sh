#!/bin/bash

# Script to deploy any project with environment-specific configurations

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

# Default values
PROJECT=""
ENVIRONMENT="dev"
ACTION="apply"
VAR_FILE=""
WORKING_DIR=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--project)
            PROJECT="$2"
            shift 2
            ;;
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -a|--action)
            ACTION="$2"
            shift 2
            ;;
        -f|--var-file)
            VAR_FILE="$2"
            shift 2
            ;;
        -d|--directory)
            WORKING_DIR="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  -p, --project PROJECT     Project name (e.g., vent-help)"
            echo "  -e, --environment ENV     Environment (dev, staging, prod) [default: dev]"
            echo "  -a, --action ACTION       Terraform action (plan, apply, destroy) [default: apply]"
            echo "  -f, --var-file FILE       Custom var file path"
            echo "  -d, --directory DIR       Working directory (default: projects/PROJECT)"
            echo "  -h, --help                Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0 -p vent-help -e dev -a plan"
            echo "  $0 -p vent-help -e prod -a apply"
            echo "  $0 -p my-app -e dev -a destroy"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Validate required parameters
if [ -z "$PROJECT" ]; then
    print_error "Project name is required. Use -p or --project"
    exit 1
fi

# Set working directory
if [ -z "$WORKING_DIR" ]; then
    WORKING_DIR="projects/$PROJECT"
fi

# Check if project directory exists
if [ ! -d "$WORKING_DIR" ]; then
    print_error "Project directory not found: $WORKING_DIR"
    print_error "Available projects:"
    for dir in projects/*/; do
        if [ -d "$dir" ] && [ "$dir" != "projects/_template/" ]; then
            echo "  - $(basename "$dir")"
        fi
    done
    exit 1
fi

# Set var file based on environment if not specified
if [ -z "$VAR_FILE" ]; then
    if [ -f "$WORKING_DIR/environments/${ENVIRONMENT}.tfvars" ]; then
        VAR_FILE="$WORKING_DIR/environments/${ENVIRONMENT}.tfvars"
    else
        print_warning "No var file found for environment: ${ENVIRONMENT}"
        print_warning "Using default terraform.tfvars if it exists"
    fi
fi

print_header "Deploying $PROJECT to $ENVIRONMENT environment"

print_status "Project: $PROJECT"
print_status "Environment: $ENVIRONMENT"
print_status "Action: $ACTION"
print_status "Working directory: $WORKING_DIR"
if [ -n "$VAR_FILE" ]; then
    print_status "Var file: $VAR_FILE"
fi

# Change to project directory
print_status "Changing to project directory..."
cd "$WORKING_DIR"

# Check if terraform is installed
if ! command -v terraform &> /dev/null; then
    print_error "Terraform is not installed. Please install Terraform first."
    exit 1
fi

# Check if AWS CLI is configured
if ! aws sts get-caller-identity &> /dev/null; then
    print_error "AWS CLI is not configured. Please run 'aws configure' first."
    exit 1
fi

# Initialize Terraform
print_status "Initializing Terraform..."
terraform init

# Build terraform command
TF_CMD="terraform ${ACTION}"

if [ -n "$VAR_FILE" ] && [ -f "$VAR_FILE" ]; then
    TF_CMD="${TF_CMD} -var-file=\"${VAR_FILE}\""
fi

# Execute terraform command
print_status "Executing: ${TF_CMD}"
eval $TF_CMD

if [ "$ACTION" = "apply" ]; then
    print_status "Deployment completed successfully!"
    print_status "Run 'terraform output' to see the outputs."
    
    # Show important outputs
    print_status "Important outputs:"
    terraform output database_endpoint 2>/dev/null || echo "  No database endpoint found"
    terraform output vpc_id 2>/dev/null || echo "  No VPC ID found"
fi

print_status "Deployment script completed!" 