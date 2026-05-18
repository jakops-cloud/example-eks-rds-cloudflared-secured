resource "aws_security_group" "db_sg" {
  name        = "${var.environment}-${var.project}-db-sg"
  description = "Allow database access"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = length(var.allow_from_security_group_ids) > 0 ? [1] : []
    content {
      description     = "Allow DB from allowed security groups"
      from_port       = local.db_port
      to_port         = local.db_port
      protocol        = "tcp"
      security_groups = var.allow_from_security_group_ids
    }
  }

  dynamic "ingress" {
    for_each = length(var.allow_from_cidrs) > 0 ? [1] : []
    content {
      description = "Allow DB from allowed CIDRs"
      from_port   = local.db_port
      to_port     = local.db_port
      protocol    = "tcp"
      cidr_blocks = var.allow_from_cidrs
    }
  }

  dynamic "egress" {
    for_each = length(var.allow_from_security_group_ids) > 0 ? [1] : []
    content {
      description     = "Allow DB egress to allowed security groups"
      from_port       = local.db_port
      to_port         = local.db_port
      protocol        = "tcp"
      security_groups = var.allow_from_security_group_ids
    }
  }

  dynamic "egress" {
    for_each = length(var.allow_from_cidrs) > 0 ? [1] : []
    content {
      description = "Allow DB egress to allowed CIDRs"
      from_port   = local.db_port
      to_port     = local.db_port
      protocol    = "tcp"
      cidr_blocks = var.allow_from_cidrs
    }
  }

  tags = merge(local.common_tags, {
    Name = "${var.environment}-${var.project}-db-sg"
    Type = "security-group"
  })
}
