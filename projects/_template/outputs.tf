# Common outputs for all projects
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "app_security_group_id" {
  description = "ID of the application security group"
  value       = module.security_groups.app_security_group_id
}

# Add your project-specific outputs here
# Example: Database outputs
# output "database_endpoint" {
#   description = "The connection endpoint for the RDS instance"
#   value       = module.postgresql.database_endpoint
# }

# output "database_name" {
#   description = "The name of the database"
#   value       = module.postgresql.database_name
# }

# Example: Application outputs
# output "alb_dns_name" {
#   description = "DNS name of the load balancer"
#   value       = module.alb.dns_name
# }

# output "ecs_cluster_name" {
#   description = "Name of the ECS cluster"
#   value       = module.ecs.cluster_name
# } 