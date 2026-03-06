variable "name" { type = string }
variable "vpc_id" { type = string }
variable "subnet_id" { type = string }

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "hostname" {
  type    = string
  default = "dev-subnet-router"
}

variable "advertise_routes" { type = list(string) }

variable "tailnet" { type = string }
variable "oauth_client_id" { type = string }

variable "oauth_client_secret" {
  type      = string
  sensitive = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
