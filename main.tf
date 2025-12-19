terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.27.0"
    }
  }
}
provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket  = "myapp-terraform-state-dev-20251118" 
    key     = "uat/terraform.tfstate"
    region  = "ap-south-1"
    encrypt = true
    dynamodb_table = "terraform-lock"           
  }
}

# VPC Module
module "vpc" {
  source       = "./modules/vpc"
  env_name             = var.env_name
  aws_region           = var.aws_region
}

# RDS Module
module "rds" {
  source            = "./modules/rds"
  env_name      = var.env_name
  db_username       = var.db_username
  db_password       = var.db_password
  db_instance_class = var.db_instance_class
  private_subnet   = module.vpc.private_subnet
  rds_sg_id         = module.vpc.rds_sg_id
}

# ECR & IAM Module
module "ecr" {
  source       = "./modules/ecr"
  env_name = var.env_name
}

module "alb" {
  source        = "./modules/alb"
  env_name      = var.env_name
  aws_region         = var.aws_region
  vpc_id        = module.vpc.vpc_id
  public_subnet = module.vpc.public_subnet
  app_sg_id     = module.vpc.app_sg_id
}

module "ecs" {
  source = "./modules/ecs"
  env_name = var.env_name
  private_subnet          = module.vpc.private_subnet
  app_sg_id               = module.vpc.app_sg_id
  pp_target_groups        = module.alb.pp_target_groups
  dd_target_groups        = module.alb.dd_target_groups
  cpu                     = "1024"
  memory                  = "2048"
  listeners_https         = [module.alb.pp_https_listener, module.alb.dd_https_listener]
  aws_region              = var.aws_region
}