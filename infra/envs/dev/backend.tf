terraform {
  backend "s3" {
    bucket         = "REPLACE_ME"
    key            = "testappaws/dev/terraform.tfstate"
    region         = "ca-central-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
