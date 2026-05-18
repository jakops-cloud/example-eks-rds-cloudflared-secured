resource "aws_security_group" "codebuild" {
  name_prefix = "${var.environment}-${var.project}-codebuild-sg"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  ingress {
    description = "Ephemeral ports for return traffic"
    from_port   = 1024
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  egress {
    description = "HTTPS to internet (package downloads)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "DNS resolution"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.environment}-${var.project}-codebuild-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "codebuild_to_eks_cluster" {
  description              = "Allow CodeBuild to communicate with EKS cluster API Server"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = var.eks_cluster_security_group_id
  source_security_group_id = aws_security_group.codebuild.id
}
