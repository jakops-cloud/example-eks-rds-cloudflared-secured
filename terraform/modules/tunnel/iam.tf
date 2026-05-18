resource "aws_iam_role" "tunnel_role" {
  name = "${var.environment}-${var.project}-tunnel-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "${var.environment}-${var.project}-tunnel-role"
    Type = "iam-role"
  })
}

resource "aws_iam_role_policy" "tunnel_secrets_policy" {
  name = "${var.environment}-${var.project}-tunnel-secrets-policy"
  role = aws_iam_role.tunnel_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = "arn:aws:secretsmanager:${var.region}:*:secret:${local.secret_name}*"
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = var.kms_key_arn
      }
    ]
  })
}

resource "aws_iam_instance_profile" "tunnel_profile" {
  name = "${var.environment}-${var.project}-tunnel-profile"
  role = aws_iam_role.tunnel_role.name

  tags = merge(local.common_tags, {
    Name = "${var.environment}-${var.project}-tunnel-profile"
    Type = "iam-instance-profile"
  })
}

resource "aws_iam_role_policy_attachment" "tunnel_ssm_policy" {
  count = var.enable_ssm ? 1 : 0

  role       = aws_iam_role.tunnel_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "tunnel_additional_policies" {
  count = length(var.additional_iam_policy_arns)

  role       = aws_iam_role.tunnel_role.name
  policy_arn = var.additional_iam_policy_arns[count.index]
}
