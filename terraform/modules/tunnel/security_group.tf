resource "aws_security_group" "tunnel_sg" {
  name_prefix = "${var.environment}-${var.project}-tunnel-"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr_block]
    description = "Allow all traffic from VPC for WARP routing"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr_block]
    description = "Allow all traffic to VPC for WARP routing"
  }

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

  egress {
    from_port   = 7844
    to_port     = 7845
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow outbound QUIC for Cloudflare Tunnel"
  }

  tags = merge(local.common_tags, {
    Name = "${var.environment}-${var.project}-tunnel-sg"
    Type = "security-group"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "tunnel_to_target" {
  for_each = var.target_security_group_ids

  description              = "Allow tunnel to communicate with ${each.key} on port 443"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = each.value
  source_security_group_id = aws_security_group.tunnel_sg.id
}
