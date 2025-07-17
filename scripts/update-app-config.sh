#!/bin/bash

# Script to update application configuration with infrastructure outputs

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if project name is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <project-name> [app-path]"
    echo "Example: $0 vent-help ../vent.help"
    exit 1
fi

PROJECT_NAME="$1"
APP_PATH="${2:-../$PROJECT_NAME}"
PROJECT_DIR="projects/$PROJECT_NAME"

# Check if project directory exists
if [ ! -d "$PROJECT_DIR" ]; then
    echo "Error: Project directory not found: $PROJECT_DIR"
    exit 1
fi

# Change to project directory
cd "$PROJECT_DIR"

# Get Terraform outputs
print_status "Getting Terraform outputs for $PROJECT_NAME..."

DATABASE_ENDPOINT=$(terraform output -raw database_endpoint 2>/dev/null || echo "")
DATABASE_NAME=$(terraform output -raw database_name 2>/dev/null || echo "")
DATABASE_USERNAME=$(terraform output -raw database_username 2>/dev/null || echo "")
DATABASE_PORT=$(terraform output -raw database_port 2>/dev/null || echo "5432")
DATABASE_SECRET_ARN=$(terraform output -raw database_secret_arn 2>/dev/null || echo "")

if [ -z "$DATABASE_ENDPOINT" ]; then
    print_warning "Could not get database endpoint from Terraform outputs."
    print_warning "Make sure you're in the project directory and have run 'terraform apply'"
    exit 1
fi

print_status "Database Endpoint: $DATABASE_ENDPOINT"
print_status "Database Name: $DATABASE_NAME"
print_status "Database Username: $DATABASE_USERNAME"
print_status "Database Port: $DATABASE_PORT"

# Check if app directory exists
if [ ! -d "$APP_PATH" ]; then
    print_warning "Application directory not found at $APP_PATH"
    print_warning "Please update the APP_PATH variable or provide it as the second argument"
    exit 1
fi

# Create .env.local file for the application
ENV_FILE="$APP_PATH/.env.local"

print_status "Creating/updating .env.local file..."

cat > "$ENV_FILE" << EOF
# Database Configuration
DATABASE_URL=postgresql://${DATABASE_USERNAME}:<YOUR_PASSWORD>@${DATABASE_ENDPOINT}:${DATABASE_PORT}/${DATABASE_NAME}

# AWS Configuration
AWS_REGION=$(terraform output -raw aws_region 2>/dev/null || echo "us-east-1")
DATABASE_SECRET_ARN=${DATABASE_SECRET_ARN}

# Environment
NODE_ENV=development
EOF

print_status "Created .env.local file at $ENV_FILE"
print_warning "IMPORTANT: Replace <YOUR_PASSWORD> with your actual database password!"

if [ -n "$DATABASE_SECRET_ARN" ]; then
    print_status "Database password is stored in AWS Secrets Manager:"
    echo "  Secret ARN: $DATABASE_SECRET_ARN"
    echo ""
    print_status "To retrieve the password:"
    echo "  aws secretsmanager get-secret-value --secret-id $DATABASE_SECRET_ARN"
fi

print_status "Next steps:"
echo "1. Update the DATABASE_URL in $ENV_FILE with your actual password"
echo "2. Test the connection from your application"
echo "3. Update any other configuration files as needed" 