resource "aws_security_group" "efs" {
  count       = var.enable_efs ? 1 : 0
  name        = "${var.environment}-${var.project}-efs-sg"
  description = "Allow NFS from EKS nodes"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow outbound HTTPS"
  }

  egress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow outbound DNS"
  }

  tags = merge(local.common_tags, {
    Name = "${var.environment}-${var.project}-efs-sg"
  })
}

resource "aws_security_group_rule" "efs_ingress_from_eks_nodes" {
  count                    = var.enable_efs ? 1 : 0
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id        = aws_security_group.efs[0].id
  source_security_group_id = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
  description              = "Allow NFS from EKS nodes"
}

resource "aws_security_group" "eks_cluster" {
  name_prefix = "${var.environment}-${var.project}-cluster-"
  description = "EKS cluster security group"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow outbound HTTPS"
  }

  egress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow outbound DNS"
  }

  tags = merge(local.common_tags, {
    Name                     = "${var.environment}-${var.project}-cluster-sg"
    "karpenter.sh/discovery" = "${var.environment}-${var.project}-eks"
  })

  lifecycle {
    create_before_destroy = true
  }
}
