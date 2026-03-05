variable "env_name" {
  description = "Optional environment name. If null, a random name is generated."
  type        = string
  default     = null
}

variable "region" {
  description = "Just a practice variable (no cloud usage)."
  type        = string
  default     = "local"
}

variable "features" {
  description = "Enabled features (practice list variable)."
  type        = list(string)
  default     = ["logging", "metrics"]
}
