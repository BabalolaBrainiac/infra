terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
    random = {
      source = "hashicorp/random"
    }
    local = {
      source = "hashicorp/local"
    }
  }
  required_version = ">= 0.13"
}

# Configure the Hetzner Cloud Provider
provider "hcloud" {
  token = var.hcloud_token
}