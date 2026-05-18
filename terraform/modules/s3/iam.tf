locals {
  iam_user_name = var.iam_user_name != null ? var.iam_user_name : "${var.environment}-${var.project}-s3-user"
}

resource "aws_iam_policy" "s3" {
  name   = "${var.environment}-${var.project}-s3-policy"
  policy = data.aws_iam_policy_document.s3_policy.json

  tags = merge(local.common_tags, {
    Name = "${var.environment}-${var.project}-s3-policy"
    Type = "iam-policy"
  })
}

resource "aws_iam_user" "s3_user" {
  count = var.enable_iam_user ? 1 : 0

  name = local.iam_user_name

  tags = merge(local.common_tags, {
    Name = local.iam_user_name
    Type = "iam-user"
  })
}

resource "aws_iam_user_policy_attachment" "s3_attach" {
  count = var.enable_iam_user ? 1 : 0

  user       = aws_iam_user.s3_user[0].name
  policy_arn = aws_iam_policy.s3.arn
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    effect    = "Allow"
    actions   = var.allowed_s3_actions
    resources = [
      aws_s3_bucket.s3.arn,
      "${aws_s3_bucket.s3.arn}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:GenerateDataKey",
      "kms:Decrypt"
    ]
    resources = [var.kms_key_arn]
  }
}
