# redis module variables

variable "server_name" {
  description = "name of the redis server"
  type        = string
}

variable "server_type" {
  description = "server type (cx21, cx31, cx41 recommended)"
  type        = string
  default     = "cpx21"
}

variable "location" {
  description = "hetzner location (nbg1, fsn1, hel1, ash, hil)"
  type        = string
  default     = "nbg1"
}

variable "ssh_key_id" {
  description = "hetzner ssh key id (or name) to attach to the server"
  type        = string
}

variable "create_floating_ip" {
  description = "create a floating ip for the server"
  type        = bool
  default     = true
}

variable "allowed_ssh_ips" {
  description = "list of ip addresses allowed for ssh access"
  type        = list(string)
  default     = ["0.0.0.0/0", "::/0"]
}

variable "redis_allowed_ips" {
  description = "list of ip addresses allowed to connect to redis"
  type        = list(string)
  default     = ["0.0.0.0/0", "::/0"]
}

variable "redis_port" {
  description = "redis tcp port"
  type        = number
  default     = 6379
}

variable "redis_maxmemory_mb" {
  description = "redis maxmemory in mb (0 means unlimited)"
  type        = number
  default     = 0
}

variable "redis_maxmemory_policy" {
  description = "redis maxmemory policy"
  type        = string
  default     = "allkeys-lru"
}

variable "enable_persistence" {
  description = "enable redis persistence (aof + rdb) and attach a volume"
  type        = bool
  default     = false
}

variable "volume_size" {
  description = "size of the volume in gb when persistence is enabled"
  type        = number
  default     = 20
}

variable "labels" {
  description = "labels to apply to resources"
  type        = map(string)
  default     = {}
}

# network configuration variables
variable "create_private_network" {
  description = "create a private network for the server"
  type        = bool
  default     = true
}

variable "network_ip_range" {
  description = "ip range for the private network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "network_zone" {
  description = "network zone for the subnet"
  type        = string
  default     = "eu-central"
}

variable "subnet_ip_range" {
  description = "ip range for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "server_private_ip" {
  description = "private ip address for the server"
  type        = string
  default     = "10.0.1.6"
}

variable "server_alias_ips" {
  description = "additional alias ips for the server"
  type        = list(string)
  default     = []
}

variable "enable_ipv6" {
  description = "enable ipv6 for the server"
  type        = bool
  default     = true
}


