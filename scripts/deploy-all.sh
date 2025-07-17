#!/bin/bash

set -e

PROJECTS=("vent-help" "babalola-dev" "root-project")
ENVIRONMENT=${1:-dev}

echo "Deploying all projects to $ENVIRONMENT environment..."

for project in "${PROJECTS[@]}"; do
    echo "\n=== Deploying $project ==="
    cd "projects/$project"
    
    # Initialize and apply
    terraform init
    terraform plan -var-file="environments/$ENVIRONMENT.tfvars"
    terraform apply -var-file="environments/$ENVIRONMENT.tfvars" -auto-approve
    
    cd ../..
done

echo "\nAll projects deployed successfully!"