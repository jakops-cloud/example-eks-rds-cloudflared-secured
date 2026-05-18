```markdown
# EKS Module

This Terraform module provisions a production-ready AWS EKS cluster with managed node groups, IRSA (IAM Roles for Service Accounts), optional Karpenter autoscaler, EFS, and AWS Load Balancer Controller support.

## Architecture

The module creates the following components:

- **EKS Cluster** — with KMS encryption, configurable API endpoint access, and CloudWatch control plane logging
- **Managed Node Group** — with configurable instance types, capacity type, and auto-repair
- **OIDC Provider** — enabling IRSA for Kubernetes service accounts
- **IAM Roles** — for cluster, node group, EBS CSI, EFS CSI, External Secrets, Load Balancer Controller, and optionally Karpenter
- **EKS Add-ons** — VPC CNI, CoreDNS, kube-proxy, EBS CSI driver, EFS CSI driver, Node Monitoring Agent
- **EFS File System** — with mount targets in all private subnets (optional)
- **Karpenter** — SQS queue and EventBridge rules for spot interruption, rebalance, and health events (optional)
- **Security Groups** — for EKS cluster and EFS

## Usage

```hcl
module "eks" {
  source = "./modules/eks"

  project     = "myapp"
  environment = "production"
  region      = "eu-west-1"

  common_tags = {
    ManagedBy = "Terraform"
  }

  vpc_id                  = module.vpc.vpc_id
  private_subnet_ids      = module.vpc.private_subnet_ids
  private_route_table_ids = module.vpc.private_route_table_ids
  kms_key_arn             = aws_kms_key.main.arn

  cluster_version = "1.32"

  endpoint_private_access = true
  endpoint_public_access  = false

  node_instance_types = ["m7g.large"]
  node_ami_type       = "AL2023_ARM_64_STANDARD"
  node_desired_size   = 2
  node_min_size       = 1
  node_max_size       = 4

  enable_efs                    = true
  enable_karpenter              = true
  enable_load_balancer_controller = true

