# VPC Outputs
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet" {
  value = module.vpc.public_subnet
}

output "private_subnets" {
  value = module.vpc.private_subnet
}

output "app_sg_id" {
  value = module.vpc.app_sg_id
}

output "rds_sg_id" {
  value = module.vpc.rds_sg_id
}

# RDS Outputs
output "rds_primary_endpoint" {
  value = module.rds.primary_endpoint
}

output "rds_replica_endpoint" {
  value = module.rds.replica_endpoint
}

# ECR/IAM Outputs
output "api_ecr_url" {
  value = module.ecr.api_ecr_url
}

output "realtime_ecr_url" {
  value = module.ecr.realtime_ecr_url
}

output "ecs_execution_role_arn" {
  value = module.ecr.ecs_execution_role_arn
}

