resource "aws_cloudwatch_log_group" "eks_cluster" {
  name              = "/aws/eks/${var.environment}-${var.project}/cluster"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_arn

  tags = local.common_tags
}
