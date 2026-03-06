vpc_cidr = "10.10.0.0/16"

public_subnet_cidrs  = ["10.10.0.0/24", "10.10.1.0/24"]
private_subnet_cidrs = ["10.10.10.0/24", "10.10.11.0/24"]

# Pipeline will set this
image         = "REPLACE_ME"
desired_count = 1

# Fill from Tailscale OAuth client
# tailnet value is the string used by the API (often shows like "fmnicolay@")
tailscale_tailnet             = "REPLACE_ME"
tailscale_oauth_client_id     = "REPLACE_ME"
tailscale_oauth_client_secret = "REPLACE_ME"
