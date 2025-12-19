# ----------------------
# Environment
# ----------------------
variable "env_name" {
  description = "Environment name (dev, prod, uat, etc.) used in resource naming"
  type        = string
}

# ----------------------
# ALB Target Groups
# ----------------------
variable "pp_target_groups" {
  description = "Map of ALB target group ARNs for PP services (api, realtime, analytics)"
  type        = map(string)
}

variable "dd_target_groups" {
  description = "Map of ALB target group ARNs for DD services (api, realtime, analytics)"
  type        = map(string)
}

# ----------------------
# Networking
# ----------------------
variable "private_subnet" {
  description = "List of private subnet IDs where ECS tasks will run"
  type        = list(string)
}

variable "app_sg_id" {
  description = "Security group ID applied to ECS tasks"
  type        = string
}

# ----------------------
# ECS Resources
# ----------------------
variable "cpu" {
  description = "CPU units for ECS tasks"
  type        = string
}

variable "memory" {
  description = "Memory (MiB) for ECS tasks"
  type        = string
}

# ----------------------
# Dependencies
# ----------------------
variable "listeners_https" {
  description = "List of HTTPS listener ARNs from ALB to set as dependency"
  type        = list(string)
}

variable "aws_region" {
  description = "AWS region where ECS resources will be deployed"
  type        = string
}
