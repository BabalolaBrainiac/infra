data "hcloud_ssh_key" "existing" {
  count = var.ssh_key_name != "" && var.ssh_public_key == "" ? 1 : 0
  name  = var.ssh_key_name
}

resource "hcloud_ssh_key" "main" {
  count = var.ssh_public_key != "" ? 1 : 0

  name       = var.ssh_key_name != "" ? var.ssh_key_name : "${var.project_name}-${var.environment}-ssh-key"
  public_key = var.ssh_public_key
}

locals {
  ssh_key_id = var.ssh_public_key != "" ? hcloud_ssh_key.main[0].id : data.hcloud_ssh_key.existing[0].id
}