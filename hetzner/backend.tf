# Backend Configuration for Babalola's Hetzner Infrastructure
# Backend settings are configured per environment using backend-config.hcl files

terraform {
  backend "remote" {
    # Backend configuration is provided via -backend-config flag
    # CLI Command to initialize: terraform init -backend-config=environments/dev/backend-config.hcl
  }
}