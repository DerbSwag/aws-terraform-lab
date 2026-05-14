# AGENTS.md

## Project Overview

AWS Infrastructure as Code with Terraform — deploys a production-like FastAPI application on AWS (VPC + EC2 + Docker + Nginx).

## Tech Stack

- Terraform (HCL) >= 1.5 — infrastructure as code
- AWS — VPC, EC2, Security Groups, Internet Gateway
- Docker + Docker Compose — application runtime
- Bash — EC2 user_data bootstrap script
- GitHub Actions — CI (terraform validate + plan)

## Architecture

```
main.tf                   → VPC + Subnet + Security Group + EC2 instance
variables.tf              → Input variables (region, instance type, SSH CIDR, key name)
outputs.tf                → Output values (public IP, app URL)
terraform.tfvars.example  → Config template (copy to terraform.tfvars)
scripts/
  user_data.sh            → EC2 bootstrap: install Docker, deploy FastAPI + Nginx
.github/workflows/        → CI pipeline
```

## Conventions

- Single flat module (no nested modules yet)
- Variables with descriptive names and defaults where safe
- `terraform.tfvars` for environment-specific values (gitignored)
- Use `.example` suffix for config templates
- Tags on all AWS resources

## Commands

- Init: `terraform init`
- Plan: `terraform plan`
- Apply: `terraform apply`
- Destroy: `terraform destroy`
- Get URL: `terraform output app_url`
- SSH: `ssh -i your-key.pem ubuntu@$(terraform output -raw instance_public_ip)`

## Security Rules

- SSH restricted to `allowed_ssh_cidr` variable (never 0.0.0.0/0 in production)
- No secrets in code — use `terraform.tfvars` (gitignored)
- State file should be remote (S3 + DynamoDB) for team use

## Important Notes

- EC2: Ubuntu 24.04, t3.micro, 20GB gp3
- VPC CIDR: 10.0.0.0/16, Public Subnet: 10.0.1.0/24
- Ports open: 22 (SSH), 80 (HTTP/Nginx), 8000 (FastAPI)
- user_data.sh auto-installs Docker and deploys app on first boot
