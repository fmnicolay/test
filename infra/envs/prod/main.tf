terraform {
  required_version = ">= 1.4.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

provider "aws" { region = var.aws_region }

locals {
  name = "testappaws-prod"
  tags = { project = "testappaws", env = "prod" }
}

module "network" {
  source               = "../../modules/network"
  name                 = local.name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  tags                 = local.tags
}

module "ecr" {
  source = "../../modules/ecr"
  name   = var.ecr_repo_name
}

module "alb" {
  source        = "../../modules/alb"
  name          = local.name
  vpc_id        = module.network.vpc_id
  subnet_ids    = module.network.public_subnet_ids
  internal      = false
  ingress_cidrs = ["0.0.0.0/0"]
  tags          = local.tags
}

module "ecs" {
  source           = "../../modules/ecs_service"
  name             = local.name
  vpc_id           = module.network.vpc_id
  subnet_ids       = module.network.private_subnet_ids
  alb_sg_id        = module.alb.alb_sg_id
  target_group_arn = module.alb.target_group_arn
  listener_arn     = module.alb.listener_arn

  image         = var.image
  desired_count = var.desired_count

  environment = [
    { name = "SPRING_PROFILES_ACTIVE", value = "prod" }
  ]

  tags = local.tags
}

output "alb_url" { value = "http://${module.alb.alb_dns_name}" }
output "ecr_repository_url" { value = module.ecr.repository_url }
