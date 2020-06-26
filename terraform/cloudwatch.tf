locals {
  metric_namespace = "LogMetrics"
  metrics = [
    {
      filter_name               = "ErrorLogCount"
      filter_pattern            = "ERROR"
      metric_name               = "${var.site_id}-fargate-redash-error"
      alarm_comparison_operator = "GreaterThanOrEqualToThreshold"
      alarm_evaluation_periods  = "1"
      alarm_threshold           = "1"
      alarm_description         = "Error occurred greater than or equal to 1 time within a minute"
    },
    {
      filter_name               = "WarnLogCount"
      filter_pattern            = "WARN"
      metric_name               = "${var.site_id}-fargate-redash-warn"
      alarm_comparison_operator = "GreaterThanOrEqualToThreshold"
      alarm_evaluation_periods  = "1"
      alarm_threshold           = "5"
      alarm_description         = "Warn occurred greater than or equal to 5 time within a minute"
    },
  ]
}

resource "aws_cloudwatch_log_group" "fargate_redash" {
  name              = "/ecs/${var.site_id}-fargate/redash"
  retention_in_days = 30

  tags = {
    Owner = var.owner
  }
}

resource "aws_cloudwatch_log_metric_filter" "fargate_redash" {
  count = length(local.metrics)

  name           = local.metrics.*.filter_name[count.index]
  pattern        = local.metrics.*.filter_pattern[count.index]
  log_group_name = aws_cloudwatch_log_group.fargate_redash.name

  metric_transformation {
    name          = local.metrics.*.metric_name[count.index]
    namespace     = local.metric_namespace
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_metric_alarm" "fargate_redash" {
  count = length(local.metrics)

  alarm_name          = local.metrics.*.metric_name[count.index]
  comparison_operator = local.metrics.*.alarm_comparison_operator[count.index]
  evaluation_periods  = local.metrics.*.alarm_evaluation_periods[count.index]
  metric_name         = local.metrics.*.metric_name[count.index]
  namespace           = local.metric_namespace
  period              = "60" # 1 min
  statistic           = "Sum"
  threshold           = local.metrics.*.alarm_threshold[count.index]
  alarm_description   = local.metrics.*.alarm_description[count.index]
  alarm_actions       = [aws_sns_topic.fargate_redash.arn]
  tags = {
    Owner = var.owner
  }
}

resource "aws_sns_topic" "fargate_redash" {
  name = "${var.site_id}-fargate-redash"
}

# email is unsupported by Terraform
# https://www.terraform.io/docs/providers/aws/r/sns_topic_subscription.html#email
# resource "aws_sns_topic_subscription" "fargate_redash" {}
