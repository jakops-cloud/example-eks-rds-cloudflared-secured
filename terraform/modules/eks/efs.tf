resource "aws_efs_file_system" "eks_efs" {
  count          = var.enable_efs ? 1 : 0
  creation_token = "${var.environment}-${var.project}-efs"

  lifecycle_policy {
    transition_to_ia = var.efs_transition_to_ia
  }

  tags = merge(local.common_tags, {
    Name = "${var.environment}-${var.project}-efs"
  })
}

resource "aws_efs_mount_target" "eks_efs" {
  count          = var.enable_efs ? length(var.private_subnet_ids) : 0
  file_system_id = aws_efs_file_system.eks_efs[0].id
  subnet_id      = var.private_subnet_ids[count.index]
  security_groups = [aws_security_group.efs[0].id]
}
