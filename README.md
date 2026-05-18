# example-eks-rds-cloudflared-secured

A production-ready AWS infrastructure example provisioning an EKS cluster with RDS PostgreSQL, S3, and secure private access via Cloudflare Tunnel — all managed with Terraform modules and Terragrunt.

## Architecture

```
                        ┌──────────────────────────────────────────┐
                        │                  VPC                     │
                        │                                          │
  Internet/WARP ──────► │  Cloudflare Tunnel (EC2 RHEL 9)          │
                        │          │                               │
                        │          ▼                               │
                        │  EKS Cluster (managed node group)        │
                        │    ├── Karpenter (autoscaler)            │
                        │    ├── AWS Load Balancer Controller      │
                        │    ├── External Secrets Operator         │
                        │    └── Helm (via CodeBuild)              │
                        │          │                               │
                        │          ▼                               │
                        │  RDS PostgreSQL (private subnet)         │
                        │  S3 Bucket (KMS encrypted)               │
                        └──────────────────────────────────────────┘
```

All resources are encrypted with a shared **KMS key**. Private access to the cluster is secured exclusively through **Cloudflare WARP + Tunnel** — no public API endpoint is exposed.

## Modules

| Module | Description |
|--------|-------------|
| [`vpc`](./terraform/modules/vpc/README.md) | VPC with public/private subnets, NAT Gateway, VPC endpoints |
| [`kms`](./terraform/modules/kms/README.md) | KMS key with configurable service access and CloudWatch Logs policy |
| [`eks`](./terraform/modules/eks/README.md) | EKS cluster with node groups, IRSA, Karpenter, EFS, and LBC |
| [`rds`](./terraform/modules/rds/README.md) | RDS PostgreSQL with encryption, monitoring, and Secrets Manager |
| [`s3`](./terraform/modules/s3/README.md) | S3 bucket with KMS encryption, versioning, and lifecycle rules |
| [`tunnel`](./terraform/modules/tunnel/README.md) | Cloudflare Tunnel on EC2 for secure private VPC access |
| [`helm`](./terraform/modules/helm/README.md) | Helm chart deployment via AWS CodeBuild |

## Repository Structure

```
.
├── terraform/
│   └── modules/
│       ├── vpc/
│       ├── kms/
│       ├── eks/
│       ├── rds/
│       ├── s3/
│       ├── tunnel/
│       └── helm/
└── terragrunt/
    └── dev/
        ├── root.hcl
        ├── env.hcl
        ├── vpc/
        ├── kms/
        ├── eks/
        ├── rds/
        ├── s3/
        ├── tunnel/
        └── helm/
```

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.0
- [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/) >= 0.50
- AWS CLI configured with a named profile (e.g. `terraform_dev`)
- S3 bucket and DynamoDB table for Terraform remote state
- Secrets Manager secrets pre-created:
    - `<env>-<project>-db-secret` — `{ "username": "...", "password": "..." }`
    - `<env>-<project>-cloudflared` — `{ "tunnel_token": "..." }`

## Deployment

Deploy all modules in dependency order:

```bash
cd terragrunt/dev

# Deploy in order
terragrunt run-all apply --terragrunt-working-dir vpc
terragrunt run-all apply --terragrunt-working-dir kms
terragrunt run-all apply --terragrunt-working-dir eks
terragrunt run-all apply --terragrunt-working-dir rds
terragrunt run-all apply --terragrunt-working-dir s3
terragrunt run-all apply --terragrunt-working-dir tunnel
terragrunt run-all apply --terragrunt-working-dir helm
```

Or deploy everything at once (Terragrunt resolves dependencies automatically):

```bash
cd terragrunt/dev
terragrunt run-all apply
```

## Security Highlights

- **No public EKS API endpoint** — `endpoint_public_access = false`
- **Cloudflare WARP** — only authenticated users with WARP can reach the cluster
- **KMS encryption** — EKS secrets, RDS storage, EBS volumes, S3 objects, and Secrets Manager all encrypted
- **IRSA** — fine-grained IAM roles per Kubernetes service account (External Secrets, EBS/EFS CSI, LBC, Karpenter)
- **SSL enforced** — RDS connections require TLS (`force_ssl = true`)
- **Private subnets only** — EKS nodes, RDS, and the tunnel instance run in private subnets
- 