# terraform-practice (agnostic)

## Quick start

```bash
cd terraform-practice/01-workspace-bootstrapper
terraform init
terraform apply
```

## Environments (tfvars)

```bash
# dev
terraform apply -var-file=environments/dev.tfvars

# prod
terraform apply -var-file=environments/prod.tfvars
```

To clean:
```bash
terraform destroy
rm -rf out/
```
