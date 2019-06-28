resource "aws_cloudwatch_log_group" "fargate_redash" {
  name              = "/ecs/${var.site_id}-fargate/redash"
  retention_in_days = 30

  tags = {
    Owner = "${var.owner}"
  }
}
