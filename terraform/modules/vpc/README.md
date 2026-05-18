# VPC Module

This Terraform module provisions a production-ready AWS VPC with tiered subnet architecture designed for EKS, RDS, and Cloudflare Tunnel workloads.

## Architecture

The module creates the following network topology:

```
VPC (configurable CIDR)
├── Public Subnets (EKS)        — /24 blocks starting at offset 0
├── Private Subnets (EKS)       — /24 blocks starting at offset public_count
├── Private Subnets (Tunnel)    — /24 blocks starting at offset public_count + 10
└── Private Subnets (RDS)       — /24 blocks starting at offset public_count + 20
```

### Components

- **Internet Gateway** — attached to the VPC for public subnet egress
- **NAT Gateway(s)** — single or one-per-AZ strategy for private subnet egress
- **Elastic IPs** — one per NAT Gateway
- **Route Tables** — one public, one private per NAT Gateway
- **RDS Subnet Group** — spanning all private RDS subnets
- **VPC Flow Logs** — optional, shipped to CloudWatch Logs with configurable retention
- **VPC Endpoints** — optional Gateway (S3, DynamoDB) and Interface endpoints
- **Default Security Group** — locked down with no ingress/egress rules

## Usage

```hcl
module "vpc" {
  source = "./modules/vpc"

  project     = "myapp"
  environment = "production"
  region      = "eu-west-1"
  vpc_cidr    = "10.0.0.0/16"

  common_tags = {
    ManagedBy = "Terraform"
  }

  public_subnet_count  = 3
  private_subnet_count = 3
  nat_gateway_strategy = "single"

  enable_flow_logs             = true
  flow_logs_retention_days     = 14

  enable_s3_endpoint      = true
  enable_ecr_api_endpoint = true
  enable_ecr_dkr_endpoint = true
}
```

## Subnet Tagging

| Subnet Type     | ELB Tag                          | Karpenter Tag              |
|-----------------|----------------------------------|----------------------------|
| Public EKS      | `kubernetes.io/role/elb = 1`     | —                          |
| Private EKS     | `kubernetes.io/role/internal-elb = 1` | `karpenter.sh/discovery` |
| Private Tunnel  | `kubernetes.io/role/internal-elb = 1` | —                        |
| Private RDS     | —                                | —                          |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `project` | Application name used as namespace prefix | `string` | — | ✅ |
| `environment` | Environment name used as namespace prefix | `string` | — | ✅ |
| `region` | AWS Region | `string` | — | ✅ |
| `vpc_cidr` | CIDR block for the VPC | `string` | — | ✅ |
| `common_tags` | Common tags applied to all resources | `map(string)` | — | ✅ |
| `public_subnet_count` | Number of public subnets | `number` | `3` | ❌ |
| `private_subnet_count` | Number of private subnets per tier | `number` | `3` | ❌ |
| `nat_gateway_strategy` | `single` or `one_per_az` | `string` | `"single"` | ❌ |
| `enable_dns_hostnames` | Enable DNS hostnames in the VPC | `bool` | `true` | ❌ |
| `enable_dns_support` | Enable DNS support in the VPC | `bool` | `true` | ❌ |
| `enable_flow_logs` | Enable VPC flow logs | `bool` | `true` | ❌ |
| `flow_logs_retention_days` | CloudWatch log retention in days | `number` | `14` | ❌ |
| `endpoint_additional_ingress_cidrs` | Extra CIDRs allowed to reach VPC endpoints | `list(string)` | `[]` | ❌ |
| `enable_s3_endpoint` | Enable S3 Gateway endpoint | `bool` | `false` | ❌ |
| `enable_dynamodb_endpoint` | Enable DynamoDB Gateway endpoint | `bool` | `false` | ❌ |
| `enable_ecr_api_endpoint` | Enable ECR API Interface endpoint | `bool` | `false` | ❌ |
| `enable_ecr_dkr_endpoint` | Enable ECR DKR Interface endpoint | `bool` | `false` | ❌ |
| `enable_ec2_endpoint` | Enable EC2 Interface endpoint | `bool` | `false` | ❌ |
| `enable_sts_endpoint` | Enable STS Interface endpoint | `bool` | `false` | ❌ |
| `enable_elb_endpoint` | Enable ELB Interface endpoint | `bool` | `false` | ❌ |
| `enable_logs_endpoint` | Enable CloudWatch Logs Interface endpoint | `bool` | `false` | ❌ |
| `enable_monitoring_endpoint` | Enable CloudWatch Monitoring Interface endpoint | `bool` | `false` | ❌ |
| `enable_ssm_endpoint` | Enable SSM Interface endpoint | `bool` | `false` | ❌ |
| `enable_ssmmessages_endpoint` | Enable SSM Messages Interface endpoint | `bool` | `false` | ❌ |
| `enable_autoscaling_endpoint` | Enable Autoscaling Interface endpoint | `bool` | `false` | ❌ |
| `enable_secretsmanager_endpoint` | Enable Secrets Manager Interface endpoint | `bool` | `false` | ❌ |

## Outputs

| Name | Description |
|------|-------------|
| `vpc_id` | ID of the VPC |
| `vpc_cidr_block` | CIDR block of the VPC |
| `public_subnet_ids` | IDs of the public subnets |
| `private_subnet_ids` | IDs of the private subnets |
| `public_subnet_cidrs` | CIDR blocks of the public subnets |
| `private_subnet_cidrs` | CIDR blocks of the private subnets |
| `internet_gateway_id` | ID of the Internet Gateway |
| `nat_gateway_ids` | IDs of the NAT Gateways |
| `public_route_table_id` | ID of the public route table |
| `private_route_table_ids` | IDs of the private route tables |
| `availability_zones` | List of availability zones used |
| `vpc_endpoints_security_group_id` | ID of the VPC endpoints security group |

## VPC Endpoints

When any Interface endpoint is enabled, a dedicated security group is created allowing inbound HTTPS (port 443) from the VPC CIDR and any additional CIDRs specified in `endpoint_additional_ingress_cidrs`.

Interface endpoints are placed in the **private EKS subnets** with private DNS enabled.