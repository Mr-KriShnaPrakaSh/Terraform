# -------------
# Environment
# -------------
variable "env_name" {
  description = "Project or environment name (used for resource naming)"
  type        = string
}

# ----------------------
# Database Credentials
# ----------------------
variable "db_username" {
  description = "RDS master username"
  type        = string
}

variable "db_password" {
  description = "RDS master password (sensitive)"
  type        = string
  sensitive   = true
}

# ----------------------
# RDS Configuration
# ----------------------
variable "db_instance_class" {
  description = "RDS instance class (e.g., db.t3.medium)"
  type        = string
}

variable "private_subnet" {
  description = "List of private subnet IDs for RDS deployment"
  type        = list(string)
}

variable "rds_sg_id" {
  description = "Security Group ID to attach to RDS instance"
  type        = string
}
