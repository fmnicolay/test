variable "aws_region" {
  type    = string
  default = "ca-central-1"
}

variable "vpc_cidr" { type = string }
variable "public_subnet_cidrs" { type = list(string) }
variable "private_subnet_cidrs" { type = list(string) }

variable "ecr_repo_name" {
  type    = string
  default = "testappaws"
}

variable "image" {
  description = "ECR image URI with tag"
  type        = string
}

variable "desired_count" {
  type    = number
  default = 1
}
