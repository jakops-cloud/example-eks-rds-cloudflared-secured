# Tunnel Module

This Terraform module provisions a Cloudflare Tunnel on an EC2 instance (RHEL 9) within a private subnet, enabling secure connectivity between your AWS VPC and Cloudflare's network.

## Architecture

The module creates the following components:

- **EC2 Instance** — RHEL 9 instance running `cloudflared` as a systemd service
- **IAM Role & Profile** — with permissions to read the tunnel token from Secrets Manager
- **Security Group** — allowing VPC-internal traffic (WARP routing) and outbound HTTPS/QUIC to Cloudflare
- **Userdata Script** — installs and configures `cloudflared` at boot, fetching the token from Secrets Manager

## Usage

```hcl
module "tunnel" {
  source = "./modules/tunnel"

  project     = "myapp"
  environment = "production"
  region      = "eu-west-1"

  common_tags = {
    ManagedBy = "Terraform"
  }

  vpc_id         = module.vpc.vpc_id
  vpc_cidr_block = module.vpc.vpc_cidr_block
  subnet_ids     = module.vpc.private_subnet_ids
  kms_key_arn    = aws_kms_key.main.arn

  instance_type         = "t4g.micro"
  instance_architecture = "arm64"

  warp_routing_enabled = true
  enable_ssm           = true

  target_security_group_ids = {
    eks_nodes = module.eks.node_security_group_id
  }
}
```

## Secrets Manager

The module expects a secret in AWS Secrets Manager with the following structure:

```json
{
  "tunnel_token": "<cloudflare-tunnel-token>"
}
```

By default, the secret name is `<environment>-<project>-cloudflared`. Override with `secret_name`.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `project` | Application name used as namespace prefix | `string` | — | ✅ |
| `environment` | Environment name used as namespace prefix | `string` | — | ✅ |
| `region` | AWS Region | `string` | — | ✅ |
| `common_tags` | Common tags applied to all resources | `map(string)` | — | ✅ |
| `vpc_id` | VPC ID | `string` | — | ✅ |
| `vpc_cidr_block` | VPC CIDR block for security group rules | `string` | — | ✅ |
| `subnet_ids` | List of private subnet IDs | `list(string)` | — | ✅ |
| `kms_key_arn` | KMS key ARN for EBS encryption and Secrets Manager | `string` | — | ✅ |
| `instance_type` | EC2 instance type | `string` | `"t4g.micro"` | ❌ |
| `instance_architecture` | EC2 architecture: `arm64` or `x86_64` | `string` | `"arm64"` | ❌ |
| `ami_id` | Custom AMI ID. If null, latest RHEL 9 is used | `string` | `null` | ❌ |
| `root_volume_size` | Root EBS volume size in GB | `number` | `8` | ❌ |
| `root_volume_type` | Root EBS volume type | `string` | `"gp3"` | ❌ |
| `secret_name` | Secrets Manager secret name containing `tunnel_token` | `string` | `"<env>-<project>-cloudflared"` | ❌ |
| `warp_routing_enabled` | Enable WARP routing in cloudflared config | `bool` | `true` | ❌ |
| `enable_ssm` | Attach SSM Managed Instance Core policy | `bool` | `true` | ❌ |
| `additional_security_group_ids` | Extra security groups to attach to the instance | `list(string)` | `[]` | ❌ |
| `target_security_group_ids` | Map of security groups the tunnel is allowed to reach on port 443 | `map(string)` | `{}` | ❌ |
| `additional_iam_policy_arns` | Extra IAM policy ARNs to attach to the tunnel role | `list(string)` | `[]` | ❌ |

## Outputs

| Name | Description |
|------|-------------|
| `tunnel_instance_id` | ID of the tunnel EC2 instance |
| `tunnel_instance_arn` | ARN of the tunnel EC2 instance |
| `tunnel_private_ip` | Private IP of the tunnel EC2 instance |
| `tunnel_security_group_id` | Security group ID for the tunnel instance |
| `tunnel_security_group_arn` | Security group ARN for the tunnel instance |
| `tunnel_iam_role_arn` | ARN of the tunnel IAM role |
| `tunnel_iam_role_name` | Name of the tunnel IAM role |

## Security Group Rules

| Direction | Protocol | Port(s) | Destination | Purpose |
|-----------|----------|---------|-------------|---------|
| Ingress | All | All | VPC CIDR | WARP routing inbound |
| Egress | All | All | VPC CIDR | WARP routing outbound |
| Egress | TCP | 443 | `0.0.0.0/0` | Cloudflare HTTPS |
| Egress | UDP | 53 | `0.0.0.0/0` | DNS resolution |
| Egress | UDP | 7844–7845 | `0.0.0.0/0` | Cloudflare QUIC |