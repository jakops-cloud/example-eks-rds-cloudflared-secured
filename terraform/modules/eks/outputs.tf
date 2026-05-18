output "cluster_id" {
  description = "The name/id of the EKS cluster"
  value       = aws_eks_cluster.main.id
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = aws_eks_cluster.main.arn
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

output "cluster_service_ip_cidr" {
  description = "The Kubernetes service IPv4 CIDR block for the EKS cluster"
  value       = aws_eks_cluster.main.kubernetes_network_config[0].service_ipv4_cidr
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster"
  value       = aws_iam_role.eks_cluster_role.arn
}

output "external_secrets_role_arn" {
  description = "ARN of the IAM role for External Secrets Operator"
  value       = aws_iam_role.external_secrets_role.arn
}

output "node_groups" {
  description = "EKS node groups"
  value       = aws_eks_node_group.main
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider for EKS"
  value       = aws_iam_openid_connect_provider.eks_oidc.arn
}

output "oidc_provider_url" {
  description = "The URL of the OIDC Provider for EKS (without https:// prefix)"
  value       = replace(aws_iam_openid_connect_provider.eks_oidc.url, "https://", "")
}

output "aws_load_balancer_controller_role_arn" {
  description = "ARN of the IAM role for AWS Load Balancer Controller (null if disabled)"
  value       = var.enable_load_balancer_controller ? aws_iam_role.aws_load_balancer_controller[0].arn : null
}

output "karpenter_controller_role_arn" {
  description = "ARN of the Karpenter controller IAM role (null if disabled)"
  value       = var.enable_karpenter ? aws_iam_role.karpenter_controller[0].arn : null
}

output "karpenter_queue_name" {
  description = "Name of the Karpenter SQS queue (null if disabled)"
  value       = var.enable_karpenter ? aws_sqs_queue.karpenter[0].name : null
}

output "efs_file_system_id" {
  description = "EFS file system ID (null if disabled)"
  value       = var.enable_efs ? aws_efs_file_system.eks_efs[0].id : null
}


