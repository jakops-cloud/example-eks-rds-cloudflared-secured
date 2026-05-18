resource "aws_eks_access_entry" "codebuild" {
  cluster_name  = var.eks_cluster_name
  principal_arn = aws_iam_role.codebuild_role.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "codebuild_admin" {
  cluster_name  = var.eks_cluster_name
  principal_arn = aws_iam_role.codebuild_role.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}
