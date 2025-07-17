.PHONY: help init plan apply destroy dev staging prod clean validate fmt security-scan

# Default target
help:
	@echo "Available commands:"
	@echo "  init         - Initialize Terraform"
	@echo "  validate     - Validate Terraform configuration"
	@echo "  fmt          - Format Terraform files"
	@echo "  security-scan - Run security scan with tfsec"
	@echo "  plan         - Plan Terraform changes"
	@echo "  apply        - Apply Terraform changes"
	@echo "  destroy      - Destroy all resources"
	@echo "  dev          - Deploy to development environment"
	@echo "  staging      - Deploy to staging environment"
	@echo "  prod         - Deploy to production environment"
	@echo "  clean        - Clean up local Terraform files"

# Initialize Terraform
init:
	terraform init

# Validate configuration
validate: init
	terraform validate

# Format Terraform files
fmt:
	terraform fmt -recursive

# Security scan (requires tfsec)
security-scan:
	@if command -v tfsec >/dev/null 2>&1; then \
		tfsec .; \
	else \
		echo "tfsec not installed. Install with: brew install tfsec"; \
	fi

# Plan changes
plan: validate
	terraform plan

# Apply changes
apply: validate
	terraform apply

# Destroy all resources
destroy:
	@echo "WARNING: This will destroy all resources!"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		terraform destroy; \
	fi

# Development environment
dev: validate
	terraform plan -var-file="environments/dev.tfvars"
	@read -p "Apply changes to DEV environment? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		terraform apply -var-file="environments/dev.tfvars"; \
	fi

# Staging environment
staging: validate
	terraform plan -var-file="environments/staging.tfvars"
	@read -p "Apply changes to STAGING environment? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		terraform apply -var-file="environments/staging.tfvars"; \
	fi

# Production environment
prod: validate security-scan
	@echo "PRODUCTION DEPLOYMENT - Extra validation required"
	terraform plan -var-file="environments/prod.tfvars"
	@read -p "Apply changes to PRODUCTION environment? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		terraform apply -var-file="environments/prod.tfvars"; \
	fi

# Clean up local files
clean:
	rm -rf .terraform
	rm -f .terraform.lock.hcl
	rm -f terraform.tfstate*
	rm -f *.tfplan