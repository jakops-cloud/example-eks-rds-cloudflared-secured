data "aws_caller_identity" "current" {}

resource "aws_iam_role" "codebuild_role" {
  name = "${var.environment}-${var.project}-helm-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
        Condition = {
          StringEquals = {
            "aws:RequestedRegion" = var.region
          }
        }
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name = "${var.environment}-${var.project}-codebuild-policy"
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${var.environment}-${var.project}-helm-deploy",
          "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${var.environment}-${var.project}-helm-deploy:*"
        ]
      },
      {
        Sid    = "EKSDescribeCluster"
        Effect = "Allow"
        Action = ["eks:DescribeCluster"]
        Resource = "arn:aws:eks:${var.region}:${data.aws_caller_identity.current.account_id}:cluster/${var.eks_cluster_name}"
        Condition = {
          StringEquals = { "aws:RequestedRegion" = var.region }
        }
      },
      {
        Sid    = "EC2NetworkInterfaceMutate"
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface"
        ]
        Resource = [
          "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:network-interface/*",
          "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:subnet/*",
          "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:security-group/*"
        ]
        Condition = {
          StringEquals = { "aws:RequestedRegion" = var.region }
        }
      },
      {
        Sid    = "EC2NetworkInterfaceDescribe"
        Effect = "Allow"
        Action = [
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeDhcpOptions",
          "ec2:DescribeVpcs"
        ]
        Resource = "*"
        Condition = {
          StringEquals = { "aws:RequestedRegion" = var.region }
        }
      },
      {
        Sid    = "EC2NetworkInterfacePermission"
        Effect = "Allow"
        Action = ["ec2:CreateNetworkInterfacePermission"]
        Resource = "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:network-interface/*"
        Condition = {
          StringEquals = {
            "aws:RequestedRegion"    = var.region
            "ec2:AuthorizedService" = "codebuild.amazonaws.com"
          }
        }
      },
      {
        Sid    = "CodeConnections"
        Effect = "Allow"
        Action = [
          "codeconnections:UseConnection",
          "codeconnections:GetConnectionToken"
        ]
        Resource = var.codestar_connection_arn
        Condition = {
          StringEquals = { "aws:RequestedRegion" = var.region }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "additional_policies" {
  for_each   = toset(var.additional_codebuild_policies)
  role       = aws_iam_role.codebuild_role.name
  policy_arn = each.value
}
