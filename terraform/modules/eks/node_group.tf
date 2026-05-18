resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.environment}-${var.project}-node-group"
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids      = local.node_subnet_ids
  instance_types  = var.node_instance_types
  ami_type        = var.node_ami_type
  capacity_type   = var.node_capacity_type
  disk_size       = var.node_disk_size

  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }

  update_config {
    max_unavailable_percentage = var.node_max_unavailable_percentage
  }

  node_repair_config {
    enabled = var.node_repair_enabled
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_container_registry_policy,
  ]

  tags = merge(local.common_tags, {
    Name                     = "${var.environment}-${var.project}-eks-node"
    "karpenter.sh/discovery" = "${var.environment}-${var.project}-eks"
  })
}
