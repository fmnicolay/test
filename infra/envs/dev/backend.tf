terraform {
  backend "s3" {
    bucket         = "tf-state-testappaws-4c880f"
    key            = "testappaws/dev/terraform.tfstate"
    region         = "ca-central-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
