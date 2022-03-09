# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm
resource "aws_cloudwatch_metric_alarm" "aws_lambda_monitoring_alarm" {
  # "dimensions" で指定した AWS Lambda が以下の条件に合致した場合、CloudWatch Alarmを飛ばす
  # 60秒に1回以上、"ERROR"判定となる
  alarm_name                = "${var.base}_alarm"
  actions_enabled           = true
  alarm_actions             = [
    aws_sns_topic.aws_lambda_monitoring_topic.arn
  ]
  dimensions                = var.alarms_associated_metric
  metric_name               = "Errors"
  namespace                 = "AWS/Lambda"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = 1
  threshold                 = 1

  # Only a period greater than 60s is supported for metrics in the "AWS/" namespaces
  period                    = 60
  statistic                 = "Sum"
  treat_missing_data        = "missing"
  evaluation_periods        = 1
  insufficient_data_actions = []
  ok_actions                = []

  tags                      = {}
  tags_all                  = {}


  depends_on = [
    aws_sns_topic.aws_lambda_monitoring_topic
  ]
}


resource "aws_sns_topic" "aws_lambda_monitoring_topic" {
  application_success_feedback_sample_rate = 0
  content_based_deduplication              = false
  display_name                             = "${var.base}_topic"
  fifo_topic                               = false
  firehose_success_feedback_sample_rate    = 0
  http_success_feedback_sample_rate        = 0
  lambda_success_feedback_sample_rate      = 0
  name                                     = "${var.base}_topic"
  /*
  policy                                   = jsonencode(
  {
    Id        = "__default_policy_ID"
    Statement = [
      {
        Action    = [
          "SNS:GetTopicAttributes",
          "SNS:SetTopicAttributes",
          "SNS:AddPermission",
          "SNS:RemovePermission",
          "SNS:DeleteTopic",
          "SNS:Subscribe",
          "SNS:ListSubscriptionsByTopic",
          "SNS:Publish",
        ]
        condition = {
          test = "StringEquals"
          variable = "AWS:SourceOwner"

          values = [
            var.aws_account_id
          ]
        }
        Effect    = "Allow"
        Principal = {
          AWS = "*"
        }
        Resource  = "arn:aws:sns:${var.region}:${var.aws_account_id}:${var.prefix}_topic"
        Sid       = "__default_statement_ID"
      },
    ]
    Version   = "2008-10-17"
  }
  )
  */
  sqs_success_feedback_sample_rate         = 0
  tags                                     = {}
  tags_all                                 = {}
}

resource "aws_sns_topic_policy" "aws_lambda_monitoring_topic_policy" {
  arn = aws_sns_topic.aws_lambda_monitoring_topic.arn
  policy = data.aws_iam_policy_document.aws_lambda_monitoring_topic_policy_document.json
}
data "aws_iam_policy_document" "aws_lambda_monitoring_topic_policy_document" {
  policy_id = "__default_policy_ID"
  statement {
        actions    = [
          "SNS:GetTopicAttributes",
          "SNS:SetTopicAttributes",
          "SNS:AddPermission",
          "SNS:RemovePermission",
          "SNS:DeleteTopic",
          "SNS:Subscribe",
          "SNS:ListSubscriptionsByTopic",
          "SNS:Publish",
        ]
        condition {
          test = "StringEquals"
          variable = "AWS:SourceOwner"

          values = [
            var.aws_account_id
          ]
        }
        effect    = "Allow"
        principals {
          type        = "AWS"
          identifiers = ["*"]
        }
        resources  = [
          aws_sns_topic.aws_lambda_monitoring_topic.arn
        ]
        sid     = "__default_statement_ID"
      }
}

output "aws_lambda_monitoring_topic_arn" {
  value = aws_sns_topic.aws_lambda_monitoring_topic.arn
}