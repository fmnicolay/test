terraform {
  required_version = ">= 1.4.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  repo = "${var.github_owner}/${var.github_repo}"

  # GitHub OIDC subject examples:
  # - repo:<owner>/<repo>:ref:refs/heads/master
  # - repo:<owner>/<repo>:ref:refs/heads/feature/foo
  prod_sub = "repo:${local.repo}:ref:refs/heads/master"
  dev_sub  = "repo:${local.repo}:ref:refs/heads/*"
}

# GitHub Actions OIDC provider
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  # GitHub's OIDC thumbprint changes occasionally. If this ever fails, update it.
  # Current commonly-used thumbprint for token.actions.githubusercontent.com:
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# Policy: ECR push/pull for a single repo
data "aws_iam_policy_document" "ecr_repo" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
      "ecr:DescribeRepositories",
      "ecr:CreateRepository",
      "ecr:ListImages",
      "ecr:DescribeImages"
    ]
    resources = [
      "arn:aws:ecr:${var.aws_region}:*:repository/${var.ecr_repo_name}",
    ]
  }
}

resource "aws_iam_policy" "ecr_repo" {
  name   = "${var.project_name}-ecr"
  policy = data.aws_iam_policy_document.ecr_repo.json
}

# NOTE: For simplicity (and because this is a personal account), we attach AdministratorAccess.
# You can tighten this later once the infra stabilizes.
resource "aws_iam_role" "gha_dev" {
  name = "${var.project_name}-gha-dev"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = local.dev_sub
          }
        }
      }
    ]
  })
}

resource "aws_iam_role" "gha_prod" {
  name = "${var.project_name}-gha-prod"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com",
            "token.actions.githubusercontent.com:sub" = local.prod_sub
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "dev_admin" {
  role       = aws_iam_role.gha_dev.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role_policy_attachment" "prod_admin" {
  role       = aws_iam_role.gha_prod.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role_policy_attachment" "dev_ecr" {
  role       = aws_iam_role.gha_dev.name
  policy_arn = aws_iam_policy.ecr_repo.arn
}

resource "aws_iam_role_policy_attachment" "prod_ecr" {
  role       = aws_iam_role.gha_prod.name
  policy_arn = aws_iam_policy.ecr_repo.arn
}

output "aws_role_to_assume_dev" {
  value       = aws_iam_role.gha_dev.arn
  description = "Set this in GitHub Actions secret AWS_ROLE_TO_ASSUME_DEV"
}

output "aws_role_to_assume_prod" {
  value       = aws_iam_role.gha_prod.arn
  description = "Set this in GitHub Actions secret AWS_ROLE_TO_ASSUME_PROD"
}
