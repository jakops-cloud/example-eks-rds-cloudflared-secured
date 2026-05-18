resource "aws_sqs_queue" "karpenter" {
  count                     = var.enable_karpenter ? 1 : 0
  name                      = "${var.environment}-${var.project}-karpenter"
  message_retention_seconds = 300
  sqs_managed_sse_enabled   = true

  tags = local.common_tags
}

resource "aws_sqs_queue_policy" "karpenter" {
  count     = var.enable_karpenter ? 1 : 0
  queue_url = aws_sqs_queue.karpenter[0].url

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = ["events.amazonaws.com", "sqs.amazonaws.com"]
      }
      Action   = "sqs:SendMessage"
      Resource = aws_sqs_queue.karpenter[0].arn
    }]
  })
}

locals {
  karpenter_event_rules = var.enable_karpenter ? {
    scheduled_change = {
      name        = "${var.environment}-${var.project}-karpenter-scheduled-change"
      description = "Karpenter scheduled change events"
      source      = "aws.health"
      detail_type = "AWS Health Event"
    }
    spot_interruption = {
      name        = "${var.environment}-${var.project}-karpenter-spot-interruption"
      description = "Karpenter spot interruption warnings"
      source      = "aws.ec2"
      detail_type = "EC2 Spot Instance Interruption Warning"
    }
    rebalance = {
      name        = "${var.environment}-${var.project}-karpenter-rebalance"
      description = "Karpenter rebalance recommendations"
      source      = "aws.ec2"
      detail_type = "EC2 Instance Rebalance Recommendation"
    }
    instance_state_change = {
      name        = "${var.environment}-${var.project}-karpenter-instance-state"
      description = "Karpenter instance state changes"
      source      = "aws.ec2"
      detail_type = "EC2 Instance State-change Notification"
    }
  } : {}
}

resource "aws_cloudwatch_event_rule" "karpenter" {
  for_each    = local.karpenter_event_rules
  name        = each.value.name
  description = each.value.description

  event_pattern = jsonencode({
    source      = [each.value.source]
    detail-type = [each.value.detail_type]
  })

  tags = local.common_tags
}

resource "aws_cloudwatch_event_target" "karpenter" {
  for_each  = local.karpenter_event_rules
  rule      = aws_cloudwatch_event_rule.karpenter[each.key].name
  target_id = "KarpenterQueue"
  arn       = aws_sqs_queue.karpenter[0].arn
}
