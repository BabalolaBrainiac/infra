resource "hcloud_ssh_key" "public_ssh_key" {
  name       = "babalola-hetzner-key"
  public_key = var.ssh_public_key
}

#ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP/9TQpRJtH3VE3TDkkECJ8C7kZuMLX+pj+pewgkueVo babalola@hetzner