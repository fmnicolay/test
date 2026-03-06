terraform {
  required_version = ">= 1.4.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

provider "aws" { region = var.aws_region }

locals {
  name = "testappaws-dev"
  tags = { project = "testappaws", env = "dev" }
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

module "tailscale_router" {
  source              = "../../modules/tailscale_router"
  name                = local.name
  vpc_id              = module.network.vpc_id
  subnet_id           = module.network.public_subnet_ids[0]
  instance_type       = var.tailscale_instance_type
  hostname            = "testappaws-dev-router"
  advertise_routes    = [var.vpc_cidr]
  tailnet             = var.tailscale_tailnet
  oauth_client_id     = var.tailscale_oauth_client_id
  oauth_client_secret = var.tailscale_oauth_client_secret
  tags                = local.tags
}

module "alb" {
  source        = "../../modules/alb"
  name          = local.name
  vpc_id        = module.network.vpc_id
  subnet_ids    = module.network.private_subnet_ids
  internal      = true
  ingress_cidrs = []
  tags          = local.tags
}

# Allow the internal ALB only from the subnet router
resource "aws_security_group_rule" "alb_from_router" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = module.alb.alb_sg_id
  source_security_group_id = module.tailscale_router.router_sg_id
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
    { name = "SPRING_PROFILES_ACTIVE", value = "dev" }
  ]

  tags = local.tags
}

output "alb_internal_dns" { value = module.alb.alb_dns_name }
output "tailscale_router_public_ip" { value = module.tailscale_router.public_ip }
output "ecr_repository_url" { value = module.ecr.repository_url }
