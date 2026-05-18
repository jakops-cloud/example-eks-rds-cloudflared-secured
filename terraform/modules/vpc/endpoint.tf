locals {
  interface_endpoints = {
    ecr_api        = { name = "ecr.api",             enabled = var.enable_ecr_api_endpoint }
    ecr_dkr        = { name = "ecr.dkr",             enabled = var.enable_ecr_dkr_endpoint }
    ec2            = { name = "ec2",                  enabled = var.enable_ec2_endpoint }
    sts            = { name = "sts",                  enabled = var.enable_sts_endpoint }
    elb            = { name = "elasticloadbalancing", enabled = var.enable_elb_endpoint }
    logs           = { name = "logs",                 enabled = var.enable_logs_endpoint }
    monitoring     = { name = "monitoring",           enabled = var.enable_monitoring_endpoint }
    ssm            = { name = "ssm",                  enabled = var.enable_ssm_endpoint }
    ssmmessages    = { name = "ssmmessages",          enabled = var.enable_ssmmessages_endpoint }
    autoscaling    = { name = "autoscaling",          enabled = var.enable_autoscaling_endpoint }
    secretsmanager = { name = "secretsmanager",       enabled = var.enable_secretsmanager_endpoint }
  }

  enabled_interface_endpoints = {
    for k, v in local.interface_endpoints : k => v if v.enabled
  }
}

resource "aws_security_group" "vpc_endpoints" {
  count = length(local.enabled_interface_endpoints) > 0 ? 1 : 0

  name        = "${var.environment}-${var.project}-vpc-endpoints-sg"
  description = "Allow traffic to VPC endpoints within the VPC"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = concat([aws_vpc.main.cidr_block], var.endpoint_additional_ingress_cidrs)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.environment}-${var.project}-vpc-endpoints-sg"
    Type = "security-group"
  })
}

resource "aws_vpc_endpoint" "s3" {
  count = var.enable_s3_endpoint ? 1 : 0

  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = concat(
    aws_route_table.private[*].id,
    [aws_route_table.public.id]
  )

  tags = merge(local.common_tags, {
    Name = "${var.environment}-${var.project}-s3-endpoint"
    Type = "vpc-endpoint"
  })
}

resource "aws_vpc_endpoint" "dynamodb" {
  count = var.enable_dynamodb_endpoint ? 1 : 0

  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.dynamodb"
  vpc_endpoint_type = "Gateway"

  route_table_ids = concat(
    aws_route_table.private[*].id,
    [aws_route_table.public.id]
  )

  tags = merge(local.common_tags, {
    Name = "${var.environment}-${var.project}-dynamodb-endpoint"
    Type = "vpc-endpoint"
  })
}

resource "aws_vpc_endpoint" "interface" {
  for_each = local.enabled_interface_endpoints

  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.${each.value.name}"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids         = aws_subnet.private_eks[*].id
  security_group_ids = [aws_security_group.vpc_endpoints[0].id]

  tags = merge(local.common_tags, {
    Name = "${var.environment}-${var.project}-${each.key}-endpoint"
    Type = "vpc-endpoint"
  })
}
