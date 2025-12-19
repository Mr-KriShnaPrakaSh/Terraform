variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "env_name" {
  description = "Project or environment name (used for resource naming)"
  type        = string
}

variable "db_username" {
  description = "RDS master username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS instance size (e.g., db.t3.micro)"
  type        = string
  default     = "db.t3.micro"
}

variable "vpc_id" {
  description = "VPC ID where resources will be deployed"
  type        = string
}

variable "app_sg_id" {
  description = "Security Group ID to attach to application resources"
  type        = string
}
