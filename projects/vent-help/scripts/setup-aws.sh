#!/bin/bash

# AWS Credentials Setup Script for Vent.Help Infrastructure

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

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Check if credentials are provided as arguments
if [ $# -eq 2 ]; then
    ACCESS_KEY_ID=$1
    SECRET_ACCESS_KEY=$2
    
    print_step "Setting up AWS credentials from command line arguments..."
    
    export AWS_ACCESS_KEY_ID="$ACCESS_KEY_ID"
    export AWS_SECRET_ACCESS_KEY="$SECRET_ACCESS_KEY"
    export AWS_DEFAULT_REGION="us-east-1"
    
    print_status "AWS credentials set from command line"
    
elif [ $# -eq 0 ]; then
    print_step "Setting up AWS credentials interactively..."
    
    # Check if AWS CLI is installed
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed. Please install it first:"
        echo "  macOS: brew install awscli"
        echo "  Ubuntu: sudo apt install awscli"
        echo "  Or download from: https://aws.amazon.com/cli/"
        exit 1
    fi
    
    # Check if credentials are already configured
    if aws sts get-caller-identity &>/dev/null; then
        print_status "AWS credentials are already configured"
        aws sts get-caller-identity
    else
        print_warning "AWS credentials not found. Please configure them:"
        echo ""
        echo "Option 1: Use aws configure"
        echo "  aws configure"
        echo ""
        echo "Option 2: Set environment variables"
        echo "  export AWS_ACCESS_KEY_ID=your_access_key"
        echo "  export AWS_SECRET_ACCESS_KEY=your_secret_key"
        echo "  export AWS_DEFAULT_REGION=us-east-1"
        echo ""
        echo "Option 3: Run this script with credentials"
        echo "  ./scripts/setup-aws.sh YOUR_ACCESS_KEY YOUR_SECRET_KEY"
        exit 1
    fi
    
else
    print_error "Usage: $0 [access_key secret_key]"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Interactive setup"
    echo "  $0 AKIA... kiIvYsj6...              # Command line setup"
    exit 1
fi

# Test the credentials
print_step "Testing AWS credentials..."
if aws sts get-caller-identity &>/dev/null; then
    print_status "AWS credentials are valid!"
    aws sts get-caller-identity
else
    print_error "AWS credentials are invalid or not working"
    exit 1
fi

print_status "AWS setup completed successfully!"
print_status "You can now run: ./scripts/deploy-infrastructure.sh dev apply" 