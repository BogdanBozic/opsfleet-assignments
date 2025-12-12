data "aws_iam_policy_document" "karpenter_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_provider.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:karpenter:karpenter"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_provider.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    principals {
      identifiers = [var.oidc_provider.arn]
      type        = "Federated"
    }
  }
}


data "aws_iam_policy_document" "karpenter_inline_policy" {

  statement {
    resources = ["*"]
    actions = [
      "ec2:DescribeImages",
      "ec2:RunInstances",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeLaunchTemplates",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeInstanceTypeOfferings",
      "ec2:DescribeAvailabilityZones",
      "ec2:DeleteLaunchTemplate",
      "ec2:CreateTags",
      "ec2:CreateLaunchTemplate",
      "ec2:CreateFleet",
      "ec2:DescribeSpotPriceHistory",
      "pricing:GetProducts",
      "ssm:GetParameter",
      "iam:CreateServiceLinkedRole"
    ]
    effect = "Allow"
  }

  statement {
    resources = ["*"]
    actions = [
      "iam:ListInstanceProfiles",
      "iam:GetInstanceProfile",
      "iam:GetRole",
      "iam:ListRoles"
    ]
    effect = "Allow"
  }

  statement {
    resources = ["*"]
    actions   = ["ec2:TerminateInstances", "ec2:DeleteLaunchTemplate"]
    effect    = "Allow"
    condition {
      test     = "StringEquals"
      values   = [var.cluster.name]
      variable = "ec2:ResourceTag/karpenter.sh/discovery"
    }
  }

  statement {
    resources = [var.cluster.arn]
    actions   = ["eks:DescribeCluster"]
    effect    = "Allow"
  }

  statement {
    resources = [var.node_pod_execution_role.arn]
    actions   = ["iam:PassRole"]
    effect    = "Allow"
  }

  statement {
    resources = [aws_sqs_queue.karpenter_interruption_handler_sqs.arn]
    actions   = ["sqs:DeleteMessage", "sqs:GetQueueUrl", "sqs:GetQueueAttributes", "sqs:ReceiveMessage"]
    effect    = "Allow"
  }
}

resource "aws_iam_role" "karpenter_role" {
  description        = "IAM Role for Karpenter Controller Service Account"
  assume_role_policy = data.aws_iam_policy_document.karpenter_role_policy.json
  name               = "eks-${var.cluster.name}-karpenter-controller"
  tags               = var.tags
}

resource "aws_iam_policy" "karpenter_policy" {
  name   = "karpenter-${var.cluster.name}-policy"
  policy = data.aws_iam_policy_document.karpenter_inline_policy.json
}

resource "aws_iam_role_policy_attachment" "karpenter_policy_attachment" {
  role       = aws_iam_role.karpenter_role.name
  policy_arn = aws_iam_policy.karpenter_policy.arn
}

data "aws_iam_policy_document" "interruption_handler_sqs" {
  statement {
    actions   = ["sqs:SendMessage"]
    effect    = "Allow"
    resources = [aws_sqs_queue.karpenter_interruption_handler_sqs.arn]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values = [
        aws_cloudwatch_event_rule.scheduled_change.arn,
        aws_cloudwatch_event_rule.spot_interruption.arn,
        aws_cloudwatch_event_rule.rebalance_recommendation.arn,
        aws_cloudwatch_event_rule.instance_state_change.arn
      ]
    }
  }
}

resource "aws_sqs_queue_policy" "karpenter" {
  policy    = data.aws_iam_policy_document.interruption_handler_sqs.json
  queue_url = aws_sqs_queue.karpenter_interruption_handler_sqs.url
}
