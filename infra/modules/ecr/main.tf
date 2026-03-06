terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# ECR repository is created by the deploy workflow (to avoid first-run bootstrap issues).
# Here we only look it up so Terraform can output the repo URL and depend on it.

data "aws_ecr_repository" "this" {
  name = var.name
}

output "repository_url" {
  value = data.aws_ecr_repository.this.repository_url
}
