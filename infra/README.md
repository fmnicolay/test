# testAppAWS - Terraform (ECS)

Environments:
- **prod**: public ALB (HTTP)
- **dev**: private ALB (internal) reachable via **Tailscale subnet router**

## Cost control
To fully stop costs: `terraform destroy` for the env.
(Setting ECS desired_count=0 still leaves VPC/ALB/NAT running.)

## Bootstrap remote state
Create S3 bucket + DynamoDB lock table first:

```bash
cd infra/bootstrap
terraform init
terraform apply
```

Then set the bucket name in:
- `infra/envs/dev/backend.tf`
- `infra/envs/prod/backend.tf`

## Deploy
```bash
cd infra/envs/dev
terraform init -reconfigure
terraform apply -var-file=dev.tfvars -var 'image=<ECR_IMAGE_URI>'

cd ../prod
terraform init -reconfigure
terraform apply -var-file=prod.tfvars -var 'image=<ECR_IMAGE_URI>'
```
