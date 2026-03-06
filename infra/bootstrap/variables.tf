variable "aws_region" {
  type    = string
  default = "ca-central-1"
}

variable "bucket_name_prefix" {
  type    = string
  default = "tf-state-testappaws"
}

variable "dynamodb_table_name" {
  type    = string
  default = "terraform-locks"
}
