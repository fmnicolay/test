variable "name" { type = string }
variable "vpc_id" { type = string }
variable "subnet_ids" { type = list(string) }

variable "alb_sg_id" { type = string }
variable "target_group_arn" { type = string }
variable "listener_arn" { type = string }

variable "image" { type = string }

variable "container_name" {
  type    = string
  default = "app"
}

variable "container_port" {
  type    = number
  default = 8080
}

variable "cpu" {
  type    = number
  default = 256
}

variable "memory" {
  type    = number
  default = 512
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "environment" {
  type    = list(object({ name = string, value = string }))
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
