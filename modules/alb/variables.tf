# ----------------------
# Environment and AWS Settings
# ----------------------
variable "env_name" {
  description = "Environment name (e.g., dev, uat, prod) used in naming resources"
  type        = string
}

variable "aws_region" {
  description = "AWS region where the resources will be deployed"
  type        = string
}

# ----------------------
# Networking
# ----------------------
variable "vpc_id" {
  description = "ID of the VPC where ECS and ALB resources will be created"
  type        = string
}

variable "public_subnet" {
  description = "List of public subnet IDs for the load balancers"
  type        = list(string)
}

variable "app_sg_id" {
  description = "Security group ID applied to ALB and ECS services"
  type        = string
}