  enable_addon_ebs_csi         = true
  enable_addon_efs_csi         = true
  enable_addon_node_monitoring = true
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `project` | Application name used as namespace prefix | `string` | — | ✅ |
| `environment` | Environment name used as namespace prefix | `string` | — | ✅ |
| `region` | AWS Region | `string` | — | ✅ |
| `common_tags` | Common tags applied to all resources | `map(string)` | — | ✅ |
| `vpc_id` | VPC ID where the cluster will be created | `string` | — | ✅ |
| `private_subnet_ids` | Private subnet IDs for the EKS cluster | `list(string)` | — | ✅ |
| `private_route_table_ids` | Private route table IDs | `list(string)` | — | ✅ |
| `kms_key_arn` | KMS key ARN for encrypting EKS secrets | `string` | — | ✅ |
| `cluster_version` | Kubernetes version for the EKS cluster | `string` | — | ✅ |
| `authentication_mode` | EKS authentication mode (`API`, `CONFIG_MAP`, `API_AND_CONFIG_MAP`) | `string` | `"API_AND_CONFIG_MAP"` | ❌ |
| `endpoint_private_access` | Enable private API server endpoint | `bool` | `true` | ❌ |
| `endpoint_public_access` | Enable public API server endpoint | `bool` | `false` | ❌ |
| `public_access_cidrs` | CIDR blocks allowed to access the public API endpoint | `list(string)` | `[]` | ❌ |
| `enabled_cluster_log_types` | Control plane log types to enable | `list(string)` | `["api", "audit", "authenticator", "controllerManager", "scheduler"]` | ❌ |
| `log_retention_days` | CloudWatch log retention in days | `number` | `7` | ❌ |
| `node_instance_types` | Instance types for the EKS node group | `list(string)` | — | ✅ |
| `node_capacity_type` | Node capacity type (`ON_DEMAND` or `SPOT`) | `string` | `"ON_DEMAND"` | ❌ |
| `node_ami_type` | AMI type for EKS nodes (e.g. `AL2023_x86_64_STANDARD`, `AL2023_ARM_64_STANDARD`) | `string` | `"AL2023_x86_64_STANDARD"` | ❌ |
| `node_disk_size` | Node root disk size in GiB | `number` | `100` | ❌ |
| `node_desired_size` | Desired number of nodes | `number` | `2` | ❌ |
| `node_max_size` | Maximum number of nodes | `number` | `4` | ❌ |
| `node_min_size` | Minimum number of nodes | `number` | `1` | ❌ |
| `node_subnet_ids` | Subnet IDs for the node group. Defaults to `private_subnet_ids` if null | `list(string)` | `null` | ❌ |
| `node_max_unavailable_percentage` | Max percentage of unavailable nodes during updates | `number` | `50` | ❌ |
| `node_repair_enabled` | Enable automatic node repair | `bool` | `true` | ❌ |
| `additional_node_iam_policy_arns` | Additional IAM policy ARNs to attach to the node group role | `list(string)` | `[]` | ❌ |
| `vpc_cni_version` | VPC CNI add-on version (`null` = latest) | `string` | `null` | ❌ |
| `coredns_version` | CoreDNS add-on version (`null` = latest) | `string` | `null` | ❌ |
| `kube_proxy_version` | kube-proxy add-on version (`null` = latest) | `string` | `null` | ❌ |
| `ebs_csi_version` | EBS CSI driver add-on version (`null` = latest) | `string` | `null` | ❌ |
| `efs_csi_version` | EFS CSI driver add-on version (`null` = latest) | `string` | `null` | ❌ |
| `eks_node_monitoring_agent_version` | EKS Node Monitoring Agent add-on version (`null` = latest) | `string` | `null` | ❌ |
| `enable_addon_ebs_csi` | Enable EBS CSI driver add-on | `bool` | `true` | ❌ |
| `enable_addon_efs_csi` | Enable EFS CSI driver add-on | `bool` | `true` | ❌ |
| `enable_addon_node_monitoring` | Enable EKS Node Monitoring Agent add-on | `bool` | `true` | ❌ |
| `enable_efs` | Create EFS file system and mount targets | `bool` | `true` | ❌ |
| `efs_transition_to_ia` | EFS lifecycle: days before transitioning to IA storage | `string` | `"AFTER_30_DAYS"` | ❌ |
| `enable_karpenter` | Enable Karpenter resources (SQS, EventBridge, IAM) | `bool` | `true` | ❌ |
| `karpenter_namespace` | Kubernetes namespace for Karpenter | `string` | `"karpenter"` | ❌ |
| `karpenter_service_account` | Kubernetes service account name for Karpenter | `string` | `"karpenter"` | ❌ |
| `external_secrets_namespace` | Kubernetes namespace for External Secrets Operator | `string` | `"external-secrets"` | ❌ |
| `external_secrets_service_account` | Kubernetes service account name for External Secrets Operator | `string` | `"external-secrets"` | ❌ |
| `external_secrets_secret_prefix` | Secrets Manager prefix for External Secrets. Defaults to `<environment>-<project>-` | `string` | `null` | ❌ |
| `enable_load_balancer_controller` | Create IAM role for AWS Load Balancer Controller | `bool` | `true` | ❌ |
| `load_balancer_controller_namespace` | Kubernetes namespace for AWS Load Balancer Controller | `string` | `"aws-load-balancer-controller"` | ❌ |
| `load_balancer_controller_service_account` | Kubernetes service account name for AWS Load Balancer Controller | `string` | `"aws-load-balancer-controller-alb"` | ❌ |

## Outputs

| Name | Description |
|------|-------------|
| `cluster_id` | Name/ID of the EKS cluster |
| `cluster_arn` | ARN of the EKS cluster |
| `cluster_endpoint` | Endpoint for the EKS control plane |
| `cluster_security_group_id` | Security group ID attached to the EKS cluster |
| `cluster_service_ip_cidr` | Kubernetes service IPv4 CIDR block |
| `cluster_iam_role_arn` | IAM role ARN of the EKS cluster |
| `external_secrets_role_arn` | IAM role ARN for External Secrets Operator |
| `node_groups` | EKS node group resource |
| `oidc_provider_arn` | ARN of the OIDC provider |
| `oidc_provider_url` | URL of the OIDC provider (without `https://` prefix) |
| `aws_load_balancer_controller_role_arn` | IAM role ARN for AWS Load Balancer Controller (`null` if disabled) |
| `karpenter_controller_role_arn` | IAM role ARN for Karpenter controller (`null` if disabled) |
| `karpenter_queue_name` | Name of the Karpenter SQS queue (`null` if disabled) |
| `efs_file_system_id` | EFS file system ID (`null` if disabled) |

## IAM Roles

| Role | Purpose |
|------|---------|
| `eks-role` | EKS cluster service role |
| `eks-node-group-role` | EKS managed node group role (includes SSM, ECR, CNI policies) |
| `ebs-csi-driver-role` | IRSA role for EBS CSI driver |
| `efs-csi-driver-role` | IRSA role for EFS CSI driver |
| `external-secrets-role` | IRSA role for External Secrets Operator |
| `aws-load-balancer-controller` | IRSA role for AWS Load Balancer Controller (optional) |
| `karpenter-controller` | IRSA role for Karpenter (optional) |

## Karpenter

When `enable_karpenter = true`, the module provisions:

- **SQS Queue** — for node lifecycle events (5-minute retention)
- **EventBridge Rules** — forwarding the following events to the SQS queue:

| Event | Source | Purpose |
|-------|--------|---------|
| AWS Health Event | `aws.health` | Scheduled maintenance |
| EC2 Spot Instance Interruption Warning | `aws.ec2` | Spot termination handling |
| EC2 Instance Rebalance Recommendation | `aws.ec2` | Proactive rebalancing |
| EC2 Instance State-change Notification | `aws.ec2` | Instance lifecycle tracking |

## External Secrets

The External Secrets IAM role grants access to Secrets Manager secrets matching the prefix `<environment>-<project>-` (configurable via `external_secrets_secret_prefix`) and KMS decrypt permissions.

## Security Groups

| Resource | Rules |
|----------|-------|
| EKS Cluster SG | Egress: TCP 443, UDP 53 to `0.0.0.0/0` |
| EFS SG | Ingress: TCP 2049 from EKS cluster SG; Egress: TCP 443, UDP 53 to `0.0.0.0/0` |
```