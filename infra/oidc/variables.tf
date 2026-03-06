variable "aws_region" {
  type    = string
  default = "ca-central-1"
}

variable "project_name" {
  type    = string
  default = "testappaws"
}

variable "github_owner" {
  type    = string
  default = "fmnicolay"
}

variable "github_repo" {
  type    = string
  default = "test"
}

variable "ecr_repo_name" {
  type    = string
  default = "testappaws"
}
