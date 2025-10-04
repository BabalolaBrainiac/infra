#!/bin/bash

# Script to create a new project from the template

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

# Check if project name is provided
if [ $# -eq 0 ]; then
    print_error "Usage: $0 <project-name>"
    print_error "Example: $0 my-awesome-app"
    exit 1
fi

PROJECT_NAME="$1"
TEMPLATE_DIR="projects/_template"
PROJECT_DIR="projects/$PROJECT_NAME"

# Validate project name
if [[ ! $PROJECT_NAME =~ ^[a-z0-9-]+$ ]]; then
    print_error "Project name must contain only lowercase letters, numbers, and hyphens"
    exit 1
fi

# Check if project already exists
if [ -d "$PROJECT_DIR" ]; then
    print_error "Project '$PROJECT_NAME' already exists at $PROJECT_DIR"
    exit 1
fi

# Check if template exists
if [ ! -d "$TEMPLATE_DIR" ]; then
    print_error "Template directory not found at $TEMPLATE_DIR"
    exit 1
fi

print_header "Creating new project: $PROJECT_NAME"

# Copy template to new project
print_status "Copying template to $PROJECT_DIR..."
cp -r "$TEMPLATE_DIR" "$PROJECT_DIR"

# Replace PROJECT_NAME placeholder in files
print_status "Updating project-specific files..."

# Function to replace PROJECT_NAME in a file
replace_project_name() {
    local file="$1"
    if [ -f "$file" ]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            sed -i '' "s/PROJECT_NAME/$PROJECT_NAME/g" "$file"
        else
            # Linux
            sed -i "s/PROJECT_NAME/$PROJECT_NAME/g" "$file"
        fi
    fi
}

# Update main.tf
replace_project_name "$PROJECT_DIR/main.tf"

# Update environments/dev.tfvars
replace_project_name "$PROJECT_DIR/environments/dev.tfvars"

# Update README.md
replace_project_name "$PROJECT_DIR/README.md"

# Create production environment file
print_status "Creating production environment configuration..."
if [ -f "$PROJECT_DIR/environments/dev.tfvars" ]; then
    cp "$PROJECT_DIR/environments/dev.tfvars" "$PROJECT_DIR/environments/prod.tfvars"
    
    # Update production-specific values
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' 's/environment = "dev"/environment = "prod"/' "$PROJECT_DIR/environments/prod.tfvars"
        sed -i '' 's/vpc_cidr = "10.0.0.0\/16"/vpc_cidr = "10.1.0.0\/16"/' "$PROJECT_DIR/environments/prod.tfvars"
        sed -i '' 's/availability_zones = \["us-east-1a", "us-east-1b"\]/availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]/' "$PROJECT_DIR/environments/prod.tfvars"
        sed -i '' 's/CostCenter = "development"/CostCenter = "production"/' "$PROJECT_DIR/environments/prod.tfvars"
        sed -i '' 's/Purpose    = "'$PROJECT_NAME'-dev"/Purpose    = "'$PROJECT_NAME'-prod"/' "$PROJECT_DIR/environments/prod.tfvars"
    else
        # Linux
        sed -i 's/environment = "dev"/environment = "prod"/' "$PROJECT_DIR/environments/prod.tfvars"
        sed -i 's/vpc_cidr = "10.0.0.0\/16"/vpc_cidr = "10.1.0.0\/16"/' "$PROJECT_DIR/environments/prod.tfvars"
        sed -i 's/availability_zones = \["us-east-1a", "us-east-1b"\]/availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]/' "$PROJECT_DIR/environments/prod.tfvars"
        sed -i 's/CostCenter = "development"/CostCenter = "production"/' "$PROJECT_DIR/environments/prod.tfvars"
        sed -i 's/Purpose    = "'$PROJECT_NAME'-dev"/Purpose    = "'$PROJECT_NAME'-prod"/' "$PROJECT_DIR/environments/prod.tfvars"
    fi
fi

# Create .gitkeep files to ensure directories are tracked
print_status "Setting up directory structure..."
mkdir -p "$PROJECT_DIR/environments"
touch "$PROJECT_DIR/environments/.gitkeep"

print_header "Project created successfully!"

print_status "Project location: $PROJECT_DIR"
print_status "Next steps:"
echo "1. cd $PROJECT_DIR"
echo "2. Review and customize the configuration files"
echo "3. Uncomment and configure modules in main.tf"
echo "4. Add project-specific variables in variables.tf"
echo "5. Add project-specific outputs in outputs.tf"
echo "6. terraform init"
echo "7. terraform plan -var-file=\"environments/dev.tfvars\""
echo "8. terraform apply -var-file=\"environments/dev.tfvars\""

print_warning "Remember to:"
echo "- Update the S3 bucket name in main.tf if needed"
echo "- Configure your AWS credentials"
echo "- Review security settings for your use case"
echo "- Update the README.md with project-specific information"

print_status "Happy coding! 🚀" 