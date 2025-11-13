provider "aws" {
  region = var.aws_region
}

module "network" {
  source      = "../../modules/network"
  environment = var.environment

  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
}

module "alb" {
  source            = "../../modules/alb"
  environment       = var.environment
  app_port          = var.app_port
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
}

module "ecs" {
  source = "../../modules/ecs"

  environment = var.environment
  app_name    = var.app_name
  app_port    = var.app_port

  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids

  alb_target_group_arn  = module.alb.alb_target_group_arn
  alb_security_group_id = module.alb.alb_security_group_id
}
