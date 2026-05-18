variable "project" {
  description = "Application name used as a namespace prefix for all resources"
  type        = string
}

variable "environment" {
  description = "Environment name used as a namespace prefix for all resources"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
}

locals {
  common_tags = merge(var.common_tags, {
    Project     = var.project
    Environment = var.environment
  })
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the cluster will be created"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "private_route_table_ids" {
  description = "List of private route table IDs"
  type        = list(string)
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for encrypting EKS resources"
  type        = string
}

variable "authentication_mode" {
  description = "Authentication mode for EKS cluster (API, CONFIG_MAP, API_AND_CONFIG_MAP)"
  type        = string
  default     = "API_AND_CONFIG_MAP"
  validation {
    condition     = contains(["API", "CONFIG_MAP", "API_AND_CONFIG_MAP"], var.authentication_mode)
    error_message = "Must be one of: API, CONFIG_MAP, API_AND_CONFIG_MAP."
  }
}

variable "endpoint_private_access" {
  description = "Enable private API server endpoint"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Enable public API server endpoint"
  type        = bool
  default     = false
}

variable "public_access_cidrs" {
  description = "CIDR blocks allowed to access the public API endpoint"
  type        = list(string)
  default     = []
}

variable "enabled_cluster_log_types" {
  description = "List of control plane log types to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 7
}

variable "node_instance_types" {
  description = "List of instance types for the EKS node group"
  type        = list(string)
}

variable "node_capacity_type" {
  description = "Type of capacity associated with the EKS node group (ON_DEMAND, SPOT)"
  type        = string
  default     = "ON_DEMAND"
  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.node_capacity_type)
    error_message = "Must be ON_DEMAND or SPOT."
  }
}

variable "node_ami_type" {
  description = "AMI type for the EKS node group (AL2023_x86_64_STANDARD, AL2023_ARM_64_STANDARD, etc.)"
  type        = string
  default     = "AL2023_x86_64_STANDARD"
}

variable "node_disk_size" {
  description = "Disk size in GiB for worker nodes"
  type        = number
  default     = 100
}

variable "node_desired_size" {
  description = "Desired number of nodes in the EKS node group"
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum number of nodes in the EKS node group"
  type        = number
  default     = 4
}

variable "node_min_size" {
  description = "Minimum number of nodes in the EKS node group"
  type        = number
  default     = 1
}

variable "node_subnet_ids" {
  description = "Subnet IDs for the node group. Defaults to all private_subnet_ids if null."
  type        = list(string)
  default     = null
}

variable "node_max_unavailable_percentage" {
  description = "Max percentage of unavailable nodes during updates"
  type        = number
  default     = 50
}

variable "node_repair_enabled" {
  description = "Enable automatic node repair"
  type        = bool
  default     = true
}

variable "additional_node_iam_policy_arns" {
  description = "Additional IAM policy ARNs to attach to the node group role"
  type        = list(string)
  default     = []
}

variable "vpc_cni_version" {
  description = "Version of the VPC CNI add-on (null = latest)"
  type        = string
  default     = null
}

variable "coredns_version" {
  description = "Version of the CoreDNS add-on (null = latest)"
  type        = string
  default     = null
}

variable "kube_proxy_version" {
  description = "Version of the kube-proxy add-on (null = latest)"
  type        = string
  default     = null
}

variable "ebs_csi_version" {
  description = "Version of the EBS CSI driver add-on (null = latest)"
  type        = string
  default     = null
}

variable "efs_csi_version" {
  description = "Version of the EFS CSI driver add-on (null = latest)"
  type        = string
  default     = null
}

variable "eks_node_monitoring_agent_version" {
  description = "Version of the EKS Node Monitoring Agent add-on (null = latest)"
  type        = string
  default     = null
}

variable "enable_addon_ebs_csi" {
  description = "Enable EBS CSI driver add-on"
  type        = bool
  default     = true
}

variable "enable_addon_efs_csi" {
  description = "Enable EFS CSI driver add-on"
  type        = bool
  default     = true
}

variable "enable_addon_node_monitoring" {
  description = "Enable EKS Node Monitoring Agent add-on"
  type        = bool
  default     = true
}

variable "enable_efs" {
  description = "Create EFS file system and mount targets for EKS"
  type        = bool
  default     = true
}

variable "efs_transition_to_ia" {
  description = "EFS lifecycle policy: days before transitioning to IA storage"
  type        = string
  default     = "AFTER_30_DAYS"
}

variable "enable_karpenter" {
  description = "Enable Karpenter autoscaler resources (SQS, EventBridge rules, IAM)"
  type        = bool
  default     = true
}

variable "karpenter_namespace" {
  description = "Kubernetes namespace where Karpenter is deployed"
  type        = string
  default     = "karpenter"
}

variable "karpenter_service_account" {
  description = "Kubernetes service account name for Karpenter"
  type        = string
  default     = "karpenter"
}

variable "external_secrets_namespace" {
  description = "Kubernetes namespace where External Secrets Operator is deployed"
  type        = string
  default     = "external-secrets"
}

variable "external_secrets_service_account" {
  description = "Kubernetes service account name for External Secrets Operator"
  type        = string
  default     = "external-secrets"
}

variable "external_secrets_secret_prefix" {
  description = "Prefix for Secrets Manager secrets accessible by External Secrets. Defaults to '<environment>-<project>-'"
  type        = string
  default     = null
}

variable "enable_load_balancer_controller" {
  description = "Create IAM role for AWS Load Balancer Controller"
  type        = bool
  default     = true
}

variable "load_balancer_controller_namespace" {
  description = "Kubernetes namespace for AWS Load Balancer Controller"
  type        = string
  default     = "aws-load-balancer-controller"
}

variable "load_balancer_controller_service_account" {
  description = "Kubernetes service account name for AWS Load Balancer Controller"
  type        = string
  default     = "aws-load-balancer-controller-alb"
}
