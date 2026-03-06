terraform {
  backend "s3" {
    bucket         = "REPLACE_ME"
    key            = "testappaws/prod/terraform.tfstate"
    region         = "ca-central-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
